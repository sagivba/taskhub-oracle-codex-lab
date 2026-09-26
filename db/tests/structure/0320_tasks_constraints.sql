-- Test: TASKS primary key, foreign keys, status and priority checks
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0070_create_tasks.sql has been applied.
-- Expected result: all three queries return zero rows.

with expected (constraint_name, constraint_type, r_constraint_name) as (
    select 'TASKS_PK',  'P', cast(null as varchar2(128)) from dual union all
    select 'TASKS_FK1', 'R', 'TODO_LISTS_PK' from dual union all
    select 'TASKS_FK2', 'R', 'TASKS_PK' from dual union all
    select 'TASKS_FK3', 'R', 'APP_USERS_PK' from dual union all
    select 'TASKS_FK4', 'R', 'APP_USERS_PK' from dual union all
    select 'TASKS_FK5', 'R', 'APP_USERS_PK' from dual union all
    select 'TASKS_CK1', 'C', cast(null as varchar2(128)) from dual union all
    select 'TASKS_CK2', 'C', cast(null as varchar2(128)) from dual
), actual as (
    select constraint_name, constraint_type, r_constraint_name
    from user_constraints
    where table_name = 'TASKS' and (constraint_type in ('P','U','R') or generated = 'USER NAME')
)
select 'CONSTRAINT_MISMATCH' as issue, nvl(e.constraint_name, a.constraint_name) constraint_name
from expected e full outer join actual a on a.constraint_name = e.constraint_name
where e.constraint_name is null or a.constraint_name is null
   or e.constraint_type <> a.constraint_type or nvl(e.r_constraint_name, '~') <> nvl(a.r_constraint_name, '~')
   or a.constraint_name in (
       select constraint_name from user_constraints where table_name = 'TASKS'
       and (status <> 'ENABLED' or validated <> 'VALIDATED' or deferrable <> 'NOT DEFERRABLE' or deferred <> 'IMMEDIATE')
   );

with expected (constraint_name, column_name) as (
    select 'TASKS_PK',  'ID' from dual union all
    select 'TASKS_FK1', 'TODO_LIST_ID' from dual union all
    select 'TASKS_FK2', 'PARENT_TASK_ID' from dual union all
    select 'TASKS_FK3', 'CREATED_BY_USER_ID' from dual union all
    select 'TASKS_FK4', 'UPDATED_BY_USER_ID' from dual union all
    select 'TASKS_FK5', 'DELETED_BY_USER_ID' from dual union all
    select 'TASKS_CK1', 'STATUS' from dual union all
    select 'TASKS_CK2', 'PRIORITY' from dual
), actual as (
    select constraint_name, column_name from user_cons_columns
    where table_name = 'TASKS'
      and constraint_name in ('TASKS_PK','TASKS_FK1','TASKS_FK2','TASKS_FK3','TASKS_FK4','TASKS_FK5','TASKS_CK1','TASKS_CK2')
)
select 'CONSTRAINT_COLUMN_MISMATCH' as issue,
       nvl(e.constraint_name, a.constraint_name) constraint_name,
       nvl(e.column_name, a.column_name) column_name
from expected e full outer join actual a
  on a.constraint_name = e.constraint_name and a.column_name = e.column_name
where e.constraint_name is null or a.constraint_name is null;

with actual as (
    select constraint_name,
           regexp_replace(upper(replace(search_condition_vc, '"', '')), '[[:space:]()]+' , '') expression
    from user_constraints where table_name = 'TASKS' and constraint_name in ('TASKS_CK1','TASKS_CK2')
)
select 'CHECK_EXPRESSION_MISMATCH' as issue, constraint_name
from actual
where (constraint_name = 'TASKS_CK1' and expression <> 'STATUSIN''OPEN'',''IN_PROGRESS'',''DONE'',''CANCELED''')
   or (constraint_name = 'TASKS_CK2' and expression <> 'PRIORITYIN1,2,3');
