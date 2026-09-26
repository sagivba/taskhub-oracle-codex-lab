-- Task: 10 Data Model
-- Target schema: TASKHUB_OWNER
-- Purpose: Create the canonical TASKS table, hierarchy/audit constraints, indexes and comments.
-- Preconditions: db/changes/0030_create_app_users.sql and 0040_create_todo_lists.sql have been applied; execute as TASKHUB_OWNER.
-- Verification: db/tests/structure/0290_tasks_table.sql through 0340_tasks_comments.sql
-- Notes: No seed data, grants, triggers, API code, context changes or views are included.

create table taskhub_owner.tasks (
    id                 number generated always as identity,
    todo_list_id       number not null,
    parent_task_id     number,
    title              varchar2(200 char) not null,
    description        varchar2(4000 char),
    status             varchar2(20 char) not null,
    priority           number not null,
    due_at             timestamp(6),
    completed_at       timestamp(6),
    created_at         timestamp(6) default systimestamp not null,
    created_by_user_id number not null,
    updated_at         timestamp(6),
    updated_by_user_id number,
    deleted_at         timestamp(6),
    deleted_by_user_id number
);

alter table taskhub_owner.tasks
    add constraint tasks_pk
    primary key (id);

alter table taskhub_owner.tasks
    add constraint tasks_fk1
    foreign key (todo_list_id)
    references taskhub_owner.todo_lists (id);

alter table taskhub_owner.tasks
    add constraint tasks_fk2
    foreign key (parent_task_id)
    references taskhub_owner.tasks (id);

alter table taskhub_owner.tasks
    add constraint tasks_fk3
    foreign key (created_by_user_id)
    references taskhub_owner.app_users (id);

alter table taskhub_owner.tasks
    add constraint tasks_fk4
    foreign key (updated_by_user_id)
    references taskhub_owner.app_users (id);

alter table taskhub_owner.tasks
    add constraint tasks_fk5
    foreign key (deleted_by_user_id)
    references taskhub_owner.app_users (id);

alter table taskhub_owner.tasks
    add constraint tasks_ck1
    check (status in ('OPEN', 'IN_PROGRESS', 'DONE', 'CANCELED'));

alter table taskhub_owner.tasks
    add constraint tasks_ck2
    check (priority in (1, 2, 3));

create index taskhub_owner.tasks_ix1
    on taskhub_owner.tasks (
        todo_list_id,
        deleted_at
    );

create index taskhub_owner.tasks_ix2
    on taskhub_owner.tasks (parent_task_id);

create index taskhub_owner.tasks_ix3
    on taskhub_owner.tasks (
        status,
        priority,
        due_at
    );

comment on table taskhub_owner.tasks is
    'Tasks and subtasks contained in TaskHub task lists.';

comment on column taskhub_owner.tasks.id is
    'Surrogate primary key for a task or subtask.';

comment on column taskhub_owner.tasks.todo_list_id is
    'Task list containing the task.';

comment on column taskhub_owner.tasks.parent_task_id is
    'Parent task in the same list; NULL for a top-level task.';

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
    'Application user that created the task.';

comment on column taskhub_owner.tasks.updated_at is
    'Database timestamp of the most recent update; NULL until the task is updated.';

comment on column taskhub_owner.tasks.updated_by_user_id is
    'Application user that performed the most recent update; NULL until the task is updated.';

comment on column taskhub_owner.tasks.deleted_at is
    'Soft-delete timestamp; NULL while the task is active.';

comment on column taskhub_owner.tasks.deleted_by_user_id is
    'Application user that soft-deleted the task; NULL while the task is active.';
