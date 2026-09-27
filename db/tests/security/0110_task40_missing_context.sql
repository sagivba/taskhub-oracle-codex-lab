-- Test: every Task 40 write entry point rejects a missing context
-- Connection/schema: TASKHUB_APP
-- Preconditions: changes 0220 and 0230 applied
-- Expected result: PASS with ORA-20002 for all six public operations
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
    assert_context_required(q'[declare l_id number; begin l_id := taskhub_api.pkg_taskhub_api.create_list('TASK40_NO_CONTEXT'); end;]', 'CREATE_LIST');
    assert_context_required(q'[begin taskhub_api.pkg_taskhub_api.update_list(-1, 'TASK40_NO_CONTEXT'); end;]', 'UPDATE_LIST');
    assert_context_required(q'[begin taskhub_api.pkg_taskhub_api.delete_list(-1); end;]', 'DELETE_LIST');
    assert_context_required(q'[begin taskhub_api.pkg_taskhub_api.add_tag_to_list(-1, 'TASK40_NO_CONTEXT'); end;]', 'ADD_TAG_TO_LIST');
    assert_context_required(q'[begin taskhub_api.pkg_taskhub_api.remove_tag_from_list(-1, 'TASK40_NO_CONTEXT'); end;]', 'REMOVE_TAG_FROM_LIST');
    assert_context_required(q'[begin taskhub_api.pkg_taskhub_api.delete_tag('TASK40_NO_CONTEXT'); end;]', 'DELETE_TAG');
    dbms_output.put_line('PASS: all Task 40 write APIs require valid context');
end;
/
