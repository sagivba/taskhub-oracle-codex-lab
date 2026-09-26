-- Task: 20 Security Context and API Layer
-- Target schema: TASKHUB_OWNER
-- Purpose: Grant the API code owner direct read access required to resolve application identities.
-- Preconditions: db/changes/0030_create_app_users.sql has been applied; execute as TASKHUB_OWNER.
-- Verification: db/tests/security/0010_task20_grant_manifest.sql
-- Notes: No privilege is granted to TASKHUB_APP and no grant option is used.

grant select on taskhub_owner.app_users to taskhub_api;
