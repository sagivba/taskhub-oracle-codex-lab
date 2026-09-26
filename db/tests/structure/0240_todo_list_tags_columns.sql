-- Test: TODO_LIST_TAGS exact column definitions and defaults
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0060_create_todo_list_tags.sql has been applied.
-- Expected result: both queries return zero rows.

with expected (column_id, column_name, data_type, data_scale, nullable) as (
    select 1, 'ID',           'NUMBER',       cast(null as number), 'N' from dual union all
    select 2, 'TODO_LIST_ID', 'NUMBER',       cast(null as number), 'N' from dual union all
    select 3, 'TAG_ID',       'NUMBER',       cast(null as number), 'N' from dual union all
    select 4, 'CREATED_AT',   'TIMESTAMP(6)', 6,                    'N' from dual
), actual as (
    select column_id, column_name, data_type, data_scale, nullable
    from user_tab_columns where table_name = 'TODO_LIST_TAGS'
)
select 'COLUMN_MISMATCH' as issue, nvl(e.column_name, a.column_name) column_name
from expected e full outer join actual a on a.column_name = e.column_name
where e.column_name is null or a.column_name is null or e.column_id <> a.column_id
   or e.data_type <> a.data_type or nvl(e.data_scale, -1) <> nvl(a.data_scale, -1)
   or e.nullable <> a.nullable;

with expected (column_name, normalized_default) as (
    select 'TODO_LIST_ID', cast(null as varchar2(4000)) from dual union all
    select 'TAG_ID',       cast(null as varchar2(4000)) from dual union all
    select 'CREATED_AT',   'SYSTIMESTAMP' from dual
), actual as (
    select column_name, case when data_default_vc is null then null
           else regexp_replace(upper(trim(data_default_vc)), '[[:space:]]+', '') end normalized_default
    from user_tab_columns where table_name = 'TODO_LIST_TAGS' and column_name <> 'ID'
)
select 'DEFAULT_MISMATCH' as issue, nvl(e.column_name, a.column_name) column_name
from expected e full outer join actual a on a.column_name = e.column_name
where e.column_name is null or a.column_name is null
   or nvl(e.normalized_default, '~') <> nvl(a.normalized_default, '~');
