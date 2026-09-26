-- Test: APP_USERS primary key, unique and check constraints
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0030_create_app_users.sql has been applied.
-- Expected result: all three queries return zero rows.
-- Identity rule: not applicable; this is a read-only structural test.

with expected_constraints (
    constraint_name,
    constraint_type,
    status,
    validated
) as (
    select 'APP_USERS_PK',  'P', 'ENABLED', 'VALIDATED' from dual union all
    select 'APP_USERS_UQ1', 'U', 'ENABLED', 'VALIDATED' from dual union all
    select 'APP_USERS_CK1', 'C', 'ENABLED', 'VALIDATED' from dual
),
actual_constraints as (
    select constraint_name,
           constraint_type,
           status,
           validated
    from user_constraints
    where table_name = 'APP_USERS'
      and (
          constraint_type in ('P', 'U')
          or generated = 'USER NAME'
      )
)
select case
           when expected.constraint_name is null then 'UNEXPECTED_CONSTRAINT'
           when actual.constraint_name is null then 'MISSING_CONSTRAINT'
           else 'CONSTRAINT_MISMATCH'
       end as issue,
       nvl(expected.constraint_name, actual.constraint_name) as constraint_name,
       expected.constraint_type as expected_type,
       actual.constraint_type as actual_type,
       expected.status as expected_status,
       actual.status as actual_status,
       expected.validated as expected_validated,
       actual.validated as actual_validated
from expected_constraints expected
full outer join actual_constraints actual
    on actual.constraint_name = expected.constraint_name
where expected.constraint_name is null
   or actual.constraint_name is null
   or expected.constraint_type <> actual.constraint_type
   or expected.status <> actual.status
   or expected.validated <> actual.validated
order by nvl(expected.constraint_name, actual.constraint_name);

with expected_columns (
    constraint_name,
    column_name,
    position
) as (
    select 'APP_USERS_PK',  'ID',        1 from dual union all
    select 'APP_USERS_UQ1', 'USERNAME',  1 from dual union all
    select 'APP_USERS_CK1', 'IS_ACTIVE', 1 from dual
),
actual_columns as (
    select constraint_name,
           column_name,
           position
    from user_cons_columns
    where table_name = 'APP_USERS'
      and constraint_name in ('APP_USERS_PK', 'APP_USERS_UQ1', 'APP_USERS_CK1')
)
select case
           when expected.constraint_name is null then 'UNEXPECTED_CONSTRAINT_COLUMN'
           when actual.constraint_name is null then 'MISSING_CONSTRAINT_COLUMN'
           else 'CONSTRAINT_COLUMN_MISMATCH'
       end as issue,
       nvl(expected.constraint_name, actual.constraint_name) as constraint_name,
       nvl(expected.column_name, actual.column_name) as column_name,
       expected.position as expected_position,
       actual.position as actual_position
from expected_columns expected
full outer join actual_columns actual
    on actual.constraint_name = expected.constraint_name
   and actual.column_name = expected.column_name
where expected.constraint_name is null
   or actual.constraint_name is null
   or expected.position <> actual.position
order by nvl(expected.constraint_name, actual.constraint_name);

select 'CHECK_CONDITION_MISMATCH' as issue,
       constraint_name,
       search_condition_vc
from user_constraints
where table_name = 'APP_USERS'
  and constraint_name = 'APP_USERS_CK1'
  and regexp_replace(
          upper(replace(search_condition_vc, '"', '')),
          '[[:space:]]+',
          ''
      ) <> 'IS_ACTIVEIN(''Y'',''N'')';
