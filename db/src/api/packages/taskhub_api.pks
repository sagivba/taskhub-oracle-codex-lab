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
