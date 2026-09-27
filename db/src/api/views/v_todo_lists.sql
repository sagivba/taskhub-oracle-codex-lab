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
