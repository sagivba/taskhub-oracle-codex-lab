begin
    begin
        dbms_scheduler.drop_job(
            job_name => 'TASKHUB_API.JOB_TASKHUB_PURGE_MONTHLY',
            force    => true
        );
    exception
        when others then
            if sqlcode <> -27475 then
                raise;
            end if;
    end;

    dbms_scheduler.create_job(
        job_name            => 'TASKHUB_API.JOB_TASKHUB_PURGE_MONTHLY',
        job_type            => 'STORED_PROCEDURE',
        job_action          => 'TASKHUB_API.PKG_TASKHUB_MAINT.PURGE_DELETED',
        number_of_arguments => 0,
        start_date          => systimestamp,
        repeat_interval     => 'FREQ=MONTHLY;BYMONTHDAY=1;BYHOUR=2;BYMINUTE=0;BYSECOND=0',
        enabled             => false,
        auto_drop           => false,
        comments            => 'Purges TaskHub soft-deleted data after the canonical 30-day retention period.'
    );

    dbms_scheduler.enable('TASKHUB_API.JOB_TASKHUB_PURGE_MONTHLY');
end;
/
