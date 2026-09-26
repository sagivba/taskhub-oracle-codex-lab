-- Test: exact grants for the Task 20 context and create-list slice
-- Connection/schema: TASKHUB_API
-- Preconditions: changes 0080 through 0160 applied
-- Expected result: no rows

with expected_grants (table_schema, table_name, grantee, privilege, grantable) as (
    select 'TASKHUB_OWNER', 'APP_USERS',          'TASKHUB_API', 'SELECT',  'NO' from dual union all
    select 'TASKHUB_OWNER', 'TODO_LISTS',         'TASKHUB_API', 'INSERT',  'NO' from dual union all
    select 'TASKHUB_OWNER', 'TODO_LISTS',         'TASKHUB_API', 'SELECT',  'NO' from dual union all
    select 'TASKHUB_API',   'PKG_TASKHUB_API',    'TASKHUB_APP', 'EXECUTE', 'NO' from dual union all
    select 'TASKHUB_API',   'PKG_TASKHUB_CONTEXT','TASKHUB_APP', 'EXECUTE', 'NO' from dual
), actual_grants as (
    select table_schema, table_name, grantee, privilege, grantable
      from all_tab_privs
     where (table_schema = 'TASKHUB_OWNER' and grantee in ('TASKHUB_API', 'TASKHUB_APP'))
        or (table_schema = 'TASKHUB_API' and grantee = 'TASKHUB_APP')
)
select 'MISSING_GRANT' as issue, e.*
  from expected_grants e
minus
select 'MISSING_GRANT', a.*
  from actual_grants a
union all
select 'UNEXPECTED_GRANT' as issue, a.*
  from actual_grants a
minus
select 'UNEXPECTED_GRANT', e.*
  from expected_grants e;
