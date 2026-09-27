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
      'Canonical task lists owned by TaskHub application users and written only through approved API operations.';

with expected_comments (
    column_name,
    comments
) as (
    select 'ID',
           'Surrogate primary key for a task list.'
    from dual union all
    select 'APP_USER_ID',
           'Canonical owner derived by TASKHUB_API from TASKHUB_CTX; callers must not supply or override it.'
    from dual union all
    select 'LIST_NAME',
           'Required user-visible task-list name supplied by the caller.'
    from dual union all
    select 'CREATED_AT',
           'Database timestamp when the task list was created.'
    from dual union all
    select 'CREATED_BY_USER_ID',
           'Creator identity derived by TASKHUB_API from TASKHUB_CTX, never accepted from the caller.'
    from dual union all
    select 'UPDATED_AT',
           'Database timestamp of the most recent update; NULL until the task list is updated.'
    from dual union all
    select 'UPDATED_BY_USER_ID',
           'Most recent updater derived from TASKHUB_CTX; NULL until the task list is updated.'
    from dual union all
    select 'DELETED_AT',
           'Soft-delete timestamp; NULL while the task list is active.'
    from dual union all
    select 'DELETED_BY_USER_ID',
           'Soft-delete actor derived from TASKHUB_CTX; NULL while the task list is active.'
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
