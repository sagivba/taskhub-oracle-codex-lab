-- Task: 70 ORDS and APEX Foundation
-- Target schema: APEX instance metadata in FREEPDB1 (human-run SYSDBA)
-- Purpose: Resume the failed APEX 26.1 ADMIN account configuration without rerunning the core installation.
-- Preconditions: APEX 26.1 is registered VALID; SQLcl defines TASKHUB_APEX_ADMIN_PASSWORD.
-- Verification: This script fails unless the unlocked INTERNAL ADMIN account exists with the ADMIN role.
-- Notes: This recovery step does not change TaskHub schema privileges or database/ORDS passwords.

declare
    l_count pls_integer;
begin
    if sys_context('USERENV', 'CON_NAME') <> 'FREEPDB1' then
        raise_application_error(-20990, 'Task 70 APEX ADMIN recovery must run in FREEPDB1');
    end if;

    select count(*)
      into l_count
      from dba_registry
     where comp_id = 'APEX'
       and status = 'VALID'
       and version like '26.1%';

    if l_count <> 1 then
        raise_application_error(-20991, 'APEX 26.1 must be registered VALID before ADMIN recovery');
    end if;
end;
/

column TASKHUB_APEX_SCHEMA new_value TASKHUB_APEX_SCHEMA noprint
select schema as TASKHUB_APEX_SCHEMA
  from dba_registry
 where comp_id = 'APEX'
   and status = 'VALID'
   and version like '26.1%';

alter session set current_schema = &TASKHUB_APEX_SCHEMA.;

variable TASKHUB_APEX_ADMIN_PASSWORD varchar2(128)
begin
    :TASKHUB_APEX_ADMIN_PASSWORD := '&TASKHUB_APEX_ADMIN_PASSWORD.';
end;
/

begin
    apex_instance_admin.create_or_update_admin_user(
        p_username => 'ADMIN'
    );
    apex_instance_admin.unlock_user(
        p_workspace => 'INTERNAL',
        p_username  => 'ADMIN',
        p_password  => :TASKHUB_APEX_ADMIN_PASSWORD
    );
    commit;
end;
/

declare
    l_count pls_integer;
begin
    select count(*)
      into l_count
      from wwv_flow_fnd_user u
      join wwv_flow_developers d
        on d.user_id = u.user_id
     where u.security_group_id = 10
       and u.user_name = 'ADMIN'
       and nvl(u.account_locked, 'N') = 'N'
       and instr(':' || d.developer_role || ':', ':ADMIN:') > 0;

    if l_count <> 1 then
        raise_application_error(-20992, 'APEX ADMIN postcondition failed');
    end if;
end;
/

alter session set current_schema = SYS;
undefine TASKHUB_APEX_SCHEMA
