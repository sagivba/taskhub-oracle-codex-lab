# Task Order

The tasks are intentionally small. Give Codex one task file at a time.

| Order | Status | Task | Gate |
|---|---|---|---|
| 00 | COMPLETE | `tasks/00_manual_bootstrap.md` | Human-only environment ready |
| 10 | COMPLETE | `tasks/10_data_model.md` | Data model and structural tests pass |
| 20 | COMPLETE | `tasks/20_security_context.md` | Deterministic context tests pass |
| 30 | COMPLETE | `tasks/30_views.md` | Read isolation and read-only tests pass |
| 40 | COMPLETE | `tasks/40_list_tag_api.md` | List/Tag API and security tests pass |
| 50 | COMPLETE | `tasks/50_task_api.md` | Task hierarchy and lifecycle tests pass |
| 60 | COMPLETE | `tasks/60_maintenance.md` | Purge retention/FK tests pass |
| 70 | COMPLETE | `tasks/70_ords_apex_foundation.md` | ORDS/APEX platform, request identity, vertical slice, export and manual browser gate pass |
| 80 | NOT STARTED | `tasks/80_security_regression.md` | Full security/regression suite passes |
| 90 | NOT STARTED | `tasks/90_clean_rebuild.md` | Rebuild from Git passes from clean bootstrap |
| 100 | NOT STARTED | `tasks/100_manual_deploy_package.md` | Human-reviewable QA package is complete |

Do not skip a gate merely because later code appears to work.
