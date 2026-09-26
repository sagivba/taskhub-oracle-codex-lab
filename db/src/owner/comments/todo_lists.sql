comment on table taskhub_owner.todo_lists is
    'Task lists owned by TaskHub application users.';

comment on column taskhub_owner.todo_lists.id is
    'Surrogate primary key for a task list.';

comment on column taskhub_owner.todo_lists.app_user_id is
    'Application user that owns the task list.';

comment on column taskhub_owner.todo_lists.list_name is
    'Name of the task list.';

comment on column taskhub_owner.todo_lists.created_at is
    'Database timestamp when the task list was created.';

comment on column taskhub_owner.todo_lists.created_by_user_id is
    'Application user that created the task list.';

comment on column taskhub_owner.todo_lists.updated_at is
    'Database timestamp of the most recent update; NULL until the task list is updated.';

comment on column taskhub_owner.todo_lists.updated_by_user_id is
    'Application user that performed the most recent update; NULL until the task list is updated.';

comment on column taskhub_owner.todo_lists.deleted_at is
    'Soft-delete timestamp; NULL while the task list is active.';

comment on column taskhub_owner.todo_lists.deleted_by_user_id is
    'Application user that soft-deleted the task list; NULL while the task list is active.';
