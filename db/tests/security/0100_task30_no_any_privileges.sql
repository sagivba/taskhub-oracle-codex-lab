-- Test: TaskHub schemas have no broad ANY system privileges
-- Connection/schema: TASKHUB_API
-- Preconditions: changes 0190 through 0210 applied
-- Expected result: no rows

select grantee,
       privilege
  from all_sys_privs
 where grantee in ('TASKHUB_OWNER', 'TASKHUB_API', 'TASKHUB_APP')
   and privilege like '% ANY %'
 order by grantee, privilege;
