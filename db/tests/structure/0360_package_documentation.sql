-- Test: package documentation markers and exact public/internal subprogram manifest
-- Connection/schema: TASKHUB_API
-- Preconditions: db/changes/0180_document_api_packages.sql applied
-- Expected result: no rows

with packages (package_name) as (
    select 'PKG_TASKHUB_CONTEXT_CORE' from dual union all
    select 'PKG_TASKHUB_CONTEXT' from dual union all
    select 'PKG_TASKHUB_TEST_CONTEXT' from dual union all
    select 'PKG_TASKHUB_API' from dual union all
    select 'PKG_TASKHUB_MAINT' from dual
), required_markers (marker) as (
    select 'PURPOSE' from dual union all
    select 'TRUST BOUNDARY' from dual union all
    select 'TRANSACTION' from dual union all
    select 'ERROR' from dual union all
    select 'TESTABILITY' from dual
), expected_subprograms (package_name, procedure_name) as (
    select 'PKG_TASKHUB_CONTEXT_CORE', 'INITIALIZE_CONTEXT' from dual union all
    select 'PKG_TASKHUB_CONTEXT_CORE', 'CLEAR_CONTEXT' from dual union all
    select 'PKG_TASKHUB_CONTEXT', 'INIT_FROM_APEX' from dual union all
    select 'PKG_TASKHUB_CONTEXT', 'CLEAR_CONTEXT' from dual union all
    select 'PKG_TASKHUB_TEST_CONTEXT', 'INIT_FOR_TEST' from dual union all
    select 'PKG_TASKHUB_TEST_CONTEXT', 'CLEAR_CONTEXT' from dual union all
    select 'PKG_TASKHUB_API', 'CREATE_LIST' from dual union all
    select 'PKG_TASKHUB_API', 'UPDATE_LIST' from dual union all
    select 'PKG_TASKHUB_API', 'DELETE_LIST' from dual union all
    select 'PKG_TASKHUB_API', 'ADD_TAG_TO_LIST' from dual union all
    select 'PKG_TASKHUB_API', 'REMOVE_TAG_FROM_LIST' from dual union all
    select 'PKG_TASKHUB_API', 'DELETE_TAG' from dual union all
    select 'PKG_TASKHUB_API', 'CREATE_TASK' from dual union all
    select 'PKG_TASKHUB_API', 'UPDATE_TASK' from dual union all
    select 'PKG_TASKHUB_API', 'DELETE_TASK' from dual union all
    select 'PKG_TASKHUB_MAINT', 'PURGE_DELETED' from dual
), actual_subprograms as (
    select object_name as package_name, procedure_name
      from user_procedures
     where object_name in (
               'PKG_TASKHUB_CONTEXT_CORE',
               'PKG_TASKHUB_CONTEXT',
               'PKG_TASKHUB_TEST_CONTEXT',
               'PKG_TASKHUB_API',
               'PKG_TASKHUB_MAINT'
           )
       and procedure_name is not null
), expected_arguments (package_name, object_name, argument_name, position, data_type, in_out) as (
    select 'PKG_TASKHUB_CONTEXT_CORE', 'INITIALIZE_CONTEXT', 'P_USERNAME', 1, 'VARCHAR2', 'IN' from dual union all
    select 'PKG_TASKHUB_TEST_CONTEXT', 'INIT_FOR_TEST', 'P_USERNAME', 1, 'VARCHAR2', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'CREATE_LIST', cast(null as varchar2(128)), 0, 'NUMBER', 'OUT' from dual union all
    select 'PKG_TASKHUB_API', 'CREATE_LIST', 'P_LIST_NAME', 1, 'VARCHAR2', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'UPDATE_LIST', 'P_LIST_ID', 1, 'NUMBER', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'UPDATE_LIST', 'P_LIST_NAME', 2, 'VARCHAR2', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'DELETE_LIST', 'P_LIST_ID', 1, 'NUMBER', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'ADD_TAG_TO_LIST', 'P_LIST_ID', 1, 'NUMBER', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'ADD_TAG_TO_LIST', 'P_TAG_NAME', 2, 'VARCHAR2', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'REMOVE_TAG_FROM_LIST', 'P_LIST_ID', 1, 'NUMBER', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'REMOVE_TAG_FROM_LIST', 'P_TAG_NAME', 2, 'VARCHAR2', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'DELETE_TAG', 'P_TAG_NAME', 1, 'VARCHAR2', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'CREATE_TASK', cast(null as varchar2(128)), 0, 'NUMBER', 'OUT' from dual union all
    select 'PKG_TASKHUB_API', 'CREATE_TASK', 'P_TODO_LIST_ID', 1, 'NUMBER', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'CREATE_TASK', 'P_PARENT_TASK_ID', 2, 'NUMBER', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'CREATE_TASK', 'P_TITLE', 3, 'VARCHAR2', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'CREATE_TASK', 'P_DESCRIPTION', 4, 'VARCHAR2', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'CREATE_TASK', 'P_STATUS', 5, 'VARCHAR2', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'CREATE_TASK', 'P_PRIORITY', 6, 'BINARY_INTEGER', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'CREATE_TASK', 'P_DUE_AT', 7, 'TIMESTAMP', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'UPDATE_TASK', 'P_TASK_ID', 1, 'NUMBER', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'UPDATE_TASK', 'P_PARENT_TASK_ID', 2, 'NUMBER', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'UPDATE_TASK', 'P_TITLE', 3, 'VARCHAR2', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'UPDATE_TASK', 'P_DESCRIPTION', 4, 'VARCHAR2', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'UPDATE_TASK', 'P_STATUS', 5, 'VARCHAR2', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'UPDATE_TASK', 'P_PRIORITY', 6, 'BINARY_INTEGER', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'UPDATE_TASK', 'P_DUE_AT', 7, 'TIMESTAMP', 'IN' from dual union all
    select 'PKG_TASKHUB_API', 'DELETE_TASK', 'P_TASK_ID', 1, 'NUMBER', 'IN' from dual
), actual_arguments as (
    select package_name, object_name, argument_name, position, data_type, in_out
      from user_arguments
     where package_name in (
               'PKG_TASKHUB_CONTEXT_CORE',
               'PKG_TASKHUB_CONTEXT',
               'PKG_TASKHUB_TEST_CONTEXT',
               'PKG_TASKHUB_API',
               'PKG_TASKHUB_MAINT'
           )
)
select 'MISSING_PACKAGE_MARKER' as issue,
       p.package_name as detail_1,
       m.marker as detail_2
  from packages p
 cross join required_markers m
 where not exists (
           select 1
             from user_source s
            where s.name = p.package_name
              and s.type = 'PACKAGE'
              and upper(s.text) like '%' || m.marker || '%'
       )
