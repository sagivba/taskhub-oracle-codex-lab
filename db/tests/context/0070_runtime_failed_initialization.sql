-- Test: runtime initialization without an APEX identity fails closed
-- Connection/schema: TASKHUB_API outside an APEX request
-- Preconditions: changes 0080 through 0120 applied
-- Expected result: PASS
-- Identity rule: begin with a valid test identity to prove runtime failure clears it.

set serveroutput on
begin
    taskhub_api.pkg_taskhub_test_context.init_for_test('TASKHUB_TEST_ALICE');
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
        raise_application_error(-20991, 'FAIL: runtime failure left stale identity');
    end if;
    dbms_output.put_line('PASS: runtime initialization fails closed without APEX identity');
end;
/
