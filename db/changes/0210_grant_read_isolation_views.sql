-- Task: 30 Read Isolation
-- Target schema: TASKHUB_API
-- Purpose: Expose only the four approved filtered read views to the application principal.
-- Preconditions: db/changes/0200_create_read_isolation_views.sql has been applied; execute as TASKHUB_API.
-- Verification: db/tests/security/0070_task30_grant_manifest.sql
--               db/tests/security/0090_task30_app_table_denial.sql
-- Notes: No owner table privilege, grant option, DML privilege or identity-setting package is exposed.

grant select on taskhub_api.v_todo_lists to taskhub_app;
grant select on taskhub_api.v_todo_list_tags to taskhub_app;
grant select on taskhub_api.v_tasks to taskhub_app;
grant select on taskhub_api.v_task_tree to taskhub_app;
