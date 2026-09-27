-- Task: 60 Maintenance and Purge
-- Target schema: TASKHUB_API
-- Purpose: Add atomic retention-aware and FK-safe physical purge logic.
-- Preconditions: db/changes/0260_grant_maintenance_delete.sql has been applied; execute as TASKHUB_API.
-- Verification: db/tests/structure/0400_task60_maintenance_contract.sql
--               db/tests/maintenance/0010_task60_purge.sql
-- Notes: Uses the specification's deleted_at < systimestamp - interval '30' day rule.

create or replace package taskhub_api.pkg_taskhub_maint
authid definer
as
    /*
     * Purpose
     *   Physically removes soft-deleted TaskHub data only after the canonical
     *   30-day retention period.
     *
     * Trust boundary and rationale
     *   This definer-rights package is internal to TASKHUB_API and is not granted
     *   to TASKHUB_APP. Direct owner-table DELETE remains unavailable to the
     *   runtime principal. The monthly Scheduler job is the normal caller.
     *
     * Transaction model
     *   PURGE_DELETED owns one atomic maintenance transaction. It commits only
     *   after all FK-safe delete stages succeed and rolls back the purge on error.
     *
     * Error model
     *   Unexpected Oracle errors propagate after rollback. Rows that cannot yet
     *   be removed without violating retention or an FK are retained for a later
     *   run rather than treated as errors.
     *
     * Testability
     *   Deterministic fixtures use timestamps well inside or outside the 30-day
     *   boundary and verify retention, FK integrity and repeatable final state.
     */

    /*
     * Deletes retained association rows first, then repeatedly deletes eligible
     * Task leaves so TASKS_FK2 never observes a parent removal before its child.
     * Eligible empty Lists and unreferenced Tags are removed last.
     */
    procedure purge_deleted;
end pkg_taskhub_maint;
/

create or replace package body taskhub_api.pkg_taskhub_maint
as
    procedure purge_deleted
    is
        l_retention_cutoff constant timestamp(6) :=
            systimestamp - interval '30' day;
    begin
        -- Associations have no independent soft-delete timestamp. Remove them
        -- before either retained parent can be physically deleted.
        delete from taskhub_owner.todo_list_tags a
         where exists (
                   select 1
                     from taskhub_owner.todo_lists l
                    where l.id = a.todo_list_id
                      and l.deleted_at < l_retention_cutoff
               )
            or exists (
                   select 1
                     from taskhub_owner.tags g
                    where g.id = a.tag_id
                      and g.deleted_at < l_retention_cutoff
               );

        -- TASKS_FK2 is NO ACTION. Each pass removes only current leaves, so an
        -- eligible descendant is gone before its eligible parent is considered.
        -- A newer or active child deliberately keeps its parent for a later run.
        loop
            delete from taskhub_owner.tasks t
             where t.deleted_at < l_retention_cutoff
               and not exists (
                       select 1
                         from taskhub_owner.tasks c
                        where c.parent_task_id = t.id
                   );

            exit when sql%rowcount = 0;
        end loop;

        delete from taskhub_owner.todo_lists l
         where l.deleted_at < l_retention_cutoff
           and not exists (
                   select 1
                     from taskhub_owner.tasks t
                    where t.todo_list_id = l.id
               )
           and not exists (
                   select 1
                     from taskhub_owner.todo_list_tags a
                    where a.todo_list_id = l.id
               );

        delete from taskhub_owner.tags g
         where g.deleted_at < l_retention_cutoff
           and not exists (
                   select 1
                     from taskhub_owner.todo_list_tags a
                    where a.tag_id = g.id
               );

        commit;
    exception
        when others then
            rollback;
            raise;
    end purge_deleted;
end pkg_taskhub_maint;
/
