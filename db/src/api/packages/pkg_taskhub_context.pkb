create or replace package body taskhub_api.pkg_taskhub_context
as
    procedure clear_context
    is
    begin
        pkg_taskhub_context_core.clear_context;
    end clear_context;

    procedure init_from_apex
    is
        l_username varchar2(128 char);
    begin
        pkg_taskhub_context_core.clear_context;
        l_username := sys_context('APEX$SESSION', 'APP_USER');
        pkg_taskhub_context_core.initialize_context(l_username);
    exception
        when others then
            pkg_taskhub_context_core.clear_context;
            raise;
    end init_from_apex;
end pkg_taskhub_context;
/
