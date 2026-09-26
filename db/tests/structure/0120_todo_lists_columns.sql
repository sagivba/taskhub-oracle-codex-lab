-- Test: TODO_LISTS exact column definition and defaults
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0040_create_todo_lists.sql has been applied.
-- Expected result: both queries return zero rows.
-- Identity rule: not applicable; this is a read-only structural test.

with expected_columns (
    column_id,
    column_name,
    data_type,
    char_used,
    char_length,
    data_precision,
    data_scale,
    nullable
) as (
    select 1, 'ID',                 'NUMBER',       cast(null as varchar2(1)), 0,   cast(null as number), null, 'N' from dual union all
    select 2, 'APP_USER_ID',        'NUMBER',       cast(null as varchar2(1)), 0,   cast(null as number), null, 'N' from dual union all
    select 3, 'LIST_NAME',          'VARCHAR2',     'C',                        200, cast(null as number), null, 'N' from dual union all
    select 4, 'CREATED_AT',         'TIMESTAMP(6)', cast(null as varchar2(1)), 0,   cast(null as number), 6,    'N' from dual union all
    select 5, 'CREATED_BY_USER_ID', 'NUMBER',       cast(null as varchar2(1)), 0,   cast(null as number), null, 'N' from dual union all
    select 6, 'UPDATED_AT',         'TIMESTAMP(6)', cast(null as varchar2(1)), 0,   cast(null as number), 6,    'Y' from dual union all
    select 7, 'UPDATED_BY_USER_ID', 'NUMBER',       cast(null as varchar2(1)), 0,   cast(null as number), null, 'Y' from dual union all
    select 8, 'DELETED_AT',         'TIMESTAMP(6)', cast(null as varchar2(1)), 0,   cast(null as number), 6,    'Y' from dual union all
    select 9, 'DELETED_BY_USER_ID', 'NUMBER',       cast(null as varchar2(1)), 0,   cast(null as number), null, 'Y' from dual
),
actual_columns as (
    select column_id,
           column_name,
           data_type,
           char_used,
           char_length,
           data_precision,
           data_scale,
           nullable
    from user_tab_columns
    where table_name = 'TODO_LISTS'
)
select case
           when expected.column_name is null then 'UNEXPECTED_COLUMN'
           when actual.column_name is null then 'MISSING_COLUMN'
           else 'COLUMN_MISMATCH'
       end as issue,
       nvl(expected.column_name, actual.column_name) as column_name,
       expected.column_id as expected_column_id,
       actual.column_id as actual_column_id,
       expected.data_type as expected_data_type,
       actual.data_type as actual_data_type,
       expected.char_used as expected_char_used,
       actual.char_used as actual_char_used,
       expected.char_length as expected_char_length,
       actual.char_length as actual_char_length,
       expected.data_precision as expected_data_precision,
       actual.data_precision as actual_data_precision,
       expected.data_scale as expected_data_scale,
       actual.data_scale as actual_data_scale,
       expected.nullable as expected_nullable,
       actual.nullable as actual_nullable
from expected_columns expected
full outer join actual_columns actual
    on actual.column_name = expected.column_name
where expected.column_name is null
   or actual.column_name is null
   or expected.column_id <> actual.column_id
   or expected.data_type <> actual.data_type
   or nvl(expected.char_used, '~') <> nvl(actual.char_used, '~')
   or nvl(expected.char_length, -1) <> nvl(actual.char_length, -1)
   or nvl(expected.data_precision, -1) <> nvl(actual.data_precision, -1)
   or nvl(expected.data_scale, -1) <> nvl(actual.data_scale, -1)
   or expected.nullable <> actual.nullable
order by nvl(expected.column_id, actual.column_id);

with expected_defaults (
    column_name,
    normalized_default
) as (
    select 'APP_USER_ID',        cast(null as varchar2(4000)) from dual union all
    select 'LIST_NAME',          cast(null as varchar2(4000)) from dual union all
    select 'CREATED_AT',         'SYSTIMESTAMP'               from dual union all
    select 'CREATED_BY_USER_ID', cast(null as varchar2(4000)) from dual union all
    select 'UPDATED_AT',         cast(null as varchar2(4000)) from dual union all
    select 'UPDATED_BY_USER_ID', cast(null as varchar2(4000)) from dual union all
    select 'DELETED_AT',         cast(null as varchar2(4000)) from dual union all
    select 'DELETED_BY_USER_ID', cast(null as varchar2(4000)) from dual
),
actual_defaults as (
    select column_name,
           case
               when data_default_vc is null then null
               else regexp_replace(
                        upper(trim(data_default_vc)),
                        '[[:space:]]+',
                        ''
                    )
           end as normalized_default
    from user_tab_columns
    where table_name = 'TODO_LISTS'
      and column_name <> 'ID'
)
select case
           when expected.column_name is null then 'UNEXPECTED_DEFAULT_COLUMN'
           when actual.column_name is null then 'MISSING_DEFAULT_COLUMN'
           else 'DEFAULT_MISMATCH'
       end as issue,
       nvl(expected.column_name, actual.column_name) as column_name,
       expected.normalized_default as expected_default,
       actual.normalized_default as actual_default
from expected_defaults expected
full outer join actual_defaults actual
    on actual.column_name = expected.column_name
where expected.column_name is null
   or actual.column_name is null
   or nvl(expected.normalized_default, '~') <>
      nvl(actual.normalized_default, '~')
order by nvl(expected.column_name, actual.column_name);
