-- Test: TASKHUB_APP cannot spoof TaskHub identity with DBMS_SESSION.SET_CONTEXT
-- Connection/schema: TASKHUB_APP
-- Preconditions: TASKHUB_CTX is associated with TASKHUB_API.PKG_TASKHUB_CONTEXT_CORE
-- Expected result: PASS with the direct context write denied and both attributes empty

set serveroutput on
begin
    taskhub_api.pkg_taskhub_context.clear_context;
    begin
        dbms_session.set_context('TASKHUB_CTX', 'APP_USER_ID', '1');
        raise_application_error(-20990, 'FAIL: TASKHUB_APP set trusted context directly');
    exception
        when others then
            if sqlcode not in (-1031, -28101, -28268) then
                raise;
            end if;
    end;

    if sys_context('TASKHUB_CTX', 'APP_USER_ID') is not null
       or sys_context('TASKHUB_CTX', 'APP_USERNAME') is not null then
        raise_application_error(-20991, 'FAIL: spoof attempt left context state');
    end if;
    dbms_output.put_line('PASS: direct context spoof denied');
end;
/
