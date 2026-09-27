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

`TASKHUB_API -> TASKHUB_APP` exposes only the approved API and filtered views.

`TASKHUB_APP` deliberately receives no direct owner-table DML. The restriction forces
writes through definer-rights operations that derive ownership/audit identity from
context and enforce business authorization. `TASKHUB_API` receives only direct object
privileges required by stored code because role privileges do not satisfy
definer-rights compilation and broader grants would weaken the boundary.

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
