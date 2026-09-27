-- Task 40 adds only the DML needed by the definer-rights List/Tag operations.
-- Existing SELECT WITH GRANT OPTION remains limited to the Task 30 view sources.
grant update on taskhub_owner.todo_lists to taskhub_api;
grant insert, update on taskhub_owner.tags to taskhub_api;
grant insert, delete on taskhub_owner.todo_list_tags to taskhub_api;
grant update on taskhub_owner.tasks to taskhub_api;

-- TASKHUB_APP keeps EXECUTE on PKG_TASKHUB_API and receives no owner-table DML.
