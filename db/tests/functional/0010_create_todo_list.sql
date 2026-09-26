-- Test: valid context creates a TODO list and returns its identifier
-- Connection/schema: TASKHUB_API
-- Preconditions: changes 0080 through 0160 applied
-- Expected result: PASS; transaction is rolled back after ownership/audit verification
-- Identity rule: clear and initialize TASKHUB_TEST_ALICE explicitly.

set serveroutput on
declare
    l_list_id number;
    l_count   number;
begin
    taskhub_api.pkg_taskhub_test_context.clear_context;
    taskhub_api.pkg_taskhub_test_context.init_for_test('TASKHUB_TEST_ALICE');
    l_list_id := taskhub_api.pkg_taskhub_api.create_list('TASK20_CREATE_LIST_TEST');

    if l_list_id is null then
        raise_application_error(-20990, 'FAIL: CREATE_LIST returned NULL');
    end if;

    select count(*)
      into l_count
      from taskhub_owner.todo_lists l
      join taskhub_owner.app_users u
        on u.id = l.app_user_id
     where l.id = l_list_id
       and l.list_name = 'TASK20_CREATE_LIST_TEST'
       and u.username = 'TASKHUB_TEST_ALICE'
       and l.created_by_user_id = l.app_user_id
       and l.updated_at is null
       and l.updated_by_user_id is null
       and l.deleted_at is null
       and l.deleted_by_user_id is null;

    if l_count <> 1 then
        raise_application_error(-20991, 'FAIL: created list ownership/audit values are incorrect');
    end if;

    rollback;
    taskhub_api.pkg_taskhub_test_context.clear_context;
    dbms_output.put_line('PASS: CREATE_LIST ownership and audit values; ID ' || l_list_id);
end;
/
