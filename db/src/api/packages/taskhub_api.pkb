create or replace package body taskhub_api.pkg_taskhub_api
as
    function current_app_user_id
        return taskhub_owner.app_users.id%type
    is
        l_context_user_id  varchar2(4000 char);
        l_context_username varchar2(4000 char);
        l_app_user_id      taskhub_owner.app_users.id%type;
    begin
        l_context_user_id := sys_context('TASKHUB_CTX', 'APP_USER_ID');
        l_context_username := sys_context('TASKHUB_CTX', 'APP_USERNAME');

        if l_context_user_id is null or l_context_username is null then
            raise_application_error(-20002, 'TaskHub application context is not initialized.');
        end if;

        -- Revalidate both context attributes and active status so deactivation or
        -- malformed/stale session state fails before any owner-table DML.
        select id
          into l_app_user_id
          from taskhub_owner.app_users
         where id = to_number(l_context_user_id)
           and username = l_context_username
           and is_active = 'Y';

        return l_app_user_id;
    exception
        when no_data_found or value_error then
            raise_application_error(-20002, 'TaskHub application context is not initialized.');
    end current_app_user_id;

    function create_list(
        p_list_name in varchar2
    ) return number
    is
        l_app_user_id taskhub_owner.app_users.id%type;
        l_list_name   varchar2(32767 char);
        l_list_id     number;
    begin
        l_app_user_id := current_app_user_id;
        l_list_name := trim(p_list_name);

        if l_list_name is null or length(l_list_name) > 200 then
            raise_application_error(-20003, 'TaskHub list name is invalid.');
        end if;

        -- Ownership and creator audit are derived from trusted context; accepting
        -- either from the caller would enable cross-user spoofing.
        insert into taskhub_owner.todo_lists (
            app_user_id,
            list_name,
            created_by_user_id
        ) values (
            l_app_user_id,
            l_list_name,
            l_app_user_id
        )
        returning id into l_list_id;

        return l_list_id;
    end create_list;

    function normalized_list_name(
        p_list_name in varchar2
    ) return varchar2
    is
        l_list_name varchar2(32767 char);
    begin
        l_list_name := trim(p_list_name);
        if l_list_name is null or length(l_list_name) > 200 then
            raise_application_error(-20003, 'TaskHub list name is invalid.');
        end if;
        return l_list_name;
    end normalized_list_name;

    function normalized_tag_name(
        p_tag_name in varchar2
    ) return varchar2
    is
        l_tag_name varchar2(32767 char);
    begin
        l_tag_name := trim(p_tag_name);
        if l_tag_name is null or length(l_tag_name) > 100 then
            raise_application_error(-20005, 'TaskHub tag name is invalid.');
        end if;
        return l_tag_name;
    end normalized_tag_name;

    procedure require_active_list(
        p_list_id     in number,
        p_app_user_id in taskhub_owner.app_users.id%type
    )
    is
        l_list_id taskhub_owner.todo_lists.id%type;
    begin
        select id
          into l_list_id
          from taskhub_owner.todo_lists
         where id = p_list_id
           and app_user_id = p_app_user_id
           and deleted_at is null;
    exception
        when no_data_found then
            -- One public result covers missing, foreign-owned and inactive Lists.
            raise_application_error(-20004, 'TaskHub list is not accessible.');
    end require_active_list;

    procedure update_list(
        p_list_id   in number,
        p_list_name in varchar2
    )
    is
        l_app_user_id taskhub_owner.app_users.id%type;
        l_list_name   varchar2(32767 char);
    begin
        l_app_user_id := current_app_user_id;
        l_list_name := normalized_list_name(p_list_name);

        update taskhub_owner.todo_lists
           set list_name = l_list_name,
               updated_at = systimestamp,
               updated_by_user_id = l_app_user_id
         where id = p_list_id
           and app_user_id = l_app_user_id
           and deleted_at is null;

        if sql%rowcount = 0 then
            raise_application_error(-20004, 'TaskHub list is not accessible.');
        end if;
    end update_list;

    procedure delete_list(
        p_list_id in number
    )
    is
        l_app_user_id taskhub_owner.app_users.id%type;
        l_deleted_at  timestamp(6);
    begin
        l_app_user_id := current_app_user_id;
        l_deleted_at := systimestamp;

        update taskhub_owner.todo_lists
           set deleted_at = l_deleted_at,
               deleted_by_user_id = l_app_user_id
         where id = p_list_id
           and app_user_id = l_app_user_id
           and deleted_at is null;

        if sql%rowcount = 0 then
            raise_application_error(-20004, 'TaskHub list is not accessible.');
        end if;

        update taskhub_owner.tasks
           set deleted_at = l_deleted_at,
               deleted_by_user_id = l_app_user_id
         where todo_list_id = p_list_id
           and deleted_at is null;
    end delete_list;

    procedure add_tag_to_list(
        p_list_id  in number,
        p_tag_name in varchar2
    )
    is
        l_app_user_id taskhub_owner.app_users.id%type;
        l_tag_name    varchar2(32767 char);
        l_tag_id      taskhub_owner.tags.id%type;
    begin
        l_app_user_id := current_app_user_id;
        l_tag_name := normalized_tag_name(p_tag_name);
        require_active_list(p_list_id, l_app_user_id);

        begin
            select id
              into l_tag_id
              from taskhub_owner.tags
             where app_user_id = l_app_user_id
               and deleted_at is null
               and upper(trim(tag_name)) = upper(l_tag_name);
        exception
            when no_data_found then
                begin
                    insert into taskhub_owner.tags (
                        app_user_id,
                        tag_name,
                        created_by_user_id
                    ) values (
                        l_app_user_id,
                        l_tag_name,
                        l_app_user_id
                    )
                    returning id into l_tag_id;
                exception
                    when dup_val_on_index then
                        -- The active-only unique index arbitrates concurrent creation.
                        select id
                          into l_tag_id
                          from taskhub_owner.tags
                         where app_user_id = l_app_user_id
                           and deleted_at is null
                           and upper(trim(tag_name)) = upper(l_tag_name);
                end;
        end;

        begin
            insert into taskhub_owner.todo_list_tags (todo_list_id, tag_id)
            values (p_list_id, l_tag_id);
        exception
            when dup_val_on_index then
                -- Re-adding the same List/Tag pair is intentionally idempotent.
                null;
        end;
    end add_tag_to_list;

    procedure remove_tag_from_list(
        p_list_id  in number,
        p_tag_name in varchar2
    )
    is
        l_app_user_id taskhub_owner.app_users.id%type;
        l_tag_name    varchar2(32767 char);
        l_tag_id      taskhub_owner.tags.id%type;
    begin
        l_app_user_id := current_app_user_id;
        l_tag_name := normalized_tag_name(p_tag_name);
        require_active_list(p_list_id, l_app_user_id);

        begin
            select id
              into l_tag_id
              from taskhub_owner.tags
             where app_user_id = l_app_user_id
               and deleted_at is null
               and upper(trim(tag_name)) = upper(l_tag_name);
        exception
            when no_data_found then
                raise_application_error(-20006, 'TaskHub tag is not accessible.');
        end;

        delete from taskhub_owner.todo_list_tags
         where todo_list_id = p_list_id
           and tag_id = l_tag_id;
    end remove_tag_from_list;

    procedure delete_tag(
        p_tag_name in varchar2
    )
    is
        l_app_user_id taskhub_owner.app_users.id%type;
        l_tag_name    varchar2(32767 char);
        l_tag_id      taskhub_owner.tags.id%type;
    begin
        l_app_user_id := current_app_user_id;
        l_tag_name := normalized_tag_name(p_tag_name);

        begin
            select id
              into l_tag_id
              from taskhub_owner.tags
             where app_user_id = l_app_user_id
               and deleted_at is null
               and upper(trim(tag_name)) = upper(l_tag_name)
             for update;
        exception
            when no_data_found then
                raise_application_error(-20006, 'TaskHub tag is not accessible.');
        end;

        -- Association rows have no soft-delete lifecycle and are removed first.
        delete from taskhub_owner.todo_list_tags
         where tag_id = l_tag_id;

        update taskhub_owner.tags
           set deleted_at = systimestamp,
               deleted_by_user_id = l_app_user_id
         where id = l_tag_id
           and app_user_id = l_app_user_id
           and deleted_at is null;

        if sql%rowcount = 0 then
            raise_application_error(-20006, 'TaskHub tag is not accessible.');
        end if;
    end delete_tag;

    function normalized_task_title(
        p_title in varchar2
    ) return varchar2
    is
        l_title varchar2(32767 char);
    begin
        l_title := trim(p_title);
        if l_title is null or length(l_title) > 200 then
            raise_application_error(-20007, 'TaskHub task input is invalid.');
        end if;
        return l_title;
    end normalized_task_title;

    function normalized_task_status(
        p_status in varchar2
    ) return varchar2
    is
        l_status varchar2(32767 char);
    begin
        l_status := upper(trim(p_status));
        if l_status is null
           or l_status not in ('OPEN', 'IN_PROGRESS', 'DONE', 'CANCELED') then
            raise_application_error(-20007, 'TaskHub task input is invalid.');
        end if;
        return l_status;
    end normalized_task_status;

    procedure validate_task_fields(
        p_description in varchar2,
        p_priority    in pls_integer
    )
    is
    begin
        if length(p_description) > 4000
           or p_priority is null
           or p_priority not in (1, 2, 3) then
            raise_application_error(-20007, 'TaskHub task input is invalid.');
        end if;
    end validate_task_fields;

    procedure require_active_task(
        p_task_id     in number,
        p_app_user_id in taskhub_owner.app_users.id%type,
        p_list_id     out taskhub_owner.todo_lists.id%type
    )
    is
    begin
        select t.todo_list_id
          into p_list_id
          from taskhub_owner.tasks t
          join taskhub_owner.todo_lists l
            on l.id = t.todo_list_id
         where t.id = p_task_id
           and t.deleted_at is null
           and l.app_user_id = p_app_user_id
           and l.deleted_at is null;
    exception
        when no_data_found then
            -- Missing, foreign-owned and inactive Tasks intentionally look identical.
            raise_application_error(-20008, 'TaskHub task is not accessible.');
    end require_active_task;

    procedure validate_task_parent(
        p_task_id        in number,
        p_list_id        in taskhub_owner.todo_lists.id%type,
        p_parent_task_id in number,
        p_app_user_id    in taskhub_owner.app_users.id%type,
        p_subtree_height in pls_integer
    )
    is
        l_parent_list_id taskhub_owner.todo_lists.id%type;
        l_parent_depth   pls_integer;
        l_cycle_found    pls_integer;
        l_cross_list     pls_integer;
        l_descendant     pls_integer;
    begin
        if p_parent_task_id is null then
            if p_subtree_height > 3 then
                raise_application_error(-20011, 'TaskHub task hierarchy is invalid.');
            end if;
            return;
        end if;

        if p_task_id is not null and p_parent_task_id = p_task_id then
            raise_application_error(-20011, 'TaskHub task hierarchy is invalid.');
        end if;

        begin
            select t.todo_list_id
              into l_parent_list_id
              from taskhub_owner.tasks t
              join taskhub_owner.todo_lists l
                on l.id = t.todo_list_id
             where t.id = p_parent_task_id
               and t.deleted_at is null
               and l.app_user_id = p_app_user_id
               and l.deleted_at is null;
        exception
            when no_data_found then
                -- Missing, foreign-owned and inactive parents share one public result.
                raise_application_error(-20009, 'TaskHub parent task is not accessible.');
        end;

        if l_parent_list_id <> p_list_id then
            raise_application_error(-20010, 'TaskHub parent task must belong to the same list.');
        end if;

        if p_task_id is not null then
            select count(*)
              into l_descendant
              from (
                  select id
                    from taskhub_owner.tasks
                   start with id = p_task_id
                          and deleted_at is null
                 connect by nocycle prior id = parent_task_id
                          and deleted_at is null
              )
             where id = p_parent_task_id;

            if l_descendant <> 0 then
                raise_application_error(-20011, 'TaskHub task hierarchy is invalid.');
            end if;
        end if;

        select nvl(max(level), 0),
               nvl(max(connect_by_iscycle), 0),
               nvl(max(case when todo_list_id <> p_list_id then 1 else 0 end), 0)
          into l_parent_depth, l_cycle_found, l_cross_list
          from taskhub_owner.tasks
         start with id = p_parent_task_id
                and deleted_at is null
       connect by nocycle prior parent_task_id = id
                and deleted_at is null;

        if l_cycle_found <> 0 then
            raise_application_error(-20011, 'TaskHub task hierarchy is invalid.');
        end if;
        if l_cross_list <> 0 then
            raise_application_error(-20010, 'TaskHub parent task must belong to the same list.');
        end if;
        if l_parent_depth + p_subtree_height > 3 then
            raise_application_error(-20011, 'TaskHub task hierarchy is invalid.');
        end if;
    end validate_task_parent;

    function create_task(
        p_todo_list_id   in number,
        p_parent_task_id in number,
        p_title          in varchar2,
        p_description    in varchar2,
        p_status         in varchar2,
        p_priority       in pls_integer,
        p_due_at         in timestamp
    ) return number
    is
        l_app_user_id taskhub_owner.app_users.id%type;
        l_title       varchar2(32767 char);
        l_status      varchar2(32767 char);
        l_task_id     taskhub_owner.tasks.id%type;
    begin
        l_app_user_id := current_app_user_id;
        l_title := normalized_task_title(p_title);
        l_status := normalized_task_status(p_status);
        validate_task_fields(p_description, p_priority);
        require_active_list(p_todo_list_id, l_app_user_id);
        validate_task_parent(
            p_task_id        => null,
            p_list_id        => p_todo_list_id,
            p_parent_task_id => p_parent_task_id,
            p_app_user_id    => l_app_user_id,
            p_subtree_height => 1
        );

        insert into taskhub_owner.tasks (
            todo_list_id,
            parent_task_id,
            title,
            description,
            status,
            priority,
            due_at,
            completed_at,
            created_by_user_id
        ) values (
            p_todo_list_id,
            p_parent_task_id,
            l_title,
            p_description,
            l_status,
            p_priority,
            p_due_at,
            case when l_status = 'DONE' then systimestamp end,
            l_app_user_id
        )
        returning id into l_task_id;

        return l_task_id;
    end create_task;

    procedure update_task(
        p_task_id        in number,
        p_parent_task_id in number,
        p_title          in varchar2,
        p_description    in varchar2,
        p_status         in varchar2,
        p_priority       in pls_integer,
        p_due_at         in timestamp
    )
    is
        l_app_user_id   taskhub_owner.app_users.id%type;
        l_list_id       taskhub_owner.todo_lists.id%type;
        l_title         varchar2(32767 char);
        l_status        varchar2(32767 char);
        l_subtree_depth pls_integer;
        l_cycle_found   pls_integer;
        l_cross_list    pls_integer;
    begin
        l_app_user_id := current_app_user_id;
        l_title := normalized_task_title(p_title);
        l_status := normalized_task_status(p_status);
        validate_task_fields(p_description, p_priority);
        require_active_task(p_task_id, l_app_user_id, l_list_id);

        select nvl(max(level), 0),
               nvl(max(connect_by_iscycle), 0),
               nvl(max(case when todo_list_id <> l_list_id then 1 else 0 end), 0)
          into l_subtree_depth, l_cycle_found, l_cross_list
          from taskhub_owner.tasks
         start with id = p_task_id
                and deleted_at is null
       connect by nocycle prior id = parent_task_id
                and deleted_at is null;

        if l_cycle_found <> 0 or l_cross_list <> 0 then
            raise_application_error(-20011, 'TaskHub task hierarchy is invalid.');
        end if;

        validate_task_parent(
            p_task_id        => p_task_id,
            p_list_id        => l_list_id,
            p_parent_task_id => p_parent_task_id,
            p_app_user_id    => l_app_user_id,
            p_subtree_height => l_subtree_depth
        );

        update taskhub_owner.tasks
           set parent_task_id = p_parent_task_id,
               title = l_title,
               description = p_description,
               status = l_status,
               priority = p_priority,
               due_at = p_due_at,
               completed_at = case
                   when l_status = 'DONE' then nvl(completed_at, systimestamp)
                   else null
               end,
               updated_at = systimestamp,
               updated_by_user_id = l_app_user_id
         where id = p_task_id
           and todo_list_id = l_list_id
           and deleted_at is null;

        if sql%rowcount = 0 then
            raise_application_error(-20008, 'TaskHub task is not accessible.');
        end if;
    end update_task;

    procedure delete_task(
        p_task_id in number
    )
    is
        l_app_user_id taskhub_owner.app_users.id%type;
        l_list_id     taskhub_owner.todo_lists.id%type;
        l_deleted_at  timestamp(6);
    begin
        l_app_user_id := current_app_user_id;
        require_active_task(p_task_id, l_app_user_id, l_list_id);
        l_deleted_at := systimestamp;

        update taskhub_owner.tasks
           set deleted_at = l_deleted_at,
               deleted_by_user_id = l_app_user_id
         where todo_list_id = l_list_id
           and deleted_at is null
           and id in (
               select id
                 from taskhub_owner.tasks
                start with id = p_task_id
                       and deleted_at is null
              connect by nocycle prior id = parent_task_id
                       and deleted_at is null
           );

        if sql%rowcount = 0 then
            raise_application_error(-20008, 'TaskHub task is not accessible.');
        end if;
    end delete_task;
end pkg_taskhub_api;
/
