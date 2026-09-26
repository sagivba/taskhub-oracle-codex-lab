-- Test: TAGS exact column definitions and defaults
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0050_create_tags.sql has been applied.
-- Expected result: both queries return zero rows.

with expected_columns (column_id, column_name, data_type, char_used, char_length, data_scale, nullable) as (
    select 1, 'ID',                 'NUMBER',       cast(null as varchar2(1)), 0,   cast(null as number), 'N' from dual union all
    select 2, 'APP_USER_ID',        'NUMBER',       cast(null as varchar2(1)), 0,   cast(null as number), 'N' from dual union all
    select 3, 'TAG_NAME',           'VARCHAR2',     'C',                        100, cast(null as number), 'N' from dual union all
    select 4, 'CREATED_AT',         'TIMESTAMP(6)', cast(null as varchar2(1)), 0,   6,                    'N' from dual union all
    select 5, 'CREATED_BY_USER_ID', 'NUMBER',       cast(null as varchar2(1)), 0,   cast(null as number), 'N' from dual union all
    select 6, 'UPDATED_AT',         'TIMESTAMP(6)', cast(null as varchar2(1)), 0,   6,                    'Y' from dual union all
    select 7, 'UPDATED_BY_USER_ID', 'NUMBER',       cast(null as varchar2(1)), 0,   cast(null as number), 'Y' from dual union all
    select 8, 'DELETED_AT',         'TIMESTAMP(6)', cast(null as varchar2(1)), 0,   6,                    'Y' from dual union all
    select 9, 'DELETED_BY_USER_ID', 'NUMBER',       cast(null as varchar2(1)), 0,   cast(null as number), 'Y' from dual
), actual_columns as (
    select column_id, column_name, data_type, char_used, char_length, data_scale, nullable
    from user_tab_columns where table_name = 'TAGS'
)
select case when e.column_name is null then 'UNEXPECTED_COLUMN'
            when a.column_name is null then 'MISSING_COLUMN' else 'COLUMN_MISMATCH' end as issue,
       nvl(e.column_name, a.column_name) as column_name
from expected_columns e full outer join actual_columns a on a.column_name = e.column_name
where e.column_name is null or a.column_name is null
   or e.column_id <> a.column_id or e.data_type <> a.data_type
   or nvl(e.char_used, '~') <> nvl(a.char_used, '~')
   or nvl(e.char_length, -1) <> nvl(a.char_length, -1)
   or nvl(e.data_scale, -1) <> nvl(a.data_scale, -1)
   or e.nullable <> a.nullable;

with expected_defaults (column_name, normalized_default) as (
    select 'APP_USER_ID',        cast(null as varchar2(4000)) from dual union all
    select 'TAG_NAME',           cast(null as varchar2(4000)) from dual union all
    select 'CREATED_AT',         'SYSTIMESTAMP' from dual union all
    select 'CREATED_BY_USER_ID', cast(null as varchar2(4000)) from dual union all
    select 'UPDATED_AT',         cast(null as varchar2(4000)) from dual union all
    select 'UPDATED_BY_USER_ID', cast(null as varchar2(4000)) from dual union all
    select 'DELETED_AT',         cast(null as varchar2(4000)) from dual union all
    select 'DELETED_BY_USER_ID', cast(null as varchar2(4000)) from dual
), actual_defaults as (
    select column_name,
           case when data_default_vc is null then null
                else regexp_replace(upper(trim(data_default_vc)), '[[:space:]]+', '') end normalized_default
    from user_tab_columns where table_name = 'TAGS' and column_name <> 'ID'
)
select 'DEFAULT_MISMATCH' as issue, nvl(e.column_name, a.column_name) as column_name
from expected_defaults e full outer join actual_defaults a on a.column_name = e.column_name
where e.column_name is null or a.column_name is null
   or nvl(e.normalized_default, '~') <> nvl(a.normalized_default, '~');
