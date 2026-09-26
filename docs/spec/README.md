# Specification Files

Canonical specification:

```text
TaskHub_POC_Specification_HE_v3.md
TaskHub_POC_Specification_HE_v3.html
```

The original supplied v2 document is preserved as:

```text
TaskHub_POC_Specification_HE_v2_original.md
```

Key v3 corrections include:

- three-schema security separation;
- code and filtered views moved to `TASKHUB_API`;
- trusted context core plus separate runtime/test facades;
- deterministic context initialization for every identity-sensitive test;
- consistent TAGS audit columns and explicit tag-delete semantics;
- active-only tag uniqueness under soft delete;
- explicit purge ordering;
- data dictionary comments as a Definition of Done requirement;
- numbered SQL in increments of 10;
- Git-first execution contract and clean-rebuild milestone gate;
- manual infrastructure/bootstrap boundary outside Codex.
