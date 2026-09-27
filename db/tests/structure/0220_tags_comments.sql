-- Test: TAGS table and column comments
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0050_create_tags.sql has been applied.
-- Expected result: both queries return zero rows.

select 'TABLE_COMMENT_MISMATCH' as issue
from user_tab_comments
where table_name = 'TAGS' and nvl(comments, '~') <> 'Canonical reusable tags scoped to one TaskHub application user and managed through the API boundary.';

with expected (column_name, comments) as (
    select 'ID', 'Surrogate primary key for a tag.' from dual union all
    select 'APP_USER_ID', 'Canonical owner derived by TASKHUB_API from TASKHUB_CTX; callers must not supply or override it.' from dual union all
    select 'TAG_NAME', 'Caller-visible tag name; active names are unique per owner after trim and case normalization.' from dual union all
    select 'CREATED_AT', 'Database timestamp when the tag was created.' from dual union all
    select 'CREATED_BY_USER_ID', 'Creator identity derived by TASKHUB_API from TASKHUB_CTX, never accepted from the caller.' from dual union all
    select 'UPDATED_AT', 'Database timestamp of the most recent update; NULL until the tag is updated.' from dual union all
    select 'UPDATED_BY_USER_ID', 'Most recent updater derived from TASKHUB_CTX; NULL until the tag is updated.' from dual union all
    select 'DELETED_AT', 'Soft-delete timestamp; NULL while the tag is active.' from dual union all
    select 'DELETED_BY_USER_ID', 'Soft-delete actor derived from TASKHUB_CTX; NULL while the tag is active.' from dual
), actual as (
    select column_name, comments from user_col_comments where table_name = 'TAGS'
)
select 'COLUMN_COMMENT_MISMATCH' as issue, nvl(e.column_name, a.column_name) column_name
from expected e full outer join actual a on a.column_name = e.column_name
where e.column_name is null or a.column_name is null or nvl(e.comments, '~') <> nvl(a.comments, '~');
