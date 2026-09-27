-- Task: Documentation hardening
-- Target schema: TASKHUB_API
-- Purpose: Publish WHAT/WHY public contracts in package specifications and rationale-only body comments.
-- Preconditions: Changes 0100 through 0160 are deployed; execute as TASKHUB_API.
-- Verification: db/tests/structure/0360_package_documentation.sql, USER_ERRORS and unchanged USER_ARGUMENTS manifest.
-- Notes: Documentation-only CREATE OR REPLACE; public signatures and executable behavior are unchanged.

create or replace package taskhub_api.pkg_taskhub_context_core
authid definer
as
    /*
     * Purpose
     *   Trusted setter for the session-scoped TASKHUB_CTX namespace. It resolves a
     *   canonical active APP_USERS row before publishing APP_USER_ID and APP_USERNAME.
     *
     * Trust boundary and rationale
     *   This definer-rights package is named by CREATE CONTEXT. It sits inside
     *   TASKHUB_API between runtime/test facades and TASKHUB_OWNER.APP_USERS.
     *   TASKHUB_APP deliberately has no EXECUTE grant because direct access would let
     *   the restricted runtime principal attempt to impersonate another application
     *   user. Only the approved facades may request initialization.
     *
     * Security and session model
     *   Initialization clears prior TASKHUB_CTX state before lookup, accepts only an
     *   active canonical username, and sets both context attributes only after full
     *   validation. Failure clears the context again, preventing reused sessions from
     *   inheriting stale identity.
     *
     * Transaction and error model
     *   The package changes session context only and does not COMMIT or ROLLBACK.
     *   Missing, unknown and inactive identities raise application error -20001 with
     *   the same external message so identity existence/status is not disclosed.
     *
     * Testability
     *   DEV tests reach this core through PKG_TASKHUB_TEST_CONTEXT, which is isolated
     *   from TASKHUB_APP. Runtime code reaches it through PKG_TASKHUB_CONTEXT.
     */

    /*
     * Resolves one active canonical application identity and replaces the current
     * TASKHUB_CTX values. The username is not a CRUD ownership parameter; it is
     * supplied only by a trusted runtime or DEV-test facade.
     *
     * Side effects: clears TASKHUB_CTX, then sets APP_USER_ID and APP_USERNAME.
     * Errors: -20001 when the username is missing, unknown or inactive; context is
     * empty after every failure. No transaction control is performed.
     */
    procedure initialize_context(
        p_username in varchar2  -- Canonical username from an approved facade; never a direct TASKHUB_APP input.
    );

    /*
     * Clears every attribute in TASKHUB_CTX for the current database session. This is
     * required at request/test boundaries because SQLcl, MCP and connection pools may
     * reuse sessions. The operation performs no transaction control.
     */
    procedure clear_context;
end pkg_taskhub_context_core;
/

create or replace package body taskhub_api.pkg_taskhub_context_core
as

    procedure clear_context
    is
    begin
        dbms_session.clear_context(
            namespace => 'TASKHUB_CTX'
        );
    end clear_context;


    procedure initialize_context(
        p_username in varchar2
    )
    is
        l_app_user_id taskhub_owner.app_users.id%type;
        l_username    taskhub_owner.app_users.username%type;
    begin
        -- Clear first so lookup failure cannot preserve identity from a reused session.
        clear_context;

        select id,
               username
          into l_app_user_id,
               l_username
          from taskhub_owner.app_users
         where username = trim(p_username)
           and is_active = 'Y';

        dbms_session.set_context(
            namespace => 'TASKHUB_CTX',
            attribute => 'APP_USER_ID',
            value     => to_char(l_app_user_id, 'TM9')
        );

        dbms_session.set_context(
            namespace => 'TASKHUB_CTX',
            attribute => 'APP_USERNAME',
            value     => l_username
        );
    exception
        when no_data_found then
            -- Unknown and inactive identities intentionally share one failure contract.
            clear_context;
            raise_application_error(-20001, 'TaskHub application identity is invalid.');
        when others then
            clear_context;
            raise;
    end initialize_context;

