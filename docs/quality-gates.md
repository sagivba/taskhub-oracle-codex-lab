# Quality Gates

## Task gate

A task passes only when its own success criteria and targeted tests pass.

## Phase gate

At the end of a phase, run all tests relevant to that phase plus previously completed regression checks that could be affected.

## Milestone gate

A milestone requires a clean rebuild after manual bootstrap and the full test suite.

## Security gate

At minimum verify:

- no direct table privileges for `TASKHUB_APP`;
- no execute privilege from `TASKHUB_APP` to core/test/maintenance packages;
- cross-user reads/writes fail as specified;
- missing context fails closed;
- stale context cannot leak across tests;
- grants match the approved manifest.

## Database object gate

Verify:

- expected objects exist;
- no unexpected invalid objects exist;
- changed PL/SQL has no `USER_ERRORS`;
- constraints are enabled;
- required indexes are valid;
- comments are present;
- no database-only object is required for rebuild.
