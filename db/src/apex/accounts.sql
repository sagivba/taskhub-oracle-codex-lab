-- Canonical shape of the POC APEX end users. Passwords are supplied only at replay time.
declare
    l_workspace_id number;
    l_user_id      number;

    procedure upsert_end_user(
        p_username   varchar2,
        p_password   varchar2,
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
    l_workspace_id := apex_util.find_security_group_id(p_workspace => 'TASKHUB');
    if l_workspace_id is null then
        raise_application_error(-20992, 'TASKHUB APEX workspace does not exist');
    end if;

    apex_util.set_security_group_id(p_security_group_id => l_workspace_id);
    upsert_end_user('TASKHUB_TEST_ALICE', '&TASKHUB_APEX_ALICE_PASSWORD.', 'Alice');
    upsert_end_user('TASKHUB_TEST_BOB', '&TASKHUB_APEX_BOB_PASSWORD.', 'Bob');
    commit;
end;
/