union all
select 'MISSING_SUBPROGRAM', e.package_name, e.procedure_name
  from expected_subprograms e
minus
select 'MISSING_SUBPROGRAM', a.package_name, a.procedure_name
  from actual_subprograms a
union all
select 'UNEXPECTED_SUBPROGRAM', a.package_name, a.procedure_name
  from actual_subprograms a
minus
select 'UNEXPECTED_SUBPROGRAM', e.package_name, e.procedure_name
  from expected_subprograms e
union all
select 'MISSING_ARGUMENT',
       e.package_name,
       e.object_name || ':' || nvl(e.argument_name, 'RETURN') || ':' ||
       e.position || ':' || e.data_type || ':' || e.in_out
  from expected_arguments e
minus
select 'MISSING_ARGUMENT',
       a.package_name,
       a.object_name || ':' || nvl(a.argument_name, 'RETURN') || ':' ||
       a.position || ':' || a.data_type || ':' || a.in_out
  from actual_arguments a
union all
select 'UNEXPECTED_ARGUMENT',
       a.package_name,
       a.object_name || ':' || nvl(a.argument_name, 'RETURN') || ':' ||
       a.position || ':' || a.data_type || ':' || a.in_out
  from actual_arguments a
minus
select 'UNEXPECTED_ARGUMENT',
       e.package_name,
       e.object_name || ':' || nvl(e.argument_name, 'RETURN') || ':' ||
       e.position || ':' || e.data_type || ':' || e.in_out
  from expected_arguments e;
