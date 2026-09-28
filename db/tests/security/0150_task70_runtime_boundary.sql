-- Test: Task 70 did not add direct owner access or privileged context-package access
-- Connection/schema: TASKHUB_APP
-- Preconditions: Task 70 platform and application configuration applied
-- Expected result: no rows

select table_schema as owner,
       table_name,
       grantee,
       privilege,
       grantable
  from all_tab_privs
 where grantee = 'TASKHUB_APP'
   and (
       table_schema = 'TASKHUB_OWNER'
       or (table_schema = 'TASKHUB_API' and table_name in (
           'PKG_TASKHUB_CONTEXT_CORE',
           'PKG_TASKHUB_TEST_CONTEXT',
           'PKG_TASKHUB_MAINT'
       ))
   )
 order by owner, table_name, privilege;

select privilege
  from user_sys_privs
 where privilege like '% ANY %'
 order by privilege;
