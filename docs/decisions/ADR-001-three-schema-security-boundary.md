# ADR-001 - Three-schema security boundary

## Status
Accepted

## Decision
Use three Oracle schemas:

```text
TASKHUB_OWNER
TASKHUB_API
TASKHUB_APP
```

`TASKHUB_OWNER` owns data objects, `TASKHUB_API` owns executable application interfaces and filtered views, and `TASKHUB_APP` receives only approved interface privileges.

## Rationale
The POC explicitly tests security separation. Keeping application code out of the data owner makes the separation visible, testable and suitable for least-privilege grants.

## Consequence
Stored code in `TASKHUB_API` requires direct object grants from `TASKHUB_OWNER`. `TASKHUB_APP` must never receive direct table access.
