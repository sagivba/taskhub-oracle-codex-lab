-- Test: TASKHUB_APP cannot insert directly into owner TODO_LISTS
-- Connection/schema: TASKHUB_APP
-- Preconditions: changes 0080 through 0160 applied
-- Expected result: PASS with ORA-00942 or ORA-01031 handled

set serveroutput on
begin
    begin
        execute immediate q'[
            insert into taskhub_owner.todo_lists (app_user_id, list_name, created_by_user_id)
            values (1, 'FORBIDDEN_DIRECT_INSERT', 1)
        ]';
        raise_application_error(-20990, 'FAIL: direct owner-table insert succeeded');
    exception
        when others then
            if sqlcode not in (-942, -1031) then
                raise;
            end if;
    end;
    dbms_output.put_line('PASS: direct TODO_LISTS insert denied');
end;
/
