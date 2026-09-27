# Canonical Database Source

`db/src/` describes the intended end state of TaskHub database objects.

`db/changes/` records how DEV reached that state.

Both must be kept aligned.

- `owner/`: TaskHub data-owner source, including concise comments and structured Oracle Annotations.
- `api/`: code, views and job source.
- `security/`: explicit grant definitions and security manifests.

Public package contracts and database-resident documentation follow
`docs/database-documentation-standard.md`. Read-only documentation export scripts live
under `db/export/`.
