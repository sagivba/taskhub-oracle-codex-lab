-- Test: TODO_LISTS exact approved index set and columns
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0040_create_todo_lists.sql has been applied.
-- Expected result: both queries return zero rows.
-- Identity rule: not applicable; this is a read-only structural test.

with expected_indexes (
    index_name,
    uniqueness,
    status
) as (
    select 'TODO_LISTS_PK',  'UNIQUE',    'VALID' from dual union all
    select 'TODO_LISTS_IX1', 'NONUNIQUE', 'VALID' from dual
),
actual_indexes as (
    select index_name,
           uniqueness,
           status
    from user_indexes
    where table_name = 'TODO_LISTS'
)
select case
           when expected.index_name is null then 'UNEXPECTED_INDEX'
           when actual.index_name is null then 'MISSING_INDEX'
           else 'INDEX_MISMATCH'
       end as issue,
       nvl(expected.index_name, actual.index_name) as index_name,
       expected.uniqueness as expected_uniqueness,
       actual.uniqueness as actual_uniqueness,
       expected.status as expected_status,
       actual.status as actual_status
from expected_indexes expected
full outer join actual_indexes actual
    on actual.index_name = expected.index_name
where expected.index_name is null
   or actual.index_name is null
   or expected.uniqueness <> actual.uniqueness
   or expected.status <> actual.status
order by nvl(expected.index_name, actual.index_name);

with expected_columns (
    index_name,
    column_name,
    column_position
) as (
    select 'TODO_LISTS_PK',  'ID',          1 from dual union all
    select 'TODO_LISTS_IX1', 'APP_USER_ID', 1 from dual union all
    select 'TODO_LISTS_IX1', 'DELETED_AT',  2 from dual
),
actual_columns as (
    select index_name,
           column_name,
           column_position
    from user_ind_columns
    where table_name = 'TODO_LISTS'
)
select case
           when expected.index_name is null then 'UNEXPECTED_INDEX_COLUMN'
           when actual.index_name is null then 'MISSING_INDEX_COLUMN'
           else 'INDEX_COLUMN_MISMATCH'
       end as issue,
       nvl(expected.index_name, actual.index_name) as index_name,
       nvl(expected.column_name, actual.column_name) as column_name,
       expected.column_position as expected_position,
       actual.column_position as actual_position
from expected_columns expected
full outer join actual_columns actual
    on actual.index_name = expected.index_name
   and actual.column_name = expected.column_name
where expected.index_name is null
   or actual.index_name is null
   or expected.column_position <> actual.column_position
order by nvl(expected.index_name, actual.index_name),
         nvl(expected.column_position, actual.column_position);
