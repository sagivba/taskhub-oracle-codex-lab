# Task 10 - Quick SQL and Data Model

## Objective
Implement the TaskHub data layer in `TASKHUB_OWNER` using Quick SQL as bootstrap and reviewed Oracle DDL as the final implementation.

## Read first

- Specification sections 5 through 14, 26, 28, 29 and 34.
- `docs/sql-file-policy.md`.

## Allowed connections

- `TASKHUB_OWNER` only for DDL/DML execution.
- Read-only verification may use documented lab connections as required.

## Required outputs

- Quick SQL source under `db/src/owner/quick-sql/`.
- Canonical table source under `db/src/owner/tables/`.
- Canonical constraint source under `db/src/owner/constraints/`.
- Canonical index source under `db/src/owner/indexes/`.
- Canonical comments under `db/src/owner/comments/`.
- Numbered change scripts in `db/changes/` before execution.
- Seed/test application users if required by later tests.
- Structural tests under `db/tests/structure/`.

## Minimum model

```text
APP_USERS
TODO_LISTS
TAGS
TODO_LIST_TAGS
TASKS
```

## Required validation

- identity primary key on each table;
- all required FKs including `TASKS.PARENT_TASK_ID` self-FK;
- explicit CHECK constraints for active flag, task status and priority;
- unique list/tag association;
- active-only normalized tag uniqueness;
- required baseline indexes;
- table and business-column comments;
- no unexpected invalid objects.

## Success criteria

- All structural tests pass.
- Data dictionary matches the approved model.
- Every state-changing statement is represented in `db/changes/`.
- Canonical source and change history are aligned.

## Stop condition

Do not start context packages while the data model or comments are incomplete.
