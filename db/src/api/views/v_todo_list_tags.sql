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
