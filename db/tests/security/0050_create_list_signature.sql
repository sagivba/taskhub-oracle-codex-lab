-- Test: CREATE_LIST exposes no caller-controlled ownership or audit parameter
-- Connection/schema: TASKHUB_API
-- Preconditions: change 0150 applied
-- Expected result: no rows

select 'UNEXPECTED_ARGUMENT' as issue,
       argument_name,
       position,
       data_type,
       in_out
  from user_arguments
 where package_name = 'PKG_TASKHUB_API'
   and object_name = 'CREATE_LIST'
   and position > 0
   and argument_name <> 'P_LIST_NAME';
