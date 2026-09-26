# Current Status

## Project state

Status: TASK 10 DATA MODEL COMPLETE

The TaskHub Oracle lab infrastructure is running, the three database schemas have been created and validated, and the Codex + SQLcl MCP read-only acceptance test has passed.

The Application Context core milestone is complete. The full canonical Task 10 owner-side model is implemented and structurally verified: `APP_USERS`, `TODO_LISTS`, `TAGS`, `TODO_LIST_TAGS` and `TASKS`.

## Current task

docs/tasks/20_security_context.md

## Approved architecture

- TASKHUB_OWNER: Data Owner
- TASKHUB_API: Code/API Owner
- TASKHUB_APP: Application / future APEX Parsing Schema
- Application Context: TASKHUB_CTX
- SQLcl MCP Restrict Level: R4
- QA deployment: manual, outside Codex

## Verified environment

WSL platform              : WSL2
WSL distribution/version : Ubuntu 24.04.3 LTS
Git version               : 2.43.0
Codex version             : 0.132.0
SQLcl version             : 26.1.2
Docker Desktop version    : 4.56.0
Docker Engine version     : 29.1.3

Oracle container          : taskhub-db
Oracle volume             : taskhub-oradata
Oracle network            : taskhub-net

Oracle image              : container-registry.oracle.com/database/free
Oracle image digest       : sha256:8a8084193724b95bc62247e3af4218b357e4f172c78925551b2181dbe2566232

Oracle product            : Oracle AI Database 26ai Free
Oracle version full       : 23.26.1.0.0
Oracle SID                : FREE
Oracle PDB/service        : FREEPDB1

Host listener port        : 1522
Container listener port   : 1521

Database open mode        : READ WRITE
FREEPDB1 open mode        : READ WRITE

NLS_CHARACTERSET          : AL32UTF8
NLS_NCHAR_CHARACTERSET    : AL16UTF16

## Database bootstrap

TASKHUB_OWNER:
- Account status: OPEN
- Default tablespace: USERS
- Temporary tablespace: TEMP
- Quota on USERS: UNLIMITED
- CREATE SESSION
- CREATE TABLE
- CREATE SEQUENCE

TASKHUB_API:
- Account status: OPEN
- Default tablespace: USERS
- Temporary tablespace: TEMP
- CREATE SESSION
- CREATE PROCEDURE
- CREATE VIEW
- CREATE JOB

TASKHUB_APP:
- Account status: OPEN
- Default tablespace: USERS
- Temporary tablespace: TEMP
- CREATE SESSION

## Security baseline validation

Verified:

- no roles granted to the three TaskHub schemas;
- no broad ANY system privileges;
- no object privileges currently granted;
- TASKHUB_APP has no direct access to TASKHUB_OWNER objects;
- no DBA or RESOURCE role grants.

## Oracle validation

Verified:

- Docker health: healthy
- Listener: PASS
- FREE: READ WRITE
- FREEPDB1: READ WRITE
- SQLcl connectivity through localhost:1522/FREEPDB1: PASS
- 13 registry components: VALID
- RAC: OPTION OFF, expected for Oracle Free single-instance

## Approved SQLcl saved connection names

TASKHUB_OWNER connection : taskhub-owner-mcp (verified through MCP)
TASKHUB_API connection   : NOT CONFIGURED
TASKHUB_APP connection   : taskhub-app-mcp (verified through MCP)

## Open items

1. Configure and document the approved `TASKHUB_API` connection before it is needed.
2. Complete Task 20 runtime/test context facades and extend the trusted core to resolve `APP_USER_ID` / `APP_USERNAME` from `APP_USERS`.
3. Add seed/test application users and cross-schema grants only in their approved task steps.

## Evidence

Environment-specific bootstrap evidence is stored under:

evidence/local/

Do not store credentials in evidence.

## Exact next step

Begin Task 20 from `docs/tasks/20_security_context.md`; configure and document the approved `TASKHUB_API` connection before executing its changes.

## Task 10 canonical data model

Status: PASS

Completed:
- Applied `0030_create_app_users.sql` through `0070_create_tasks.sql` in dependency order.
- Implemented the five-table owner model: `APP_USERS`, `TODO_LISTS`, `TAGS`, `TODO_LIST_TAGS`, `TASKS`.
- Verified identity PKs, all required FKs including the TASKS self-FK, unique/check constraints, active-only normalized tag uniqueness, required indexes, defaults, nullability and comments.
- Ran the complete structural suite `0010` through `0340`; all 34 files returned only their expected zero-row results.
- Kept `db/deploy/install/run_all.sql` synchronized with the accepted clean-install order.

