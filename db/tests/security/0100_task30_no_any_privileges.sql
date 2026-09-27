-- Test: the connected TaskHub schema has no broad ANY system privileges
-- Connection/schema: run separately as TASKHUB_OWNER, TASKHUB_API and TASKHUB_APP
-- Preconditions: changes 0190 through 0210 applied
-- Expected result: no rows

select user as grantee,
       privilege
  from user_sys_privs
 where privilege like '% ANY %'
 order by privilege;
