# TaskHub Specification Review - v2 to v3

## Review outcome

The supplied v2 specification was a strong baseline, but several architecture and testability issues had to be corrected before using it as the repository source of truth.

All accepted corrections are incorporated into `docs/spec/TaskHub_POC_Specification_HE_v3.md`.

## Incorporated corrections

### Three-schema separation

Changed from two schemas to:

```text
TASKHUB_OWNER
TASKHUB_API
TASKHUB_APP
```

This makes the intended security separation explicit and testable.

### Views moved to the API boundary

Filtered read-only views are owned by `TASKHUB_API`, not by the Data Owner.

`TASKHUB_APP` therefore consumes only API-owned interfaces and has no direct grant from the data owner.

### Context testability without exposing a test bypass

A single context package containing both runtime and `init_for_test` entry points would create a package-level privilege problem because Oracle `EXECUTE` is granted on the package object, not on individual packaged procedures.

The v3 design therefore separates:

```text
PKG_TASKHUB_CONTEXT_CORE
PKG_TASKHUB_CONTEXT
PKG_TASKHUB_TEST_CONTEXT
```

The DEV-only test facade is not granted to `TASKHUB_APP`.

### Deterministic session identity

Every test or MCP flow that depends on identity must clear and initialize the context explicitly. Tests must not rely on state from a previous database session use.

### Soft-delete-aware tag uniqueness

The original unique index would continue to block a tag name after soft delete.

The v3 design specifies active-only normalized uniqueness using a function-based unique index.

### Purge ordering

Physical purge now explicitly requires child/association deletion order that preserves FK and self-FK integrity.

### Data dictionary documentation

Table and business-column comments are now part of the Definition of Done and are tested.

### Numbered SQL and replay

All persistent changes use four-digit filenames in increments of 10 and are written before execution.

### Clean rebuild gate

A milestone requires a clean rebuild from repository source after the approved manual bootstrap, followed by the full test suite.


### Audit consistency for TAGS

The v2 model described full application audit behavior but omitted `CREATED_BY_USER_ID` and `UPDATED_BY_USER_ID` from `TAGS`. v3 adds them and narrows the audit rules explicitly per table.

### Tag deletion semantics

The v2 specification applied soft delete to `TAGS` but did not define an API operation that could actually soft-delete a tag. v3 adds `delete_tag(p_tag_id)` and defines `remove_tag_from_list` as association removal rather than tag deletion.

## Deliberately deferred decisions

The following are not guessed in the starter repository:

- exact Oracle 26ai Docker image/tag;
- actual WSL/Codex/SQLcl/Java versions and paths;
- final SQLcl saved connection names;
- whether `TODO_LIST_TAGS(TAG_ID)` needs a separate index, which depends on actual queries/purge access paths;
- adoption of `utPLSQL`, which is deferred until deterministic SQL/PLSQL tests prove insufficient.
