-- Task: 60 Maintenance and Purge
-- Target schema: TASKHUB_OWNER
-- Purpose: Grant the parent-table DELETE privileges required by the maintenance package.
-- Preconditions: Task 50 grants are present; execute as TASKHUB_OWNER.
-- Verification: db/tests/security/0070_task30_grant_manifest.sql
-- Notes: TODO_LIST_TAGS DELETE already exists; TASKHUB_APP receives no new privilege.

grant delete on taskhub_owner.todo_lists to taskhub_api;
grant delete on taskhub_owner.tags to taskhub_api;
grant delete on taskhub_owner.tasks to taskhub_api;
