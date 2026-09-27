create or replace package body taskhub_api.pkg_taskhub_test_context
as
    procedure clear_context
    is
    begin
        pkg_taskhub_context_core.clear_context;
    end clear_context;

    procedure init_for_test(
        p_username in varchar2
    )
    is
    begin
        -- This username-taking path is isolated in a package not granted to TASKHUB_APP.
        pkg_taskhub_context_core.clear_context;
        pkg_taskhub_context_core.initialize_context(p_username);
    exception
        when others then
            pkg_taskhub_context_core.clear_context;
            raise;
    end init_for_test;
end pkg_taskhub_test_context;
/
