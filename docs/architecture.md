# TaskHub Architecture

## Purpose

This document summarizes the approved target architecture for the POC. The full functional specification is in `docs/spec/TaskHub_POC_Specification_HE_v3.md`.

## Database schemas

### TASKHUB_OWNER

Data Owner only.

Owns tables, constraints, indexes, identity columns and data dictionary comments.

It does not own application API packages and is never the future APEX parsing schema.

### TASKHUB_API

Code/API Owner.

Owns:

- `PKG_TASKHUB_CONTEXT_CORE`
- `PKG_TASKHUB_CONTEXT`
- `PKG_TASKHUB_TEST_CONTEXT` in DEV only
- `PKG_TASKHUB_API`
- `PKG_TASKHUB_MAINT`
- filtered read-only views
- monthly purge scheduler job

It receives only explicit object grants from `TASKHUB_OWNER`.

### TASKHUB_APP

Application schema and future APEX parsing schema.

It receives only approved interface privileges from `TASKHUB_API`.

It must have no direct table privilege on `TASKHUB_OWNER`.

## Trust path

```text
Application / future APEX
          |
          v
     TASKHUB_APP
          |
          | EXECUTE / SELECT
          v
     TASKHUB_API
          |
          | explicit object grants
          v
    TASKHUB_OWNER
```

## Source of truth

The repository, not the current database state, is the source of truth.

A database object that cannot be reconstructed from the repository is considered configuration drift and a failed milestone condition.
