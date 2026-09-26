-- Supports ownership-filtered active-list reads on APP_USER_ID and DELETED_AT.
create index taskhub_owner.todo_lists_ix1
    on taskhub_owner.todo_lists (
        app_user_id,
        deleted_at
    );

-- TODO_LISTS_PK is the unique index created for the TODO_LISTS primary key.
-- No standalone ID or APP_USER_ID index is required.
