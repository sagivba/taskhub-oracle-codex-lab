-- Test: Task 40 List/Tag behavior, isolation, non-disclosure, filtered reads and caller rollback
-- Connection/schema: TASKHUB_API
-- Preconditions: 0060_task40_fixture_setup.sql and changes 0220 through 0230 completed
-- Expected result: PASS; all API-created data and fixture mutations are rolled back
-- Identity rule: clear and initialize explicitly before every Alice/Bob identity switch.

set serveroutput on
declare
    l_alice_id           number;
    l_bob_id             number;
    l_fixture_alice_list number;
    l_fixture_bob_list   number;
    l_created_list       number;
    l_deleted_list       number;
    l_alice_list_1       number;
    l_alice_list_2       number;
    l_work_tag_old       number;
    l_work_tag_new       number;
    l_deleted_list_tag   number;
    l_alice_shared_tag   number;
    l_bob_shared_tag     number;
    l_count              number;
    l_code_1             number;
    l_code_2             number;
    l_code_3             number;
    l_message_1          varchar2(4000);
    l_message_2          varchar2(4000);
    l_message_3          varchar2(4000);

    procedure assert_count(
        p_actual   in number,
        p_expected in number,
        p_label    in varchar2
    ) is
    begin
        if p_actual <> p_expected then
            raise_application_error(-20990, 'FAIL: ' || p_label || '; expected ' || p_expected || ', actual ' || p_actual);
        end if;
    end assert_count;

    procedure assert_same_error(
        p_code_1    in number,
        p_message_1 in varchar2,
        p_code_2    in number,
        p_message_2 in varchar2,
        p_label     in varchar2
    ) is
    begin
        if p_code_1 is null or p_code_1 <> p_code_2 or p_message_1 <> p_message_2 then
            raise_application_error(-20991, 'FAIL: non-disclosure mismatch for ' || p_label);
        end if;
    end assert_same_error;

    procedure capture_update_list(
        p_list_id in number,
        p_code    out number,
        p_message out varchar2
    ) is
    begin
        p_code := null;
        p_message := null;
        begin
            taskhub_api.pkg_taskhub_api.update_list(p_list_id, 'TASK40_PROBE');
        exception when others then p_code := sqlcode; p_message := sqlerrm;
        end;
    end capture_update_list;

    procedure capture_delete_list(
        p_list_id in number,
        p_code    out number,
        p_message out varchar2
    ) is
    begin
        p_code := null;
        p_message := null;
        begin
            taskhub_api.pkg_taskhub_api.delete_list(p_list_id);
        exception when others then p_code := sqlcode; p_message := sqlerrm;
        end;
    end capture_delete_list;

    procedure capture_add_tag(
        p_list_id in number,
        p_code    out number,
        p_message out varchar2
    ) is
    begin
        p_code := null;
        p_message := null;
        begin
            taskhub_api.pkg_taskhub_api.add_tag_to_list(p_list_id, 'TASK40_CROSS_LIST');
        exception when others then p_code := sqlcode; p_message := sqlerrm;
        end;
    end capture_add_tag;

    procedure capture_remove_tag(
        p_list_id  in number,
        p_tag_name in varchar2,
        p_code     out number,
        p_message  out varchar2
    ) is
    begin
        p_code := null;
        p_message := null;
        begin
            taskhub_api.pkg_taskhub_api.remove_tag_from_list(p_list_id, p_tag_name);
        exception when others then p_code := sqlcode; p_message := sqlerrm;
        end;
    end capture_remove_tag;

    procedure capture_delete_tag(
        p_tag_name in varchar2,
        p_code     out number,
        p_message  out varchar2
    ) is
    begin
        p_code := null;
        p_message := null;
        begin
            taskhub_api.pkg_taskhub_api.delete_tag(p_tag_name);
        exception when others then p_code := sqlcode; p_message := sqlerrm;
        end;
    end capture_delete_tag;
