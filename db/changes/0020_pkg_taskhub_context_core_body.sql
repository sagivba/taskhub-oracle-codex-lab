create or replace package body taskhub_api.pkg_taskhub_context_core
as

    procedure clear_context
    is
    begin
        dbms_session.clear_context(
            namespace => 'TASKHUB_CTX'
        );
    end clear_context;


    procedure init_for_test(
        p_username in varchar2
    )
    is
    begin
        clear_context;

        dbms_session.set_context(
            namespace => 'TASKHUB_CTX',
            attribute => 'APP_USER',
            value     => upper(trim(p_username))
        );
    end init_for_test;

end pkg_taskhub_context_core;
/
