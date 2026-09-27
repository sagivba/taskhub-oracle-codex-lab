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
