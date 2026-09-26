-- Task: 20 Security Context and API Layer - Create TODO List slice
-- Target schema: TASKHUB_API
-- Purpose: Create the minimal definer-rights API entry point for creating a context-owned TODO list.
-- Preconditions: 0100 and 0140 have been applied; execute as TASKHUB_API.
-- Verification: db/tests/functional/0010_create_todo_list.sql and db/tests/security/0040_unset_context_rejected.sql
-- Notes: The package performs no COMMIT or ROLLBACK and accepts no ownership identifier.

create or replace package taskhub_api.pkg_taskhub_api
authid definer
as
    function create_list(p_list_name in varchar2) return number;
end pkg_taskhub_api;
/

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

    function create_list(p_list_name in varchar2) return number
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

        insert into taskhub_owner.todo_lists (app_user_id, list_name, created_by_user_id)
        values (l_app_user_id, l_list_name, l_app_user_id)
        returning id into l_list_id;

        return l_list_id;
    end create_list;
end pkg_taskhub_api;
/
