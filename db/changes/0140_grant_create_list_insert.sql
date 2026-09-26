-- Task: 20 Security Context and API Layer - Create TODO List slice
-- Target schema: TASKHUB_OWNER
-- Purpose: Grant the API code owner the table access required by CREATE_LIST and INSERT RETURNING.
-- Preconditions: db/changes/0040_create_todo_lists.sql has been applied; execute as TASKHUB_OWNER.
-- Verification: db/tests/security/0010_task20_grant_manifest.sql
-- Notes: No privilege is granted to TASKHUB_APP and no grant option is used.

grant select, insert on taskhub_owner.todo_lists to taskhub_api;
