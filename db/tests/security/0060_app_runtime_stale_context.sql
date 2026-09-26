-- Test: TASKHUB_APP runtime initialization fails closed outside APEX and retains no stale identity
-- Connection/schema: TASKHUB_APP outside an APEX request
-- Preconditions: changes 0080 through 0160 applied
-- Expected result: PASS

set serveroutput on
begin
    taskhub_api.pkg_taskhub_context.clear_context;
    begin
        taskhub_api.pkg_taskhub_context.init_from_apex;
        raise_application_error(-20990, 'FAIL: missing APEX identity was accepted');
    exception
        when others then
            if sqlcode <> -20001 then
                raise;
            end if;
    end;

    if sys_context('TASKHUB_CTX', 'APP_USER_ID') is not null
       or sys_context('TASKHUB_CTX', 'APP_USERNAME') is not null then
        raise_application_error(-20991, 'FAIL: runtime session retained identity');
    end if;
    dbms_output.put_line('PASS: runtime session fails closed without APEX identity');
end;
/
