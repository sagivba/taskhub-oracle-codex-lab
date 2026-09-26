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
