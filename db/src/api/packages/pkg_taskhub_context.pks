create or replace package taskhub_api.pkg_taskhub_context
authid definer
as
    procedure init_from_apex;
    procedure clear_context;
end pkg_taskhub_context;
/
