-- Task: 40 List and Tag API
-- Target schema: TASKHUB_OWNER
-- Purpose: Grant only the direct DML required by the definer-rights List/Tag API.
-- Preconditions: Task 30 grants are present; execute as TASKHUB_OWNER.
-- Verification: db/tests/security/0070_task30_grant_manifest.sql
-- Notes: Task 30 SELECT WITH GRANT OPTION is preserved; no DML is granted to TASKHUB_APP.

grant update on taskhub_owner.todo_lists to taskhub_api;
grant insert, update on taskhub_owner.tags to taskhub_api;
grant insert, delete on taskhub_owner.todo_list_tags to taskhub_api;
grant update on taskhub_owner.tasks to taskhub_api;
