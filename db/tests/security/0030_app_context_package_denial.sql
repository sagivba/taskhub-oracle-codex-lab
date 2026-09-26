-- Test: TASKHUB_APP cannot execute trusted-core or DEV-only test context packages
-- Connection/schema: TASKHUB_APP
-- Preconditions: changes 0080 through 0160 applied
-- Expected result: PASS with both dynamic calls denied

set serveroutput on
declare
    procedure expect_denied(p_block in varchar2)
    is
    begin
        execute immediate p_block;
        raise_application_error(-20990, 'FAIL: forbidden package execution succeeded');
    exception
        when others then
            if sqlcode not in (-6550, -1031) then
                raise;
            end if;
    end expect_denied;
begin
    expect_denied('begin taskhub_api.pkg_taskhub_context_core.clear_context; end;');
    expect_denied('begin taskhub_api.pkg_taskhub_test_context.clear_context; end;');
    dbms_output.put_line('PASS: core and test context packages denied');
end;
/
