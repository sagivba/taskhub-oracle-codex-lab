-- Task: 40 List and Tag API
-- Target schema: TASKHUB_API
-- Purpose: Add context-owned List update/delete and normalized Tag association lifecycle operations.
-- Preconditions: db/changes/0220_grant_list_tag_api_dml.sql has been applied; execute as TASKHUB_API.
-- Verification: db/tests/structure/0360_package_documentation.sql
--               db/tests/functional/0070_task40_list_tag_api.sql
--               db/tests/security/0110_task40_missing_context.sql
-- Notes: Missing/foreign/deleted objects share generic errors; the package leaves transaction control to its caller.

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

    function normalized_list_name(
        p_list_name in varchar2
    ) return varchar2
    is
        l_list_name varchar2(32767 char);
    begin
        l_list_name := trim(p_list_name);
        if l_list_name is null or length(l_list_name) > 200 then
            raise_application_error(-20003, 'TaskHub list name is invalid.');
        end if;
        return l_list_name;
    end normalized_list_name;

    function normalized_tag_name(
        p_tag_name in varchar2
    ) return varchar2
    is
        l_tag_name varchar2(32767 char);
    begin
        l_tag_name := trim(p_tag_name);
        if l_tag_name is null or length(l_tag_name) > 100 then
            raise_application_error(-20005, 'TaskHub tag name is invalid.');
        end if;
        return l_tag_name;
    end normalized_tag_name;

    procedure require_active_list(
        p_list_id     in number,
        p_app_user_id in taskhub_owner.app_users.id%type
    )
    is
        l_list_id taskhub_owner.todo_lists.id%type;
    begin
        select id
          into l_list_id
          from taskhub_owner.todo_lists
         where id = p_list_id
           and app_user_id = p_app_user_id
           and deleted_at is null;
    exception
        when no_data_found then
            -- One public result covers missing, foreign-owned and inactive Lists.
            raise_application_error(-20004, 'TaskHub list is not accessible.');
    end require_active_list;

    procedure update_list(
        p_list_id   in number,
        p_list_name in varchar2
    )
    is
        l_app_user_id taskhub_owner.app_users.id%type;
        l_list_name   varchar2(32767 char);
    begin
        l_app_user_id := current_app_user_id;
        l_list_name := normalized_list_name(p_list_name);

        update taskhub_owner.todo_lists
           set list_name = l_list_name,
               updated_at = systimestamp,
               updated_by_user_id = l_app_user_id
         where id = p_list_id
           and app_user_id = l_app_user_id
           and deleted_at is null;

        if sql%rowcount = 0 then
            raise_application_error(-20004, 'TaskHub list is not accessible.');
        end if;
    end update_list;

    procedure delete_list(
        p_list_id in number
    )
    is
        l_app_user_id taskhub_owner.app_users.id%type;
        l_deleted_at  timestamp(6);
    begin
        l_app_user_id := current_app_user_id;
        l_deleted_at := systimestamp;

        update taskhub_owner.todo_lists
           set deleted_at = l_deleted_at,
               deleted_by_user_id = l_app_user_id
         where id = p_list_id
           and app_user_id = l_app_user_id
           and deleted_at is null;

        if sql%rowcount = 0 then
            raise_application_error(-20004, 'TaskHub list is not accessible.');
        end if;

        update taskhub_owner.tasks
           set deleted_at = l_deleted_at,
               deleted_by_user_id = l_app_user_id
         where todo_list_id = p_list_id
           and deleted_at is null;
    end delete_list;

    procedure add_tag_to_list(
        p_list_id  in number,
        p_tag_name in varchar2
    )
    is
        l_app_user_id taskhub_owner.app_users.id%type;
        l_tag_name    varchar2(32767 char);
        l_tag_id      taskhub_owner.tags.id%type;
    begin
        l_app_user_id := current_app_user_id;
        l_tag_name := normalized_tag_name(p_tag_name);
        require_active_list(p_list_id, l_app_user_id);

        begin
            select id
              into l_tag_id
              from taskhub_owner.tags
             where app_user_id = l_app_user_id
               and deleted_at is null
               and upper(trim(tag_name)) = upper(l_tag_name);
        exception
            when no_data_found then
                begin
                    insert into taskhub_owner.tags (
                        app_user_id,
                        tag_name,
                        created_by_user_id
                    ) values (
                        l_app_user_id,
                        l_tag_name,
                        l_app_user_id
                    )
                    returning id into l_tag_id;
                exception
                    when dup_val_on_index then
                        -- The active-only unique index arbitrates concurrent creation.
                        select id
                          into l_tag_id
                          from taskhub_owner.tags
                         where app_user_id = l_app_user_id
                           and deleted_at is null
                           and upper(trim(tag_name)) = upper(l_tag_name);
                end;
        end;

        begin
            insert into taskhub_owner.todo_list_tags (todo_list_id, tag_id)
            values (p_list_id, l_tag_id);
        exception
            when dup_val_on_index then
                -- Re-adding the same List/Tag pair is intentionally idempotent.
                null;
        end;
    end add_tag_to_list;

    procedure remove_tag_from_list(
        p_list_id  in number,
        p_tag_name in varchar2
    )
    is
        l_app_user_id taskhub_owner.app_users.id%type;
        l_tag_name    varchar2(32767 char);
        l_tag_id      taskhub_owner.tags.id%type;
    begin
        l_app_user_id := current_app_user_id;
        l_tag_name := normalized_tag_name(p_tag_name);
        require_active_list(p_list_id, l_app_user_id);

        begin
            select id
              into l_tag_id
              from taskhub_owner.tags
             where app_user_id = l_app_user_id
               and deleted_at is null
               and upper(trim(tag_name)) = upper(l_tag_name);
        exception
            when no_data_found then
                raise_application_error(-20006, 'TaskHub tag is not accessible.');
        end;

        delete from taskhub_owner.todo_list_tags
         where todo_list_id = p_list_id
           and tag_id = l_tag_id;
    end remove_tag_from_list;

    procedure delete_tag(
        p_tag_name in varchar2
    )
    is
        l_app_user_id taskhub_owner.app_users.id%type;
        l_tag_name    varchar2(32767 char);
        l_tag_id      taskhub_owner.tags.id%type;
    begin
        l_app_user_id := current_app_user_id;
        l_tag_name := normalized_tag_name(p_tag_name);

        begin
            select id
              into l_tag_id
              from taskhub_owner.tags
             where app_user_id = l_app_user_id
               and deleted_at is null
               and upper(trim(tag_name)) = upper(l_tag_name)
             for update;
        exception
            when no_data_found then
                raise_application_error(-20006, 'TaskHub tag is not accessible.');
        end;

        -- Association rows have no soft-delete lifecycle and are removed first.
        delete from taskhub_owner.todo_list_tags
         where tag_id = l_tag_id;

        update taskhub_owner.tags
           set deleted_at = systimestamp,
               deleted_by_user_id = l_app_user_id
         where id = l_tag_id
           and app_user_id = l_app_user_id
           and deleted_at is null;

        if sql%rowcount = 0 then
            raise_application_error(-20006, 'TaskHub tag is not accessible.');
        end if;
    end delete_tag;
end pkg_taskhub_api;
/
