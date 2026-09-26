# SQL File Policy

## Why numbered SQL exists

Codex can execute SQL through MCP, but the human operator must be able to replay the same accepted changes without Codex.

Therefore every state-changing SQL action is persisted first.

## Numbering

Use four digits and increments of 10:

```text
0010_description.sql
0020_description.sql
0030_description.sql
```

This leaves insertion space without renumbering the full history.

## Required header

Every change file should begin with comments similar to:

```sql
-- Task: 10 Data Model
-- Target schema: TASKHUB_OWNER
-- Purpose: Create APP_USERS and TODO_LISTS base tables
-- Preconditions: Manual bootstrap complete
-- Verification: db/tests/structure/...
```

## What belongs in db/changes

- DDL
- material seed/setup DML
- grants/revokes
- scheduler creation/change
- changes that alter persistent database state

## What does not belong in db/changes

- one-off dictionary SELECTs
- troubleshooting queries that do not change state
- repeated verification queries, which belong in `db/tests/`

## Immutability

Once a task is accepted and marked DONE, do not rewrite its executed migration history to hide a later change. Add a new numbered change file and update canonical source under `db/src/`.
