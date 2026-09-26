# Task Order

The tasks are intentionally small. Give Codex one task file at a time.

| Order | Task | Gate |
|---|---|---|
| 00 | `tasks/00_manual_bootstrap.md` | Human-only environment ready |
| 10 | `tasks/10_data_model.md` | Data model and structural tests pass |
| 20 | `tasks/20_security_context.md` | Deterministic context tests pass |
| 30 | `tasks/30_views.md` | Read isolation and read-only tests pass |
| 40 | `tasks/40_list_tag_api.md` | List/Tag API and security tests pass |
| 50 | `tasks/50_task_api.md` | Task hierarchy and lifecycle tests pass |
| 60 | `tasks/60_maintenance.md` | Purge retention/FK tests pass |
| 70 | `tasks/70_security_regression.md` | Full security/regression suite passes |
| 80 | `tasks/80_clean_rebuild.md` | Rebuild from Git passes from clean bootstrap |
| 90 | `tasks/90_manual_deploy_package.md` | Human-reviewable QA package is complete |

Do not skip a gate merely because later code appears to work.
