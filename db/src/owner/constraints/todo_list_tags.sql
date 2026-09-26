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
