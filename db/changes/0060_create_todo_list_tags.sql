-- Task: 10 Data Model
-- Target schema: TASKHUB_OWNER
-- Purpose: Create the canonical TODO_LIST_TAGS table, constraints, tag-side index and comments.
-- Preconditions: db/changes/0040_create_todo_lists.sql and 0050_create_tags.sql have been applied; execute as TASKHUB_OWNER.
-- Verification: db/tests/structure/0230_todo_list_tags_table.sql through 0280_todo_list_tags_comments.sql
-- Notes: No seed data, grants, triggers, API code, context changes or views are included.

create table taskhub_owner.todo_list_tags (
    id           number generated always as identity,
    todo_list_id number not null,
    tag_id       number not null,
    created_at   timestamp(6) default systimestamp not null
);

alter table taskhub_owner.todo_list_tags
    add constraint todo_list_tags_pk
    primary key (id);

alter table taskhub_owner.todo_list_tags
    add constraint todo_list_tags_fk1
    foreign key (todo_list_id)
    references taskhub_owner.todo_lists (id);

alter table taskhub_owner.todo_list_tags
    add constraint todo_list_tags_fk2
    foreign key (tag_id)
    references taskhub_owner.tags (id);

alter table taskhub_owner.todo_list_tags
    add constraint todo_list_tags_uq1
    unique (todo_list_id, tag_id);

create index taskhub_owner.todo_list_tags_ix1
    on taskhub_owner.todo_list_tags (tag_id);

comment on table taskhub_owner.todo_list_tags is
    'Unique many-to-many associations between task lists and tags.';

comment on column taskhub_owner.todo_list_tags.id is
    'Surrogate primary key for a list/tag association.';

comment on column taskhub_owner.todo_list_tags.todo_list_id is
    'Task list participating in the association.';

comment on column taskhub_owner.todo_list_tags.tag_id is
    'Tag participating in the association.';

comment on column taskhub_owner.todo_list_tags.created_at is
    'Database timestamp when the list/tag association was created.';
