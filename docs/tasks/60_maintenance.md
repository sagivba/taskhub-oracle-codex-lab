# Task 60 - Maintenance and Purge

## Objective
Implement retention-aware physical purge and the monthly scheduler job.

## Required objects

```text
TASKHUB_API.PKG_TASKHUB_MAINT
TASKHUB_API.JOB_TASKHUB_PURGE_MONTHLY
```

## Purge rules

Physical deletion is allowed only when the row has passed the 30-day retention rule defined in the specification.

Purge order must preserve FK and self-FK integrity.

## Tests

- rows newer than retention are preserved;
- eligible association rows are removed before parents;
- task descendants/parents are removed safely;
- list purge does not leave invalid references;
- tag purge does not leave invalid associations;
- repeated purge is safe for the same final state.

## Success criteria

Purge tests pass and the scheduler definition is reproducible from source.
