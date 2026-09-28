# Manual DBA Bootstrap

Files in this directory are privileged human-run scripts.

Codex must not execute them through MCP.

Recommended order for a new clean lab:

```text
0010_create_lab_users.sql
0020_create_application_context.sql
0030_verify_lab_bootstrap.sql
```

Before Task 70 platform installation, connect as `SYSDBA` directly to
`FREEPDB1` and run the read-only prerequisite check:

```text
0040_verify_task70_platform_prerequisites.sql
```

The Task 70 runbook owns the subsequent ORDS/APEX installation order. Do not
run an APEX installer against the root container.

`TASKHUB_CTX` can be created before `TASKHUB_API.PKG_TASKHUB_CONTEXT_CORE` exists. Oracle does not require the trusted package to exist at `CREATE CONTEXT` time, but it must exist when the context is used at runtime.

For a destructive reset, review and run `0090_drop_lab_environment.sql`, then repeat the bootstrap.
