-- Task: 10 Data Model
-- Target schema: TASKHUB_OWNER
-- Purpose: Create the canonical TODO_LISTS table, constraints, index and comments.
-- Preconditions: db/changes/0030_create_app_users.sql has been applied; execute as TASKHUB_OWNER.
-- Verification: db/tests/structure/0010_invalid_objects.sql
--               db/tests/structure/0110_todo_lists_table.sql
--               db/tests/structure/0120_todo_lists_columns.sql
--               db/tests/structure/0130_todo_lists_identity.sql
--               db/tests/structure/0140_todo_lists_constraints.sql
--               db/tests/structure/0150_todo_lists_indexes.sql
--               db/tests/structure/0160_todo_lists_comments.sql
-- Notes: No seed data, grants, triggers, API code, context changes or views are included.

create table taskhub_owner.todo_lists (
    id                 number generated always as identity,
    app_user_id        number not null,
    list_name          varchar2(200 char) not null,
    created_at         timestamp(6) default systimestamp not null,
    created_by_user_id number not null,
    updated_at         timestamp(6),
    updated_by_user_id number,
    deleted_at         timestamp(6),
    deleted_by_user_id number
);

alter table taskhub_owner.todo_lists
    add constraint todo_lists_pk
    primary key (id);

alter table taskhub_owner.todo_lists
    add constraint todo_lists_fk1
    foreign key (app_user_id)
    references taskhub_owner.app_users (id);

alter table taskhub_owner.todo_lists
    add constraint todo_lists_fk2
    foreign key (created_by_user_id)
    references taskhub_owner.app_users (id);

alter table taskhub_owner.todo_lists
    add constraint todo_lists_fk3
    foreign key (updated_by_user_id)
    references taskhub_owner.app_users (id);

alter table taskhub_owner.todo_lists
    add constraint todo_lists_fk4
    foreign key (deleted_by_user_id)
    references taskhub_owner.app_users (id);

create index taskhub_owner.todo_lists_ix1
    on taskhub_owner.todo_lists (
        app_user_id,
        deleted_at
    );

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
