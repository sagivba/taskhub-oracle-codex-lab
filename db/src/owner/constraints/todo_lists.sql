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
