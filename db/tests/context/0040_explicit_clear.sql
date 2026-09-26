-- Test: explicit clear removes all TaskHub context attributes
-- Connection/schema: TASKHUB_API
-- Preconditions: changes 0080 through 0120 applied
-- Expected result: PASS
-- Identity rule: initialize explicitly, then clear.

set serveroutput on
begin
    taskhub_api.pkg_taskhub_test_context.init_for_test('TASKHUB_TEST_ALICE');
    taskhub_api.pkg_taskhub_test_context.clear_context;

    if sys_context('TASKHUB_CTX', 'APP_USER_ID') is not null
       or sys_context('TASKHUB_CTX', 'APP_USERNAME') is not null then
        raise_application_error(-20990, 'FAIL: clear left context attributes');
    end if;
    dbms_output.put_line('PASS: explicit clear');
end;
/
