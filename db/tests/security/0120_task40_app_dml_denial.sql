-- Test: TASKHUB_APP has no direct DML path to any Task 40 owner table
-- Connection/schema: TASKHUB_APP
-- Preconditions: changes 0220 and 0230 applied
-- Expected result: PASS for INSERT, UPDATE and DELETE denial on all four tables

set serveroutput on
declare
    procedure assert_denied(
        p_sql   in varchar2,
        p_label in varchar2
    ) is
    begin
        begin
            execute immediate p_sql;
            raise_application_error(-20990, 'FAIL: direct ' || p_label || ' succeeded');
        exception
            when others then
                if sqlcode not in (-942, -1031) then
                    raise;
                end if;
        end;
    end assert_denied;
begin
    assert_denied(q'[insert into taskhub_owner.todo_lists (app_user_id, list_name, created_by_user_id) values (-1, 'DENIED', -1)]', 'TODO_LISTS INSERT');
    assert_denied(q'[update taskhub_owner.todo_lists set list_name = list_name where 1 = 0]', 'TODO_LISTS UPDATE');
    assert_denied(q'[delete from taskhub_owner.todo_lists where 1 = 0]', 'TODO_LISTS DELETE');

    assert_denied(q'[insert into taskhub_owner.tags (app_user_id, tag_name, created_by_user_id) values (-1, 'DENIED', -1)]', 'TAGS INSERT');
    assert_denied(q'[update taskhub_owner.tags set tag_name = tag_name where 1 = 0]', 'TAGS UPDATE');
    assert_denied(q'[delete from taskhub_owner.tags where 1 = 0]', 'TAGS DELETE');

    assert_denied(q'[insert into taskhub_owner.todo_list_tags (todo_list_id, tag_id) values (-1, -1)]', 'TODO_LIST_TAGS INSERT');
    assert_denied(q'[update taskhub_owner.todo_list_tags set tag_id = tag_id where 1 = 0]', 'TODO_LIST_TAGS UPDATE');
    assert_denied(q'[delete from taskhub_owner.todo_list_tags where 1 = 0]', 'TODO_LIST_TAGS DELETE');

    assert_denied(q'[insert into taskhub_owner.tasks (todo_list_id, title, status, priority, created_by_user_id) values (-1, 'DENIED', 'OPEN', 1, -1)]', 'TASKS INSERT');
    assert_denied(q'[update taskhub_owner.tasks set title = title where 1 = 0]', 'TASKS UPDATE');
    assert_denied(q'[delete from taskhub_owner.tasks where 1 = 0]', 'TASKS DELETE');
    dbms_output.put_line('PASS: TASKHUB_APP direct DML denied on all Task 40 owner tables');
end;
/
