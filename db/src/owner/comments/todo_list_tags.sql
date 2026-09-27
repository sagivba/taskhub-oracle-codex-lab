comment on table taskhub_owner.todo_list_tags is
    'Canonical list/tag associations; API authorization requires both referenced objects to share the context owner.';

comment on column taskhub_owner.todo_list_tags.id is
    'Surrogate primary key for a list/tag association.';

comment on column taskhub_owner.todo_list_tags.todo_list_id is
    'Associated task list; TASKHUB_API must validate that it belongs to the current context user.';

comment on column taskhub_owner.todo_list_tags.tag_id is
    'Associated tag; TASKHUB_API must validate the same owner as the list and current context.';

comment on column taskhub_owner.todo_list_tags.created_at is
    'Database timestamp when the list/tag association was created.';
