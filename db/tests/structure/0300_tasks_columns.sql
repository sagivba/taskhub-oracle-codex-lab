-- Test: TASKS exact column definitions and defaults
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0070_create_tasks.sql has been applied.
-- Expected result: both queries return zero rows.

with expected (column_id, column_name, data_type, char_used, char_length, data_scale, nullable) as (
    select 1,  'ID',                 'NUMBER',       cast(null as varchar2(1)), 0,    cast(null as number), 'N' from dual union all
    select 2,  'TODO_LIST_ID',       'NUMBER',       cast(null as varchar2(1)), 0,    cast(null as number), 'N' from dual union all
    select 3,  'PARENT_TASK_ID',     'NUMBER',       cast(null as varchar2(1)), 0,    cast(null as number), 'Y' from dual union all
    select 4,  'TITLE',              'VARCHAR2',     'C',                        200,  cast(null as number), 'N' from dual union all
    select 5,  'DESCRIPTION',        'VARCHAR2',     'C',                        4000, cast(null as number), 'Y' from dual union all
    select 6,  'STATUS',             'VARCHAR2',     'C',                        20,   cast(null as number), 'N' from dual union all
    select 7,  'PRIORITY',           'NUMBER',       cast(null as varchar2(1)), 0,    cast(null as number), 'N' from dual union all
    select 8,  'DUE_AT',             'TIMESTAMP(6)', cast(null as varchar2(1)), 0,    6,                    'Y' from dual union all
    select 9,  'COMPLETED_AT',       'TIMESTAMP(6)', cast(null as varchar2(1)), 0,    6,                    'Y' from dual union all
    select 10, 'CREATED_AT',         'TIMESTAMP(6)', cast(null as varchar2(1)), 0,    6,                    'N' from dual union all
    select 11, 'CREATED_BY_USER_ID', 'NUMBER',       cast(null as varchar2(1)), 0,    cast(null as number), 'N' from dual union all
    select 12, 'UPDATED_AT',         'TIMESTAMP(6)', cast(null as varchar2(1)), 0,    6,                    'Y' from dual union all
    select 13, 'UPDATED_BY_USER_ID', 'NUMBER',       cast(null as varchar2(1)), 0,    cast(null as number), 'Y' from dual union all
    select 14, 'DELETED_AT',         'TIMESTAMP(6)', cast(null as varchar2(1)), 0,    6,                    'Y' from dual union all
    select 15, 'DELETED_BY_USER_ID', 'NUMBER',       cast(null as varchar2(1)), 0,    cast(null as number), 'Y' from dual
), actual as (
    select column_id, column_name, data_type, char_used, char_length, data_scale, nullable
    from user_tab_columns where table_name = 'TASKS'
)
select 'COLUMN_MISMATCH' as issue, nvl(e.column_name, a.column_name) column_name
from expected e full outer join actual a on a.column_name = e.column_name
where e.column_name is null or a.column_name is null or e.column_id <> a.column_id
   or e.data_type <> a.data_type or nvl(e.char_used, '~') <> nvl(a.char_used, '~')
   or nvl(e.char_length, -1) <> nvl(a.char_length, -1)
   or nvl(e.data_scale, -1) <> nvl(a.data_scale, -1) or e.nullable <> a.nullable;

with expected (column_name, normalized_default) as (
    select 'TODO_LIST_ID',       cast(null as varchar2(4000)) from dual union all
    select 'PARENT_TASK_ID',     cast(null as varchar2(4000)) from dual union all
    select 'TITLE',              cast(null as varchar2(4000)) from dual union all
    select 'DESCRIPTION',        cast(null as varchar2(4000)) from dual union all
    select 'STATUS',             cast(null as varchar2(4000)) from dual union all
    select 'PRIORITY',           cast(null as varchar2(4000)) from dual union all
    select 'DUE_AT',             cast(null as varchar2(4000)) from dual union all
    select 'COMPLETED_AT',       cast(null as varchar2(4000)) from dual union all
    select 'CREATED_AT',         'SYSTIMESTAMP' from dual union all
    select 'CREATED_BY_USER_ID', cast(null as varchar2(4000)) from dual union all
    select 'UPDATED_AT',         cast(null as varchar2(4000)) from dual union all
    select 'UPDATED_BY_USER_ID', cast(null as varchar2(4000)) from dual union all
    select 'DELETED_AT',         cast(null as varchar2(4000)) from dual union all
    select 'DELETED_BY_USER_ID', cast(null as varchar2(4000)) from dual
), actual as (
    select column_name, case when data_default_vc is null then null
           else regexp_replace(upper(trim(data_default_vc)), '[[:space:]]+', '') end normalized_default
    from user_tab_columns where table_name = 'TASKS' and column_name <> 'ID'
)
select 'DEFAULT_MISMATCH' as issue, nvl(e.column_name, a.column_name) column_name
from expected e full outer join actual a on a.column_name = e.column_name
where e.column_name is null or a.column_name is null
   or nvl(e.normalized_default, '~') <> nvl(a.normalized_default, '~');
