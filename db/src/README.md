# Canonical Database Source

`db/src/` describes the intended end state of TaskHub database objects.

`db/changes/` records how DEV reached that state.

Both must be kept aligned.

- `owner/`: TaskHub data-owner source.
- `api/`: code, views and job source.
- `security/`: explicit grant definitions and security manifests.
