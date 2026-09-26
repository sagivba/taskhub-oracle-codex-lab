# Contributing

This repository is a controlled Oracle POC and uses the same small-change discipline as the user's AI-friendly template repositories.

Before changing database implementation files, read `AGENTS.md` and the active task in `docs/tasks/`.

Key contribution rules:

- one logical task at a time;
- source files before database execution;
- every state-changing SQL action recorded under `db/changes/`;
- tests updated with behavior changes;
- architecture and security boundaries are not changed implicitly;
- no credentials, wallets, saved connection stores or environment secrets in Git;
- milestone completion requires the clean-rebuild gate.
