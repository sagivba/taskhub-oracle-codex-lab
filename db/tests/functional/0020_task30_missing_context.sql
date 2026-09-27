-- Test: missing application context returns zero rows from all Task 30 views
-- Connection/schema: TASKHUB_API
-- Preconditions: changes 0190 through 0210 applied
-- Expected result: PASS
-- Identity rule: clear TASKHUB_CTX explicitly before every view query.

set serveroutput on
declare
    l_count number;

    procedure assert_empty(p_view_name in varchar2) is
    begin
        taskhub_api.pkg_taskhub_test_context.clear_context;
        execute immediate 'select count(*) from taskhub_api.' || p_view_name into l_count;
        if l_count <> 0 then
            raise_application_error(-20990, 'FAIL: ' || p_view_name || ' returned rows without context');
        end if;
    end assert_empty;
begin
    assert_empty('V_TODO_LISTS');
    assert_empty('V_TODO_LIST_TAGS');
    assert_empty('V_TASKS');
    assert_empty('V_TASK_TREE');
    taskhub_api.pkg_taskhub_test_context.clear_context;
    dbms_output.put_line('PASS: all Task 30 views fail closed without context');
end;
/
