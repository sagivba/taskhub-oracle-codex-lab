-- Task: 20 Security Context and API Layer
-- Target schema: TASKHUB_API
-- Purpose: Create the runtime APEX facade for deterministic TaskHub context initialization and clearing.
-- Preconditions: 0100 has been applied; execute as TASKHUB_API.
-- Verification: db/tests/context/0070_runtime_failed_initialization.sql
-- Notes: INIT_FROM_APEX reads APEX$SESSION.APP_USER and accepts no caller-supplied identity.

create or replace package taskhub_api.pkg_taskhub_context
authid definer
as
    procedure init_from_apex;
    procedure clear_context;
end pkg_taskhub_context;
/

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
