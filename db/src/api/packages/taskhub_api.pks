create or replace package taskhub_api.pkg_taskhub_api
authid definer
as
    /*
     * Purpose
     *   Public business-operation boundary for TaskHub writes. The current incremental
     *   contract exposes context-owned List and Tag operations.
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
     *   means context is missing or invalid; -20003 and -20005 mean List/Tag input
     *   validation failed; -20004 and -20006 are generic inaccessible List/Tag errors.
     *   The generic errors deliberately do not disclose whether another user's or a
     *   soft-deleted object exists. Unexpected Oracle failures propagate.
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

    /*
     * Renames one active List owned by the current context user and refreshes its
     * update audit fields. Ownership and audit identity remain context-derived so a
     * caller cannot rename another user's List or spoof the updater. Missing, foreign
     * and soft-deleted IDs all raise -20004. Invalid names raise -20003. The change
     * remains in the caller's transaction.
     */
    procedure update_list(
        p_list_id   in number,   -- Candidate List ID; resolved only within the current user's active rows.
        p_list_name in varchar2  -- New visible name; required, trimmed, maximum 200 characters.
    );

    /*
     * Soft-deletes one active context-owned List and every currently active Task under
     * it. Association rows remain physically present and are hidden by the filtered
     * views because the List is inactive. Missing, foreign and already deleted IDs all
     * raise -20004 to prevent existence disclosure. The caller controls the transaction.
     */
    procedure delete_list(
        p_list_id in number  -- Candidate List ID; resolved only within the current user's active rows.
    );

    /*
     * Adds a normalized Tag to an active context-owned List, creating the current
     * user's Tag when no active UPPER(TRIM(TAG_NAME)) match exists. The stored display
     * name is trimmed but preserves case. Active-only database uniqueness arbitrates
     * concurrent creation, and an existing association is a successful no-op. A List
     * inaccessible to the current user raises -20004; invalid Tag input raises -20005.
     * All steps participate in the caller's transaction.
     */
    procedure add_tag_to_list(
        p_list_id  in number,   -- Active List ID resolved only for the current context user.
        p_tag_name in varchar2  -- Tag display name; required, trimmed, maximum 100 characters.
    );

    /*
     * Physically removes only the association between an active context-owned List and
     * an active Tag owned by that same user. The Tag itself is unchanged, and a missing
     * association is a successful no-op. Inaccessible Lists and Tags raise the generic
     * -20004 and -20006 errors respectively. The caller controls the transaction.
     */
    procedure remove_tag_from_list(
        p_list_id  in number,   -- Active List ID resolved only for the current context user.
        p_tag_name in varchar2  -- Tag name matched by UPPER(TRIM(...)) for the current user only.
    );

    /*
     * Resolves an active Tag by current context user plus normalized name, physically
     * removes its association rows, then soft-deletes the Tag. Historical rows are
     * never undeleted, so later reuse creates a new ID. Missing, foreign and already
     * deleted matches all raise -20006 without disclosing existence. The caller owns
     * the transaction boundary.
     */
    procedure delete_tag(
        p_tag_name in varchar2  -- Tag name matched by UPPER(TRIM(...)) for the current user only.
    );
end pkg_taskhub_api;
/
