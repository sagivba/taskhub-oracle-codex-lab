-- Test: APP_USERS expected indexes and absence of redundant USERNAME indexes
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0030_create_app_users.sql has been applied.
-- Expected result: all four queries return zero rows.
-- Identity rule: not applicable; this is a read-only structural test.

with expected_indexes (
    constraint_name,
    index_name,
    uniqueness,
    status
) as (
    select 'APP_USERS_PK',  'APP_USERS_PK',  'UNIQUE', 'VALID' from dual union all
    select 'APP_USERS_UQ1', 'APP_USERS_UQ1', 'UNIQUE', 'VALID' from dual
),
actual_indexes as (
    select constraints.constraint_name,
           constraints.index_name,
           indexes.uniqueness,
           indexes.status
    from user_constraints constraints
    left join user_indexes indexes
        on indexes.index_name = constraints.index_name
       and indexes.table_name = constraints.table_name
    where constraints.table_name = 'APP_USERS'
      and constraints.constraint_name in ('APP_USERS_PK', 'APP_USERS_UQ1')
)
select case
           when expected.constraint_name is null then 'UNEXPECTED_SUPPORTING_INDEX'
           when actual.constraint_name is null then 'MISSING_SUPPORTING_INDEX'
           else 'SUPPORTING_INDEX_MISMATCH'
       end as issue,
       nvl(expected.constraint_name, actual.constraint_name) as constraint_name,
       nvl(expected.index_name, actual.index_name) as index_name,
       expected.uniqueness as expected_uniqueness,
       actual.uniqueness as actual_uniqueness,
       expected.status as expected_status,
       actual.status as actual_status
from expected_indexes expected
full outer join actual_indexes actual
    on actual.constraint_name = expected.constraint_name
where expected.constraint_name is null
   or actual.constraint_name is null
   or nvl(expected.index_name, '~') <> nvl(actual.index_name, '~')
   or nvl(expected.uniqueness, '~') <> nvl(actual.uniqueness, '~')
   or nvl(expected.status, '~') <> nvl(actual.status, '~')
order by nvl(expected.constraint_name, actual.constraint_name);

with expected_columns (
    index_name,
    column_name,
    column_position
) as (
    select 'APP_USERS_PK',  'ID',       1 from dual union all
    select 'APP_USERS_UQ1', 'USERNAME', 1 from dual
),
actual_columns as (
    select index_name,
           column_name,
           column_position
    from user_ind_columns
    where table_name = 'APP_USERS'
      and index_name in ('APP_USERS_PK', 'APP_USERS_UQ1')
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
order by nvl(expected.index_name, actual.index_name);

select 'REDUNDANT_USERNAME_INDEX' as issue,
       index_name
from user_ind_columns
where table_name = 'APP_USERS'
group by index_name
having count(*) = 1
   and max(column_name) = 'USERNAME'
   and index_name <> 'APP_USERS_UQ1';

select 'USERNAME_NORMALIZATION_INDEX_NOT_ALLOWED' as issue,
       index_columns.index_name,
       index_columns.column_position,
       hidden_columns.data_default_vc as column_expression
from user_ind_columns index_columns
join user_tab_cols hidden_columns
    on hidden_columns.table_name = index_columns.table_name
   and hidden_columns.column_name = index_columns.column_name
where index_columns.table_name = 'APP_USERS'
  and hidden_columns.hidden_column = 'YES'
  and hidden_columns.virtual_column = 'YES'
  and regexp_like(
          upper(replace(hidden_columns.data_default_vc, '"', '')),
          '(^|[^A-Z0-9_])USERNAME([^A-Z0-9_]|$)'
      )
  and regexp_like(
          upper(hidden_columns.data_default_vc),
          '(^|[^A-Z0-9_])(UPPER|LOWER|TRIM|LTRIM|RTRIM|NLSSORT)[[:space:]]*[(]'
      );
