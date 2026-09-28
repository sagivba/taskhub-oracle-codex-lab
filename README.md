# TaskHub Oracle Codex MCP Lab

Repository starter for a controlled Oracle Database development POC using Codex CLI and Oracle SQLcl MCP.

The repository is intentionally designed to act as the operating system of the lab. A new human or Codex session should be able to understand the approved architecture, current task, SQL execution history, tests, rebuild procedure and security boundaries from the repository itself.

## Start here

Read in this order:

```text
AGENTS.md
docs/status/CURRENT_STATUS.md
docs/spec/TaskHub_POC_Specification_HE_v3.md
docs/architecture.md
docs/security-model.md
docs/database-documentation-standard.md
docs/task_order.md
```

## Core architecture

```text
TASKHUB_APP
    |
    | EXECUTE / SELECT only
    v
TASKHUB_API
    |
    | explicit object grants
    v
TASKHUB_OWNER
```

- `TASKHUB_OWNER`: tables, constraints, indexes, comments and structured annotations.
- `TASKHUB_API`: packages, filtered read-only views, context code and maintenance job.
- `TASKHUB_APP`: APEX parsing schema with only approved interface privileges.

## Bootstrap boundary

The first Oracle container setup is manual.

The human operator is responsible for:

- validating WSL, Docker, Java, SQLcl and Codex versions;
- creating the clean Oracle container;
- creating the three lab database users;
- creating the `TASKHUB_CTX` application context namespace;
- preparing only the approved lab SQLcl saved connections;
- configuring SQLcl MCP at Restrict Level `R4`.

Codex starts only after this bootstrap is complete.

See `docs/manual-bootstrap.md`.

## Development rule

Every state-changing DDL or material DML statement must be written to a numbered SQL file under `db/changes/` before execution.

Codex runs the file contents through MCP `run-sql` under R4. A human can replay accepted scripts with SQLcl runner files under `db/deploy/`.

## Clean rebuild rule

After each milestone, the application layer must be reproducible from Git after the approved manual bootstrap. The full test suite must pass after the rebuild.

## Repository layout

```text
AGENTS.md
README.md
TODO.md
.github/
docs/
  spec/
  diagrams/
  tasks/
  decisions/
  status/
  reference/
db/
  admin/
  src/
    owner/
    api/
    security/
  changes/
  deploy/
  export/
  tests/
scripts/
evidence/
```

## Current state

The manual bootstrap and Database/API foundation through Task 60 are complete. This
includes the canonical five-table owner model, context boundary, filtered read-only
views, List/Tag and Task/Subtask APIs, retention-aware purge and monthly Scheduler job.

Task 70 - ORDS + APEX Foundation is complete. The ORDS/APEX platform, TaskHub
workspace/accounts, minimal APEX application export/import, request-context
lifecycle and mandatory browser isolation gate have passed. Task 80 has not started.

See `docs/status/CURRENT_STATUS.md`.

## Review and pitfalls

- `docs/review/specification_review_v2_to_v3.md`: what changed from the supplied specification and why.
- `docs/pitfalls-run-sql-vs-sqlcl-scripts.md`: differences to remember between MCP `run-sql` and manual SQLcl script execution.
- `docs/diagrams/`: current ERD, three-schema security architecture and lab execution flow.