end pkg_taskhub_context_core;
/

create or replace package taskhub_api.pkg_taskhub_context
authid definer
as
    /*
     * Purpose
     *   Runtime application-context facade for a future APEX parsing schema.
     *
     * Trust boundary and rationale
     *   TASKHUB_APP receives EXECUTE on this package but not on the trusted core.
     *   The facade accepts no username parameter: it reads APEX$SESSION.APP_USER and
     *   delegates canonical validation to PKG_TASKHUB_CONTEXT_CORE. This prevents a
     *   runtime caller from selecting another user's identity while preserving the
     *   TASKHUB_APP -> TASKHUB_API -> TASKHUB_OWNER boundary.
     *
     * Security and session model
     *   TASKHUB_CTX is session scoped. Every initialization clears old state first;
     *   missing, unknown or inactive APEX identities fail closed and leave both
     *   APP_USER_ID and APP_USERNAME empty. Context values are readable through
     *   SYS_CONTEXT, but only the trusted core can set them.
     *
     * Transaction and error model
     *   Context operations neither COMMIT nor ROLLBACK. Invalid initialization
     *   propagates application error -20001 from the core.
     *
     * Testability
     *   Non-APEX DEV tests use PKG_TASKHUB_TEST_CONTEXT instead. Separating that hook
     *   prevents the runtime principal from gaining arbitrary-identity initialization.
     */

    /*
     * Initializes TASKHUB_CTX from APEX$SESSION.APP_USER for the current request.
     * Preconditions: a valid APEX username mapping to one active APP_USERS row.
     * Side effects: replaces session identity. Error -20001 covers missing, unknown
     * or inactive identity. No transaction control is performed.
     */
    procedure init_from_apex;

    /*
     * Clears TASKHUB_CTX so a reused runtime session cannot retain a prior request's
     * identity. No transaction control is performed.
     */
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
        -- Runtime identity comes only from APEX session state, never a caller parameter.
        pkg_taskhub_context_core.clear_context;
        l_username := sys_context('APEX$SESSION', 'APP_USER');
        pkg_taskhub_context_core.initialize_context(l_username);
    exception
        when others then
            -- Fail closed even if future core logic fails after partial context work.
            pkg_taskhub_context_core.clear_context;
            raise;
    end init_from_apex;
end pkg_taskhub_context;
/

create or replace package taskhub_api.pkg_taskhub_test_context
authid definer
as
    /*
     * Purpose
     *   DEV-only facade for deterministic identity-sensitive tests without APEX.
     *
     * Trust boundary and rationale
     *   The package is owned by TASKHUB_API but is not granted to TASKHUB_APP and is
     *   excluded from production-like deployment by default. Oracle grants EXECUTE at
     *   package level, so isolating test initialization prevents the runtime principal
     *   from calling a username-taking hook to impersonate another application user.
     *
     * Security, session and error model
     *   The facade delegates to the trusted core, which clears stale state, resolves
     *   one active APP_USERS row and sets TASKHUB_CTX.APP_USER_ID/APP_USERNAME. Missing,
     *   unknown or inactive usernames raise -20001 and leave context empty. The package
     *   changes session state only and never COMMITs or ROLLBACKs.
     *
     * Testability
     *   Every test explicitly clears and initializes identity in its own flow so test
     *   order and SQLcl/MCP session reuse cannot hide stale-context defects.
     */

    /*
     * Initializes a deterministic active identity for a DEV test. The username is
     * caller controlled only by trusted test code, never by TASKHUB_APP or a business
     * API. Error -20001 covers missing, unknown and inactive identities. No transaction
     * control is performed.
     */
    procedure init_for_test(
        p_username in varchar2  -- Canonical test username; accepted only through this ungranted DEV facade.
    );

    /*
     * Clears TASKHUB_CTX for the current test session, preventing order-dependent or
     * stale identity. No transaction control is performed.
     */
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

