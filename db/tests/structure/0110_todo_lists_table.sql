-- Test: TODO_LISTS table existence
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0040_create_todo_lists.sql has been applied.
-- Expected result: zero rows.
-- Identity rule: not applicable; this is a read-only structural test.

select 'MISSING_TABLE' as issue,
       'TODO_LISTS' as object_name
from dual
where not exists (
    select 1
    from user_tables
    where table_name = 'TODO_LISTS'
);
