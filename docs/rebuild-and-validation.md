# Rebuild and Validation

## Goal

A milestone is valid only if the application can be recreated from repository source after the approved manual bootstrap.

## Bootstrap vs application rebuild

Manual bootstrap owns:

- Oracle container
- database users
- `TASKHUB_CTX` namespace
- SQLcl/MCP connection configuration

Repository rebuild owns:

- all TaskHub tables, constraints, indexes and comments
- explicit cross-schema object grants
- all API packages
- filtered views
- scheduler job
- seed/test data required by the POC
- application-facing grants

## Milestone rebuild gate

1. Capture current expected manifests.
2. Reset the application environment according to the approved DBA runbook.
3. Run the manual bootstrap.
4. Recreate application objects from `db/changes/` / install runner.
5. Run all structural, context, security, functional and maintenance tests.
6. Verify no invalid objects remain.
7. Verify expected grants and absence of forbidden direct grants.
8. Record concise evidence under `evidence/`.

Do not mark a milestone DONE if the existing database is the only place where the correct state exists.
