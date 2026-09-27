-- Task: 30 Read Isolation
-- Target schema: TASKHUB_OWNER
-- Purpose: Grant the API owner the direct reads and delegation authority Oracle requires for filtered view grants.
-- Preconditions: Task 10 tables and Task 20 grants are present; execute as TASKHUB_OWNER.
-- Verification: db/tests/security/0070_task30_grant_manifest.sql
-- Notes: The object-specific grant option is limited to the four view source tables so TASKHUB_API can grant its views.
--        No DML, ANY privilege or direct privilege to TASKHUB_APP is included.

grant select on taskhub_owner.todo_lists to taskhub_api with grant option;
grant select on taskhub_owner.tags to taskhub_api with grant option;
grant select on taskhub_owner.todo_list_tags to taskhub_api with grant option;
grant select on taskhub_owner.tasks to taskhub_api with grant option;
