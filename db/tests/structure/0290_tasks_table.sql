-- Test: TASKS table existence
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0070_create_tasks.sql has been applied.
-- Expected result: zero rows.

select 'MISSING_TABLE' as issue, 'TASKS' as object_name
from dual
where not exists (select 1 from user_tables where table_name = 'TASKS');
