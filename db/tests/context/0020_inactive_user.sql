-- Test: inactive application user is rejected and context remains empty
-- Connection/schema: TASKHUB_API
-- Preconditions: changes 0080 through 0120 applied
-- Expected result: PASS
-- Identity rule: start from a valid context to prove failure clears stale state.

set serveroutput on
declare
begin
    taskhub_api.pkg_taskhub_test_context.init_for_test('TASKHUB_TEST_ALICE');
    begin
        taskhub_api.pkg_taskhub_test_context.init_for_test('TASKHUB_TEST_INACTIVE');
        raise_application_error(-20990, 'FAIL: inactive user was accepted');
    exception
        when others then
            if sqlcode <> -20001 then
                raise;
            end if;
    end;

    if sys_context('TASKHUB_CTX', 'APP_USER_ID') is not null
       or sys_context('TASKHUB_CTX', 'APP_USERNAME') is not null then
        raise_application_error(-20991, 'FAIL: inactive-user failure left stale context');
    end if;
    dbms_output.put_line('PASS: inactive user rejected');
end;
/
