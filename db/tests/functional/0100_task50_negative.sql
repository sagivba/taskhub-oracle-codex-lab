-- Test: Task 50 hierarchy, ownership, non-disclosure and input rejection
-- Connection/schema: TASKHUB_API
-- Preconditions: changes 0240 and 0250 applied
-- Expected result: PASS; every created row is rolled back
-- Identity rule: every Alice/Bob switch is explicit in the same session.

set serveroutput on
declare
    l_alice_list_1  number;
    l_alice_list_2  number;
    l_deleted_list  number;
    l_root           number;
    l_child          number;
    l_grand          number;
    l_tall_root      number;
    l_tall_child     number;
    l_tall_grand     number;
    l_other_root     number;
    l_deleted_task   number;
    l_bob_list       number;
    l_bob_task       number;
    l_code_1         number;
    l_code_2         number;
    l_code_3         number;
    l_message_1      varchar2(4000);
    l_message_2      varchar2(4000);
    l_message_3      varchar2(4000);
    l_count          number;

    procedure assert_code(p_actual in number, p_expected in number, p_label in varchar2) is
    begin
        if p_actual <> p_expected then
            raise_application_error(-20990, 'FAIL: ' || p_label || '; expected ' || p_expected || ', actual ' || nvl(to_char(p_actual), 'NULL'));
        end if;
    end;

    procedure assert_same_error(
        p_code_1 in number, p_message_1 in varchar2,
        p_code_2 in number, p_message_2 in varchar2,
        p_label in varchar2
    ) is
    begin
        if p_code_1 is null or p_code_1 <> p_code_2 or p_message_1 <> p_message_2 then
            raise_application_error(-20991, 'FAIL: non-disclosure mismatch for ' || p_label);
        end if;
    end;

    procedure capture_create(
        p_list_id in number, p_parent_id in number, p_status in varchar2, p_priority in pls_integer,
        p_code out number, p_message out varchar2
    ) is
        l_id number;
    begin
        p_code := null; p_message := null;
        begin
            l_id := taskhub_api.pkg_taskhub_api.create_task(p_list_id, p_parent_id, 'TASK50_NEGATIVE_PROBE', null, p_status, p_priority, null);
        exception when others then p_code := sqlcode; p_message := sqlerrm;
        end;
    end;

    procedure capture_update(
        p_task_id in number, p_parent_id in number, p_status in varchar2, p_priority in pls_integer,
        p_code out number, p_message out varchar2
    ) is
    begin
        p_code := null; p_message := null;
        begin
            taskhub_api.pkg_taskhub_api.update_task(p_task_id, p_parent_id, 'TASK50_NEGATIVE_PROBE', null, p_status, p_priority, null);
        exception when others then p_code := sqlcode; p_message := sqlerrm;
        end;
    end;

    procedure capture_delete(
        p_task_id in number, p_code out number, p_message out varchar2
    ) is
    begin
        p_code := null; p_message := null;
        begin
            taskhub_api.pkg_taskhub_api.delete_task(p_task_id);
        exception when others then p_code := sqlcode; p_message := sqlerrm;
        end;
    end;
