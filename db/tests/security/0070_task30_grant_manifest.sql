-- Test: exact cumulative direct object-grant manifest through Task 60
-- Connection/schema: TASKHUB_API
-- Preconditions: changes 0190 through 0280 applied
-- Expected result: no rows

with expected_grants (table_schema, table_name, grantee, privilege, grantable) as (
    select 'TASKHUB_OWNER', 'APP_USERS',          'TASKHUB_API', 'SELECT',  'NO' from dual union all
    select 'TASKHUB_OWNER', 'TODO_LISTS',         'TASKHUB_API', 'INSERT',  'NO' from dual union all
    select 'TASKHUB_OWNER', 'TODO_LISTS',         'TASKHUB_API', 'SELECT',  'YES' from dual union all
    select 'TASKHUB_OWNER', 'TODO_LISTS',         'TASKHUB_API', 'UPDATE',  'NO' from dual union all
    select 'TASKHUB_OWNER', 'TODO_LISTS',         'TASKHUB_API', 'DELETE',  'NO' from dual union all
    select 'TASKHUB_OWNER', 'TAGS',               'TASKHUB_API', 'SELECT',  'YES' from dual union all
    select 'TASKHUB_OWNER', 'TAGS',               'TASKHUB_API', 'INSERT',  'NO' from dual union all
    select 'TASKHUB_OWNER', 'TAGS',               'TASKHUB_API', 'UPDATE',  'NO' from dual union all
    select 'TASKHUB_OWNER', 'TAGS',               'TASKHUB_API', 'DELETE',  'NO' from dual union all
    select 'TASKHUB_OWNER', 'TODO_LIST_TAGS',     'TASKHUB_API', 'SELECT',  'YES' from dual union all
    select 'TASKHUB_OWNER', 'TODO_LIST_TAGS',     'TASKHUB_API', 'INSERT',  'NO' from dual union all
    select 'TASKHUB_OWNER', 'TODO_LIST_TAGS',     'TASKHUB_API', 'DELETE',  'NO' from dual union all
    select 'TASKHUB_OWNER', 'TASKS',              'TASKHUB_API', 'SELECT',  'YES' from dual union all
    select 'TASKHUB_OWNER', 'TASKS',              'TASKHUB_API', 'INSERT',  'NO' from dual union all
    select 'TASKHUB_OWNER', 'TASKS',              'TASKHUB_API', 'UPDATE',  'NO' from dual union all
    select 'TASKHUB_OWNER', 'TASKS',              'TASKHUB_API', 'DELETE',  'NO' from dual union all
    select 'TASKHUB_API',   'PKG_TASKHUB_API',    'TASKHUB_APP', 'EXECUTE', 'NO' from dual union all
    select 'TASKHUB_API',   'PKG_TASKHUB_CONTEXT','TASKHUB_APP', 'EXECUTE', 'NO' from dual union all
    select 'TASKHUB_API',   'V_TODO_LISTS',       'TASKHUB_APP', 'SELECT',  'NO' from dual union all
    select 'TASKHUB_API',   'V_TODO_LIST_TAGS',   'TASKHUB_APP', 'SELECT',  'NO' from dual union all
    select 'TASKHUB_API',   'V_TASKS',            'TASKHUB_APP', 'SELECT',  'NO' from dual union all
    select 'TASKHUB_API',   'V_TASK_TREE',        'TASKHUB_APP', 'SELECT',  'NO' from dual
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
