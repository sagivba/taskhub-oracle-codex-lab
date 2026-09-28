-- Canonical Task 70 APEX instance state.
declare
    l_version varchar2(30);
begin
    select version_no into l_version from apex_release;
    apex_instance_admin.set_parameter(
        p_parameter => 'IMAGE_PREFIX',
        p_value     => '/i/'
    );
    commit;
end;
/
