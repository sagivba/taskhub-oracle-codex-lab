-- Task: 20 Security Context and API Layer
-- Target schema: TASKHUB_API
-- Purpose: Create the DEV-only deterministic test facade without exposing it to TASKHUB_APP.
-- Preconditions: 0100 has been applied; execute as TASKHUB_API in the DEV lab only.
-- Verification: db/tests/context/0010_valid_active_user.sql through 0060_failed_reinitialization.sql
-- Notes: This package is intentionally absent from application-facing grants.

create or replace package taskhub_api.pkg_taskhub_test_context
authid definer
as
    procedure init_for_test(p_username in varchar2);
    procedure clear_context;
end pkg_taskhub_test_context;
/

create or replace package body taskhub_api.pkg_taskhub_test_context
as
    procedure clear_context
    is
    begin
        pkg_taskhub_context_core.clear_context;
    end clear_context;

    procedure init_for_test(p_username in varchar2)
    is
    begin
        pkg_taskhub_context_core.clear_context;
        pkg_taskhub_context_core.initialize_context(p_username);
    exception
        when others then
            pkg_taskhub_context_core.clear_context;
            raise;
    end init_for_test;
end pkg_taskhub_test_context;
/
