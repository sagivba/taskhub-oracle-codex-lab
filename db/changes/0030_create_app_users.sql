-- Task: 10 Data Model
-- Target schema: TASKHUB_OWNER
-- Purpose: Create the canonical APP_USERS table, constraints and comments.
-- Preconditions: Manual bootstrap complete; execute as TASKHUB_OWNER.
-- Verification: db/tests/structure/0010_invalid_objects.sql
--               db/tests/structure/0050_app_users_table.sql
--               db/tests/structure/0060_app_users_columns.sql
--               db/tests/structure/0070_app_users_identity.sql
--               db/tests/structure/0080_app_users_constraints.sql
--               db/tests/structure/0090_app_users_indexes.sql
--               db/tests/structure/0100_app_users_comments.sql
-- Notes: No seed data, grants, triggers or context changes are included.

create table taskhub_owner.app_users (
    id           number generated always as identity,
    username     varchar2(128 char) not null,
    display_name varchar2(200 char),
    email        varchar2(320 char),
    is_active    varchar2(1 char) not null,
    created_at   timestamp(6) default systimestamp not null,
    updated_at   timestamp(6)
);

alter table taskhub_owner.app_users
    add constraint app_users_pk
    primary key (id);

alter table taskhub_owner.app_users
    add constraint app_users_uq1
    unique (username);

alter table taskhub_owner.app_users
    add constraint app_users_ck1
    check (is_active in ('Y', 'N'));

comment on table taskhub_owner.app_users is
    'Application identities used by TaskHub; rows do not represent Oracle database users.';

comment on column taskhub_owner.app_users.id is
    'Surrogate primary key for an application identity.';

comment on column taskhub_owner.app_users.username is
    'Unique case-sensitive application username used by TASKHUB_API to resolve session identity.';

comment on column taskhub_owner.app_users.display_name is
    'Optional display name for the application user.';

comment on column taskhub_owner.app_users.email is
    'Optional email address for the application user; not an authentication credential.';

comment on column taskhub_owner.app_users.is_active is
    'Application identity status: Y permits context initialization; N denies it.';

comment on column taskhub_owner.app_users.created_at is
    'Database timestamp when the application identity row was created.';

comment on column taskhub_owner.app_users.updated_at is
    'Database timestamp of the most recent update; NULL until the row is updated.';
