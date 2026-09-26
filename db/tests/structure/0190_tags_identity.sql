-- Test: TAGS identity generation mode
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0050_create_tags.sql has been applied.
-- Expected result: zero rows.

select 'IDENTITY_MISMATCH' as issue
from dual
where not exists (
    select 1 from user_tab_identity_cols
    where table_name = 'TAGS' and column_name = 'ID' and generation_type = 'ALWAYS'
)
or (select count(*) from user_tab_identity_cols where table_name = 'TAGS') <> 1;
