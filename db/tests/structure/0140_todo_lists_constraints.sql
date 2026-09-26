-- Test: TODO_LISTS primary key and foreign keys
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0040_create_todo_lists.sql has been applied.
-- Expected result: all five queries return zero rows.
-- Identity rule: not applicable; this is a read-only structural test.

with expected_constraints (
    constraint_name,
    constraint_type,
    status,
    validated
) as (
    select 'TODO_LISTS_PK',  'P', 'ENABLED', 'VALIDATED' from dual union all
    select 'TODO_LISTS_FK1', 'R', 'ENABLED', 'VALIDATED' from dual union all
    select 'TODO_LISTS_FK2', 'R', 'ENABLED', 'VALIDATED' from dual union all
    select 'TODO_LISTS_FK3', 'R', 'ENABLED', 'VALIDATED' from dual union all
    select 'TODO_LISTS_FK4', 'R', 'ENABLED', 'VALIDATED' from dual
),
actual_constraints as (
    select constraint_name,
           constraint_type,
           status,
           validated
    from user_constraints
    where table_name = 'TODO_LISTS'
      and constraint_type in ('P', 'U', 'R')
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

select 'UNEXPECTED_CHECK_CONSTRAINT' as issue,
       constraint_name,
       search_condition_vc
from user_constraints
where table_name = 'TODO_LISTS'
  and constraint_type = 'C'
  and not (
      generated = 'GENERATED NAME'
      and regexp_replace(
              upper(replace(search_condition_vc, '"', '')),
              '[[:space:]]+',
              ''
          ) in (
              'IDISNOTNULL',
              'APP_USER_IDISNOTNULL',
              'LIST_NAMEISNOTNULL',
              'CREATED_ATISNOTNULL',
              'CREATED_BY_USER_IDISNOTNULL'
          )
  );

with expected_columns (
    constraint_name,
    column_name,
    position
) as (
    select 'TODO_LISTS_PK',  'ID',                 1 from dual union all
    select 'TODO_LISTS_FK1', 'APP_USER_ID',        1 from dual union all
    select 'TODO_LISTS_FK2', 'CREATED_BY_USER_ID', 1 from dual union all
    select 'TODO_LISTS_FK3', 'UPDATED_BY_USER_ID', 1 from dual union all
    select 'TODO_LISTS_FK4', 'DELETED_BY_USER_ID', 1 from dual
),
actual_columns as (
    select constraint_name,
           column_name,
           position
    from user_cons_columns
    where table_name = 'TODO_LISTS'
      and constraint_name in (
          'TODO_LISTS_PK',
          'TODO_LISTS_FK1',
          'TODO_LISTS_FK2',
          'TODO_LISTS_FK3',
          'TODO_LISTS_FK4'
      )
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

with expected_foreign_keys (
    constraint_name,
    referenced_constraint_name,
    delete_rule,
    deferrable,
    deferred
) as (
    select 'TODO_LISTS_FK1', 'APP_USERS_PK', 'NO ACTION', 'NOT DEFERRABLE', 'IMMEDIATE' from dual union all
    select 'TODO_LISTS_FK2', 'APP_USERS_PK', 'NO ACTION', 'NOT DEFERRABLE', 'IMMEDIATE' from dual union all
    select 'TODO_LISTS_FK3', 'APP_USERS_PK', 'NO ACTION', 'NOT DEFERRABLE', 'IMMEDIATE' from dual union all
    select 'TODO_LISTS_FK4', 'APP_USERS_PK', 'NO ACTION', 'NOT DEFERRABLE', 'IMMEDIATE' from dual
),
actual_foreign_keys as (
    select constraint_name,
           r_constraint_name as referenced_constraint_name,
           delete_rule,
           deferrable,
           deferred
    from user_constraints
    where table_name = 'TODO_LISTS'
      and constraint_type = 'R'
)
select case
           when expected.constraint_name is null then 'UNEXPECTED_FOREIGN_KEY'
           when actual.constraint_name is null then 'MISSING_FOREIGN_KEY'
           else 'FOREIGN_KEY_MISMATCH'
       end as issue,
       nvl(expected.constraint_name, actual.constraint_name) as constraint_name,
       expected.referenced_constraint_name as expected_referenced_constraint,
       actual.referenced_constraint_name as actual_referenced_constraint,
       expected.delete_rule as expected_delete_rule,
       actual.delete_rule as actual_delete_rule,
       expected.deferrable as expected_deferrable,
       actual.deferrable as actual_deferrable,
       expected.deferred as expected_deferred,
       actual.deferred as actual_deferred
from expected_foreign_keys expected
full outer join actual_foreign_keys actual
    on actual.constraint_name = expected.constraint_name
where expected.constraint_name is null
   or actual.constraint_name is null
   or expected.referenced_constraint_name <> actual.referenced_constraint_name
   or expected.delete_rule <> actual.delete_rule
   or expected.deferrable <> actual.deferrable
   or expected.deferred <> actual.deferred
order by nvl(expected.constraint_name, actual.constraint_name);

with expected_targets (
    constraint_name,
    referenced_table_name,
    referenced_column_name,
    referenced_position
) as (
    select 'TODO_LISTS_FK1', 'APP_USERS', 'ID', 1 from dual union all
    select 'TODO_LISTS_FK2', 'APP_USERS', 'ID', 1 from dual union all
    select 'TODO_LISTS_FK3', 'APP_USERS', 'ID', 1 from dual union all
    select 'TODO_LISTS_FK4', 'APP_USERS', 'ID', 1 from dual
),
actual_targets as (
    select foreign_keys.constraint_name,
           referenced_constraints.table_name as referenced_table_name,
           referenced_columns.column_name as referenced_column_name,
           referenced_columns.position as referenced_position
    from user_constraints foreign_keys
    join user_constraints referenced_constraints
        on referenced_constraints.constraint_name = foreign_keys.r_constraint_name
    join user_cons_columns referenced_columns
        on referenced_columns.constraint_name = referenced_constraints.constraint_name
       and referenced_columns.table_name = referenced_constraints.table_name
    where foreign_keys.table_name = 'TODO_LISTS'
      and foreign_keys.constraint_type = 'R'
)
select case
           when expected.constraint_name is null then 'UNEXPECTED_FOREIGN_KEY_TARGET'
           when actual.constraint_name is null then 'MISSING_FOREIGN_KEY_TARGET'
           else 'FOREIGN_KEY_TARGET_MISMATCH'
       end as issue,
       nvl(expected.constraint_name, actual.constraint_name) as constraint_name,
       expected.referenced_table_name as expected_table,
       actual.referenced_table_name as actual_table,
       expected.referenced_column_name as expected_column,
       actual.referenced_column_name as actual_column,
       expected.referenced_position as expected_position,
       actual.referenced_position as actual_position
from expected_targets expected
full outer join actual_targets actual
    on actual.constraint_name = expected.constraint_name
   and actual.referenced_column_name = expected.referenced_column_name
where expected.constraint_name is null
   or actual.constraint_name is null
   or expected.referenced_table_name <> actual.referenced_table_name
   or expected.referenced_position <> actual.referenced_position
order by nvl(expected.constraint_name, actual.constraint_name);
