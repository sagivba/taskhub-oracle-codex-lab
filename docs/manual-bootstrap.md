# Manual Lab Bootstrap

## Boundary

The first Oracle environment bootstrap is intentionally manual and outside Codex.

Do not ask Codex to build the initial Docker container or create the database users.

## Step 1 - Environment check

Run from WSL:

```bash
scripts/check_environment.sh
```

Review the output before deciding Docker image, paths or SQLcl configuration.

The script is read-only. It does not open saved database connection contents.

## Step 2 - Create a clean Oracle container

The exact Docker command is intentionally not hard-coded in this starter repository.

Choose it only after confirming the installed Docker version, the desired Oracle 26ai image and the service/PDB naming in the actual environment.

Record the final values in:

```text
docs/status/CURRENT_STATUS.md
```

## Step 3 - Create database users and context namespace

Connect manually to the target PDB with a DBA account and run:

```text
db/admin/0010_create_lab_users.sql
db/admin/0020_create_application_context.sql
db/admin/0030_verify_lab_bootstrap.sql
```

The application context can be created before its trusted package exists. The trusted package must exist when context attributes are set at runtime.

Do not grant `CREATE ANY CONTEXT` to the application schemas merely to automate this step.

## Step 4 - Configure dedicated SQLcl saved connections

Create saved connections only for this lab and record their names in `docs/status/CURRENT_STATUS.md`.

Expected logical connections:

```text
TASKHUB_OWNER
TASKHUB_API
TASKHUB_APP
```

The actual saved connection names may differ, but they must be documented before Codex starts.

Do not expose unrelated DEV/TEST/PROD connections to the lab workflow.

## Step 5 - Configure SQLcl MCP

Start with Restrict Level `R4`.

Do not lower the level merely because a script contains SQLcl client commands such as `@`, `@@`, `SET`, `PROMPT`, `SPOOL` or `ACCEPT`.

Codex should execute database SQL through `run-sql`. Manual deployment runners can use normal SQLcl script commands outside MCP.

## Step 6 - Update current status

Before starting Task 10, fill in:

- WSL version
- Codex version/path
- SQLcl version/path
- Java version/path
- Docker version
- Oracle version/service/PDB
- saved lab connection names

Then mark Task 00 DONE.
