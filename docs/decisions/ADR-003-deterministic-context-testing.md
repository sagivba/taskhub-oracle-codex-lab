# ADR-003 - Deterministic application-context testing

## Status
Accepted

## Decision
Every identity-sensitive test explicitly clears and initializes `TASKHUB_CTX` in the same flow.

Use a DEV-only test facade for `init_for_test(p_username)` and do not grant it to `TASKHUB_APP`.

## Rationale
Database sessions can be reused. Tests that depend on prior session context can pass incorrectly and create cross-user leakage risk.

## Consequence
Stale-context prevention is an explicit negative test and a release gate.
