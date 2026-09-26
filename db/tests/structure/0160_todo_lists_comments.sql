-- Test: TODO_LISTS table and column comments
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0040_create_todo_lists.sql has been applied.
-- Expected result: both queries return zero rows.
-- Identity rule: not applicable; this is a read-only structural test.

select 'TABLE_COMMENT_MISMATCH' as issue,
       table_name,
       comments
from user_tab_comments
where table_name = 'TODO_LISTS'
  and nvl(comments, '~') <>
      'Task lists owned by TaskHub application users.';

with expected_comments (
    column_name,
    comments
) as (
    select 'ID',
           'Surrogate primary key for a task list.'
    from dual union all
    select 'APP_USER_ID',
           'Application user that owns the task list.'
    from dual union all
    select 'LIST_NAME',
           'Name of the task list.'
    from dual union all
    select 'CREATED_AT',
           'Database timestamp when the task list was created.'
    from dual union all
    select 'CREATED_BY_USER_ID',
           'Application user that created the task list.'
    from dual union all
    select 'UPDATED_AT',
           'Database timestamp of the most recent update; NULL until the task list is updated.'
    from dual union all
    select 'UPDATED_BY_USER_ID',
           'Application user that performed the most recent update; NULL until the task list is updated.'
    from dual union all
    select 'DELETED_AT',
           'Soft-delete timestamp; NULL while the task list is active.'
    from dual union all
    select 'DELETED_BY_USER_ID',
           'Application user that soft-deleted the task list; NULL while the task list is active.'
    from dual
),
actual_comments as (
    select column_name,
           comments
    from user_col_comments
    where table_name = 'TODO_LISTS'
)
select case
           when expected.column_name is null then 'UNEXPECTED_COLUMN_COMMENT'
           when actual.column_name is null then 'MISSING_COLUMN_COMMENT'
           else 'COLUMN_COMMENT_MISMATCH'
       end as issue,
       nvl(expected.column_name, actual.column_name) as column_name,
       expected.comments as expected_comments,
       actual.comments as actual_comments
from expected_comments expected
full outer join actual_comments actual
    on actual.column_name = expected.column_name
where expected.column_name is null
   or actual.column_name is null
   or nvl(expected.comments, '~') <> nvl(actual.comments, '~')
order by nvl(expected.column_name, actual.column_name);
