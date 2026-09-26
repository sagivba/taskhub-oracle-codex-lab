-- Task: 10 Data Model
-- Target schema: TASKHUB_OWNER
-- Purpose: Create the canonical TAGS table, constraints, active-name unique index and comments.
-- Preconditions: db/changes/0030_create_app_users.sql has been applied; execute as TASKHUB_OWNER.
-- Verification: db/tests/structure/0170_tags_table.sql through 0220_tags_comments.sql
-- Notes: No seed data, grants, triggers, API code, context changes or views are included.

create table taskhub_owner.tags (
    id                 number generated always as identity,
    app_user_id        number not null,
    tag_name           varchar2(100 char) not null,
    created_at         timestamp(6) default systimestamp not null,
    created_by_user_id number not null,
    updated_at         timestamp(6),
    updated_by_user_id number,
    deleted_at         timestamp(6),
    deleted_by_user_id number
);

alter table taskhub_owner.tags
    add constraint tags_pk
    primary key (id);

alter table taskhub_owner.tags
    add constraint tags_fk1
    foreign key (app_user_id)
    references taskhub_owner.app_users (id);

alter table taskhub_owner.tags
    add constraint tags_fk2
    foreign key (created_by_user_id)
    references taskhub_owner.app_users (id);

alter table taskhub_owner.tags
    add constraint tags_fk3
    foreign key (updated_by_user_id)
    references taskhub_owner.app_users (id);

alter table taskhub_owner.tags
    add constraint tags_fk4
    foreign key (deleted_by_user_id)
    references taskhub_owner.app_users (id);

create unique index taskhub_owner.tags_uq1
    on taskhub_owner.tags (
        case when deleted_at is null then app_user_id end,
        case when deleted_at is null then upper(trim(tag_name)) end
    );

comment on table taskhub_owner.tags is
    'Reusable tags owned by TaskHub application users.';

comment on column taskhub_owner.tags.id is
    'Surrogate primary key for a tag.';

comment on column taskhub_owner.tags.app_user_id is
    'Application user that owns the tag.';

comment on column taskhub_owner.tags.tag_name is
    'Tag name; active names are unique per owner after trim and case normalization.';

comment on column taskhub_owner.tags.created_at is
    'Database timestamp when the tag was created.';

comment on column taskhub_owner.tags.created_by_user_id is
    'Application user that created the tag.';

comment on column taskhub_owner.tags.updated_at is
    'Database timestamp of the most recent update; NULL until the tag is updated.';

comment on column taskhub_owner.tags.updated_by_user_id is
    'Application user that performed the most recent update; NULL until the tag is updated.';

comment on column taskhub_owner.tags.deleted_at is
    'Soft-delete timestamp; NULL while the tag is active.';

comment on column taskhub_owner.tags.deleted_by_user_id is
    'Application user that soft-deleted the tag; NULL while the tag is active.';
