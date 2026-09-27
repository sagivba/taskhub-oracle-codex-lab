# AGENTS.md - TaskHub Oracle Codex Lab

This repository is the operating system and source of truth for the TaskHub Oracle POC.

These rules apply to Codex CLI and any AI-assisted development performed in this repository.

## 1. Non-negotiable source-of-truth rule

- Git files are the source of truth.
- Never make a database-only change.
- Every state-changing DDL or material DML statement must exist in a numbered file under `db/changes/` before it is executed.
- Update the canonical end-state source under `db/src/` in the same task.
- One-off read-only diagnostic SQL does not require a change file. A query that becomes part of verification must be saved under `db/tests/`.
- Do not rely on information that exists only in a chat, Codex context, SQLcl session, or database session.

## 2. Architecture boundary

The POC uses three database schemas:

- `TASKHUB_OWNER`: data owner only. Tables, constraints, indexes, identity columns and data dictionary comments.
- `TASKHUB_API`: code owner. Packages, filtered read-only views, scheduler job and application-context code.
- `TASKHUB_APP`: application schema and future APEX parsing schema. It receives only approved `EXECUTE` and `SELECT` grants.

`TASKHUB_APP` must never receive direct table privileges on `TASKHUB_OWNER`.

Do not collapse these schemas or move objects between them unless the task explicitly changes the approved architecture.

## 3. Manual bootstrap is outside Codex scope

Codex must not:

- create or drop Oracle database users;
- create or drop the Oracle container;
- change Docker configuration unless a task explicitly changes this boundary;
- create or drop `TASKHUB_CTX`;
- grant itself system privileges;
- modify SQLcl MCP configuration;
- lower the SQLcl MCP Restrict Level;
- inspect or use an unrelated saved database connection;
- connect to QA, Production, or any environment not explicitly documented as the lab.

The human operator performs the privileged bootstrap described in `docs/manual-bootstrap.md` and `db/admin/`.

## 4. MCP execution policy

The lab starts with SQLcl MCP Restrict Level `R4`.

- Use MCP `run-sql` for SQL and PL/SQL execution in DEV.
- Do not depend on `@` or `@@` through MCP.
- Do not use SQLcl host commands through MCP.
- For manual human replay, maintain SQLcl runner files under `db/deploy/` that use `@` or `@@` as appropriate.
- Use only the saved lab connections recorded in `docs/status/CURRENT_STATUS.md`.
- If the connection names are not recorded, stop and ask the user instead of guessing.

## 5. Numbered SQL policy

Files under `db/changes/` use four-digit numbers in increments of 10:

```text
0010_<description>.sql
0020_<description>.sql
0030_<description>.sql
```

Rules:

- Create the change file before executing its SQL.
- The filename must describe one coherent logical change.
- The file header must state task, target schema, purpose, preconditions and verification.
- After a task is marked DONE, treat its executed change files as append-only history. Do not rewrite them to hide later changes. Add a new numbered change file instead.
- Keep `db/deploy/install/run_all.sql` synchronized with the accepted clean-install sequence.
- Do not put ad hoc diagnostic SELECTs in `db/changes/`.

## 6. Task execution contract

Before implementing a task, read:

1. `docs/status/CURRENT_STATUS.md`
2. `docs/task_order.md`
3. the current file under `docs/tasks/`
4. relevant sections of `docs/spec/TaskHub_POC_Specification_HE_v3.md`
5. relevant architecture/security decisions under `docs/decisions/`

Every task must define:

- objective;
- scope;
- allowed schemas/connections;
- required output files;
- success criteria;
- tests;
- stop condition.

Do not start the next task until the current task meets its stop condition or is explicitly marked BLOCKED/PARTIAL.

## 7. Change style

- Keep changes small and reviewable.
- Make one logical change at a time.
- Do not edit unrelated files.
- Do not reorganize the repository unless explicitly requested.
- Do not introduce speculative abstractions.
- Prefer explicit Oracle SQL and PL/SQL over clever metaprogramming.
- Preserve the approved three-schema security boundary.
- Quick SQL is a bootstrap input, not the final implementation.
- Do not add dependencies, test frameworks or deployment tools unless a task explicitly requires them.

## 8. Application Context rules

The application context is `TASKHUB_CTX`.

The trusted package is:

```text
TASKHUB_API.PKG_TASKHUB_CONTEXT_CORE
```

Runtime APEX facade:

```text
TASKHUB_API.PKG_TASKHUB_CONTEXT
```

DEV-only test facade:

