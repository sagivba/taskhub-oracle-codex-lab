# Pitfalls - MCP run-sql vs SQLcl Script Execution

## Why this matters

Under SQLcl MCP Restrict Level `R4`, Codex should send database SQL/PLSQL through `run-sql` rather than relying on SQLcl script execution with `@` or `@@`.

A file that works when executed manually with `@file.sql` can contain SQLcl client commands that are not database SQL.

## Client commands vs database statements

Examples of SQLcl/SQL*Plus-style client commands include:

```text
SET
DEFINE
UNDEFINE
ACCEPT
PROMPT
SPOOL
WHENEVER
@script.sql
@@script.sql
```

These must not be assumed to behave as part of `run-sql` input.

Keep manual runner scripts separate from database-only source whenever useful.

## Substitution variables

A manual script may contain:

```text
&name
&&name
DEFINE
SET DEFINE OFF
```

Codex must not blindly send such a script as database SQL and expect SQLcl substitution behavior.

For source that contains literal ampersands, Hebrew text or generated strings, verify whether the content is database SQL or depends on a SQLcl preprocessing command.

## Slash terminator

The `/` used after a PL/SQL unit is a client-side execution convention in SQLcl/SQL*Plus workflows.

When using MCP `run-sql`, Codex must follow the actual tool input behavior and not assume that copying a manual SQLcl script byte-for-byte is always correct.

## Encoding and Hebrew

Repository files must be UTF-8.

Tests should include at least one Hebrew value in data/comments when Hebrew content is relevant, so encoding problems are found in DEV rather than during manual deployment.

Do not treat an encoding failure as a reason to lower the MCP Restrict Level.

## DDL transaction behavior

Oracle DDL has implicit transaction effects. A failed multi-step deployment cannot be treated like one ordinary rollback-able DML transaction.

Keep changes small, ordered and verifiable.

## Manual deployment path

The repository keeps a separate manual SQLcl path under `db/deploy/`.

Human deployment can use SQLcl client features when required. Codex R4 development does not need to mimic every client command through MCP.
