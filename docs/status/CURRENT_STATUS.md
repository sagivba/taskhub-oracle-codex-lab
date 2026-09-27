# Current Status

## Project state

Status: TASK 60 MAINTENANCE AND PURGE COMPLETE; TASKS 10, 20, 30, 40, 50 AND DOCUMENTATION HARDENING REMAIN PASS

The TaskHub Oracle lab infrastructure is running, the three database schemas have been created and validated, and the Codex + SQLcl MCP read-only acceptance test has passed.

The canonical model, security context, documentation hardening, filtered views and Task 40/50 APIs remain verified. Task 60 now provides retention-aware FK-safe physical purge through an internal maintenance package and an enabled monthly Scheduler job.

## Current task

docs/tasks/70_security_regression.md

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
- `TASKHUB_OWNER.TODO_LISTS`: `SELECT WITH GRANT OPTION`, `INSERT` to `TASKHUB_API`;
- `TASKHUB_OWNER.TODO_LISTS`: `UPDATE` to `TASKHUB_API`;
- `TASKHUB_OWNER.TAGS`: `SELECT WITH GRANT OPTION`, `INSERT`, `UPDATE` to `TASKHUB_API`;
- `TASKHUB_OWNER.TODO_LIST_TAGS`: `SELECT WITH GRANT OPTION`, `INSERT`, `DELETE` to `TASKHUB_API`;
- `TASKHUB_OWNER.TASKS`: `SELECT WITH GRANT OPTION`, `INSERT`, `UPDATE` to `TASKHUB_API`;
- `TASKHUB_OWNER.TODO_LISTS`, `TAGS`, `TASKS`: `DELETE` to `TASKHUB_API` for internal maintenance;
- `TASKHUB_API.PKG_TASKHUB_CONTEXT`: `EXECUTE` to `TASKHUB_APP`;
- `TASKHUB_API.PKG_TASKHUB_API`: `EXECUTE` to `TASKHUB_APP`;
- `TASKHUB_API.V_TODO_LISTS`, `V_TODO_LIST_TAGS`, `V_TASKS`, `V_TASK_TREE`: `SELECT` to `TASKHUB_APP`;
- no owner-table privilege to `TASKHUB_APP`;
- no `TASKHUB_APP` execution privilege on context core/test/maintenance packages.

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

1. Task 70 full security/regression consolidation has not been started.
2. Positive `TASKHUB_APP` initialization through `INIT_FROM_APEX` requires a real APEX request context; DEV identity tests remain intentionally behind the ungranted test facade.

## Evidence

Environment-specific bootstrap evidence is stored under:

evidence/local/

Do not store credentials in evidence.

## Exact next step

Begin Task 70 only when explicitly requested, using `docs/tasks/70_security_regression.md`. Preserve the completed Task 60 retention, hierarchy and least-privilege boundaries.

## Task 60 Maintenance and Purge

Status: PASS (2026-09-27)

Completed:

- Added internal definer-rights `TASKHUB_API.PKG_TASKHUB_MAINT.PURGE_DELETED` using the canonical `deleted_at < systimestamp - interval '30' day` retention rule.
- Purges associations first, then eligible Task leaves in repeated passes, then eligible empty Lists and unreferenced eligible Tags; newer children safely retain older parents.
- Added enabled `JOB_TASKHUB_PURGE_MONTHLY` as a `STORED_PROCEDURE` job for the first day of each month at 02:00, invoking the maintenance package without embedded purge SQL.
- Added only non-grantable `TODO_LISTS`, `TAGS` and `TASKS DELETE` grants to `TASKHUB_API`; `TASKHUB_APP` retains no owner-table privilege and no maintenance-package execution.
- Preserved the exact Task 20/30/40/50 public package signatures and existing runtime grants.
- Added changes `0260` through `0280`, canonical package/job/grant source, generated install-runner entries and persistent structure/security/maintenance tests.
- Verified retention preservation, association-first deletion, two three-level hierarchy purges, mixed-age hierarchy safety, List/Tag referential integrity, repeatable final state and zero residual fixtures.
- Verified valid package objects, empty package errors, exact Scheduler metadata, enabled constraints, valid indexes, complete comments, exact grants, no broad `ANY` privileges and restricted-runtime negative behavior.
- Ran Task 20 context switching, Task 20 create-list, Task 50 positive/negative and Task 30/40/50 runtime-security regressions successfully.

Evidence:

- `evidence/local/task60_maintenance_purge_2026-09-27.md`

## Task 50 Task and Subtask API

Status: PASS (2026-09-27)

Completed:

