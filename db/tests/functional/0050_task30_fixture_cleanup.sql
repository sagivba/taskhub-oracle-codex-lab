-- Test fixture cleanup: remove every bounded Task 30 row in FK-safe order
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: 0030_task30_fixture_setup.sql may have run
-- Expected result: PASS and zero residual TASK30-prefixed business rows
-- Identity rule: owner cleanup does not initialize application context.

set serveroutput on
declare
    l_count number;
begin
    delete from taskhub_owner.todo_list_tags
     where todo_list_id in (
               select id
                 from taskhub_owner.todo_lists
                where list_name like 'TASK30\_%' escape '\'
           )
        or tag_id in (
               select id
                 from taskhub_owner.tags
                where tag_name like 'TASK30\_%' escape '\'
           );

    delete from taskhub_owner.tasks
     where title like 'TASK30\_%' escape '\';

    delete from taskhub_owner.tags
     where tag_name like 'TASK30\_%' escape '\';

    delete from taskhub_owner.todo_lists
     where list_name like 'TASK30\_%' escape '\';

    select sum(row_count)
      into l_count
      from (
          select count(*) as row_count
            from taskhub_owner.todo_lists
           where list_name like 'TASK30\_%' escape '\'
          union all
          select count(*)
            from taskhub_owner.tags
           where tag_name like 'TASK30\_%' escape '\'
          union all
          select count(*)
            from taskhub_owner.tasks
           where title like 'TASK30\_%' escape '\'
      );

    if l_count <> 0 then
        raise_application_error(-20990, 'FAIL: Task 30 fixture cleanup left residual rows');
    end if;

    commit;
    dbms_output.put_line('PASS: Task 30 fixture removed with zero residual rows');
exception
    when others then
        rollback;
        raise;
end;
/
