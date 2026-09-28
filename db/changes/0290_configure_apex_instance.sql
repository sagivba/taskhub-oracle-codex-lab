-- Task: 70 ORDS and APEX Foundation
-- Target schema: APEX instance metadata in FREEPDB1 (human-run SYSDBA)
-- Purpose: Configure the APEX static-resource prefix served by the self-contained ORDS runtime image.
-- Preconditions: APEX 26.1 is valid in FREEPDB1; execute as an authorized APEX instance administrator.
-- Verification: db/tests/structure/0410_task70_apex_platform.sql
-- Notes: No TaskHub schema privilege is added or changed.

declare
    l_version varchar2(30);
begin
    if sys_context('USERENV', 'CON_NAME') <> 'FREEPDB1' then
        raise_application_error(-20990, 'Task 70 APEX configuration must run in FREEPDB1');
    end if;

    select version_no
      into l_version
      from apex_release;

    if l_version not like '26.1%' then
        raise_application_error(-20991, 'Expected APEX 26.1; found ' || l_version);
    end if;

    apex_instance_admin.set_parameter(
        p_parameter => 'IMAGE_PREFIX',
        p_value     => '/i/'
    );
    commit;
end;
/
