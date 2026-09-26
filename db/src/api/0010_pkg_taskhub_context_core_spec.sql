create or replace package taskhub_api.pkg_taskhub_context_core
authid definer
as
    procedure initialize_context(
        p_username in varchar2
    );

    procedure clear_context;
end pkg_taskhub_context_core;
/
