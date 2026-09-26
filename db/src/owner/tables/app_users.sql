create table taskhub_owner.app_users (
    id           number generated always as identity,
    username     varchar2(128 char) not null,
    display_name varchar2(200 char),
    email        varchar2(320 char),
    is_active    varchar2(1 char) not null,
    created_at   timestamp(6) default systimestamp not null,
    updated_at   timestamp(6)
);
