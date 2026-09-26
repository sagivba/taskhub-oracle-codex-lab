# Codex Workflow

## Objective

Use Codex for bounded Oracle development work while keeping infrastructure/bootstrap troubleshooting outside its development context.

## R4 execution loop

The lab starts at SQLcl MCP Restrict Level `R4`.

Codex does not use `@script.sql` through MCP. Instead:

1. Read the active task and required specification sections.
2. Edit canonical source under `db/src/`.
3. Create a numbered SQL file under `db/changes/` before any state change.
4. Read that file and send its SQL/PLSQL through MCP `run-sql`.
5. Run targeted verification queries/tests.
6. Fix source and add a new numbered change if the accepted database state changes again.
7. Update status/evidence when the task gate passes.

## Manual replay path

Humans are not dependent on Codex for rebuild or QA deployment.

Accepted changes are replayable in order through:

```text
db/deploy/install/run_all.sql
```

This runner is generated from `db/changes/` by:

```bash
scripts/generate_run_all.sh
```

The runner uses SQLcl `@@` paths and is for manual SQLcl execution, not MCP R4 execution.

## Token discipline

Do not ask Codex to rediscover the project on every task.

The repository provides:

- current state;
- task-specific scope;
- approved architecture decisions;
- expected tests;
- exact database source files;
- change history.

Return concise evidence and avoid large dictionary dumps unless diagnosing a failure.
