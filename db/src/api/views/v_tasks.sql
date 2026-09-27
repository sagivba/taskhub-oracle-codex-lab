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
