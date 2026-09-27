-- Test: Task 60 monthly Scheduler definition invokes only the maintenance API
-- Connection/schema: TASKHUB_API
-- Preconditions: change 0280 applied
-- Expected result: zero rows

select 'SCHEDULER_DEFINITION_MISMATCH' as issue,
       job_name as detail
  from user_scheduler_jobs
 where job_name = 'JOB_TASKHUB_PURGE_MONTHLY'
   and (job_type <> 'STORED_PROCEDURE'
        or job_action <> 'TASKHUB_API.PKG_TASKHUB_MAINT.PURGE_DELETED'
        or number_of_arguments <> 0
        or repeat_interval <> 'FREQ=MONTHLY;BYMONTHDAY=1;BYHOUR=2;BYMINUTE=0;BYSECOND=0'
        or enabled <> 'TRUE'
        or auto_drop <> 'FALSE')
union all
select 'SCHEDULER_JOB_MISSING', 'JOB_TASKHUB_PURGE_MONTHLY'
  from dual
 where not exists (
           select 1
             from user_scheduler_jobs
            where job_name = 'JOB_TASKHUB_PURGE_MONTHLY'
       );
