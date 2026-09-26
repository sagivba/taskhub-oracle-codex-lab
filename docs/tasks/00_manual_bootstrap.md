# Task 00 - Manual Lab Bootstrap

## Owner
Human operator. This task is outside Codex implementation scope.

## Objective
Create and document a clean Oracle lab that Codex can safely use later.

## Required actions

1. Run `scripts/check_environment.sh` in WSL.
2. Review versions and actual paths.
3. Review `~/.dbtools` metadata without reading credential contents.
4. Create a clean Oracle container manually.
5. Create `TASKHUB_OWNER`, `TASKHUB_API`, `TASKHUB_APP` using `db/admin/0010_create_lab_users.sql`.
6. Create `TASKHUB_CTX` using `db/admin/0020_create_application_context.sql`.
7. Verify the bootstrap with `db/admin/0030_verify_lab_bootstrap.sql`.
8. Create dedicated SQLcl saved connections for the three schemas.
9. Configure SQLcl MCP with Restrict Level `R4`.
10. Record all verified environment facts and saved connection names in `docs/status/CURRENT_STATUS.md`.

## Success criteria

- Clean Oracle lab is reachable from WSL.
- Three schemas exist with only approved system privileges.
- `TASKHUB_CTX` exists and is associated with `TASKHUB_API.PKG_TASKHUB_CONTEXT_CORE`.
- No unrelated saved connection is approved for Codex use.
- R4 is the documented MCP level.
- Current status contains real versions, paths and connection names.

## Stop condition

Stop before Task 10 if any environment fact is unknown or a saved connection could expose an unrelated database.
