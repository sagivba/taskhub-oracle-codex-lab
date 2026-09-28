-- Task: 70 ORDS and APEX Foundation
-- Target schema: APEX workspace metadata in FREEPDB1 (human-run SYSDBA)
-- Purpose: Create or reset the two POC-only Oracle APEX Accounts end users.
-- Preconditions: db/changes/0300_create_taskhub_apex_workspace.sql has succeeded;
--                SQLcl defines TASKHUB_APEX_ALICE_PASSWORD and TASKHUB_APEX_BOB_PASSWORD.
-- Verification: db/tests/structure/0410_task70_apex_platform.sql
-- Notes: Names remain exact and uppercase because APP_USERS lookup is case-sensitive.

declare
    l_workspace_id number;
    l_user_id      number;
    l_count        pls_integer;

    procedure upsert_end_user(
        p_username varchar2,
        p_password varchar2,
        p_first_name varchar2
    ) is
    begin
        l_user_id := apex_util.get_user_id(p_username => p_username);
        if l_user_id is null then
            apex_util.create_user(
                p_user_name                    => p_username,
                p_first_name                   => p_first_name,
                p_description                  => 'TaskHub Task 70 POC end user',
                p_web_password                 => p_password,
                p_developer_privs              => null,
                p_default_schema               => 'TASKHUB_APP',
                p_allow_access_to_schemas      => 'TASKHUB_APP',
                p_account_locked               => 'N',
                p_change_password_on_first_use => 'N',
                p_allow_app_building_yn        => 'N',
                p_allow_sql_workshop_yn        => 'N',
                p_allow_websheet_dev_yn        => 'N',
                p_allow_team_development_yn    => 'N'
            );
        else
            apex_util.edit_user(
                p_user_id                      => l_user_id,
                p_user_name                    => p_username,
                p_first_name                   => p_first_name,
                p_web_password                 => p_password,
                p_new_password                 => p_password,
                p_allow_access_to_schemas      => 'TASKHUB_APP',
                p_default_schema               => 'TASKHUB_APP',
                p_developer_roles              => null,
                p_description                  => 'TaskHub Task 70 POC end user',
                p_account_locked               => 'N',
                p_failed_access_attempts       => 0,
                p_change_password_on_first_use => 'N',
                p_first_password_use_occurred  => 'N'
            );
        end if;
    end;
begin
    if sys_context('USERENV', 'CON_NAME') <> 'FREEPDB1' then
        raise_application_error(-20990, 'Task 70 account configuration must run in FREEPDB1');
    end if;

    select count(*)
      into l_count
      from taskhub_owner.app_users
     where username in ('TASKHUB_TEST_ALICE', 'TASKHUB_TEST_BOB')
       and is_active = 'Y';
    if l_count <> 2 then
        raise_application_error(-20991, 'Both TaskHub APEX identities must map to active APP_USERS rows');
    end if;

    l_workspace_id := apex_util.find_security_group_id(p_workspace => 'TASKHUB');
    if l_workspace_id is null then
        raise_application_error(-20992, 'TASKHUB APEX workspace does not exist');
    end if;

    apex_util.set_security_group_id(p_security_group_id => l_workspace_id);
    upsert_end_user('TASKHUB_TEST_ALICE', '&TASKHUB_APEX_ALICE_PASSWORD.', 'Alice');
    upsert_end_user('TASKHUB_TEST_BOB', '&TASKHUB_APEX_BOB_PASSWORD.', 'Bob');

    select count(*) into l_count
      from apex_workspace_apex_users
     where workspace_name = 'TASKHUB';
    if l_count <> 2 then
        raise_application_error(-20993, 'TASKHUB workspace contains unexpected APEX accounts');
    end if;

    select count(*) into l_count
      from apex_workspace_apex_users
     where workspace_name = 'TASKHUB'
       and user_name in ('TASKHUB_TEST_ALICE', 'TASKHUB_TEST_BOB')
       and is_admin = 'No'
       and is_application_developer = 'No'
       and account_locked = 'No'
       and failed_access_attempts = 0
       and password_version is not null;
    if l_count <> 2 then
        raise_application_error(-20994, 'TaskHub APEX account postcondition failed');
    end if;

    commit;
end;
/
