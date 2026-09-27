-- Task: 30 Read Isolation
-- Target schema: TASKHUB_API
-- Purpose: Create the four context-filtered, soft-delete-aware, read-only application views.
-- Preconditions: db/changes/0190_grant_read_view_sources.sql has been applied; execute as TASKHUB_API.
-- Verification: db/tests/structure/0370_task30_views.sql
--               db/tests/functional/0020_task30_missing_context.sql
--               db/tests/functional/0040_task30_read_isolation.sql
--               db/tests/security/0080_task30_views_read_only.sql
-- Notes: Missing context fails closed because every ownership path compares with TASKHUB_CTX.APP_USER_ID.

create or replace view taskhub_api.v_todo_lists as
select l.id,
       l.app_user_id,
       l.list_name,
       l.created_at,
       l.created_by_user_id,
       l.updated_at,
       l.updated_by_user_id,
       l.deleted_at,
       l.deleted_by_user_id
  from taskhub_owner.todo_lists l
 where l.app_user_id = to_number(sys_context('TASKHUB_CTX', 'APP_USER_ID'))
   and l.deleted_at is null
with read only;

comment on table taskhub_api.v_todo_lists is
    'Read-only active lists for the TASKHUB_CTX application user; missing context returns no rows so callers cannot bypass ownership filtering.';

comment on column taskhub_api.v_todo_lists.app_user_id is
    'Canonical list owner matched only to TASKHUB_CTX.APP_USER_ID.';

comment on column taskhub_api.v_todo_lists.deleted_at is
    'Always NULL because soft-deleted lists are excluded at the read boundary.';

create or replace view taskhub_api.v_todo_list_tags as
select a.id,
       a.todo_list_id,
       a.tag_id,
       a.created_at
  from taskhub_owner.todo_list_tags a
  join taskhub_owner.todo_lists l
    on l.id = a.todo_list_id
  join taskhub_owner.tags t
    on t.id = a.tag_id
 where l.app_user_id = to_number(sys_context('TASKHUB_CTX', 'APP_USER_ID'))
   and l.deleted_at is null
   and t.app_user_id = l.app_user_id
   and t.deleted_at is null
with read only;

comment on table taskhub_api.v_todo_list_tags is
    'Read-only active list/tag associations for TASKHUB_CTX; both endpoints must be active and share the context owner so inconsistent cross-owner rows fail closed.';

comment on column taskhub_api.v_todo_list_tags.todo_list_id is
    'Associated active list owned by TASKHUB_CTX.APP_USER_ID.';

comment on column taskhub_api.v_todo_list_tags.tag_id is
    'Associated active tag whose owner must equal both the list owner and TASKHUB_CTX.APP_USER_ID.';

create or replace view taskhub_api.v_tasks as
select t.id,
       t.todo_list_id,
       t.parent_task_id,
       t.title,
       t.description,
       t.status,
       t.priority,
       t.due_at,
       t.completed_at,
       t.created_at,
       t.created_by_user_id,
       t.updated_at,
       t.updated_by_user_id,
       t.deleted_at,
       t.deleted_by_user_id
  from taskhub_owner.tasks t
  join taskhub_owner.todo_lists l
    on l.id = t.todo_list_id
 where l.app_user_id = to_number(sys_context('TASKHUB_CTX', 'APP_USER_ID'))
   and l.deleted_at is null
   and t.deleted_at is null
with read only;

comment on table taskhub_api.v_tasks is
    'Read-only active tasks whose ownership is derived through an active list matched to TASKHUB_CTX.APP_USER_ID.';

comment on column taskhub_api.v_tasks.todo_list_id is
    'Ownership path to an active list matched to TASKHUB_CTX.APP_USER_ID.';

comment on column taskhub_api.v_tasks.deleted_at is
    'Always NULL because soft-deleted tasks are excluded at the read boundary.';

create or replace view taskhub_api.v_task_tree as
with filtered_tasks as (
    select t.id as task_id,
           t.todo_list_id,
           t.parent_task_id,
           t.title,
           t.status,
           t.priority
      from taskhub_owner.tasks t
      join taskhub_owner.todo_lists l
        on l.id = t.todo_list_id
     where l.app_user_id = to_number(sys_context('TASKHUB_CTX', 'APP_USER_ID'))
       and l.deleted_at is null
       and t.deleted_at is null
)
select task_id,
       todo_list_id,
       parent_task_id,
       title,
       status,
       priority,
       level - 1 as task_depth
  from filtered_tasks
 start with parent_task_id is null
connect by nocycle prior task_id = parent_task_id
               and prior todo_list_id = todo_list_id
               and level <= 4
with read only;

comment on table taskhub_api.v_task_tree is
    'Read-only depth-0-through-3 hierarchy built only from active tasks in active lists owned by TASKHUB_CTX.APP_USER_ID; prefiltering prevents global-tree leakage.';

comment on column taskhub_api.v_task_tree.task_id is
    'Identifier of an ownership-filtered active task in the hierarchy.';

comment on column taskhub_api.v_task_tree.task_depth is
    'Zero-based hierarchy depth constrained by the view to values from 0 through 3.';
