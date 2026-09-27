-- Test: Task 50 positive hierarchy, lifecycle, priority, soft-delete and rollback behavior
-- Connection/schema: TASKHUB_API
-- Preconditions: changes 0240 and 0250 applied
-- Expected result: PASS; every created row is rolled back
-- Identity rule: clear and initialize TASKHUB_TEST_ALICE explicitly.

set serveroutput on
declare
    l_alice_id        number;
    l_list_id         number;
    l_root_id         number;
    l_level_2_id      number;
    l_level_3_id      number;
    l_done_id         number;
    l_completed_at    timestamp(6);
    l_completed_again timestamp(6);
    l_root_a          number;
    l_root_b          number;
    l_movable         number;
    l_movable_child   number;
    l_leaf_id         number;
    l_delete_root     number;
    l_delete_child    number;
    l_delete_grand    number;
    l_priority_3      number;
    l_priority_1      number;
    l_priority_2      number;
    l_priority_order  varchar2(100);
    l_count           number;

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
begin
    taskhub_api.pkg_taskhub_test_context.clear_context;
    taskhub_api.pkg_taskhub_test_context.init_for_test('TASKHUB_TEST_ALICE');
    select id into l_alice_id from taskhub_owner.app_users where username = 'TASKHUB_TEST_ALICE';

    l_list_id := taskhub_api.pkg_taskhub_api.create_list('TASK50_POSITIVE_LIST');
    l_root_id := taskhub_api.pkg_taskhub_api.create_task(
        p_todo_list_id => l_list_id,
        p_title        => '  TASK50_LEVEL_1  '
    );
    l_level_2_id := taskhub_api.pkg_taskhub_api.create_task(l_list_id, l_root_id, 'TASK50_LEVEL_2');
    l_level_3_id := taskhub_api.pkg_taskhub_api.create_task(l_list_id, l_level_2_id, 'TASK50_LEVEL_3');

    if l_root_id is null or l_level_2_id is null or l_level_3_id is null then
        raise_application_error(-20991, 'FAIL: CREATE_TASK returned NULL');
    end if;

    select count(*) into l_count
      from taskhub_owner.tasks t
      join taskhub_owner.todo_lists l on l.id = t.todo_list_id
     where t.id in (l_root_id, l_level_2_id, l_level_3_id)
       and l.app_user_id = l_alice_id
       and t.created_by_user_id = l_alice_id
       and t.created_at is not null
       and t.deleted_at is null;
    assert_count(l_count, 3, 'Levels 1-3 ownership and creation audit');

    select count(*) into l_count
      from taskhub_api.v_task_tree
     where (task_id = l_root_id and task_depth = 0)
        or (task_id = l_level_2_id and task_depth = 1)
        or (task_id = l_level_3_id and task_depth = 2);
    assert_count(l_count, 3, 'Levels 1-3 exposed as zero-based view depths 0-2');

    select count(*) into l_count
      from taskhub_owner.tasks
     where id = l_root_id
       and title = 'TASK50_LEVEL_1'
       and parent_task_id is null
       and status = 'OPEN'
       and priority = 2;
    assert_count(l_count, 1, 'CREATE_TASK defaults and trimmed title');

    taskhub_api.pkg_taskhub_api.update_task(
        l_root_id,
        null,
        'TASK50_UPDATED_TITLE',
        'TASK50 updated description',
        'IN_PROGRESS',
        1,
        timestamp '2030-01-02 03:04:05'
    );
    select count(*) into l_count
      from taskhub_owner.tasks
     where id = l_root_id
       and todo_list_id = l_list_id
       and title = 'TASK50_UPDATED_TITLE'
       and description = 'TASK50 updated description'
       and status = 'IN_PROGRESS'
       and priority = 1
       and due_at = timestamp '2030-01-02 03:04:05'
       and updated_at is not null
       and updated_by_user_id = l_alice_id;
    assert_count(l_count, 1, 'UPDATE_TASK mutable fields, immutable List and audit');

    l_done_id := taskhub_api.pkg_taskhub_api.create_task(
        l_list_id, null, 'TASK50_CREATED_DONE', null, 'DONE', 2, null
    );
    select completed_at into l_completed_at from taskhub_owner.tasks where id = l_done_id;
    if l_completed_at is null then
        raise_application_error(-20992, 'FAIL: task created DONE has no COMPLETED_AT');
    end if;

    taskhub_api.pkg_taskhub_api.update_task(l_done_id, null, 'TASK50_DONE_AGAIN', null, 'DONE', 2, null);
    select completed_at into l_completed_again from taskhub_owner.tasks where id = l_done_id;
    if l_completed_again <> l_completed_at then
        raise_application_error(-20993, 'FAIL: DONE to DONE changed COMPLETED_AT');
    end if;

    taskhub_api.pkg_taskhub_api.update_task(l_done_id, null, 'TASK50_REOPENED', null, 'OPEN', 2, null);
    select count(*) into l_count from taskhub_owner.tasks where id = l_done_id and completed_at is null;
    assert_count(l_count, 1, 'leaving DONE clears COMPLETED_AT');
    taskhub_api.pkg_taskhub_api.update_task(l_done_id, null, 'TASK50_DONE_LATER', null, 'DONE', 2, null);
    select count(*) into l_count from taskhub_owner.tasks where id = l_done_id and completed_at is not null;
    assert_count(l_count, 1, 'entering DONE sets COMPLETED_AT');

    l_root_a := taskhub_api.pkg_taskhub_api.create_task(l_list_id, null, 'TASK50_REPARENT_ROOT_A');
    l_root_b := taskhub_api.pkg_taskhub_api.create_task(l_list_id, null, 'TASK50_REPARENT_ROOT_B');
    l_movable := taskhub_api.pkg_taskhub_api.create_task(l_list_id, l_root_a, 'TASK50_REPARENT_MOVABLE');
    l_movable_child := taskhub_api.pkg_taskhub_api.create_task(l_list_id, l_movable, 'TASK50_REPARENT_CHILD');
    taskhub_api.pkg_taskhub_api.update_task(l_movable, l_root_b, 'TASK50_REPARENT_MOVABLE', null, 'OPEN', 2, null);
    select count(*) into l_count from taskhub_owner.tasks where id = l_movable and parent_task_id = l_root_b;
    assert_count(l_count, 1, 'valid same-List re-parent');
    taskhub_api.pkg_taskhub_api.update_task(l_movable, null, 'TASK50_REPARENT_MOVABLE', null, 'OPEN', 2, null);
    select count(*) into l_count from taskhub_owner.tasks where id = l_movable and parent_task_id is null;
    assert_count(l_count, 1, 'valid shallower re-parent');

    l_priority_3 := taskhub_api.pkg_taskhub_api.create_task(l_list_id, null, 'TASK50_PRIORITY_3', null, 'OPEN', 3, null);
    l_priority_1 := taskhub_api.pkg_taskhub_api.create_task(l_list_id, null, 'TASK50_PRIORITY_1', null, 'OPEN', 1, null);
    l_priority_2 := taskhub_api.pkg_taskhub_api.create_task(l_list_id, null, 'TASK50_PRIORITY_2', null, 'OPEN', 2, null);
    select listagg(priority, ',') within group (order by priority)
      into l_priority_order
      from taskhub_api.v_tasks
     where title like 'TASK50_PRIORITY_%';
    if l_priority_order <> '1,2,3' then
        raise_application_error(-20994, 'FAIL: priority order was ' || l_priority_order);
    end if;

    l_leaf_id := taskhub_api.pkg_taskhub_api.create_task(l_list_id, l_root_b, 'TASK50_DELETE_LEAF');
    taskhub_api.pkg_taskhub_api.delete_task(l_leaf_id);
    select count(*) into l_count
      from taskhub_owner.tasks
     where id = l_leaf_id
       and deleted_at is not null
       and deleted_by_user_id = l_alice_id;
    assert_count(l_count, 1, 'leaf soft delete audit');
    select count(*) into l_count from taskhub_api.v_tasks where id = l_leaf_id;
    assert_count(l_count, 0, 'deleted leaf hidden from V_TASKS');

    l_delete_root := taskhub_api.pkg_taskhub_api.create_task(l_list_id, null, 'TASK50_DELETE_ROOT', null, 'DONE', 2, null);
    l_delete_child := taskhub_api.pkg_taskhub_api.create_task(l_list_id, l_delete_root, 'TASK50_DELETE_CHILD');
    l_delete_grand := taskhub_api.pkg_taskhub_api.create_task(l_list_id, l_delete_child, 'TASK50_DELETE_GRAND');
    taskhub_api.pkg_taskhub_api.delete_task(l_delete_root);
    select count(*) into l_count
      from taskhub_owner.tasks
     where id in (l_delete_root, l_delete_child, l_delete_grand)
       and deleted_at is not null
       and deleted_by_user_id = l_alice_id;
    assert_count(l_count, 3, 'subtree soft delete audit');
    select count(distinct deleted_at) into l_count
      from taskhub_owner.tasks
     where id in (l_delete_root, l_delete_child, l_delete_grand);
    assert_count(l_count, 1, 'subtree uses one delete timestamp');
    select count(*) into l_count
      from taskhub_owner.tasks
     where id = l_delete_root and completed_at is not null;
    assert_count(l_count, 1, 'soft delete preserves historical COMPLETED_AT');
    select count(*) into l_count
      from taskhub_api.v_tasks
     where id in (l_delete_root, l_delete_child, l_delete_grand);
    assert_count(l_count, 0, 'deleted subtree hidden from V_TASKS');
    select count(*) into l_count
      from taskhub_api.v_task_tree
     where task_id in (l_delete_root, l_delete_child, l_delete_grand);
    assert_count(l_count, 0, 'deleted subtree hidden from V_TASK_TREE');

    rollback;
    select count(*) into l_count from taskhub_owner.todo_lists where id = l_list_id;
    assert_count(l_count, 0, 'caller rollback removes Task 50 positive data');
    taskhub_api.pkg_taskhub_test_context.clear_context;
    dbms_output.put_line('PASS: Task 50 positive hierarchy, lifecycle, priority, delete and rollback behavior');
exception
    when others then
        rollback;
        taskhub_api.pkg_taskhub_test_context.clear_context;
        raise;
end;
/