create or replace package taskhub_api.pkg_taskhub_api
authid definer
as
    /*
     * Purpose
     *   Public business-operation boundary for TaskHub writes. The current incremental
     *   contract exposes list creation; later approved tasks may add operations.
     *
     * Trust boundary and rationale
     *   TASKHUB_APP is a restricted runtime principal and receives EXECUTE on this
     *   definer-rights package, not direct DML on TASKHUB_OWNER tables. TASKHUB_API has
     *   only direct object grants required by approved operations. This centralizes
     *   ownership, audit and validation so a runtime caller cannot bypass them.
     *
     * Identity and security model
     *   Identity comes from validated TASKHUB_CTX.APP_USER_ID and APP_USERNAME,
     *   originally resolved from APP_USERS by the trusted context path. Callers may
     *   control business input such as a list name but must never control APP_USER_ID,
     *   owner IDs or audit-user IDs. Active context identity is revalidated before DML.
     *
     * Transaction model and rationale
     *   The package never COMMITs or ROLLBACKs. The caller owns the transaction boundary
     *   so multiple API calls can form one atomic business operation.
     *
     * Error model
     *   Application errors are local rather than centrally catalogued. Error -20002
     *   means context is missing or invalid; -20003 means list-name validation failed.
     *   Unexpected Oracle failures propagate.
     *
     * Testability
     *   DEV tests initialize identity through the isolated test facade, verify derived
     *   ownership/audit values, and roll back. Security tests prove TASKHUB_APP cannot
     *   write owner tables directly.
     */

    /*
     * Creates one canonical TODO list for the current validated context identity and
     * returns its database-generated ID.
     *
     * Authorization and rationale: ownership and CREATED_BY_USER_ID are derived from
     * TASKHUB_CTX rather than accepted as parameters, preventing one user from creating
     * data on behalf of another. Preconditions: initialized active context and a
     * nonblank name of at most 200 characters. Side effects: inserts one TODO_LISTS row.
     * Errors: -20002 for invalid context; -20003 for invalid name. The insert participates
     * in the caller's transaction and performs no COMMIT or ROLLBACK.
     */
    function create_list(
        p_list_name in varchar2  -- Caller-supplied visible name; required, trimmed, maximum 200 characters.
    ) return number;
end pkg_taskhub_api;
/

create or replace package body taskhub_api.pkg_taskhub_api
as
    function current_app_user_id
        return taskhub_owner.app_users.id%type
    is
        l_context_user_id  varchar2(4000 char);
        l_context_username varchar2(4000 char);
        l_app_user_id      taskhub_owner.app_users.id%type;
    begin
        l_context_user_id := sys_context('TASKHUB_CTX', 'APP_USER_ID');
        l_context_username := sys_context('TASKHUB_CTX', 'APP_USERNAME');

        if l_context_user_id is null or l_context_username is null then
            raise_application_error(-20002, 'TaskHub application context is not initialized.');
        end if;

        -- Revalidate both context attributes and active status so deactivation or
        -- malformed/stale session state fails before any owner-table DML.
        select id
          into l_app_user_id
          from taskhub_owner.app_users
         where id = to_number(l_context_user_id)
           and username = l_context_username
           and is_active = 'Y';

        return l_app_user_id;
    exception
        when no_data_found or value_error then
            raise_application_error(-20002, 'TaskHub application context is not initialized.');
    end current_app_user_id;

    function create_list(
        p_list_name in varchar2
    ) return number
    is
        l_app_user_id taskhub_owner.app_users.id%type;
        l_list_name   varchar2(32767 char);
        l_list_id     number;
    begin
        l_app_user_id := current_app_user_id;
        l_list_name := trim(p_list_name);

        if l_list_name is null or length(l_list_name) > 200 then
            raise_application_error(-20003, 'TaskHub list name is invalid.');
        end if;

        -- Ownership and creator audit are derived from trusted context; accepting
        -- either from the caller would enable cross-user spoofing.
        insert into taskhub_owner.todo_lists (
            app_user_id,
            list_name,
            created_by_user_id
        ) values (
            l_app_user_id,
            l_list_name,
            l_app_user_id
        )
        returning id into l_list_id;

        return l_list_id;
    end create_list;
end pkg_taskhub_api;
/

