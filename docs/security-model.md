# Security Model

## Security objective

The POC deliberately separates data ownership, executable application code and application execution identity.

The security boundary is the combination of:

```text
Application Context
+
Definer-rights PL/SQL
+
Filtered read-only views
+
Explicit object grants
```

## Identity

Application identity is not passed as a CRUD parameter.

The effective application user is read from:

```sql
sys_context('TASKHUB_CTX', 'APP_USER_ID')
```

The username is available as:

```sql
sys_context('TASKHUB_CTX', 'APP_USERNAME')
```

The runtime caller does not supply either value. `APEX$SESSION.APP_USER` is resolved
to one active canonical `APP_USERS` row by the trusted context path. This prevents a
caller from choosing another user's numeric ID and keeps ownership and audit fields
anchored to the same validated identity source.

## Context package separation

`TASKHUB_CTX` is associated with:

```text
TASKHUB_API.PKG_TASKHUB_CONTEXT_CORE
```

The core package is not granted to `TASKHUB_APP`.

Any session may read its own context values with `SYS_CONTEXT`, but only the package
trusted by `TASKHUB_CTX` can set them. Withholding core execution from `TASKHUB_APP`
prevents the restricted runtime principal from invoking identity-setting operations.

Runtime APEX code uses:

```text
TASKHUB_API.PKG_TASKHUB_CONTEXT
```

DEV tests use:

```text
TASKHUB_API.PKG_TASKHUB_TEST_CONTEXT
```

The test package is not granted to `TASKHUB_APP` and is not part of the production-like deployment package by default.

The separate test facade exists because Oracle grants `EXECUTE` at package level. If a
username-taking test hook shared the runtime package, granting runtime initialization
would also expose impersonation capability.

## Deterministic session rule

Every identity-sensitive test must clear and initialize context explicitly.

This is required because SQLcl, MCP and future pools can reuse database sessions. A passing test must never depend on context left by a previous operation.

## Privilege model

`TASKHUB_OWNER -> TASKHUB_API` uses direct object grants required for stored-code compilation and runtime.

For the four Task 30 view sources (`TODO_LISTS`, `TAGS`, `TODO_LIST_TAGS` and
`TASKS`), the direct `SELECT` grants include object-specific `WITH GRANT OPTION`.
Oracle requires that delegation authority before `TASKHUB_API` can grant its views to
`TASKHUB_APP`. The exception is deliberately limited to these four `SELECT` grants:
it adds no DML, no `ANY` privilege and no direct owner-table privilege for
`TASKHUB_APP`.

`TASKHUB_API -> TASKHUB_APP` exposes only the approved API and filtered views.

`TASKHUB_APP` deliberately receives no direct owner-table DML. The restriction forces
writes through definer-rights operations that derive ownership/audit identity from
context and enforce business authorization. `TASKHUB_API` receives only direct object
privileges required by stored code because role privileges do not satisfy
definer-rights compilation and broader grants would weaken the boundary.

Task 40 adds only `TODO_LISTS UPDATE`, `TAGS INSERT/UPDATE`,
`TODO_LIST_TAGS INSERT/DELETE` and `TASKS UPDATE` to `TASKHUB_API`. Tag identity is
the current context user plus `UPPER(TRIM(TAG_NAME))`; the active-only unique index is
the concurrency authority and lets deleted names be recreated as new rows. List and
Tag lookup errors deliberately collapse missing, foreign and inactive objects into
generic results. Association add/remove is idempotent, List deletion retains link rows
for later purge, and Tag deletion physically removes its links before soft deletion.

Task 50 adds only `TASKS INSERT` to `TASKHUB_API`; existing `UPDATE` implements both
ordinary updates and logical deletion. Task ownership continues to inherit through a context-owned active
List. Parent lookup collapses missing, foreign and inactive rows into one result, while
a same-user parent in another List can report the same-list rule. Hierarchy validation
combines proposed parent depth with active subtree height and rejects self-parenting,
descendant cycles and any result beyond root/child/grandchild. Status uses canonical
`CANCELED`; DONE state alone controls `COMPLETED_AT`.

Task 60 adds non-grantable `DELETE` on `TODO_LISTS`, `TAGS` and `TASKS` only to
`TASKHUB_API`; the association-table `DELETE` grant already exists from Task 40.
`PKG_TASKHUB_MAINT` is an internal definer-rights boundary and is not executable by
`TASKHUB_APP`. It removes associations before retained parents, repeatedly deletes
eligible Task leaves before their parents because `TASKS_FK2` is immediate `NO ACTION`,
and deletes only empty eligible Lists and unreferenced eligible Tags. The monthly job
invokes that package instead of embedding table DML.

Forbidden shortcuts include:

```text
SELECT ANY TABLE
INSERT ANY TABLE
UPDATE ANY TABLE
DELETE ANY TABLE
EXECUTE ANY PROCEDURE
```

## Non-disclosure rule

Where the specification requires it, the API must not reveal whether an ID exists when it belongs to another application user. The externally visible behavior for missing and unauthorized IDs must be equivalent.

## Transaction model

Business API packages do not issue `COMMIT` or `ROLLBACK`. The runtime caller owns the
transaction boundary so several approved operations can participate in one atomic
business transaction rather than being committed independently by lower-level code.

The internal maintenance package is deliberately different: its Scheduler-oriented
purge owns one atomic transaction, commits only after every FK-safe stage succeeds and
rolls back on error. It is not exposed to the runtime principal.

Task 30 and Task 40 DEV cross-schema fixtures use a separate testing exception. Fixture setup
as `TASKHUB_OWNER` commits so a different `TASKHUB_API` session can initialize trusted
context and verify the views; FK-safe owner cleanup then commits and proves zero
residual prefixed rows. This cross-session test orchestration does not execute through
or alter the transaction contract of `PKG_TASKHUB_API`.
