-- Test: every Task 50 write entry point rejects missing context through the runtime package grant
-- Connection/schema: TASKHUB_APP
-- Preconditions: changes 0240 and 0250 applied
-- Expected result: PASS with ORA-20002 for CREATE_TASK, UPDATE_TASK and DELETE_TASK
-- Identity rule: clear TASKHUB_CTX through the approved runtime facade first.

set serveroutput on
declare
    procedure assert_context_required(
        p_call  in varchar2,
        p_label in varchar2
    ) is
    begin
        begin
            execute immediate p_call;
            raise_application_error(-20990, 'FAIL: ' || p_label || ' accepted missing context');
        exception
            when others then
                if sqlcode <> -20002 then
                    raise;
                end if;
        end;
    end assert_context_required;
begin
    taskhub_api.pkg_taskhub_context.clear_context;
    assert_context_required(q'[declare l_id number; begin l_id := taskhub_api.pkg_taskhub_api.create_task(-1, null, 'NO_CONTEXT'); end;]', 'CREATE_TASK');
    assert_context_required(q'[begin taskhub_api.pkg_taskhub_api.update_task(-1, null, 'NO_CONTEXT', null, 'OPEN', 2, null); end;]', 'UPDATE_TASK');
    assert_context_required(q'[begin taskhub_api.pkg_taskhub_api.delete_task(-1); end;]', 'DELETE_TASK');
    dbms_output.put_line('PASS: all Task 50 write APIs require valid context through TASKHUB_APP');
end;
/
