# ADR-005 - Manual infrastructure bootstrap

## Status
Accepted

## Decision
The initial Oracle container, database users, application context namespace and MCP connection setup are created manually by the human operator.

## Rationale
These are privileged, one-time environment tasks. Keeping them outside Codex preserves agent context for database development and avoids giving the agent unnecessary administrative authority.

## Consequence
The clean-rebuild boundary starts after the documented manual bootstrap.
