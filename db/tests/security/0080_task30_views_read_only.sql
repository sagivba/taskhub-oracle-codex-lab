-- Test: INSERT, UPDATE and DELETE are denied through every Task 30 view
-- Connection/schema: TASKHUB_APP
-- Preconditions: changes 0190 through 0210 applied
-- Expected result: PASS for all twelve denied DML statements
-- Identity rule: clear TASKHUB_CTX explicitly before testing.

set serveroutput on
declare
    procedure assert_read_only(p_sql in varchar2, p_label in varchar2) is
    begin
        begin
            execute immediate p_sql;
            raise_application_error(-20990, 'FAIL: ' || p_label || ' succeeded');
        exception
            when others then
                -- TASKHUB_APP has SELECT only, so Oracle may reject at the privilege
                -- layer before reaching the view-level WITH READ ONLY restriction.
                if sqlcode not in (-1031, -1732, -41900, -42399) then
                    raise;
                end if;
        end;
    end assert_read_only;
begin
    taskhub_api.pkg_taskhub_context.clear_context;

    assert_read_only('insert into taskhub_api.v_todo_lists select * from taskhub_api.v_todo_lists where 1=0', 'V_TODO_LISTS INSERT');
    assert_read_only('update taskhub_api.v_todo_lists set list_name = list_name where 1=0', 'V_TODO_LISTS UPDATE');
    assert_read_only('delete from taskhub_api.v_todo_lists where 1=0', 'V_TODO_LISTS DELETE');

    assert_read_only('insert into taskhub_api.v_todo_list_tags select * from taskhub_api.v_todo_list_tags where 1=0', 'V_TODO_LIST_TAGS INSERT');
    assert_read_only('update taskhub_api.v_todo_list_tags set tag_id = tag_id where 1=0', 'V_TODO_LIST_TAGS UPDATE');
    assert_read_only('delete from taskhub_api.v_todo_list_tags where 1=0', 'V_TODO_LIST_TAGS DELETE');

    assert_read_only('insert into taskhub_api.v_tasks select * from taskhub_api.v_tasks where 1=0', 'V_TASKS INSERT');
    assert_read_only('update taskhub_api.v_tasks set title = title where 1=0', 'V_TASKS UPDATE');
    assert_read_only('delete from taskhub_api.v_tasks where 1=0', 'V_TASKS DELETE');

    assert_read_only('insert into taskhub_api.v_task_tree select * from taskhub_api.v_task_tree where 1=0', 'V_TASK_TREE INSERT');
    assert_read_only('update taskhub_api.v_task_tree set title = title where 1=0', 'V_TASK_TREE UPDATE');
    assert_read_only('delete from taskhub_api.v_task_tree where 1=0', 'V_TASK_TREE DELETE');

    dbms_output.put_line('PASS: all Task 30 views reject INSERT, UPDATE and DELETE');
end;
/