- Preserved every Task 40 signature and added `CREATE_TASK`, `UPDATE_TASK` and `DELETE_TASK` to `PKG_TASKHUB_API`.
- Used canonical `CANCELED`, priority `1..3`, context-derived audit identity and immutable `TODO_LIST_ID` after creation.
- Enforced active context-owned Lists/Tasks/parents, same-List parenting, root/child/grandchild maximum depth, self/deep-cycle prevention and hierarchy-safe re-parenting based on ancestor depth plus subtree height.
- Implemented DONE `COMPLETED_AT` set/preserve/clear lifecycle and soft deletion of a Task plus active same-List descendants with one logical timestamp.
- Added only `TASKS INSERT` to `TASKHUB_API`; logical deletion continues through existing `UPDATE`, and `TASKHUB_APP` retains no owner-table privilege.
- Added changes `0240` and `0250`, canonical source/grants, install-runner entries and persistent structure/security/functional tests.
- Verified valid package specification/body, empty affected `USER_ERRORS`, exact defaults/signatures/grants, positive and negative hierarchy behavior, non-disclosure, lifecycle, priority order, audit, filtered views, caller rollback and zero residual rows.
- Ran focused Task 20 context, Task 30 filtered-read, Task 40 List/Tag and restricted-runtime regressions before advancing beyond the Task 50 gate.
- Existing TASKS comments and annotations already document ownership, same-List hierarchy, cycle/depth validation, lifecycle, priority and context-derived audit, so no owner metadata DDL was necessary.

Evidence:

- `evidence/local/task50_task_subtask_api_2026-09-27.md`

## Task 40 List and Tag API

Status: PASS (2026-09-27)

Completed:

- Preserved `CREATE_LIST` and added `UPDATE_LIST`, `DELETE_LIST`, `ADD_TAG_TO_LIST`, `REMOVE_TAG_FROM_LIST` and name-based `DELETE_TAG` to `PKG_TASKHUB_API`.
- Derived ownership and audit identity only from validated `TASKHUB_CTX`; no public routine accepts an application-user or audit-user ID.
- Implemented generic non-disclosing List/Tag errors for missing, foreign and soft-deleted objects.
- Preserved active-only normalized Tag uniqueness, handled concurrent create with unique-index arbitration, and made association add/remove idempotent.
- Soft-deleted Lists plus their active Tasks, retained List associations for filtered-view hiding, and physically removed Tag associations before soft-deleting Tags.
- Added only the minimal owner-to-API DML grants; `TASKHUB_APP` retains package/view access and no owner-table privilege.
- Added changes `0220` and `0230`, canonical source/grants, install-runner entries, persistent structure/security/functional tests and synchronized documentation.
- Verified valid package specification/body, empty affected `USER_ERRORS`, exact signatures/grants, active-only index expressions, positive and cross-user behavior, exact missing/foreign/inactive non-disclosure, caller rollback, runtime direct-DML denial and zero residual fixtures.
- Ran focused Task 20 stale-context and Task 30 List/Tag filtered-view regressions; Task 50 was not started.

Evidence:

- `evidence/local/task40_list_tag_api_2026-09-27.md`

## Task 30 read isolation

Status: PASS (2026-09-27)

Completed:

- Added `V_TODO_LISTS`, `V_TODO_LIST_TAGS`, `V_TASKS` and `V_TASK_TREE` under `TASKHUB_API`, all explicitly `WITH READ ONLY`.
- Derived identity only from `TASKHUB_CTX.APP_USER_ID`; missing context returns zero rows.
- Filtered soft-deleted lists, tags and tasks and made list/tag associations fail closed on owner mismatch.
- Built the task hierarchy from the prefiltered task dataset and exposed only depth 0 through 3.
- Added numbered changes `0190` through `0210`, canonical view/grant source, persistent structure/security/functional tests and generated install-runner entries.
- Granted `TASKHUB_APP` only `SELECT` on the four views; direct owner-table reads and all view DML remain denied.
- Verified four valid views, empty affected `USER_ERRORS`, exact grants, no broad `ANY` privileges and passing Task 10/20 regressions.
- Verified Alice/Bob isolation, same-session Alice-to-Bob reinitialization, soft-delete behavior, cross-owner association defense, tree isolation/depth and missing-context behavior.
- Used the approved bounded cross-schema fixture exception: uniquely prefixed setup committed for API-session visibility, FK-safe cleanup committed, and final residual rows equaled zero. Application API transaction behavior was unchanged.

Approved Oracle grant exception:

- Oracle returned `ORA-01720` when `TASKHUB_API` attempted to delegate its views without grant option on their sources.
- The approved resolution grants object-specific `SELECT WITH GRANT OPTION` only on `TODO_LISTS`, `TAGS`, `TODO_LIST_TAGS` and `TASKS` to `TASKHUB_API`; it adds no DML, `ANY` privilege or application table access.

Evidence:

- `evidence/local/task30_read_isolation_2026-09-27.md`

## Documentation hardening

Status: PASS (2026-09-27)

Completed:

- Added a WHAT/WHY standard in `docs/database-documentation-standard.md` and linked it from `AGENTS.md`.
- Improved traditional comments for security-sensitive ownership, audit, identity and association columns.
- Added 126 Oracle Annotation usages across all five canonical tables: 30 table-level and 96 column-level.
- Documented all four current package specifications as public contracts, including trust, identity, privileges, transaction, errors and testability.
- Added only rationale comments to package bodies; executable statements and public signatures are unchanged.
- Added read-only annotation export `db/export/0010_annotations.sql` using the verified Oracle 26ai `USER_ANNOTATIONS_USAGE` shape.
- Applied changes `0170_document_owner_objects.sql` and `0180_document_api_packages.sql` through SQLcl MCP.
- Verified exact comments/annotations, eight valid package objects, empty `USER_ERRORS`, unchanged signature/grant manifests and passing context/create-list/security regression behavior.

Evidence:

- `evidence/local/documentation_hardening_2026-09-27.md`

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
