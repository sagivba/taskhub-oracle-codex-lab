-- Test: canonical owner annotation manifest and structured security metadata
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0170_document_owner_objects.sql applied
-- Expected result: no rows

with expected_table_annotations (object_name, annotation_name) as (
    select t.object_name, a.annotation_name
      from (
            select 'APP_USERS' object_name from dual union all
            select 'TODO_LISTS' from dual union all
            select 'TAGS' from dual union all
            select 'TODO_LIST_TAGS' from dual union all
            select 'TASKS' from dual
           ) t
      cross join (
            select 'DESCRIPTION' annotation_name from dual union all
            select 'PURPOSE' from dual union all
            select 'DOMAIN' from dual union all
            select 'OWNERSHIP' from dual union all
            select 'SECURITY_MODEL' from dual union all
            select 'LIFECYCLE' from dual
           ) a
), actual_table_annotations as (
    select object_name, annotation_name
      from user_annotations_usage
     where object_name in ('APP_USERS','TODO_LISTS','TAGS','TODO_LIST_TAGS','TASKS')
       and object_type = 'TABLE'
       and column_name is null
), required_column_annotations (object_name, column_name, annotation_name) as (
    select 'APP_USERS', 'ID', 'IDENTITY_SOURCE' from dual union all
    select 'APP_USERS', 'USERNAME', 'BUSINESS_KEY' from dual union all
    select 'APP_USERS', 'USERNAME', 'SECURITY_SENSITIVE' from dual union all
    select 'APP_USERS', 'IS_ACTIVE', 'SECURITY_SENSITIVE' from dual union all
    select 'TODO_LISTS', 'APP_USER_ID', 'DERIVED_FROM_CONTEXT' from dual union all
    select 'TODO_LISTS', 'APP_USER_ID', 'SECURITY_SENSITIVE' from dual union all
    select 'TODO_LISTS', 'CREATED_BY_USER_ID', 'DERIVED_FROM_CONTEXT' from dual union all
    select 'TAGS', 'APP_USER_ID', 'DERIVED_FROM_CONTEXT' from dual union all
    select 'TAGS', 'APP_USER_ID', 'SECURITY_SENSITIVE' from dual union all
    select 'TAGS', 'CREATED_BY_USER_ID', 'DERIVED_FROM_CONTEXT' from dual union all
    select 'TODO_LIST_TAGS', 'TODO_LIST_ID', 'AUTHORIZATION' from dual union all
    select 'TODO_LIST_TAGS', 'TAG_ID', 'AUTHORIZATION' from dual union all
    select 'TASKS', 'TODO_LIST_ID', 'AUTHORIZATION' from dual union all
    select 'TASKS', 'PARENT_TASK_ID', 'SECURITY_SENSITIVE' from dual union all
    select 'TASKS', 'CREATED_BY_USER_ID', 'DERIVED_FROM_CONTEXT' from dual
), actual_column_annotations as (
    select object_name, column_name, annotation_name
      from user_annotations_usage
     where object_name in ('APP_USERS','TODO_LISTS','TAGS','TODO_LIST_TAGS','TASKS')
       and object_type = 'TABLE'
       and column_name is not null
)
select 'MISSING_TABLE_ANNOTATION' as issue,
       e.object_name,
       cast(null as varchar2(128)) as column_name,
       e.annotation_name
  from expected_table_annotations e
minus
select 'MISSING_TABLE_ANNOTATION',
       a.object_name,
       cast(null as varchar2(128)),
       a.annotation_name
  from actual_table_annotations a
union all
select 'MISSING_COLUMN_ANNOTATION',
       e.object_name,
       e.column_name,
       e.annotation_name
  from required_column_annotations e
minus
select 'MISSING_COLUMN_ANNOTATION',
       a.object_name,
       a.column_name,
       a.annotation_name
  from actual_column_annotations a
union all
select 'NULL_ANNOTATION_VALUE',
       object_name,
       column_name,
       annotation_name
  from user_annotations_usage
 where object_name in ('APP_USERS','TODO_LISTS','TAGS','TODO_LIST_TAGS','TASKS')
   and annotation_value is null
union all
select 'UNEXPECTED_ANNOTATION_COUNT',
       cast(count(*) as varchar2(128)),
       cast(null as varchar2(128)),
       'EXPECTED_126'
  from user_annotations_usage
 where object_name in ('APP_USERS','TODO_LISTS','TAGS','TODO_LIST_TAGS','TASKS')
having count(*) <> 126;
