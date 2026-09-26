-- Task: 20 Security Context and API Layer
-- Target schema: TASKHUB_OWNER
-- Purpose: Create deterministic DEV application identities for context and security tests.
-- Preconditions: db/changes/0030_create_app_users.sql has been applied; execute once as TASKHUB_OWNER.
-- Verification: db/tests/context/0010_valid_active_user.sql through 0060_failed_reinitialization.sql
-- Notes: These are application identities, not Oracle users; no credentials are stored.

insert into taskhub_owner.app_users (username, display_name, email, is_active)
values ('TASKHUB_TEST_ALICE', 'TaskHub Test Alice', 'taskhub-test-alice@example.invalid', 'Y');

insert into taskhub_owner.app_users (username, display_name, email, is_active)
values ('TASKHUB_TEST_BOB', 'TaskHub Test Bob', 'taskhub-test-bob@example.invalid', 'Y');

insert into taskhub_owner.app_users (username, display_name, email, is_active)
values ('TASKHUB_TEST_INACTIVE', 'TaskHub Test Inactive', 'taskhub-test-inactive@example.invalid', 'N');

commit;
