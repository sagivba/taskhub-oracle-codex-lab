# Current Status

## Project state

Status: TASK 20 SECURITY CONTEXT COMPLETE; CREATE-LIST API SLICE PASS

The TaskHub Oracle lab infrastructure is running, the three database schemas have been created and validated, and the Codex + SQLcl MCP read-only acceptance test has passed.

The full canonical Task 10 owner-side model is implemented and structurally verified. Task 20 now has validated runtime/test context facades, deterministic stale-session protection and least-privilege grants. The first Task 40 vertical slice, `PKG_TASKHUB_API.CREATE_LIST`, is implemented and verified; the rest of Task 40 remains pending.

## Current task

docs/tasks/30_views.md

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

## Current security grants

Verified:

- no broad `ANY` system privileges or roles were added;
- `TASKHUB_OWNER.APP_USERS`: `SELECT` to `TASKHUB_API`;
- `TASKHUB_OWNER.TODO_LISTS`: `SELECT`, `INSERT` to `TASKHUB_API`;
- `TASKHUB_API.PKG_TASKHUB_CONTEXT`: `EXECUTE` to `TASKHUB_APP`;
- `TASKHUB_API.PKG_TASKHUB_API`: `EXECUTE` to `TASKHUB_APP`;
- no owner-table privilege to `TASKHUB_APP`;
- no `TASKHUB_APP` execution privilege on context core/test packages.

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
TASKHUB_API connection   : taskhub-api-mcp (verified through MCP)
TASKHUB_APP connection   : taskhub-app-mcp (verified through MCP)

## Open items

1. Oracle Annotation export support is not implemented and no repository specification currently defines it; define scope before implementation.
2. No PL/SQL package documentation convention is defined; establish one before broad package expansion.
3. Task 30 filtered read-only views remain next in the approved task order.
4. Task 40 still requires list update/delete and all tag operations, ownership/non-disclosure behavior and full CRUD tests.
5. Positive `TASKHUB_APP` initialization through `INIT_FROM_APEX` requires a real APEX request context; DEV identity tests remain intentionally behind the ungranted test facade.

## Evidence

Environment-specific bootstrap evidence is stored under:

evidence/local/

Do not store credentials in evidence.

## Exact next step

Begin Task 30 from `docs/tasks/30_views.md`. Do not expand the remaining Task 40 API before the Task 30 view gate passes.

## Task 20 security context and create-list slice

Status: PASS

Completed:

- Added deterministic DEV identities for Alice, Bob and an inactive user.
- Replaced the bootstrap `APP_USER` setter with validated `APP_USER_ID` / `APP_USERNAME` initialization.
- Added `PKG_TASKHUB_CONTEXT` and DEV-only `PKG_TASKHUB_TEST_CONTEXT`.
- Added minimal `PKG_TASKHUB_API.CREATE_LIST(p_list_name) return number` with context-derived ownership/audit values and no transaction control.
- Added numbered changes `0080` through `0160`, canonical source, install-runner entries and context/security/functional tests.
- Verified all eight API package objects are valid and `USER_ERRORS` is empty.
- Verified the exact five-grant manifest and live negative behavior from `TASKHUB_APP`.
- Verified create-list ownership/audit behavior with rollback and no residual test rows.

Documentation-debt reconciliation:

- Oracle Annotation export support: not implemented or specified; recorded as follow-up.
- PL/SQL package documentation convention: not defined; recorded as follow-up.

Evidence:

- `evidence/local/task20_create_list_slice_2026-09-27.md`

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
- The approved `TASKHUB_API` saved connection is now configured and verified.

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
- Historical note: seed users, the APP_USERS lookup grant and context identity extension were delivered in Task 20.

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
- Created and compiled the core, runtime and DEV-only test context packages.
- Added deterministic, validated `APP_USER_ID` / `APP_USERNAME` initialization and explicit clear behavior.
- Verified active, inactive, unknown, A-to-B and valid-to-failed flows as `TASKHUB_API`.
- Verified `TASKHUB_APP` cannot invoke core/test packages or set the trusted context directly.

Security decision:
- `TASKHUB_APP` will not receive direct `EXECUTE` on `PKG_TASKHUB_CONTEXT_CORE`.
- Identity initialization remains behind the `TASKHUB_API` security boundary.
- Runtime identity accepts no caller username and reads `APEX$SESSION.APP_USER`.

Evidence:
- `evidence/local/taskhub_context_milestone.txt`

Next:
- Task 30 filtered views and read-isolation gate.

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
