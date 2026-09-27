-- Test fixture cleanup: remove every bounded Task 40 row in FK-safe order
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: 0060_task40_fixture_setup.sql may have run
-- Expected result: PASS and zero residual TASK40-prefixed business rows

set serveroutput on
declare
    l_count number;
begin
    delete from taskhub_owner.todo_list_tags
     where todo_list_id in (
               select id from taskhub_owner.todo_lists where list_name like 'TASK40\_%' escape '\'
           )
        or tag_id in (
               select id from taskhub_owner.tags where tag_name like 'TASK40\_%' escape '\'
           );

    delete from taskhub_owner.tasks where title like 'TASK40\_%' escape '\';
    delete from taskhub_owner.tags where tag_name like 'TASK40\_%' escape '\';
    delete from taskhub_owner.todo_lists where list_name like 'TASK40\_%' escape '\';

    select (select count(*) from taskhub_owner.todo_lists where list_name like 'TASK40\_%' escape '\')
         + (select count(*) from taskhub_owner.tags where tag_name like 'TASK40\_%' escape '\')
         + (select count(*) from taskhub_owner.tasks where title like 'TASK40\_%' escape '\')
      into l_count
      from dual;

    if l_count <> 0 then
        raise_application_error(-20990, 'FAIL: Task 40 cleanup left residual rows');
    end if;

    commit;
    dbms_output.put_line('PASS: Task 40 fixture removed with zero residual rows');
exception
    when others then
        rollback;
        raise;
end;
/
