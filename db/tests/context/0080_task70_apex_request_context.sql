-- Test: real APEX session initialization/cleanup is fail-closed across reused DB session state
-- Connection/schema: TASKHUB_APP
-- Preconditions: APEX application 700 is installed with Task 70 initialization and cleanup code
-- Expected result: PASS for Alice, Bob, unknown, inactive, and cleanup transitions

set serveroutput on
declare
    procedure assert_context(p_id varchar2, p_username varchar2, p_label varchar2) is
    begin
        if nvl(sys_context('TASKHUB_CTX', 'APP_USER_ID'), '#NULL#') <> nvl(p_id, '#NULL#')
           or nvl(sys_context('TASKHUB_CTX', 'APP_USERNAME'), '#NULL#') <> nvl(p_username, '#NULL#') then
            raise_application_error(-20990, 'FAIL: unexpected context after ' || p_label);
        end if;
    end;

    procedure delete_current_apex_session is
    begin
        apex_session.delete_session;
    exception
        when others then
            apex_session.detach;
    end;

    procedure assert_rejected(p_username varchar2, p_label varchar2) is
        l_error_code    pls_integer;
        l_error_message varchar2(4000);
    begin
        begin
            apex_session.create_session(
                p_app_id   => 700,
                p_page_id  => 1,
                p_username => p_username
            );
            raise_application_error(-20991, 'FAIL: ' || p_label || ' identity was accepted');
        exception
            when others then
                l_error_code := sqlcode;
                l_error_message := sqlerrm;
                if l_error_code <> -20987
                   or instr(
                          l_error_message,
                          'APEX - Error processing database session setup code'
                      ) = 0 then
                    raise_application_error(
                        -20990,
                        'FAIL: ' || p_label || ' rejection returned unexpected error ' ||
                        l_error_code || ': ' || l_error_message
                    );
                end if;
        end;
        assert_context(null, null, p_label || ' rejection');
        delete_current_apex_session;
        assert_context(null, null, p_label || ' cleanup');
    end;
begin
    taskhub_api.pkg_taskhub_context.clear_context;
    assert_context(null, null, 'explicit initial clear');

    apex_session.create_session(
        p_app_id   => 700,
        p_page_id  => 1,
        p_username => 'TASKHUB_TEST_ALICE'
    );
    assert_context('1', 'TASKHUB_TEST_ALICE', 'Alice request');
    apex_session.delete_session;
    assert_context(null, null, 'Alice cleanup');

    apex_session.create_session(
        p_app_id   => 700,
        p_page_id  => 1,
        p_username => 'TASKHUB_TEST_BOB'
    );
    assert_context('2', 'TASKHUB_TEST_BOB', 'Bob request on reused DB session');
    apex_session.delete_session;
    assert_context(null, null, 'Bob cleanup');

    assert_rejected('TASKHUB_TEST_UNKNOWN', 'unknown');
    assert_rejected('TASKHUB_TEST_INACTIVE', 'inactive');

    dbms_output.put_line('PASS: APEX request context lifecycle and fail-closed identity transitions');
exception
    when others then
        declare
            l_error_code    pls_integer := sqlcode;
            l_error_message varchar2(4000) := sqlerrm;
        begin
        taskhub_api.pkg_taskhub_context.clear_context;
        begin
            apex_session.detach;
        exception
            when others then null;
        end;
        raise_application_error(
            -20990,
            'FAIL: unexpected request-context error ' ||
            l_error_code || ': ' || l_error_message
        );
        end;
end;
/
