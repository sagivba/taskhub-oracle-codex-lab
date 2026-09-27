comment on table taskhub_owner.todo_lists is
    'Canonical task lists owned by TaskHub application users and written only through approved API operations.';

comment on column taskhub_owner.todo_lists.id is
    'Surrogate primary key for a task list.';

comment on column taskhub_owner.todo_lists.app_user_id is
    'Canonical owner derived by TASKHUB_API from TASKHUB_CTX; callers must not supply or override it.';

comment on column taskhub_owner.todo_lists.list_name is
    'Required user-visible task-list name supplied by the caller.';

comment on column taskhub_owner.todo_lists.created_at is
    'Database timestamp when the task list was created.';

comment on column taskhub_owner.todo_lists.created_by_user_id is
    'Creator identity derived by TASKHUB_API from TASKHUB_CTX, never accepted from the caller.';

comment on column taskhub_owner.todo_lists.updated_at is
    'Database timestamp of the most recent update; NULL until the task list is updated.';

comment on column taskhub_owner.todo_lists.updated_by_user_id is
    'Most recent updater derived from TASKHUB_CTX; NULL until the task list is updated.';

comment on column taskhub_owner.todo_lists.deleted_at is
    'Soft-delete timestamp; NULL while the task list is active.';

comment on column taskhub_owner.todo_lists.deleted_by_user_id is
    'Soft-delete actor derived from TASKHUB_CTX; NULL while the task list is active.';
