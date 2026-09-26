-- Test: valid active application user initializes both context attributes
-- Connection/schema: TASKHUB_API
-- Preconditions: changes 0080 through 0120 applied
-- Expected result: PASS
-- Identity rule: clear context before initialization.

set serveroutput on
declare
    l_expected_id varchar2(4000 char);
begin
    taskhub_api.pkg_taskhub_test_context.clear_context;
    taskhub_api.pkg_taskhub_test_context.init_for_test('TASKHUB_TEST_ALICE');

    select to_char(id, 'TM9')
      into l_expected_id
      from taskhub_owner.app_users
     where username = 'TASKHUB_TEST_ALICE';

    if sys_context('TASKHUB_CTX', 'APP_USER_ID') <> l_expected_id
       or sys_context('TASKHUB_CTX', 'APP_USERNAME') <> 'TASKHUB_TEST_ALICE' then
        raise_application_error(-20990, 'FAIL: valid identity was not initialized correctly');
    end if;

    taskhub_api.pkg_taskhub_test_context.clear_context;
    dbms_output.put_line('PASS: valid active user');
end;
/
