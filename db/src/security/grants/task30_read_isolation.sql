-- Views use direct owner-table SELECT grants because roles cannot support stored
-- view compilation. Oracle also requires object-specific grant option before the
-- view owner can grant those views; it remains limited to the four source tables.
grant select on taskhub_owner.todo_lists to taskhub_api with grant option;
grant select on taskhub_owner.tags to taskhub_api with grant option;
grant select on taskhub_owner.todo_list_tags to taskhub_api with grant option;
grant select on taskhub_owner.tasks to taskhub_api with grant option;

-- TASKHUB_APP sees data only through context-filtered, soft-delete-aware views;
-- withholding owner-table access prevents callers from bypassing those predicates.
grant select on taskhub_api.v_todo_lists to taskhub_app;
grant select on taskhub_api.v_todo_list_tags to taskhub_app;
grant select on taskhub_api.v_tasks to taskhub_app;
grant select on taskhub_api.v_task_tree to taskhub_app;
