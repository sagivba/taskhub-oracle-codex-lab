-- Task: 20 Security Context and API Layer
-- Target schema: TASKHUB_API
-- Purpose: Expose only the approved runtime context facade to TASKHUB_APP.
-- Preconditions: 0110 has been applied; execute as TASKHUB_API.
-- Verification: db/tests/security/0010_task20_grant_manifest.sql and 0030_app_context_package_denial.sql
-- Notes: Core and DEV-only test context packages remain ungranted.

grant execute on taskhub_api.pkg_taskhub_context to taskhub_app;
