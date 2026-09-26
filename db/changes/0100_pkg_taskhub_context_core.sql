-- Task: 20 Security Context and API Layer
-- Target schema: TASKHUB_API
-- Purpose: Replace the bootstrap setter with validated APP_USER_ID and APP_USERNAME initialization.
-- Preconditions: 0080 and 0090 have been applied; execute as TASKHUB_API.
-- Verification: db/tests/context/0010_valid_active_user.sql through 0060_failed_reinitialization.sql
-- Notes: The trusted core remains ungranted to TASKHUB_APP.

create or replace package taskhub_api.pkg_taskhub_context_core
authid definer
as
    procedure initialize_context(
        p_username in varchar2
    );

    procedure clear_context;
end pkg_taskhub_context_core;
/

create or replace package body taskhub_api.pkg_taskhub_context_core
as
    procedure clear_context
    is
    begin
        dbms_session.clear_context(namespace => 'TASKHUB_CTX');
    end clear_context;

    procedure initialize_context(
        p_username in varchar2
    )
    is
        l_app_user_id taskhub_owner.app_users.id%type;
        l_username    taskhub_owner.app_users.username%type;
    begin
        clear_context;

        select id, username
          into l_app_user_id, l_username
          from taskhub_owner.app_users
         where username = trim(p_username)
           and is_active = 'Y';

        dbms_session.set_context(
            namespace => 'TASKHUB_CTX',
            attribute => 'APP_USER_ID',
            value     => to_char(l_app_user_id, 'TM9')
        );

        dbms_session.set_context(
            namespace => 'TASKHUB_CTX',
            attribute => 'APP_USERNAME',
            value     => l_username
        );
    exception
        when no_data_found then
            clear_context;
            raise_application_error(-20001, 'TaskHub application identity is invalid.');
        when others then
            clear_context;
            raise;
    end initialize_context;
end pkg_taskhub_context_core;
/
