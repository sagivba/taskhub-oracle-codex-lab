# ADR-006 - Separate runtime and test context interfaces

## Status
Accepted

## Decision
Use three context-related packages in `TASKHUB_API`:

```text
PKG_TASKHUB_CONTEXT_CORE
PKG_TASKHUB_CONTEXT
PKG_TASKHUB_TEST_CONTEXT
```

The core package is the trusted package associated with `TASKHUB_CTX` and is not granted to `TASKHUB_APP`.

The runtime facade is granted to `TASKHUB_APP`.

The DEV-only test facade exposes `init_for_test(p_username)` and is not granted to `TASKHUB_APP`.

## Rationale
Oracle grants `EXECUTE` at the package object level. Putting a test-only initializer in the same package granted to the application would expose that test entry point to the application schema.

## Consequence
The deployment package must distinguish DEV-only context test code from production-like runtime interfaces.
