-- Test: TASKHUB_APP cannot directly SELECT any owner table behind the Task 30 views
-- Connection/schema: TASKHUB_APP
-- Preconditions: changes 0190 through 0210 applied
-- Expected result: PASS with direct SELECT denied for all five relevant owner tables

set serveroutput on
declare
    procedure assert_select_denied(p_table_name in varchar2) is
        l_count number;
    begin
        begin
            execute immediate 'select count(*) from taskhub_owner.' || p_table_name into l_count;
            raise_application_error(-20990, 'FAIL: direct SELECT succeeded on ' || p_table_name);
        exception
            when others then
                if sqlcode not in (-942, -1031) then
                    raise;
                end if;
        end;
    end assert_select_denied;
begin
    assert_select_denied('APP_USERS');
    assert_select_denied('TODO_LISTS');
    assert_select_denied('TAGS');
    assert_select_denied('TODO_LIST_TAGS');
    assert_select_denied('TASKS');
    dbms_output.put_line('PASS: TASKHUB_APP direct owner-table SELECT denied');
end;
/
