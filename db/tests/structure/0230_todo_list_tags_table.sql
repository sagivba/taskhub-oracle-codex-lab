-- Test: TODO_LIST_TAGS table existence
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0060_create_todo_list_tags.sql has been applied.
-- Expected result: zero rows.

select 'MISSING_TABLE' as issue, 'TODO_LIST_TAGS' as object_name
from dual
where not exists (select 1 from user_tables where table_name = 'TODO_LIST_TAGS');
