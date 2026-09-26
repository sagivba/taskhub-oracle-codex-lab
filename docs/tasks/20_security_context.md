# Task 20 - Application Context and Deterministic Test Identity

## Objective
Implement secure application identity handling without depending on APEX during DEV tests.

## Required objects

```text
TASKHUB_API.PKG_TASKHUB_CONTEXT_CORE
TASKHUB_API.PKG_TASKHUB_CONTEXT
TASKHUB_API.PKG_TASKHUB_TEST_CONTEXT
```

## Security design

- `TASKHUB_CTX` is already created manually by the DBA bootstrap.
- The trusted package associated with the context is `PKG_TASKHUB_CONTEXT_CORE`.
- `PKG_TASKHUB_CONTEXT` is the runtime APEX facade.
- `PKG_TASKHUB_TEST_CONTEXT` is DEV-only and must not be granted to `TASKHUB_APP`.

## Required behavior

`init_from_apex` and `init_for_test` must clear prior context first.

On valid active user, set:

```text
APP_USER_ID
APP_USERNAME
```

On invalid or inactive user:

- fail;
- leave context empty.

## Tests

Create deterministic tests for:

- valid user;
- inactive user;
- unknown username;
- explicit clear;
- re-initialize user A then user B in same session;
- failed initialization after a valid context leaves no stale user;
- `TASKHUB_APP` cannot execute core/test package.

## Success criteria

Every context-dependent test initializes identity explicitly and passes when repeated in different orders.

## Stop condition

Do not create user-filtered views until stale-session tests pass.
