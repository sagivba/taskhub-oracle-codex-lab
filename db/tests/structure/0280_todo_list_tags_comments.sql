-- Test: TODO_LIST_TAGS table and column comments
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0060_create_todo_list_tags.sql has been applied.
-- Expected result: both queries return zero rows.

select 'TABLE_COMMENT_MISMATCH' as issue from user_tab_comments
where table_name = 'TODO_LIST_TAGS'
  and nvl(comments, '~') <> 'Unique many-to-many associations between task lists and tags.';

with expected (column_name, comments) as (
    select 'ID', 'Surrogate primary key for a list/tag association.' from dual union all
    select 'TODO_LIST_ID', 'Task list participating in the association.' from dual union all
    select 'TAG_ID', 'Tag participating in the association.' from dual union all
    select 'CREATED_AT', 'Database timestamp when the list/tag association was created.' from dual
), actual as (
    select column_name, comments from user_col_comments where table_name = 'TODO_LIST_TAGS'
)
select 'COLUMN_COMMENT_MISMATCH' as issue, nvl(e.column_name, a.column_name) column_name
from expected e full outer join actual a on a.column_name = e.column_name
where e.column_name is null or a.column_name is null or nvl(e.comments, '~') <> nvl(a.comments, '~');
