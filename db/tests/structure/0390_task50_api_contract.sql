-- Test: Task 50 defaults, canonical constraints and transaction/privilege boundaries
-- Connection/schema: TASKHUB_API
-- Preconditions: changes 0240 and 0250 applied
-- Expected result: all queries return zero rows

with expected (argument_name, position, defaulted) as (
    select 'P_TODO_LIST_ID', 1, 'N' from dual union all
    select 'P_PARENT_TASK_ID', 2, 'Y' from dual union all
    select 'P_TITLE', 3, 'N' from dual union all
    select 'P_DESCRIPTION', 4, 'Y' from dual union all
    select 'P_STATUS', 5, 'Y' from dual union all
    select 'P_PRIORITY', 6, 'Y' from dual union all
    select 'P_DUE_AT', 7, 'Y' from dual
), actual as (
    select argument_name, position, defaulted
      from user_arguments
     where package_name = 'PKG_TASKHUB_API'
       and object_name = 'CREATE_TASK'
       and position > 0
)
select 'CREATE_TASK_DEFAULT_MISMATCH' as issue,
       nvl(e.argument_name, a.argument_name) as detail
  from expected e
  full outer join actual a
    on a.argument_name = e.argument_name
   and a.position = e.position
 where e.argument_name is null
    or a.argument_name is null
    or e.defaulted <> a.defaulted;

select 'TASK_CONSTRAINT_MISMATCH' as issue,
       constraint_name as detail
  from all_constraints
 where owner = 'TASKHUB_OWNER'
   and table_name = 'TASKS'
   and constraint_name in ('TASKS_CK1', 'TASKS_CK2')
   and (status <> 'ENABLED' or validated <> 'VALIDATED')
union all
select 'MISSING_TASK_CONSTRAINT', expected_name
  from (
      select 'TASKS_CK1' expected_name from dual union all
      select 'TASKS_CK2' from dual
  )
 where not exists (
           select 1
             from all_constraints
            where owner = 'TASKHUB_OWNER'
              and table_name = 'TASKS'
              and constraint_name = expected_name
       );

select 'TRANSACTION_CONTROL_IN_API_BODY' as issue,
       to_char(line) as detail
  from user_source
 where name = 'PKG_TASKHUB_API'
   and type = 'PACKAGE BODY'
   and regexp_like(upper(text), '(^|[^A-Z_])(COMMIT|ROLLBACK)([^A-Z_]|$)');

select 'UNEXPECTED_TASKS_DELETE_GRANT' as issue,
       grantee as detail
  from all_tab_privs
 where table_schema = 'TASKHUB_OWNER'
   and table_name = 'TASKS'
   and privilege = 'DELETE'
   and grantee in ('TASKHUB_API', 'TASKHUB_APP');
