-- Test: Task 60 retention-aware, association-first and hierarchy-safe purge
-- Connection/schema: TASKHUB_API
-- Preconditions: changes 0260 and 0270 applied; TASKHUB_TEST_ALICE exists
-- Expected result: PASS and zero residual TASK60_PURGE_% fixtures

set serveroutput on
declare
    l_user_id          number;
    l_old_list_id      number;
    l_new_list_id      number;
    l_task_list_id     number;
    l_tag_list_id      number;
    l_mixed_list_id    number;
    l_list_tag_id      number;
    l_new_tag_id       number;
    l_old_tag_id       number;
    l_old_root_id      number;
    l_old_child_id     number;
    l_old_grand_id     number;
    l_new_task_id      number;
    l_task_root_id     number;
    l_task_child_id    number;
    l_task_grand_id    number;
    l_mixed_parent_id  number;
    l_mixed_child_id   number;
    l_before_lists     number;
    l_before_tags      number;
    l_before_links     number;
    l_before_tasks     number;
    l_after_lists      number;
    l_after_tags       number;
    l_after_links      number;
    l_after_tasks      number;
    l_count            number;
    l_old              timestamp(6) := systimestamp - interval '45' day;
    l_new              timestamp(6) := systimestamp - interval '5' day;

    procedure assert_count(
        p_actual   in number,
        p_expected in number,
        p_label    in varchar2
    ) is
    begin
        if p_actual <> p_expected then
            raise_application_error(
                -20990,
                'FAIL: ' || p_label || '; expected ' || p_expected ||
                ', actual ' || p_actual
            );
        end if;
    end assert_count;

    procedure fixture_counts(
        p_lists out number,
        p_tags  out number,
        p_links out number,
        p_tasks out number
    ) is
    begin
        select count(*) into p_lists
          from taskhub_owner.todo_lists
         where list_name like 'TASK60_PURGE_%';

        select count(*) into p_tags
          from taskhub_owner.tags
         where tag_name like 'TASK60_PURGE_%';

        select count(*) into p_links
          from taskhub_owner.todo_list_tags a
         where exists (
                   select 1 from taskhub_owner.todo_lists l
                    where l.id = a.todo_list_id
                      and l.list_name like 'TASK60_PURGE_%'
               )
            or exists (
                   select 1 from taskhub_owner.tags g
                    where g.id = a.tag_id
                      and g.tag_name like 'TASK60_PURGE_%'
               );

        select count(*) into p_tasks
          from taskhub_owner.tasks t
         where exists (
                   select 1 from taskhub_owner.todo_lists l
                    where l.id = t.todo_list_id
                      and l.list_name like 'TASK60_PURGE_%'
               );
    end fixture_counts;

    procedure cleanup_fixture is
    begin
        delete from taskhub_owner.todo_list_tags a
         where exists (
                   select 1 from taskhub_owner.todo_lists l
                    where l.id = a.todo_list_id
                      and l.list_name like 'TASK60_PURGE_%'
               )
            or exists (
                   select 1 from taskhub_owner.tags g
                    where g.id = a.tag_id
                      and g.tag_name like 'TASK60_PURGE_%'
               );

        loop
            delete from taskhub_owner.tasks t
             where exists (
                       select 1 from taskhub_owner.todo_lists l
                        where l.id = t.todo_list_id
                          and l.list_name like 'TASK60_PURGE_%'
                   )
               and not exists (
                       select 1 from taskhub_owner.tasks c
                        where c.parent_task_id = t.id
                   );
            exit when sql%rowcount = 0;
        end loop;

        delete from taskhub_owner.todo_lists
         where list_name like 'TASK60_PURGE_%';
        delete from taskhub_owner.tags
         where tag_name like 'TASK60_PURGE_%';
        commit;
    end cleanup_fixture;
