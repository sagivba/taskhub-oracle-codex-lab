comment on table taskhub_owner.todo_list_tags is
    'Unique many-to-many associations between task lists and tags.';

comment on column taskhub_owner.todo_list_tags.id is
    'Surrogate primary key for a list/tag association.';

comment on column taskhub_owner.todo_list_tags.todo_list_id is
    'Task list participating in the association.';

comment on column taskhub_owner.todo_list_tags.tag_id is
    'Tag participating in the association.';

comment on column taskhub_owner.todo_list_tags.created_at is
    'Database timestamp when the list/tag association was created.';
