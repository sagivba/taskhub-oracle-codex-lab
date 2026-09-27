-- Test: Task 60 maintenance package contract and actual self-FK semantics
-- Connection/schema: TASKHUB_API
-- Preconditions: changes 0260 and 0270 applied
-- Expected result: all queries return zero rows

select 'MAINTENANCE_OBJECT_MISSING_OR_INVALID' as issue,
       e.object_type as detail
  from (
      select 'PACKAGE' object_type from dual union all
      select 'PACKAGE BODY' from dual
  ) e
 where not exists (
           select 1
             from user_objects o
            where o.object_name = 'PKG_TASKHUB_MAINT'
              and o.object_type = e.object_type
              and o.status = 'VALID'
       );

select 'MAINTENANCE_SIGNATURE_MISMATCH' as issue,
       'PURGE_DELETED' as detail
  from dual
 where not exists (
           select 1
             from user_procedures
            where object_name = 'PKG_TASKHUB_MAINT'
              and procedure_name = 'PURGE_DELETED'
       )
    or exists (
           select 1
             from user_arguments
            where package_name = 'PKG_TASKHUB_MAINT'
       );

select 'TASK_SELF_FK_NOT_IMMEDIATE_NO_ACTION' as issue,
       constraint_name as detail
  from all_constraints
 where owner = 'TASKHUB_OWNER'
   and constraint_name = 'TASKS_FK2'
   and (status <> 'ENABLED'
        or validated <> 'VALIDATED'
        or deferrable <> 'NOT DEFERRABLE'
        or delete_rule <> 'NO ACTION');

select 'MAINTENANCE_COMPILE_ERROR' as issue,
       type || ':' || line || ':' || position || ':' || text as detail
  from user_errors
 where name = 'PKG_TASKHUB_MAINT';
