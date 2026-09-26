# Current Status

## Project state

Status: MANUAL BOOTSTRAP PARTIAL

The TaskHub Oracle lab infrastructure is running and the three database schemas have been created and validated.

No TaskHub application objects have been implemented yet.

## Current task

docs/tasks/00_manual_bootstrap.md

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

TASKHUB_OWNER connection : NOT CONFIGURED
TASKHUB_API connection   : NOT CONFIGURED
TASKHUB_APP connection   : NOT CONFIGURED

## Open items

1. Create TASKHUB_CTX in the later approved bootstrap step.
2. Create dedicated SQLcl saved connections.
3. Configure SQLcl MCP with Restrict Level R4.
4. Complete remaining Task 00 validation.
5. Only then start Task 10.

## Evidence

Environment-specific bootstrap evidence is stored under:

evidence/local/

Do not store credentials in evidence.

## Exact next step

Stop the current infrastructure and schema bootstrap phase here.

Do not start TaskHub tables, PL/SQL, Application Context, MCP or Codex development yet.

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
