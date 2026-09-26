-- Test: TODO_LIST_TAGS primary key, foreign keys and unique association
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0060_create_todo_list_tags.sql has been applied.
-- Expected result: all three queries return zero rows.

with expected (constraint_name, constraint_type, r_constraint_name) as (
    select 'TODO_LIST_TAGS_PK',  'P', cast(null as varchar2(128)) from dual union all
    select 'TODO_LIST_TAGS_FK1', 'R', 'TODO_LISTS_PK' from dual union all
    select 'TODO_LIST_TAGS_FK2', 'R', 'TAGS_PK' from dual union all
    select 'TODO_LIST_TAGS_UQ1', 'U', cast(null as varchar2(128)) from dual
), actual as (
    select constraint_name, constraint_type, r_constraint_name
    from user_constraints where table_name = 'TODO_LIST_TAGS' and constraint_type in ('P', 'U', 'R')
)
select 'CONSTRAINT_MISMATCH' as issue, nvl(e.constraint_name, a.constraint_name) constraint_name
from expected e full outer join actual a on a.constraint_name = e.constraint_name
where e.constraint_name is null or a.constraint_name is null
   or e.constraint_type <> a.constraint_type or nvl(e.r_constraint_name, '~') <> nvl(a.r_constraint_name, '~')
   or a.constraint_name in (
       select constraint_name from user_constraints where table_name = 'TODO_LIST_TAGS'
       and (status <> 'ENABLED' or validated <> 'VALIDATED' or deferrable <> 'NOT DEFERRABLE' or deferred <> 'IMMEDIATE')
   );

with expected (constraint_name, column_name, position) as (
    select 'TODO_LIST_TAGS_PK',  'ID',           1 from dual union all
    select 'TODO_LIST_TAGS_FK1', 'TODO_LIST_ID', 1 from dual union all
    select 'TODO_LIST_TAGS_FK2', 'TAG_ID',       1 from dual union all
    select 'TODO_LIST_TAGS_UQ1', 'TODO_LIST_ID', 1 from dual union all
    select 'TODO_LIST_TAGS_UQ1', 'TAG_ID',       2 from dual
), actual as (
    select constraint_name, column_name, position from user_cons_columns
    where table_name = 'TODO_LIST_TAGS'
      and constraint_name in ('TODO_LIST_TAGS_PK','TODO_LIST_TAGS_FK1','TODO_LIST_TAGS_FK2','TODO_LIST_TAGS_UQ1')
)
select 'CONSTRAINT_COLUMN_MISMATCH' as issue,
       nvl(e.constraint_name, a.constraint_name) constraint_name,
       nvl(e.column_name, a.column_name) column_name
from expected e full outer join actual a
  on a.constraint_name = e.constraint_name and a.column_name = e.column_name
where e.constraint_name is null or a.constraint_name is null or e.position <> a.position;

select 'UNEXPECTED_CHECK_CONSTRAINT' as issue, constraint_name
from user_constraints
where table_name = 'TODO_LIST_TAGS' and constraint_type = 'C'
  and not (generated = 'GENERATED NAME' and regexp_replace(upper(replace(search_condition_vc, '"', '')), '[[:space:]]+', '')
      in ('IDISNOTNULL','TODO_LIST_IDISNOTNULL','TAG_IDISNOTNULL','CREATED_ATISNOTNULL'));
