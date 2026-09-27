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
