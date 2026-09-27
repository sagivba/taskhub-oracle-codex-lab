# Task 90 - Clean Rebuild Gate

Status: NOT STARTED

## Objective
Prove that repository source, not accumulated database state, is sufficient to recreate the POC after manual bootstrap.

## Human prerequisite

The human performs the approved reset/bootstrap of the container/users/context namespace.

Codex must not create/drop users or context namespace.

## Codex rebuild

- reconstruct application objects from accepted source/change files;
- use only approved lab connections;
- do not repair the database with unrecorded ad hoc DDL/DML;
- regenerate manual install runner if needed;
- run the entire test suite.

## Required evidence

- object manifest;
- invalid-object result;
- grant manifest;
- full test PASS summary;
- list of executed numbered change files;
- confirmation that no database-only source was required.

## Success criteria

The clean rebuilt database passes the same validation as the pre-reset milestone state.

Only then mark the milestone DONE.
