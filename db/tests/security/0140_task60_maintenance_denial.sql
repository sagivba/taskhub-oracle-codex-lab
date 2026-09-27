-- Test: TASKHUB_APP cannot invoke the internal physical-purge package
-- Connection/schema: TASKHUB_APP
-- Preconditions: changes 0260 through 0280 applied
-- Expected result: PASS with PKG_TASKHUB_MAINT execution denied

set serveroutput on
begin
    begin
        execute immediate 'begin taskhub_api.pkg_taskhub_maint.purge_deleted; end;';
        raise_application_error(-20990, 'FAIL: TASKHUB_APP invoked physical purge');
    exception
        when others then
            if sqlcode not in (-6550, -1031) then
                raise;
            end if;
    end;
    dbms_output.put_line('PASS: TASKHUB_APP cannot invoke PKG_TASKHUB_MAINT');
end;
/
