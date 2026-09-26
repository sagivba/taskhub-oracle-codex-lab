create or replace package taskhub_api.pkg_taskhub_context_core
authid definer
as
    procedure init_for_test(
        p_username in varchar2
    );

    procedure clear_context;
end pkg_taskhub_context_core;
/
