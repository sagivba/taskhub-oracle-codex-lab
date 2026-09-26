-- Test: TODO_LISTS identity generation mode
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0040_create_todo_lists.sql has been applied.
-- Expected result: zero rows.
-- Identity rule: not applicable; this is a read-only structural test.

with expected_identity as (
    select 'TODO_LISTS' as table_name,
           'ID' as column_name,
           'ALWAYS' as generation_type
    from dual
),
actual_identity as (
    select table_name,
           column_name,
           generation_type
    from user_tab_identity_cols
    where table_name = 'TODO_LISTS'
)
select case
           when expected.table_name is null then 'UNEXPECTED_IDENTITY_COLUMN'
           when actual.table_name is null then 'MISSING_IDENTITY_COLUMN'
           else 'IDENTITY_MISMATCH'
       end as issue,
       nvl(expected.table_name, actual.table_name) as table_name,
       nvl(expected.column_name, actual.column_name) as column_name,
       expected.generation_type as expected_generation_type,
       actual.generation_type as actual_generation_type
from expected_identity expected
full outer join actual_identity actual
    on actual.table_name = expected.table_name
   and actual.column_name = expected.column_name
where expected.table_name is null
   or actual.table_name is null
   or expected.generation_type <> actual.generation_type;
