# Task 40 - List and Tag API

## Objective
Implement list and tag business operations in `TASKHUB_API.PKG_TASKHUB_API` using context-derived identity.

## Scope

Implement and test at least:

- create/update/delete list;
- add tag to list;
- remove tag from list;
- soft-delete tag;
- create missing tag for the current user when allowed by the specification;
- list/tag ownership validation;
- soft delete;
- generic not-found/unauthorized behavior.

## Security requirements

- no CRUD parameter accepts `APP_USER_ID`;
- no direct caller-controlled audit user IDs;
- cross-user list/tag association is rejected;
- `TASKHUB_APP` performs writes only through the API package;
- no `COMMIT` or `ROLLBACK` inside the package.

## Tests

Include positive CRUD tests and negative cross-user tests.

Verify that a soft-deleted tag does not block creation of a new active tag with the same normalized name.

## Success criteria

List and tag API behavior matches the specification and all targeted security tests pass.
