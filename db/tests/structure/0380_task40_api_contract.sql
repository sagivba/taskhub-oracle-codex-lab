-- Test: Task 40 package body has no transaction control and active Tag uniqueness remains valid
-- Connection/schema: TASKHUB_API
-- Preconditions: changes 0220 and 0230 applied
-- Expected result: both queries return zero rows

select 'TRANSACTION_CONTROL_IN_API_BODY' as issue,
       line,
       text
  from user_source
 where name = 'PKG_TASKHUB_API'
   and type = 'PACKAGE BODY'
   and regexp_like(upper(text), '(^|[^A-Z_])(COMMIT|ROLLBACK)([^A-Z_]|$)');

select 'ACTIVE_TAG_INDEX_MISSING_OR_INVALID' as issue,
       cast(null as number) as line,
       cast(null as varchar2(4000)) as text
  from dual
 where not exists (
           select 1
             from all_indexes
            where owner = 'TASKHUB_OWNER'
              and index_name = 'TAGS_UQ1'
              and table_name = 'TAGS'
              and uniqueness = 'UNIQUE'
              and index_type = 'FUNCTION-BASED NORMAL'
              and status = 'VALID'
       );
