-- Test: APP_USERS table and column comments
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0030_create_app_users.sql has been applied.
-- Expected result: both queries return zero rows.
-- Identity rule: not applicable; this is a read-only structural test.

select 'TABLE_COMMENT_MISMATCH' as issue,
       table_name,
       comments
from user_tab_comments
where table_name = 'APP_USERS'
  and nvl(comments, '~') <>
      'Application identities used by TaskHub; rows do not represent Oracle database users.';

with expected_comments (
    column_name,
    comments
) as (
    select 'ID',
           'Surrogate primary key for an application identity.'
    from dual union all
    select 'USERNAME',
           'Unique case-sensitive application username used by TASKHUB_API to resolve session identity.'
    from dual union all
    select 'DISPLAY_NAME',
           'Optional display name for the application user.'
    from dual union all
    select 'EMAIL',
           'Optional email address for the application user; not an authentication credential.'
    from dual union all
    select 'IS_ACTIVE',
           'Application identity status: Y permits context initialization; N denies it.'
    from dual union all
    select 'CREATED_AT',
           'Database timestamp when the application identity row was created.'
    from dual union all
    select 'UPDATED_AT',
           'Database timestamp of the most recent update; NULL until the row is updated.'
    from dual
),
actual_comments as (
    select column_name,
           comments
    from user_col_comments
    where table_name = 'APP_USERS'
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
