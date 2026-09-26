-- Test: TAGS table existence
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0050_create_tags.sql has been applied.
-- Expected result: zero rows.

select 'MISSING_TABLE' as issue, 'TAGS' as object_name
from dual
where not exists (
    select 1 from user_tables where table_name = 'TAGS'
);
