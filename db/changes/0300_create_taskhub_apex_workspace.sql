-- Task: 70 ORDS and APEX Foundation
-- Target schema: APEX instance metadata in FREEPDB1 (human-run SYSDBA)
-- Purpose: Create the TASKHUB workspace with TASKHUB_APP as its only schema mapping.
-- Preconditions: APEX 26.1 is valid in FREEPDB1 and TASKHUB_APP exists.
-- Verification: db/tests/structure/0410_task70_apex_platform.sql
-- Notes: Existing workspaces with a different mapping cause a fail-closed error.

declare
    l_workspace_id number;
    l_schemas      varchar2(4000);
    l_count        pls_integer;
begin
    if sys_context('USERENV', 'CON_NAME') <> 'FREEPDB1' then
        raise_application_error(-20990, 'Task 70 workspace configuration must run in FREEPDB1');
    end if;

    l_workspace_id := apex_util.find_security_group_id(p_workspace => 'TASKHUB');

    if l_workspace_id is null then
        apex_instance_admin.add_workspace(
            p_workspace          => 'TASKHUB',
            p_primary_schema     => 'TASKHUB_APP',
            p_additional_schemas => null
        );
    else
        l_schemas := apex_instance_admin.get_schemas(p_workspace => 'TASKHUB');
        if upper(trim(l_schemas)) <> 'TASKHUB_APP' then
            raise_application_error(
                -20991,
                'TASKHUB workspace has an unexpected schema mapping: ' || l_schemas
            );
        end if;
    end if;

    select count(*) into l_count
      from apex_workspaces
     where workspace = 'TASKHUB';
    if l_count <> 1 then
        raise_application_error(-20992, 'TASKHUB workspace postcondition failed');
    end if;

    select count(*) into l_count
      from apex_workspace_schemas
     where workspace_name = 'TASKHUB'
       and schema = 'TASKHUB_APP';
    if l_count <> 1 then
        raise_application_error(-20993, 'TASKHUB_APP workspace mapping postcondition failed');
    end if;

    select count(*) into l_count
      from apex_workspace_schemas
     where workspace_name = 'TASKHUB';
    if l_count <> 1 then
        raise_application_error(-20994, 'TASKHUB workspace has an unexpected additional schema mapping');
    end if;

    commit;
end;
/
