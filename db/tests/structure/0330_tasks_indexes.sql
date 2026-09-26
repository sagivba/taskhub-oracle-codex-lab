-- Test: TASKS exact approved index set and columns
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0070_create_tasks.sql has been applied.
-- Expected result: both queries return zero rows.

with expected (index_name, uniqueness) as (
    select 'TASKS_PK',  'UNIQUE' from dual union all
    select 'TASKS_IX1', 'NONUNIQUE' from dual union all
    select 'TASKS_IX2', 'NONUNIQUE' from dual union all
    select 'TASKS_IX3', 'NONUNIQUE' from dual
), actual as (
    select index_name, uniqueness from user_indexes where table_name = 'TASKS'
)
select 'INDEX_MISMATCH' as issue, nvl(e.index_name, a.index_name) index_name
from expected e full outer join actual a on a.index_name = e.index_name
where e.index_name is null or a.index_name is null or e.uniqueness <> a.uniqueness
   or exists (select 1 from user_indexes i where i.index_name = a.index_name and i.status <> 'VALID');

with expected (index_name, column_name, column_position) as (
    select 'TASKS_PK',  'ID',             1 from dual union all
    select 'TASKS_IX1', 'TODO_LIST_ID',   1 from dual union all
    select 'TASKS_IX1', 'DELETED_AT',     2 from dual union all
    select 'TASKS_IX2', 'PARENT_TASK_ID', 1 from dual union all
    select 'TASKS_IX3', 'STATUS',         1 from dual union all
    select 'TASKS_IX3', 'PRIORITY',       2 from dual union all
    select 'TASKS_IX3', 'DUE_AT',         3 from dual
), actual as (
    select index_name, column_name, column_position from user_ind_columns where table_name = 'TASKS'
)
select 'INDEX_COLUMN_MISMATCH' as issue, nvl(e.index_name, a.index_name) index_name,
       nvl(e.column_name, a.column_name) column_name
from expected e full outer join actual a
  on a.index_name = e.index_name and a.column_name = e.column_name
where e.index_name is null or a.index_name is null or e.column_position <> a.column_position;
