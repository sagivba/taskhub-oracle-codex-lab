-- Run as TASKHUB_OWNER after tables exist.
-- Expected result after Task 10: zero rows for business columns.

select table_name,
       column_name
from user_col_comments
where table_name in ('APP_USERS','TODO_LISTS','TAGS','TODO_LIST_TAGS','TASKS')
  and comments is null
order by table_name, column_name;
