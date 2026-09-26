-- Test: failed initialization after a valid identity leaves no stale identity
-- Connection/schema: TASKHUB_API
-- Preconditions: changes 0080 through 0120 applied
-- Expected result: PASS
-- Identity rule: initialize a valid identity, then deliberately fail in the same session.

set serveroutput on
begin
    taskhub_api.pkg_taskhub_test_context.init_for_test('TASKHUB_TEST_BOB');
    begin
        taskhub_api.pkg_taskhub_test_context.init_for_test('TASKHUB_TEST_UNKNOWN');
        raise_application_error(-20990, 'FAIL: invalid identity was accepted');
    exception
        when others then
            if sqlcode <> -20001 then
                raise;
            end if;
    end;

    if sys_context('TASKHUB_CTX', 'APP_USER_ID') is not null
       or sys_context('TASKHUB_CTX', 'APP_USERNAME') is not null then
        raise_application_error(-20991, 'FAIL: stale valid identity survived failed initialization');
    end if;
    dbms_output.put_line('PASS: failed reinitialization clears identity');
end;
/