begin
    taskhub_api.pkg_taskhub_test_context.clear_context;
    taskhub_api.pkg_taskhub_test_context.init_for_test('TASKHUB_TEST_ALICE');
    l_alice_list_1 := taskhub_api.pkg_taskhub_api.create_list('TASK50_NEG_ALICE_LIST_1');
    l_alice_list_2 := taskhub_api.pkg_taskhub_api.create_list('TASK50_NEG_ALICE_LIST_2');
    l_deleted_list := taskhub_api.pkg_taskhub_api.create_list('TASK50_NEG_DELETED_LIST');
    l_root := taskhub_api.pkg_taskhub_api.create_task(l_alice_list_1, null, 'TASK50_NEG_ROOT');
    l_child := taskhub_api.pkg_taskhub_api.create_task(l_alice_list_1, l_root, 'TASK50_NEG_CHILD');
    l_grand := taskhub_api.pkg_taskhub_api.create_task(l_alice_list_1, l_child, 'TASK50_NEG_GRAND');
    l_other_root := taskhub_api.pkg_taskhub_api.create_task(l_alice_list_2, null, 'TASK50_NEG_OTHER_LIST_ROOT');
    l_deleted_task := taskhub_api.pkg_taskhub_api.create_task(l_alice_list_1, null, 'TASK50_NEG_DELETED_TASK');
    taskhub_api.pkg_taskhub_api.delete_task(l_deleted_task);
    taskhub_api.pkg_taskhub_api.delete_list(l_deleted_list);

    l_tall_root := taskhub_api.pkg_taskhub_api.create_task(l_alice_list_1, null, 'TASK50_NEG_TALL_ROOT');
    l_tall_child := taskhub_api.pkg_taskhub_api.create_task(l_alice_list_1, l_tall_root, 'TASK50_NEG_TALL_CHILD');
    l_tall_grand := taskhub_api.pkg_taskhub_api.create_task(l_alice_list_1, l_tall_child, 'TASK50_NEG_TALL_GRAND');

    taskhub_api.pkg_taskhub_test_context.init_for_test('TASKHUB_TEST_BOB');
    l_bob_list := taskhub_api.pkg_taskhub_api.create_list('TASK50_NEG_BOB_LIST');
    l_bob_task := taskhub_api.pkg_taskhub_api.create_task(l_bob_list, null, 'TASK50_NEG_BOB_TASK');
    taskhub_api.pkg_taskhub_test_context.init_for_test('TASKHUB_TEST_ALICE');

    capture_create(l_alice_list_1, l_grand, 'OPEN', 2, l_code_1, l_message_1);
    assert_code(l_code_1, -20011, 'Level 4 creation rejected');

    capture_update(l_tall_root, l_root, 'OPEN', 2, l_code_1, l_message_1);
    assert_code(l_code_1, -20011, 'Level 4 re-parent rejected');
    select count(*) into l_count from taskhub_owner.tasks where id = l_tall_root and parent_task_id is null;
    if l_count <> 1 then raise_application_error(-20992, 'FAIL: rejected re-parent changed hierarchy'); end if;

    capture_create(l_alice_list_1, l_other_root, 'OPEN', 2, l_code_1, l_message_1);
    assert_code(l_code_1, -20010, 'same-user parent in another List rejected');

    capture_create(l_alice_list_1, -505050, 'OPEN', 2, l_code_1, l_message_1);
    capture_create(l_alice_list_1, l_bob_task, 'OPEN', 2, l_code_2, l_message_2);
    capture_create(l_alice_list_1, l_deleted_task, 'OPEN', 2, l_code_3, l_message_3);
    assert_same_error(l_code_1, l_message_1, l_code_2, l_message_2, 'missing versus foreign parent');
    assert_same_error(l_code_1, l_message_1, l_code_3, l_message_3, 'missing versus deleted parent');
    assert_code(l_code_1, -20009, 'generic inaccessible parent code');

    capture_update(l_root, l_root, 'OPEN', 2, l_code_1, l_message_1);
    assert_code(l_code_1, -20011, 'self-parent rejected');
    capture_update(l_root, l_child, 'OPEN', 2, l_code_1, l_message_1);
    assert_code(l_code_1, -20011, 'descendant-as-parent cycle rejected');
    capture_update(l_child, l_grand, 'OPEN', 2, l_code_1, l_message_1);
    assert_code(l_code_1, -20011, 'deep cycle rejected');

    capture_update(-505050, null, 'OPEN', 2, l_code_1, l_message_1);
    capture_update(l_bob_task, null, 'OPEN', 2, l_code_2, l_message_2);
    capture_update(l_deleted_task, null, 'OPEN', 2, l_code_3, l_message_3);
    assert_same_error(l_code_1, l_message_1, l_code_2, l_message_2, 'UPDATE_TASK missing versus foreign');
    assert_same_error(l_code_1, l_message_1, l_code_3, l_message_3, 'UPDATE_TASK missing versus deleted');
    assert_code(l_code_1, -20008, 'generic inaccessible update code');

    capture_delete(-505050, l_code_1, l_message_1);
    capture_delete(l_bob_task, l_code_2, l_message_2);
    capture_delete(l_deleted_task, l_code_3, l_message_3);
    assert_same_error(l_code_1, l_message_1, l_code_2, l_message_2, 'DELETE_TASK missing versus foreign');
    assert_same_error(l_code_1, l_message_1, l_code_3, l_message_3, 'DELETE_TASK missing versus deleted');
    assert_code(l_code_1, -20008, 'generic inaccessible delete code');

    capture_create(l_deleted_list, null, 'OPEN', 2, l_code_1, l_message_1);
    assert_code(l_code_1, -20004, 'deleted List rejects new Task');
    capture_create(l_alice_list_1, null, 'INVALID', 2, l_code_1, l_message_1);
    assert_code(l_code_1, -20007, 'invalid status rejected');
    capture_create(l_alice_list_1, null, 'OPEN', 4, l_code_1, l_message_1);
    assert_code(l_code_1, -20007, 'invalid priority rejected');
    capture_update(l_root, null, 'INVALID', 2, l_code_1, l_message_1);
    assert_code(l_code_1, -20007, 'invalid update status rejected');
    capture_update(l_root, null, 'OPEN', 0, l_code_1, l_message_1);
    assert_code(l_code_1, -20007, 'invalid update priority rejected');

    select count(*) into l_count from taskhub_owner.tasks where id = l_bob_task and deleted_at is null;
    if l_count <> 1 then raise_application_error(-20993, 'FAIL: Alice affected Bob Task'); end if;

    rollback;
    select count(*) into l_count from taskhub_owner.todo_lists where id in (l_alice_list_1, l_bob_list);
    if l_count <> 0 then raise_application_error(-20994, 'FAIL: caller rollback left negative-test data'); end if;
    taskhub_api.pkg_taskhub_test_context.clear_context;
    dbms_output.put_line('PASS: Task 50 negative hierarchy, ownership, non-disclosure and input behavior');
exception
    when others then
        rollback;
        taskhub_api.pkg_taskhub_test_context.clear_context;
        raise;
end;
/
