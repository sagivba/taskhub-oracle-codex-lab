# Numbered Database Changes

This directory records the SQL that actually changes persistent database state in DEV.

Codex must create the file before executing its contents through MCP.

Naming convention:

```text
0010_description.sql
0020_description.sql
0030_description.sql
```

Use increments of 10.

Each file should contain one coherent logical change and a header with task, target schema, purpose, preconditions and verification.

After a task is accepted as DONE, treat its executed change files as history. Add a later numbered file instead of rewriting history.

Use `scripts/generate_run_all.sh` to generate the manual SQLcl clean-install runner.
