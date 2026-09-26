-- Test: the same session can be deterministically reinitialized from user A to user B
-- Connection/schema: TASKHUB_API
-- Preconditions: changes 0080 through 0120 applied
-- Expected result: PASS
-- Identity rule: clear first and initialize both identities in this flow.

set serveroutput on
begin
    taskhub_api.pkg_taskhub_test_context.clear_context;
    taskhub_api.pkg_taskhub_test_context.init_for_test('TASKHUB_TEST_ALICE');
    taskhub_api.pkg_taskhub_test_context.init_for_test('TASKHUB_TEST_BOB');

    if sys_context('TASKHUB_CTX', 'APP_USERNAME') <> 'TASKHUB_TEST_BOB' then
        raise_application_error(-20990, 'FAIL: user A survived reinitialization to user B');
    end if;

    taskhub_api.pkg_taskhub_test_context.clear_context;
    dbms_output.put_line('PASS: user A to user B reinitialization');
end;
/
