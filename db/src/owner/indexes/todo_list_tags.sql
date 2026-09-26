-- Supports tag-side association removal and physical purge. The unique
-- TODO_LIST_TAGS_UQ1 index starts with TODO_LIST_ID and cannot support this
-- TAG_ID access path.
create index taskhub_owner.todo_list_tags_ix1
    on taskhub_owner.todo_list_tags (tag_id);

-- TODO_LIST_TAGS_PK and TODO_LIST_TAGS_UQ1 are the unique indexes created for
-- the primary key and unique list/tag association constraint respectively.
