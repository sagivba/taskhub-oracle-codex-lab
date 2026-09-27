-- Test: exact Task 30 view objects, read-only metadata, required tree columns and documentation
-- Connection/schema: TASKHUB_API
-- Preconditions: changes 0190 through 0210 applied
-- Expected result: no rows

with expected_views (view_name) as (
    select 'V_TODO_LISTS' from dual union all
    select 'V_TODO_LIST_TAGS' from dual union all
    select 'V_TASKS' from dual union all
    select 'V_TASK_TREE' from dual
), expected_tree_columns (column_name, column_id) as (
    select 'TASK_ID', 1 from dual union all
    select 'TODO_LIST_ID', 2 from dual union all
    select 'PARENT_TASK_ID', 3 from dual union all
    select 'TITLE', 4 from dual union all
    select 'STATUS', 5 from dual union all
    select 'PRIORITY', 6 from dual union all
    select 'TASK_DEPTH', 7 from dual
)
select 'MISSING_OR_INVALID_VIEW' as issue, e.view_name as detail
  from expected_views e
 where not exists (
           select 1
             from user_objects o
            where o.object_name = e.view_name
              and o.object_type = 'VIEW'
              and o.status = 'VALID'
       )
union all
select 'VIEW_NOT_READ_ONLY', e.view_name
  from expected_views e
  join user_views v
    on v.view_name = e.view_name
 where v.read_only = 'N'
union all
select 'MISSING_VIEW_COMMENT', e.view_name
  from expected_views e
  left join user_tab_comments c
    on c.table_name = e.view_name
   and c.table_type = 'VIEW'
 where c.comments is null
union all
select 'TREE_COLUMN_MISMATCH',
       e.column_name || ':' || e.column_id
  from expected_tree_columns e
 where not exists (
           select 1
             from user_tab_columns c
            where c.table_name = 'V_TASK_TREE'
              and c.column_name = e.column_name
              and c.column_id = e.column_id
       )
union all
select 'UNEXPECTED_TREE_COLUMN', c.column_name || ':' || c.column_id
  from user_tab_columns c
 where c.table_name = 'V_TASK_TREE'
   and not exists (
           select 1
             from expected_tree_columns e
            where e.column_name = c.column_name
              and e.column_id = c.column_id
       )
union all
select 'COMPILE_ERROR', name || ':' || type || ':' || line || ':' || position
  from user_errors
 where name in ('V_TODO_LISTS', 'V_TODO_LIST_TAGS', 'V_TASKS', 'V_TASK_TREE');
