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
