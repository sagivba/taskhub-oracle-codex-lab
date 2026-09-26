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

## Context package separation

`TASKHUB_CTX` is associated with:

```text
TASKHUB_API.PKG_TASKHUB_CONTEXT_CORE
```

The core package is not granted to `TASKHUB_APP`.

Runtime APEX code uses:

```text
TASKHUB_API.PKG_TASKHUB_CONTEXT
```

DEV tests use:

```text
TASKHUB_API.PKG_TASKHUB_TEST_CONTEXT
```

The test package is not granted to `TASKHUB_APP` and is not part of the production-like deployment package by default.

## Deterministic session rule

Every identity-sensitive test must clear and initialize context explicitly.

This is required because SQLcl, MCP and future pools can reuse database sessions. A passing test must never depend on context left by a previous operation.

## Privilege model

`TASKHUB_OWNER -> TASKHUB_API` uses direct object grants required for stored-code compilation and runtime.

`TASKHUB_API -> TASKHUB_APP` exposes only the approved API and filtered views.

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
