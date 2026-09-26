-- Test: APP_USERS table existence
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0030_create_app_users.sql has been applied.
-- Expected result: zero rows.
-- Identity rule: not applicable; this is a read-only structural test.

select 'MISSING_TABLE' as issue,
       'APP_USERS' as object_name
from dual
where not exists (
    select 1
    from user_tables
    where table_name = 'APP_USERS'
);
