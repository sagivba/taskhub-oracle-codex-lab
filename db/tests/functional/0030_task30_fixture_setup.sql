-- Test fixture: bounded Task 30 read-isolation data
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: Task 20 test users exist and Task 30 views are deployed
-- Expected result: PASS; run 0050_task30_fixture_cleanup.sql after verification
-- Identity rule: this owner-only fixture never initializes or substitutes application context.
-- Transaction note: cross-schema visibility requires a committed fixture; cleanup removes every prefixed row and commits.

set serveroutput on
declare
    l_alice_id          number;
    l_bob_id            number;
    l_alice_list_id     number;
    l_alice_deleted_id  number;
    l_bob_list_id       number;
    l_alice_tag_id      number;
    l_alice_tag_del_id  number;
    l_bob_tag_id        number;
    l_root_id           number;
    l_depth_1_id        number;
    l_depth_2_id        number;
    l_depth_3_id        number;
begin
    select id into l_alice_id
      from taskhub_owner.app_users
     where username = 'TASKHUB_TEST_ALICE';

    select id into l_bob_id
      from taskhub_owner.app_users
     where username = 'TASKHUB_TEST_BOB';

    insert into taskhub_owner.todo_lists (
        app_user_id, list_name, created_by_user_id
    ) values (
        l_alice_id, 'TASK30_ALICE_ACTIVE', l_alice_id
    ) returning id into l_alice_list_id;

    insert into taskhub_owner.todo_lists (
        app_user_id, list_name, created_by_user_id, deleted_at, deleted_by_user_id
    ) values (
        l_alice_id, 'TASK30_ALICE_DELETED', l_alice_id, systimestamp, l_alice_id
    ) returning id into l_alice_deleted_id;

    insert into taskhub_owner.todo_lists (
        app_user_id, list_name, created_by_user_id
    ) values (
        l_bob_id, 'TASK30_BOB_ACTIVE', l_bob_id
    ) returning id into l_bob_list_id;

    insert into taskhub_owner.tags (
        app_user_id, tag_name, created_by_user_id
    ) values (
        l_alice_id, 'TASK30_ALICE_ACTIVE_TAG', l_alice_id
    ) returning id into l_alice_tag_id;

    insert into taskhub_owner.tags (
        app_user_id, tag_name, created_by_user_id, deleted_at, deleted_by_user_id
    ) values (
        l_alice_id, 'TASK30_ALICE_DELETED_TAG', l_alice_id, systimestamp, l_alice_id
    ) returning id into l_alice_tag_del_id;

    insert into taskhub_owner.tags (
        app_user_id, tag_name, created_by_user_id
    ) values (
        l_bob_id, 'TASK30_BOB_ACTIVE_TAG', l_bob_id
    ) returning id into l_bob_tag_id;

    insert into taskhub_owner.todo_list_tags (todo_list_id, tag_id)
    values (l_alice_list_id, l_alice_tag_id);

    insert into taskhub_owner.todo_list_tags (todo_list_id, tag_id)
    values (l_alice_deleted_id, l_alice_tag_id);

    insert into taskhub_owner.todo_list_tags (todo_list_id, tag_id)
    values (l_alice_list_id, l_alice_tag_del_id);

    insert into taskhub_owner.todo_list_tags (todo_list_id, tag_id)
    values (l_alice_list_id, l_bob_tag_id);

    insert into taskhub_owner.todo_list_tags (todo_list_id, tag_id)
    values (l_bob_list_id, l_bob_tag_id);

    insert into taskhub_owner.tasks (
        todo_list_id, title, status, priority, created_by_user_id
    ) values (
        l_alice_list_id, 'TASK30_ALICE_DEPTH_0', 'OPEN', 1, l_alice_id
    ) returning id into l_root_id;

    insert into taskhub_owner.tasks (
        todo_list_id, parent_task_id, title, status, priority, created_by_user_id
    ) values (
        l_alice_list_id, l_root_id, 'TASK30_ALICE_DEPTH_1', 'OPEN', 2, l_alice_id
    ) returning id into l_depth_1_id;

    insert into taskhub_owner.tasks (
        todo_list_id, parent_task_id, title, status, priority, created_by_user_id
    ) values (
        l_alice_list_id, l_depth_1_id, 'TASK30_ALICE_DEPTH_2', 'IN_PROGRESS', 2, l_alice_id
    ) returning id into l_depth_2_id;

    insert into taskhub_owner.tasks (
        todo_list_id, parent_task_id, title, status, priority, created_by_user_id
    ) values (
        l_alice_list_id, l_depth_2_id, 'TASK30_ALICE_DEPTH_3', 'OPEN', 3, l_alice_id
    ) returning id into l_depth_3_id;

    -- Task 30 only verifies that the read tree is capped; write-side level-4 prevention belongs to Task 50.
    insert into taskhub_owner.tasks (
        todo_list_id, parent_task_id, title, status, priority, created_by_user_id
    ) values (
        l_alice_list_id, l_depth_3_id, 'TASK30_ALICE_DEPTH_4_HIDDEN', 'OPEN', 3, l_alice_id
    );

    insert into taskhub_owner.tasks (
        todo_list_id, title, status, priority, created_by_user_id, deleted_at, deleted_by_user_id
    ) values (
        l_alice_list_id, 'TASK30_ALICE_SOFT_DELETED', 'OPEN', 1, l_alice_id, systimestamp, l_alice_id
    );

    insert into taskhub_owner.tasks (
        todo_list_id, title, status, priority, created_by_user_id
    ) values (
        l_alice_deleted_id, 'TASK30_UNDER_DELETED_LIST', 'OPEN', 1, l_alice_id
    );

    insert into taskhub_owner.tasks (
        todo_list_id, title, status, priority, created_by_user_id
    ) values (
        l_bob_list_id, 'TASK30_BOB_DEPTH_0', 'OPEN', 1, l_bob_id
    );

    commit;
    dbms_output.put_line('PASS: bounded Task 30 fixture created');
exception
    when others then
        rollback;
        raise;
end;
/
