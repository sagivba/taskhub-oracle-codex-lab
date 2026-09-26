-- Supports active-task reads and list-scoped purge by TODO_LIST_ID and DELETED_AT.
create index taskhub_owner.tasks_ix1
    on taskhub_owner.tasks (
        todo_list_id,
        deleted_at
    );

-- Supports hierarchy traversal and child-before-parent physical purge.
create index taskhub_owner.tasks_ix2
    on taskhub_owner.tasks (parent_task_id);

-- Supports status/priority work queues ordered or filtered by due date.
create index taskhub_owner.tasks_ix3
    on taskhub_owner.tasks (
        status,
        priority,
        due_at
    );

-- TASKS_PK is the unique index created for the TASKS primary key.