```text
TASKHUB_API.PKG_TASKHUB_TEST_CONTEXT
```

Identity-sensitive tests and MCP flows must be deterministic:

- clear context first;
- initialize the requested test identity explicitly;
- never rely on a previous session's context;
- on failed initialization, verify that the context is empty;
- `TASKHUB_APP` must not have execute privilege on the core or test package.

## 9. PL/SQL security and transaction rules

- `APP_USER_ID` must not be accepted as a CRUD parameter.
- Resolve the application user from `TASKHUB_CTX`.
- Check ownership before every user-scoped operation.
- Use the same externally visible error behavior for "not found" and "belongs to another user" when the specification requires non-disclosure.
- `PKG_TASKHUB_API` must not issue `COMMIT` or `ROLLBACK`.
- Stored PL/SQL must compile using direct object grants, not privileges inherited only through roles.
- Do not use `ANY` privileges to solve compilation or access problems.
- Do not expose the DEV-only test-context package to `TASKHUB_APP`.

## 10. Data model and documentation rules

- Every table must have a `COMMENT ON TABLE` statement.
- Every business column must have a `COMMENT ON COLUMN` statement.
- Follow `docs/database-documentation-standard.md` for Oracle comments, annotations and PL/SQL public-contract documentation.
- Non-obvious architecture and security documentation must explain why the boundary exists, not only what object implements it.
- Every required PK, FK, UK and CHECK constraint must have a stable explicit name.
- Every index must have a documented purpose or supporting query/constraint.
- Do not add indexes only because a foreign key exists. Add them when the workload, purge path or locking behavior justifies them.
- Soft-delete behavior must be reflected consistently in views, unique rules and purge tests.

## 11. Testing policy

The initial POC uses deterministic SQL/PLSQL tests. Do not introduce `utPLSQL` unless a later task explicitly approves it.

Testing layers:

- `db/tests/structure/`: objects, columns, constraints, indexes, comments, invalid objects.
- `db/tests/context/`: context initialization, clearing, inactive/missing users, stale-session prevention.
- `db/tests/security/`: grants, direct-access denial, cross-user isolation, negative authorization.
- `db/tests/functional/`: status transitions, priority, hierarchy, CRUD, soft delete.
- `db/tests/maintenance/`: purge retention and FK-safe physical deletion.
- `db/tests/rebuild/`: expected manifests and clean-rebuild verification.

Tests must be deterministic and must not depend on execution order unless the test file explicitly creates its own prerequisite state.

## 12. Required verification after a change

At minimum, run the checks relevant to the task:

- expected objects exist;
- no unexpected invalid objects exist;
- `USER_ERRORS` is empty for changed PL/SQL/views when applicable;
- required constraints are enabled;
- required indexes exist and are valid;
- required comments exist;
- grants match the security contract;
- identity-sensitive tests initialize context explicitly;
- task-specific positive and negative tests pass.

Return concise evidence. Do not dump large dictionary query results into the conversation unless needed to diagnose a failure.

## 13. Clean rebuild gate

A milestone is not complete until the clean-rebuild gate passes.

After the human performs the approved manual bootstrap, the repository must be sufficient to recreate all application-owned objects and data required by the POC.

The rebuild gate must prove:

- installation from Git succeeds in the documented order;
- full structural tests pass;
- security tests pass;
- functional tests pass;
- expected grants match;
- no invalid objects remain;
- no database-only source is required.

## 14. QA boundary

Codex develops and tests only in the DEV lab.

Codex may produce deployment packages for QA, but must not deploy to QA.

QA deployment is a human-run, reviewed SQLcl process outside the lab.

## 15. Documentation and status

When a task changes architecture, workflow, setup, security contract or deployment behavior, update the relevant documentation in the same task.

At task completion update:

```text
docs/status/CURRENT_STATUS.md
```

Record:

- completed task;
- tests run and result;
- change scripts created;
- open issues;
- exact next task.

## 16. Definition of Done

Do not claim DONE unless:

- success criteria are satisfied;
- required files are present in Git;
- relevant tests pass;
- documentation is aligned;
- no unrecorded database-only change was made;
- evidence is concise and reproducible.

If a required check cannot be run, state exactly what was not run and why. Mark the task PARTIAL or BLOCKED rather than DONE.

## 17. If unsure

- Do not invent missing requirements.
- Prefer the smallest safe change.
- Prefer a read-only verification before changing database state.
- Preserve the approved security boundary.
- Ask the user before changing architecture, MCP policy, schema responsibilities or bootstrap rules.
