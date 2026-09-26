# Task 90 - Manual QA Deployment Package

## Objective
Produce a human-reviewable SQLcl deployment package for an environment outside the Codex lab.

## Boundary

Codex creates files only. Codex does not connect to or deploy to QA.

## Required outputs

- clean-install runner where appropriate;
- ordered upgrade scripts where appropriate;
- required grants;
- validation scripts;
- rollback/recovery notes for operations that are not transactionally reversible;
- deployment README with prerequisites and expected evidence.

## Rules

- no DEV-only test package in production-like deployment unless explicitly approved;
- no credentials or connection strings in the package;
- no reliance on MCP-specific behavior;
- SQLcl `@`/`@@` runner path must be manually reviewable.

## Success criteria

A DBA can understand the order, prerequisites, validation and failure handling without asking Codex to reconstruct hidden context.
