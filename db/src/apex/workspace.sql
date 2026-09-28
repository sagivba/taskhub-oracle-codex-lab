-- Canonical TaskHub APEX workspace mapping.
declare
    l_workspace_id number;
    l_schemas      varchar2(4000);
begin
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
            raise_application_error(-20991, 'Unexpected TASKHUB workspace schema mapping');
        end if;
    end if;
    commit;
end;
/
