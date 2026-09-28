-- Test: APEX 26.1, local image prefix, TaskHub workspace mapping, and exact POC accounts
-- Connection/schema: human-run SYSDBA connected directly to FREEPDB1
-- Preconditions: Task 70 platform configuration applied
-- Expected result: PASS

set serveroutput on
declare
    l_version      varchar2(30);
    l_image_prefix varchar2(4000);
    l_count        pls_integer;

    procedure require(p_condition boolean, p_message varchar2) is
    begin
        if not p_condition then
            raise_application_error(-20990, p_message);
        end if;
    end;
begin
    require(
        sys_context('USERENV', 'CON_NAME') = 'FREEPDB1',
        'Test must run in FREEPDB1'
    );

    select version_no into l_version from apex_release;
    require(l_version like '26.1%', 'Expected APEX 26.1; found ' || l_version);

    l_image_prefix := apex_instance_admin.get_parameter(p_parameter => 'IMAGE_PREFIX');
    require(l_image_prefix = '/i/', 'Unexpected APEX IMAGE_PREFIX: ' || l_image_prefix);

    select count(*) into l_count
      from apex_workspaces
     where workspace = 'TASKHUB';
    require(l_count = 1, 'TASKHUB workspace is missing or duplicated');

    select count(*) into l_count
      from apex_workspace_schemas
     where workspace_name = 'TASKHUB'
       and schema = 'TASKHUB_APP';
    require(l_count = 1, 'TASKHUB_APP workspace mapping is missing');

    select count(*) into l_count
      from apex_workspace_schemas
     where workspace_name = 'TASKHUB';
    require(l_count = 1, 'TASKHUB workspace has an unexpected additional schema mapping');

    select count(*) into l_count
      from apex_workspace_apex_users
     where workspace_name = 'TASKHUB';
    require(l_count = 2, 'TASKHUB workspace contains unexpected APEX accounts');

    select count(*) into l_count
      from apex_workspace_apex_users
     where workspace_name = 'TASKHUB'
       and user_name in ('TASKHUB_TEST_ALICE', 'TASKHUB_TEST_BOB')
       and is_admin = 'No'
       and is_application_developer = 'No'
       and account_locked = 'No'
       and failed_access_attempts = 0
       and password_version is not null;
    require(l_count = 2, 'Expected unlocked TaskHub end-user accounts are not usable');

    dbms_output.put_line('PASS: APEX 26.1 local images, TASKHUB workspace, mapping, and exact end-user accounts');
end;
/

select username, account_status
  from dba_users
 where username in (
       'APEX_PUBLIC_USER',
       'APEX_PUBLIC_ROUTER',
       'APEX_LISTENER',
       'APEX_REST_PUBLIC_USER',
       'ORDS_METADATA',
       'ORDS_PUBLIC_USER'
   )
 order by username;
