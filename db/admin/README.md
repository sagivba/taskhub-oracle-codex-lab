# Manual DBA Bootstrap

Files in this directory are privileged human-run scripts.

Codex must not execute them through MCP.

Recommended order for a new clean lab:

```text
0010_create_lab_users.sql
0020_create_application_context.sql
0030_verify_lab_bootstrap.sql
```

`TASKHUB_CTX` can be created before `TASKHUB_API.PKG_TASKHUB_CONTEXT_CORE` exists. Oracle does not require the trusted package to exist at `CREATE CONTEXT` time, but it must exist when the context is used at runtime.

For a destructive reset, review and run `0090_drop_lab_environment.sql`, then repeat the bootstrap.