Change scripts added in the completion milestone:
- `db/changes/0050_create_tags.sql`
- `db/changes/0060_create_todo_list_tags.sql`
- `db/changes/0070_create_tasks.sql`

Test compatibility note:
- `0210_tags_indexes.sql` uses `DBMS_METADATA.GET_DDL` to verify function expressions without applying string operations to the legacy LONG dictionary column.

Open issues:
- No Task 10 data-model issues remain.
- The approved `TASKHUB_API` saved connection is still not configured.

Evidence:
- `evidence/local/task10_data_model_completion_2026-09-26.md`

## APP_USERS milestone

Status: PASS

Completed:
- Corrected the manual bootstrap with `CREATE SEQUENCE` for `TASKHUB_OWNER`, required by the approved identity-column design.
- Applied `db/changes/0030_create_app_users.sql` successfully.
- Verified the exact seven-column model, identity generation, defaults, constraints, indexes and comments.
- Verified that no unexpected invalid object, redundant USERNAME index or username-normalization index was introduced.

Pending:
- No seed users yet.
- No APP_USERS grants yet.
- Application Context has not yet been extended with `APP_USER_ID` / `APP_USERNAME`.

Evidence:
- `evidence/local/app_users_0030_execution_2026-09-26.md`

## TODO_LISTS milestone

Status: PASS

Completed:
- Applied `db/changes/0040_create_todo_lists.sql` successfully.
- Structural verification `0110` through `0160` passed with zero discrepancies.
- Verified `TASKHUB_OWNER.APP_USERS` remains the prerequisite owner and audit-identity table.

Evidence:
- `evidence/local/todo_lists_0040_execution_2026-09-26.md`

Next:
- Continue Task 10 with `TASKHUB_OWNER.TAGS`.

## Application Context milestone

Status: PASS

Completed:
- Created `TASKHUB_CTX`.
- Created and compiled `TASKHUB_API.PKG_TASKHUB_CONTEXT_CORE`.
- Added deterministic `init_for_test(p_username)` behavior.
- Added `clear_context`.
- Verified `APP_USER` is session-local and is cleared correctly.
- Verified behavior as `TASKHUB_API`.
- Verified `TASKHUB_APP` cannot invoke the internal context-core package directly.

Security decision:
- `TASKHUB_APP` will not receive direct `EXECUTE` on `PKG_TASKHUB_CONTEXT_CORE`.
- Identity initialization will remain behind the `TASKHUB_API` security boundary.
- `USER_ID` is intentionally deferred until the canonical users table exists and the API can resolve it internally.

Evidence:
- `evidence/local/taskhub_context_milestone.txt`

Next:
- Continue with the next database source milestone.
- Build the canonical owner-side objects before extending the context with `USER_ID`.

## Codex + SQLcl MCP read-only acceptance

Status: PASS

Discovery:
- MCP server: `sqlcl-taskhub-lab`
- Discovery tool: `connections_list`
- Saved connection discovered: `taskhub-app-mcp`

Connection and identity:
- Connection tool: `connect`
- Saved connection used: `taskhub-app-mcp`
- SQL tool: `sql_run`
- `CONNECTED_USER = TASKHUB_APP`
- `CURRENT_SCHEMA = TASKHUB_APP`
- `TASKHUB_CTX.APP_USER = NULL`

Security boundary metadata:
- Direct privileges from `TASKHUB_APP` to `TASKHUB_API.PKG_TASKHUB_CONTEXT_CORE`: no rows selected.
- PUBLIC privileges on `TASKHUB_API.PKG_TASKHUB_CONTEXT_CORE`: no rows selected.
- `SESSION_ROLES`: no rows selected.
- `TASKHUB_API.PKG_TASKHUB_CONTEXT_CORE` was not invoked.

Safety:
- No DDL, DML, or PL/SQL was executed.
- No privileges, architecture, or database state were changed.

Conclusion:
- Codex + SQLcl MCP read-only acceptance test: PASS.
- The `TASKHUB_APP` security boundary against direct execution of `PKG_TASKHUB_CONTEXT_CORE` is verified through metadata.
- Evidence: `evidence/local/codex_sqlcl_mcp_acceptance_2026-09-26.md`.
