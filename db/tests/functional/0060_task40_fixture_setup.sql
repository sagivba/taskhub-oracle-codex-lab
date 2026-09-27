-- Test fixture: bounded Task 40 List-delete cascade data
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: Task 20 test users exist and no TASK40-prefixed rows remain
-- Expected result: PASS; run 0080_task40_fixture_cleanup.sql after verification
-- Transaction note: cross-schema visibility requires committed setup and FK-safe committed cleanup.

set serveroutput on
declare
    l_alice_id      number;
    l_bob_id        number;
    l_alice_list_id number;
    l_bob_list_id   number;
    l_count         number;
begin
    select (select count(*) from taskhub_owner.todo_lists where list_name like 'TASK40\_%' escape '\')
         + (select count(*) from taskhub_owner.tags where tag_name like 'TASK40\_%' escape '\')
         + (select count(*) from taskhub_owner.tasks where title like 'TASK40\_%' escape '\')
      into l_count
      from dual;

    if l_count <> 0 then
        raise_application_error(-20990, 'FAIL: stale TASK40 fixture rows exist before setup');
    end if;

    select id into l_alice_id from taskhub_owner.app_users where username = 'TASKHUB_TEST_ALICE';
    select id into l_bob_id from taskhub_owner.app_users where username = 'TASKHUB_TEST_BOB';

    insert into taskhub_owner.todo_lists (app_user_id, list_name, created_by_user_id)
    values (l_alice_id, 'TASK40_FIX_ALICE_LIST', l_alice_id)
    returning id into l_alice_list_id;

    insert into taskhub_owner.todo_lists (app_user_id, list_name, created_by_user_id)
    values (l_bob_id, 'TASK40_FIX_BOB_LIST', l_bob_id)
    returning id into l_bob_list_id;

    insert into taskhub_owner.tasks (todo_list_id, title, status, priority, created_by_user_id)
    values (l_alice_list_id, 'TASK40_FIX_ALICE_TASK', 'OPEN', 1, l_alice_id);

    insert into taskhub_owner.tasks (todo_list_id, title, status, priority, created_by_user_id)
    values (l_bob_list_id, 'TASK40_FIX_BOB_TASK', 'OPEN', 1, l_bob_id);

    commit;
    dbms_output.put_line('PASS: bounded Task 40 fixture created');
exception
    when others then
        rollback;
        raise;
end;
/
