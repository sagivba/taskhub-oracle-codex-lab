# ADR-002 - Git and numbered SQL are the source of truth

## Status
Accepted

## Decision
Every state-changing DDL or material DML statement is written to a numbered file under `db/changes/` before execution.

Canonical end-state source is kept under `db/src/`.

Numbering uses four digits in increments of 10.

## Rationale
The same accepted database state must be reproducible without depending on Codex conversation history or accumulated lab state.

## Consequence
A database-only change is a process defect. Human manual replay and Codex MCP execution both originate from repository files.
