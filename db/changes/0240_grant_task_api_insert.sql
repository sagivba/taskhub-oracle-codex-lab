-- Task: 50 Task and Subtask API
-- Target schema: TASKHUB_OWNER
-- Purpose: Grant the sole missing direct privilege needed by CREATE_TASK.
-- Preconditions: Task 40 grants are present; execute as TASKHUB_OWNER.
-- Verification: db/tests/security/0070_task30_grant_manifest.sql
-- Notes: UPDATE already exists; no DELETE or TASKHUB_APP table privilege is granted.

grant insert on taskhub_owner.tasks to taskhub_api;