begin
    select id into l_alice_id from taskhub_owner.app_users where username = 'TASKHUB_TEST_ALICE';
    select id into l_bob_id from taskhub_owner.app_users where username = 'TASKHUB_TEST_BOB';
    select id into l_fixture_alice_list from taskhub_owner.todo_lists where list_name = 'TASK40_FIX_ALICE_LIST';
    select id into l_fixture_bob_list from taskhub_owner.todo_lists where list_name = 'TASK40_FIX_BOB_LIST';

    taskhub_api.pkg_taskhub_test_context.clear_context;
    taskhub_api.pkg_taskhub_test_context.init_for_test('TASKHUB_TEST_ALICE');

    l_created_list := taskhub_api.pkg_taskhub_api.create_list('  TASK40_CREATED_LIST  ');
    select count(*) into l_count
      from taskhub_owner.todo_lists
     where id = l_created_list
       and app_user_id = l_alice_id
       and list_name = 'TASK40_CREATED_LIST'
       and created_by_user_id = l_alice_id
       and deleted_at is null;
    assert_count(l_count, 1, 'CREATE_LIST context ownership, trim and audit');

    taskhub_api.pkg_taskhub_api.update_list(l_created_list, '  TASK40_UPDATED_LIST  ');
    select count(*) into l_count
      from taskhub_owner.todo_lists
     where id = l_created_list
       and app_user_id = l_alice_id
       and list_name = 'TASK40_UPDATED_LIST'
       and created_by_user_id = l_alice_id
       and updated_at is not null
       and updated_by_user_id = l_alice_id;
    assert_count(l_count, 1, 'UPDATE_LIST preserves owner/creator and derives updater');

    l_deleted_list := taskhub_api.pkg_taskhub_api.create_list('TASK40_DELETED_LIST');
    taskhub_api.pkg_taskhub_api.delete_list(l_deleted_list);

    capture_update_list(-404040, l_code_1, l_message_1);
    capture_update_list(l_fixture_bob_list, l_code_2, l_message_2);
    capture_update_list(l_deleted_list, l_code_3, l_message_3);
    assert_same_error(l_code_1, l_message_1, l_code_2, l_message_2, 'UPDATE_LIST missing versus foreign');
    assert_same_error(l_code_1, l_message_1, l_code_3, l_message_3, 'UPDATE_LIST missing versus deleted');
    assert_count(case when l_code_1 = -20004 then 1 else 0 end, 1, 'UPDATE_LIST generic inaccessible code');

    capture_delete_list(-404040, l_code_1, l_message_1);
    capture_delete_list(l_fixture_bob_list, l_code_2, l_message_2);
    capture_delete_list(l_deleted_list, l_code_3, l_message_3);
    assert_same_error(l_code_1, l_message_1, l_code_2, l_message_2, 'DELETE_LIST missing versus foreign');
    assert_same_error(l_code_1, l_message_1, l_code_3, l_message_3, 'DELETE_LIST missing versus deleted');
    assert_count(case when l_code_1 = -20004 then 1 else 0 end, 1, 'DELETE_LIST generic inaccessible code');

    taskhub_api.pkg_taskhub_api.add_tag_to_list(l_fixture_alice_list, 'TASK40_LIST_DELETE_TAG');
    select id into l_deleted_list_tag
      from taskhub_owner.tags
     where app_user_id = l_alice_id
       and deleted_at is null
       and upper(trim(tag_name)) = 'TASK40_LIST_DELETE_TAG';
    taskhub_api.pkg_taskhub_api.delete_list(l_fixture_alice_list);
    select count(*) into l_count
      from taskhub_owner.todo_lists
     where id = l_fixture_alice_list
       and deleted_at is not null
       and deleted_by_user_id = l_alice_id;
    assert_count(l_count, 1, 'DELETE_LIST soft-deletes owned List');
    select count(*) into l_count
      from taskhub_owner.tasks
     where todo_list_id = l_fixture_alice_list
       and deleted_at is not null
       and deleted_by_user_id = l_alice_id;
    assert_count(l_count, 1, 'DELETE_LIST soft-deletes active Tasks');
    select count(*) into l_count
      from taskhub_owner.todo_list_tags
     where todo_list_id = l_fixture_alice_list
       and tag_id = l_deleted_list_tag;
    assert_count(l_count, 1, 'DELETE_LIST retains physical association');
    select count(*) into l_count
      from taskhub_api.v_todo_list_tags
     where todo_list_id = l_fixture_alice_list
       and tag_id = l_deleted_list_tag;
    assert_count(l_count, 0, 'filtered read hides association under deleted List');
    select count(*) into l_count
      from taskhub_owner.todo_lists
     where id = l_fixture_bob_list and deleted_at is null;
    assert_count(l_count, 1, 'foreign List remains active');

    l_alice_list_1 := taskhub_api.pkg_taskhub_api.create_list('TASK40_TAG_LIST_1');
    l_alice_list_2 := taskhub_api.pkg_taskhub_api.create_list('TASK40_TAG_LIST_2');
    taskhub_api.pkg_taskhub_api.add_tag_to_list(l_alice_list_1, ' Work ');
    taskhub_api.pkg_taskhub_api.add_tag_to_list(l_alice_list_1, 'work');
    taskhub_api.pkg_taskhub_api.add_tag_to_list(l_alice_list_2, 'WORK');

    select min(id), count(*) into l_work_tag_old, l_count
      from taskhub_owner.tags
     where app_user_id = l_alice_id
       and deleted_at is null
       and upper(trim(tag_name)) = 'WORK';
    assert_count(l_count, 1, 'normalized Tag identity creates one active Tag');
    select count(*) into l_count
      from taskhub_owner.todo_list_tags
     where tag_id = l_work_tag_old
       and todo_list_id in (l_alice_list_1, l_alice_list_2);
    assert_count(l_count, 2, 'Tag reused across Lists and duplicate association is no-op');

    taskhub_api.pkg_taskhub_api.remove_tag_from_list(l_alice_list_1, ' WORK ');
    taskhub_api.pkg_taskhub_api.remove_tag_from_list(l_alice_list_1, 'work');
    select count(*) into l_count from taskhub_owner.todo_list_tags where tag_id = l_work_tag_old;
    assert_count(l_count, 1, 'association removal and repeated removal are idempotent');

    taskhub_api.pkg_taskhub_api.delete_tag(' work ');
    select count(*) into l_count
      from taskhub_owner.tags
     where id = l_work_tag_old
       and deleted_at is not null
       and deleted_by_user_id = l_alice_id;
    assert_count(l_count, 1, 'DELETE_TAG soft-deletes Tag with context audit');
    select count(*) into l_count from taskhub_owner.todo_list_tags where tag_id = l_work_tag_old;
    assert_count(l_count, 0, 'DELETE_TAG physically removes associations');
    select count(*) into l_count from taskhub_api.v_todo_list_tags where tag_id = l_work_tag_old;
    assert_count(l_count, 0, 'soft-deleted Tag absent from filtered reads');

    taskhub_api.pkg_taskhub_api.add_tag_to_list(l_alice_list_1, ' WORK ');
    select id into l_work_tag_new
      from taskhub_owner.tags
     where app_user_id = l_alice_id
       and deleted_at is null
       and upper(trim(tag_name)) = 'WORK';
    if l_work_tag_new = l_work_tag_old then
        raise_application_error(-20992, 'FAIL: recreated Tag reused deleted row ID');
    end if;

    taskhub_api.pkg_taskhub_test_context.init_for_test('TASKHUB_TEST_BOB');
    taskhub_api.pkg_taskhub_api.add_tag_to_list(l_fixture_bob_list, 'Shared');
    taskhub_api.pkg_taskhub_api.add_tag_to_list(l_fixture_bob_list, 'TASK40_BOB_ONLY');
    select id into l_bob_shared_tag
      from taskhub_owner.tags
     where app_user_id = l_bob_id and deleted_at is null and upper(trim(tag_name)) = 'SHARED';

    taskhub_api.pkg_taskhub_test_context.init_for_test('TASKHUB_TEST_ALICE');
    taskhub_api.pkg_taskhub_api.add_tag_to_list(l_alice_list_1, ' shared ');
    select id into l_alice_shared_tag
      from taskhub_owner.tags
     where app_user_id = l_alice_id and deleted_at is null and upper(trim(tag_name)) = 'SHARED';
    if l_alice_shared_tag = l_bob_shared_tag then
        raise_application_error(-20993, 'FAIL: Alice reused Bob Tag');
    end if;

    capture_add_tag(l_fixture_bob_list, l_code_1, l_message_1);
    assert_count(case when l_code_1 = -20004 then 1 else 0 end, 1, 'Alice cannot associate with Bob List');

    taskhub_api.pkg_taskhub_api.add_tag_to_list(l_alice_list_1, 'TASK40_TAG_HISTORY');
    taskhub_api.pkg_taskhub_api.delete_tag('TASK40_TAG_HISTORY');
    capture_delete_tag('TASK40_TAG_HISTORY', l_code_1, l_message_1);
    capture_delete_tag('TASK40_NEVER_EXISTS', l_code_2, l_message_2);
    capture_delete_tag('TASK40_BOB_ONLY', l_code_3, l_message_3);
    assert_same_error(l_code_1, l_message_1, l_code_2, l_message_2, 'DELETE_TAG inactive versus missing');
    assert_same_error(l_code_1, l_message_1, l_code_3, l_message_3, 'DELETE_TAG inactive versus foreign');
    assert_count(case when l_code_1 = -20006 then 1 else 0 end, 1, 'DELETE_TAG generic inaccessible code');

    capture_remove_tag(l_alice_list_1, 'TASK40_NEVER_EXISTS', l_code_1, l_message_1);
    capture_remove_tag(l_alice_list_1, 'TASK40_BOB_ONLY', l_code_2, l_message_2);
    assert_same_error(l_code_1, l_message_1, l_code_2, l_message_2, 'REMOVE_TAG missing versus foreign');

    select count(*) into l_count
      from taskhub_owner.tags
     where app_user_id = l_bob_id
       and deleted_at is null
       and upper(trim(tag_name)) = 'TASK40_BOB_ONLY';
    assert_count(l_count, 1, 'Alice cannot affect Bob Tag through DELETE_TAG');

    rollback;

    select count(*) into l_count from taskhub_owner.todo_lists where id = l_created_list;
    assert_count(l_count, 0, 'caller rollback removes API-created List');
    select count(*) into l_count
      from taskhub_owner.todo_lists
     where id = l_fixture_alice_list and deleted_at is null;
    assert_count(l_count, 1, 'caller rollback restores fixture List');
    select count(*) into l_count
      from taskhub_owner.tasks
     where todo_list_id = l_fixture_alice_list and deleted_at is null;
    assert_count(l_count, 1, 'caller rollback restores cascaded Task mutation');

    taskhub_api.pkg_taskhub_test_context.clear_context;
    dbms_output.put_line('PASS: Task 40 List/Tag behavior, isolation, non-disclosure and caller rollback');
exception
    when others then
        rollback;
        taskhub_api.pkg_taskhub_test_context.clear_context;
        raise;
end;
/
