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
