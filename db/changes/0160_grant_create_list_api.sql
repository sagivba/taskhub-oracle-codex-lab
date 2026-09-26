-- Task: 20 Security Context and API Layer - Create TODO List slice
-- Target schema: TASKHUB_API
-- Purpose: Expose the approved create-list API package to TASKHUB_APP.
-- Preconditions: 0150 has been applied successfully; execute as TASKHUB_API.
-- Verification: db/tests/security/0010_task20_grant_manifest.sql and 0040_unset_context_rejected.sql
-- Notes: No owner-table privilege is granted to TASKHUB_APP.

grant execute on taskhub_api.pkg_taskhub_api to taskhub_app;
