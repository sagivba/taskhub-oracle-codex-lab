-- Export: Oracle Annotations for objects owned by the connected schema
-- Connection/schema: object owner; TASKHUB_OWNER for the canonical TaskHub model
-- Purpose: expose structured documentation without requiring DBA dictionary access
-- Expected columns: OBJECT_NAME, OBJECT_TYPE, TARGET_LEVEL, COLUMN_NAME,
--                   ANNOTATION_NAME, ANNOTATION_VALUE

select object_name,
       object_type,
       case
           when column_name is null then 'OBJECT'
           else 'COLUMN'
       end as target_level,
       column_name,
       annotation_name,
       annotation_value
  from user_annotations_usage
 where object_name in (
           'APP_USERS',
           'TODO_LISTS',
           'TAGS',
           'TODO_LIST_TAGS',
           'TASKS'
       )
 order by object_name,
          case when column_name is null then 0 else 1 end,
          column_name,
          annotation_name;
