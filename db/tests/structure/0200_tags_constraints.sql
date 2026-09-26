-- Test: TAGS primary key and foreign keys
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0050_create_tags.sql has been applied.
-- Expected result: all three queries return zero rows.

with expected (constraint_name, constraint_type, r_constraint_name) as (
    select 'TAGS_PK',  'P', cast(null as varchar2(128)) from dual union all
    select 'TAGS_FK1', 'R', 'APP_USERS_PK' from dual union all
    select 'TAGS_FK2', 'R', 'APP_USERS_PK' from dual union all
    select 'TAGS_FK3', 'R', 'APP_USERS_PK' from dual union all
    select 'TAGS_FK4', 'R', 'APP_USERS_PK' from dual
), actual as (
    select constraint_name, constraint_type, r_constraint_name
    from user_constraints where table_name = 'TAGS' and constraint_type in ('P', 'U', 'R')
)
select 'CONSTRAINT_MISMATCH' as issue, nvl(e.constraint_name, a.constraint_name) constraint_name
from expected e full outer join actual a on a.constraint_name = e.constraint_name
where e.constraint_name is null or a.constraint_name is null
   or e.constraint_type <> a.constraint_type
   or nvl(e.r_constraint_name, '~') <> nvl(a.r_constraint_name, '~')
   or a.constraint_name in (
       select constraint_name from user_constraints
       where table_name = 'TAGS' and (status <> 'ENABLED' or validated <> 'VALIDATED'
          or deferrable <> 'NOT DEFERRABLE' or deferred <> 'IMMEDIATE')
   );

with expected (constraint_name, column_name) as (
    select 'TAGS_PK',  'ID' from dual union all
    select 'TAGS_FK1', 'APP_USER_ID' from dual union all
    select 'TAGS_FK2', 'CREATED_BY_USER_ID' from dual union all
    select 'TAGS_FK3', 'UPDATED_BY_USER_ID' from dual union all
    select 'TAGS_FK4', 'DELETED_BY_USER_ID' from dual
), actual as (
    select constraint_name, column_name from user_cons_columns
    where table_name = 'TAGS' and constraint_name in ('TAGS_PK','TAGS_FK1','TAGS_FK2','TAGS_FK3','TAGS_FK4')
)
select 'CONSTRAINT_COLUMN_MISMATCH' as issue,
       nvl(e.constraint_name, a.constraint_name) constraint_name,
       nvl(e.column_name, a.column_name) column_name
from expected e full outer join actual a
  on a.constraint_name = e.constraint_name and a.column_name = e.column_name
where e.constraint_name is null or a.constraint_name is null;

select 'UNEXPECTED_CHECK_CONSTRAINT' as issue, constraint_name
from user_constraints
where table_name = 'TAGS' and constraint_type = 'C'
  and not (generated = 'GENERATED NAME' and regexp_replace(upper(replace(search_condition_vc, '"', '')), '[[:space:]]+', '')
      in ('IDISNOTNULL','APP_USER_IDISNOTNULL','TAG_NAMEISNOTNULL','CREATED_ATISNOTNULL','CREATED_BY_USER_IDISNOTNULL'));
