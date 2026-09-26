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
