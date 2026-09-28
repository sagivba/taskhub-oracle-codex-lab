-- Canonical Task 70 APEX instance ADMIN state. Password is supplied only at replay time.
begin
    apex_instance_admin.create_or_update_admin_user(
        p_username => 'ADMIN'
    );
    apex_instance_admin.unlock_user(
        p_workspace => 'INTERNAL',
        p_username  => 'ADMIN',
        p_password  => '&TASKHUB_APEX_ADMIN_PASSWORD.'
    );
    commit;
end;
/
