# Task 50 - Task and Subtask API

## Objective
Implement task CRUD, hierarchy rules and lifecycle behavior.

## Scope

Implement at least:

- create task;
- update task;
- soft-delete task and descendants;
- parent validation;
- same-list rule;
- maximum depth 3;
- cycle prevention;
- status transitions;
- priority behavior;
- audit columns from application context.

## Required negative tests

- level 4 creation;
- parent in another list;
- parent owned by another user;
- cycle creation;
- update/delete another user's task;
- invalid ID does not disclose existence vs unauthorized ID.

## Lifecycle tests

- entering `DONE` sets `COMPLETED_AT` if null;
- leaving `DONE` clears `COMPLETED_AT`;
- priority order 1,2,3 maps to HIGH, MEDIUM, LOW behavior in ordering.

## Success criteria

Hierarchy, ownership, soft-delete and status tests all pass.
