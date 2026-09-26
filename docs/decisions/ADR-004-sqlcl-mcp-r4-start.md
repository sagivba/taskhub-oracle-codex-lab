# ADR-004 - Start SQLcl MCP at Restrict Level R4

## Status
Accepted

## Decision
Start the lab with SQLcl MCP Restrict Level `R4`.

Codex sends SQL/PLSQL content through `run-sql` and does not depend on SQLcl `@`/`@@` execution through MCP.

## Rationale
The initial POC needs database SQL/PLSQL execution, not a broader SQLcl command surface.

## Consequence
Manual SQLcl deployment runners can use `@`/`@@` outside MCP. A move to a less restrictive level requires an explicit decision and documented need.
