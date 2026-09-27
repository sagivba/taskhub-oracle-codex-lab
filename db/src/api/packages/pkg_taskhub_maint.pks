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
