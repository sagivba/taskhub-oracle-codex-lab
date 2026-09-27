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
