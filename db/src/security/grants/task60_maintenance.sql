-- Task 60 adds only the parent-table DELETE privileges required by the
-- definer-rights maintenance package. TODO_LIST_TAGS DELETE already exists.
grant delete on taskhub_owner.todo_lists to taskhub_api;
grant delete on taskhub_owner.tags to taskhub_api;
grant delete on taskhub_owner.tasks to taskhub_api;

-- Deliberately absent: owner-table privileges or PKG_TASKHUB_MAINT EXECUTE for
-- TASKHUB_APP. Physical purge remains an internal scheduled maintenance path.
