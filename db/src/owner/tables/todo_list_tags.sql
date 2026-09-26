create table taskhub_owner.todo_list_tags (
    id           number generated always as identity,
    todo_list_id number not null,
    tag_id       number not null,
    created_at   timestamp(6) default systimestamp not null
);
