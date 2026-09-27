comment on table taskhub_owner.tasks is
    'Canonical tasks and subtasks whose ownership is inherited from their containing TaskHub list.';

comment on column taskhub_owner.tasks.id is
    'Surrogate primary key for a task or subtask.';

comment on column taskhub_owner.tasks.todo_list_id is
    'Containing list and source of task ownership; TASKHUB_API must authorize it against TASKHUB_CTX.';

comment on column taskhub_owner.tasks.parent_task_id is
    'Parent task in the same list; NULL for a top-level task and never valid across list boundaries.';

comment on column taskhub_owner.tasks.title is
    'Task title.';

comment on column taskhub_owner.tasks.description is
    'Optional task description.';

comment on column taskhub_owner.tasks.status is
    'Lifecycle status: OPEN, IN_PROGRESS, DONE or CANCELED.';

comment on column taskhub_owner.tasks.priority is
    'Numeric priority: 1 high, 2 medium, 3 low.';

comment on column taskhub_owner.tasks.due_at is
    'Optional due timestamp.';

comment on column taskhub_owner.tasks.completed_at is
    'Completion timestamp; populated while status is DONE and otherwise NULL.';

comment on column taskhub_owner.tasks.created_at is
    'Database timestamp when the task was created.';

comment on column taskhub_owner.tasks.created_by_user_id is
    'Creator identity derived by TASKHUB_API from TASKHUB_CTX, never accepted from the caller.';

comment on column taskhub_owner.tasks.updated_at is
    'Database timestamp of the most recent update; NULL until the task is updated.';

comment on column taskhub_owner.tasks.updated_by_user_id is
    'Most recent updater derived from TASKHUB_CTX; NULL until the task is updated.';

comment on column taskhub_owner.tasks.deleted_at is
    'Soft-delete timestamp; NULL while the task is active.';

comment on column taskhub_owner.tasks.deleted_by_user_id is
    'Soft-delete actor derived from TASKHUB_CTX; NULL while the task is active.';
