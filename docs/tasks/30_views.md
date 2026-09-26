# Task 30 - Filtered Read-only Views

## Objective
Expose read paths through `TASKHUB_API` while keeping `TASKHUB_OWNER` tables inaccessible to `TASKHUB_APP`.

## Required views

```text
V_TODO_LISTS
V_TODO_LIST_TAGS
V_TASKS
V_TASK_TREE
```

All views must be `WITH READ ONLY`.

## Required behavior

- filter by `TASKHUB_CTX.APP_USER_ID`;
- return zero rows when context is missing;
- hide soft-deleted rows;
- derive task ownership through the parent list;
- `V_TODO_LIST_TAGS` must also exclude associations whose list or tag is soft-deleted;
- task tree depth is 0 through 3.

## Tests

- user A sees only A data;
- user B sees only B data;
- missing context returns zero rows;
- soft-deleted list/task/tag data is hidden;
- attempts to update through views fail;
- direct table select as `TASKHUB_APP` fails.

## Success criteria

All positive and negative read-security tests pass and `TASKHUB_APP` has only the approved view grants.
