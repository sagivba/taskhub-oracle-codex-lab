-- Test: TASKHUB_APP can call CREATE_LIST but an unset context is rejected
-- Connection/schema: TASKHUB_APP
-- Preconditions: changes 0080 through 0160 applied
-- Expected result: PASS with ORA-20002 handled
-- Identity rule: clear through the approved runtime facade before the call.

set serveroutput on
declare
    l_list_id number;
begin
    taskhub_api.pkg_taskhub_context.clear_context;
    begin
        l_list_id := taskhub_api.pkg_taskhub_api.create_list('MUST_NOT_BE_CREATED');
        raise_application_error(-20990, 'FAIL: CREATE_LIST accepted an unset context');
    exception
        when others then
            if sqlcode <> -20002 then
                raise;
            end if;
    end;
    dbms_output.put_line('PASS: unset context rejected through TASKHUB_APP');
end;
/
