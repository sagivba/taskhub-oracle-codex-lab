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
