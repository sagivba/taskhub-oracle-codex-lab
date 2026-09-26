-- Test: TASKS table and column comments
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0070_create_tasks.sql has been applied.
-- Expected result: both queries return zero rows.

select 'TABLE_COMMENT_MISMATCH' as issue from user_tab_comments
where table_name = 'TASKS' and nvl(comments, '~') <> 'Tasks and subtasks contained in TaskHub task lists.';

with expected (column_name, comments) as (
    select 'ID', 'Surrogate primary key for a task or subtask.' from dual union all
    select 'TODO_LIST_ID', 'Task list containing the task.' from dual union all
    select 'PARENT_TASK_ID', 'Parent task in the same list; NULL for a top-level task.' from dual union all
    select 'TITLE', 'Task title.' from dual union all
    select 'DESCRIPTION', 'Optional task description.' from dual union all
    select 'STATUS', 'Lifecycle status: OPEN, IN_PROGRESS, DONE or CANCELED.' from dual union all
    select 'PRIORITY', 'Numeric priority: 1 high, 2 medium, 3 low.' from dual union all
    select 'DUE_AT', 'Optional due timestamp.' from dual union all
    select 'COMPLETED_AT', 'Completion timestamp; populated while status is DONE and otherwise NULL.' from dual union all
    select 'CREATED_AT', 'Database timestamp when the task was created.' from dual union all
    select 'CREATED_BY_USER_ID', 'Application user that created the task.' from dual union all
    select 'UPDATED_AT', 'Database timestamp of the most recent update; NULL until the task is updated.' from dual union all
    select 'UPDATED_BY_USER_ID', 'Application user that performed the most recent update; NULL until the task is updated.' from dual union all
    select 'DELETED_AT', 'Soft-delete timestamp; NULL while the task is active.' from dual union all
    select 'DELETED_BY_USER_ID', 'Application user that soft-deleted the task; NULL while the task is active.' from dual
), actual as (
    select column_name, comments from user_col_comments where table_name = 'TASKS'
)
select 'COLUMN_COMMENT_MISMATCH' as issue, nvl(e.column_name, a.column_name) column_name
from expected e full outer join actual a on a.column_name = e.column_name
where e.column_name is null or a.column_name is null or nvl(e.comments, '~') <> nvl(a.comments, '~');
