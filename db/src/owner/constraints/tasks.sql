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