begin
    cleanup_fixture;

    select id into l_user_id
      from taskhub_owner.app_users
     where username = 'TASKHUB_TEST_ALICE';

    insert into taskhub_owner.todo_lists (
        app_user_id, list_name, created_by_user_id, deleted_at, deleted_by_user_id
    ) values (
        l_user_id, 'TASK60_PURGE_OLD_LIST', l_user_id, l_old, l_user_id
    ) returning id into l_old_list_id;

    insert into taskhub_owner.todo_lists (
        app_user_id, list_name, created_by_user_id, deleted_at, deleted_by_user_id
    ) values (
        l_user_id, 'TASK60_PURGE_NEW_LIST', l_user_id, l_new, l_user_id
    ) returning id into l_new_list_id;

    insert into taskhub_owner.todo_lists (app_user_id, list_name, created_by_user_id)
    values (l_user_id, 'TASK60_PURGE_TASK_LIST', l_user_id)
    returning id into l_task_list_id;

    insert into taskhub_owner.todo_lists (app_user_id, list_name, created_by_user_id)
    values (l_user_id, 'TASK60_PURGE_TAG_LIST', l_user_id)
    returning id into l_tag_list_id;

    insert into taskhub_owner.todo_lists (app_user_id, list_name, created_by_user_id)
    values (l_user_id, 'TASK60_PURGE_MIXED_LIST', l_user_id)
    returning id into l_mixed_list_id;

    insert into taskhub_owner.tags (app_user_id, tag_name, created_by_user_id)
    values (l_user_id, 'TASK60_PURGE_ACTIVE_LIST_TAG', l_user_id)
    returning id into l_list_tag_id;

    insert into taskhub_owner.tags (
        app_user_id, tag_name, created_by_user_id, deleted_at, deleted_by_user_id
    ) values (
        l_user_id, 'TASK60_PURGE_NEW_TAG', l_user_id, l_new, l_user_id
    ) returning id into l_new_tag_id;

    insert into taskhub_owner.tags (
        app_user_id, tag_name, created_by_user_id, deleted_at, deleted_by_user_id
    ) values (
        l_user_id, 'TASK60_PURGE_OLD_TAG', l_user_id, l_old, l_user_id
    ) returning id into l_old_tag_id;

    insert into taskhub_owner.todo_list_tags (todo_list_id, tag_id)
    values (l_old_list_id, l_list_tag_id);
    insert into taskhub_owner.todo_list_tags (todo_list_id, tag_id)
    values (l_new_list_id, l_new_tag_id);
    insert into taskhub_owner.todo_list_tags (todo_list_id, tag_id)
    values (l_tag_list_id, l_old_tag_id);

    insert into taskhub_owner.tasks (
        todo_list_id, title, status, priority, created_by_user_id,
        deleted_at, deleted_by_user_id
    ) values (
        l_old_list_id, 'TASK60_PURGE_OLD_ROOT', 'OPEN', 2, l_user_id,
        l_old, l_user_id
    ) returning id into l_old_root_id;
    insert into taskhub_owner.tasks (
        todo_list_id, parent_task_id, title, status, priority,
        created_by_user_id, deleted_at, deleted_by_user_id
    ) values (
        l_old_list_id, l_old_root_id, 'TASK60_PURGE_OLD_CHILD', 'OPEN', 2,
        l_user_id, l_old, l_user_id
    ) returning id into l_old_child_id;
    insert into taskhub_owner.tasks (
        todo_list_id, parent_task_id, title, status, priority,
        created_by_user_id, deleted_at, deleted_by_user_id
    ) values (
        l_old_list_id, l_old_child_id, 'TASK60_PURGE_OLD_GRAND', 'OPEN', 2,
        l_user_id, l_old, l_user_id
    ) returning id into l_old_grand_id;

    insert into taskhub_owner.tasks (
        todo_list_id, title, status, priority, created_by_user_id,
        deleted_at, deleted_by_user_id
    ) values (
        l_new_list_id, 'TASK60_PURGE_NEW_TASK', 'OPEN', 2, l_user_id,
        l_new, l_user_id
    ) returning id into l_new_task_id;

    insert into taskhub_owner.tasks (
        todo_list_id, title, status, priority, created_by_user_id,
        deleted_at, deleted_by_user_id
    ) values (
        l_task_list_id, 'TASK60_PURGE_TASK_ROOT', 'OPEN', 2, l_user_id,
        l_old, l_user_id
    ) returning id into l_task_root_id;
    insert into taskhub_owner.tasks (
        todo_list_id, parent_task_id, title, status, priority,
        created_by_user_id, deleted_at, deleted_by_user_id
    ) values (
        l_task_list_id, l_task_root_id, 'TASK60_PURGE_TASK_CHILD', 'OPEN', 2,
        l_user_id, l_old, l_user_id
    ) returning id into l_task_child_id;
    insert into taskhub_owner.tasks (
        todo_list_id, parent_task_id, title, status, priority,
        created_by_user_id, deleted_at, deleted_by_user_id
    ) values (
        l_task_list_id, l_task_child_id, 'TASK60_PURGE_TASK_GRAND', 'OPEN', 2,
        l_user_id, l_old, l_user_id
    ) returning id into l_task_grand_id;

    insert into taskhub_owner.tasks (
        todo_list_id, title, status, priority, created_by_user_id,
        deleted_at, deleted_by_user_id
    ) values (
        l_mixed_list_id, 'TASK60_PURGE_MIXED_PARENT', 'OPEN', 2, l_user_id,
        l_old, l_user_id
    ) returning id into l_mixed_parent_id;
    insert into taskhub_owner.tasks (
        todo_list_id, parent_task_id, title, status, priority,
        created_by_user_id, deleted_at, deleted_by_user_id
    ) values (
        l_mixed_list_id, l_mixed_parent_id, 'TASK60_PURGE_MIXED_CHILD', 'OPEN', 2,
        l_user_id, l_new, l_user_id
    ) returning id into l_mixed_child_id;
    commit;

    taskhub_api.pkg_taskhub_maint.purge_deleted;

    select count(*) into l_count
      from taskhub_owner.todo_lists where id = l_old_list_id;
    assert_count(l_count, 0, 'eligible List physically deleted');
    select count(*) into l_count
      from taskhub_owner.tasks
     where id in (l_old_root_id, l_old_child_id, l_old_grand_id);
    assert_count(l_count, 0, 'eligible List Task hierarchy deleted child before parent');
    select count(*) into l_count
      from taskhub_owner.todo_list_tags
     where todo_list_id = l_old_list_id;
    assert_count(l_count, 0, 'eligible List association removed before List');
    select count(*) into l_count
      from taskhub_owner.tags where id = l_list_tag_id;
    assert_count(l_count, 1, 'active Tag linked to purged List preserved');

    select count(*) into l_count
      from taskhub_owner.todo_lists where id = l_new_list_id;
    assert_count(l_count, 1, 'newer-than-retention List preserved');
    select count(*) into l_count
      from taskhub_owner.tasks where id = l_new_task_id;
    assert_count(l_count, 1, 'newer-than-retention Task preserved');
    select count(*) into l_count
      from taskhub_owner.tags where id = l_new_tag_id;
    assert_count(l_count, 1, 'newer-than-retention Tag preserved');
    select count(*) into l_count
      from taskhub_owner.todo_list_tags
     where todo_list_id = l_new_list_id and tag_id = l_new_tag_id;
    assert_count(l_count, 1, 'newer parent association preserved');

    select count(*) into l_count
      from taskhub_owner.tasks
     where id in (l_task_root_id, l_task_child_id, l_task_grand_id);
    assert_count(l_count, 0, 'eligible standalone Task hierarchy purged');
    select count(*) into l_count
      from taskhub_owner.todo_lists where id = l_task_list_id;
    assert_count(l_count, 1, 'active List preserved after Task purge');

    select count(*) into l_count
      from taskhub_owner.tasks
     where id in (l_mixed_parent_id, l_mixed_child_id);
    assert_count(l_count, 2, 'newer child safely blocks eligible parent');

    select count(*) into l_count
      from taskhub_owner.tags where id = l_old_tag_id;
    assert_count(l_count, 0, 'eligible Tag physically deleted');
    select count(*) into l_count
      from taskhub_owner.todo_list_tags where tag_id = l_old_tag_id;
    assert_count(l_count, 0, 'eligible Tag association removed before Tag');
    select count(*) into l_count
      from taskhub_owner.todo_lists where id = l_tag_list_id;
    assert_count(l_count, 1, 'active List linked to purged Tag preserved');

    select count(*) into l_count
      from taskhub_owner.tasks t
     where not exists (
               select 1 from taskhub_owner.todo_lists l
                where l.id = t.todo_list_id
           )
        or (t.parent_task_id is not null and not exists (
               select 1 from taskhub_owner.tasks p
                where p.id = t.parent_task_id
           ));
    assert_count(l_count, 0, 'no invalid Task references');
    select count(*) into l_count
      from taskhub_owner.todo_list_tags a
     where not exists (
               select 1 from taskhub_owner.todo_lists l
                where l.id = a.todo_list_id
           )
        or not exists (
               select 1 from taskhub_owner.tags g
                where g.id = a.tag_id
           );
    assert_count(l_count, 0, 'no invalid List/Tag associations');

    fixture_counts(l_before_lists, l_before_tags, l_before_links, l_before_tasks);
    taskhub_api.pkg_taskhub_maint.purge_deleted;
    fixture_counts(l_after_lists, l_after_tags, l_after_links, l_after_tasks);
    assert_count(l_after_lists, l_before_lists, 'repeat purge List state');
    assert_count(l_after_tags, l_before_tags, 'repeat purge Tag state');
    assert_count(l_after_links, l_before_links, 'repeat purge association state');
    assert_count(l_after_tasks, l_before_tasks, 'repeat purge Task state');

    cleanup_fixture;
    fixture_counts(l_after_lists, l_after_tags, l_after_links, l_after_tasks);
    assert_count(l_after_lists + l_after_tags + l_after_links + l_after_tasks, 0,
                 'fixture cleanup');
    dbms_output.put_line('PASS: Task 60 retention, FK order and repeatable purge state');
exception
    when others then
        cleanup_fixture;
        raise;
end;
/
