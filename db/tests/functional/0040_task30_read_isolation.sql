-- Test: Alice/Bob isolation, soft-delete filtering, cross-owner association defense and task-tree depth
-- Connection/schema: TASKHUB_API
-- Preconditions: 0030_task30_fixture_setup.sql completed
-- Expected result: PASS; then run 0050_task30_fixture_cleanup.sql as TASKHUB_OWNER
-- Identity rule: clear context before initialization and explicitly reinitialize Alice to Bob in this session.

set serveroutput on
declare
    l_count number;

    procedure assert_count(
        p_sql      in varchar2,
        p_expected in number,
        p_label    in varchar2
    ) is
    begin
        execute immediate p_sql into l_count;
        if l_count <> p_expected then
            raise_application_error(
                -20990,
                'FAIL: ' || p_label || '; expected ' || p_expected || ', actual ' || l_count
            );
        end if;
    end assert_count;
begin
    taskhub_api.pkg_taskhub_test_context.clear_context;
    taskhub_api.pkg_taskhub_test_context.init_for_test('TASKHUB_TEST_ALICE');

    assert_count(q'[select count(*) from taskhub_api.v_todo_lists where list_name = 'TASK30_ALICE_ACTIVE']', 1, 'Alice active list visible');
    assert_count(q'[select count(*) from taskhub_api.v_todo_lists where list_name like 'TASK30_BOB%']', 0, 'Bob list hidden from Alice');
    assert_count(q'[select count(*) from taskhub_api.v_todo_lists where list_name = 'TASK30_ALICE_DELETED']', 0, 'soft-deleted list hidden');

    assert_count(q'[select count(*) from taskhub_api.v_tasks where title like 'TASK30_ALICE_DEPTH_%']', 5, 'Alice active tasks visible');
    assert_count(q'[select count(*) from taskhub_api.v_tasks where title = 'TASK30_ALICE_SOFT_DELETED']', 0, 'soft-deleted task hidden');
    assert_count(q'[select count(*) from taskhub_api.v_tasks where title = 'TASK30_UNDER_DELETED_LIST']', 0, 'task under soft-deleted list hidden');
    assert_count(q'[select count(*) from taskhub_api.v_tasks where title like 'TASK30_BOB%']', 0, 'Bob tasks hidden from Alice');

    assert_count(q'[select count(*) from taskhub_api.v_todo_list_tags a join taskhub_owner.tags t on t.id = a.tag_id where t.tag_name = 'TASK30_ALICE_ACTIVE_TAG']', 1, 'active same-owner association visible');
    assert_count(q'[select count(*) from taskhub_api.v_todo_list_tags a join taskhub_owner.todo_lists l on l.id = a.todo_list_id where l.list_name = 'TASK30_ALICE_DELETED']', 0, 'association under soft-deleted list hidden');
    assert_count(q'[select count(*) from taskhub_api.v_todo_list_tags a join taskhub_owner.tags t on t.id = a.tag_id where t.tag_name = 'TASK30_ALICE_DELETED_TAG']', 0, 'association to soft-deleted tag hidden');
    assert_count(q'[select count(*) from taskhub_api.v_todo_list_tags a join taskhub_owner.tags t on t.id = a.tag_id where t.tag_name = 'TASK30_BOB_ACTIVE_TAG']', 0, 'cross-owner association hidden');

    assert_count(q'[select count(*) from taskhub_api.v_task_tree where title like 'TASK30_ALICE_DEPTH_%']', 4, 'tree exposes only Alice depth 0 through 3');
    assert_count(q'[select count(*) from taskhub_api.v_task_tree where title like 'TASK30_BOB%']', 0, 'tree hides Bob tasks from Alice');
    assert_count(q'[select count(*) from taskhub_api.v_task_tree where task_depth < 0 or task_depth > 3]', 0, 'tree depth remains 0 through 3');
    assert_count(q'[select count(*) from taskhub_api.v_task_tree where title = 'TASK30_ALICE_DEPTH_4_HIDDEN']', 0, 'tree caps level 4 without adding write rules');

    -- Reinitialize in the same database session to prove no Alice rows survive the identity switch.
    taskhub_api.pkg_taskhub_test_context.init_for_test('TASKHUB_TEST_BOB');
    assert_count(q'[select count(*) from taskhub_api.v_todo_lists where list_name like 'TASK30_ALICE%']', 0, 'Alice lists hidden after Alice-to-Bob reinitialization');
    assert_count(q'[select count(*) from taskhub_api.v_todo_lists where list_name = 'TASK30_BOB_ACTIVE']', 1, 'Bob list visible');
    assert_count(q'[select count(*) from taskhub_api.v_tasks where title like 'TASK30_ALICE%']', 0, 'Alice tasks hidden from Bob');
    assert_count(q'[select count(*) from taskhub_api.v_tasks where title = 'TASK30_BOB_DEPTH_0']', 1, 'Bob task visible');
    assert_count(q'[select count(*) from taskhub_api.v_todo_list_tags a join taskhub_owner.tags t on t.id = a.tag_id where t.tag_name = 'TASK30_BOB_ACTIVE_TAG']', 1, 'Bob same-owner association visible');
    assert_count(q'[select count(*) from taskhub_api.v_task_tree where title = 'TASK30_BOB_DEPTH_0']', 1, 'Bob tree task visible');
    assert_count(q'[select count(*) from taskhub_api.v_task_tree where title like 'TASK30_ALICE%']', 0, 'Alice tree tasks hidden from Bob');

    taskhub_api.pkg_taskhub_test_context.clear_context;
    dbms_output.put_line('PASS: Task 30 user isolation, soft delete, association defense and tree depth');
exception
    when others then
        taskhub_api.pkg_taskhub_test_context.clear_context;
        raise;
end;
/
