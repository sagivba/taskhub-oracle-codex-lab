# Task 70 - Security and Regression Suite

## Objective
Run the POC as an adversarial security/regression exercise, not only a happy-path functional test.

## Required security tests

- direct table SELECT from `TASKHUB_APP` denied;
- direct table DML from `TASKHUB_APP` denied;
- test-context/core/maintenance package execution from `TASKHUB_APP` denied;
- approved API/runtime-context execution succeeds;
- approved view reads succeed;
- missing context fails closed;
- stale context is cleared between identities;
- cross-user read/update/delete denied;
- cross-user list/tag association denied;
- invalid ID and unauthorized ID do not disclose a useful difference.

## Structural regression

Re-run object, constraint, index, comment, grant and invalid-object checks.

## Success criteria

All approved acceptance criteria relevant before rebuild pass in one repeatable suite.
