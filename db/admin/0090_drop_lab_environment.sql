-- DESTRUCTIVE MANUAL DBA SCRIPT
-- Purpose: remove the TaskHub lab security namespace and database users.
-- Review the target PDB before running.
-- The context is dropped explicitly because application contexts are stored in SYS
-- and can survive dropping the schema associated with their trusted package.

prompt *** DESTRUCTIVE RESET OF TASKHUB LAB ***

-- If TASKHUB_CTX does not exist, Oracle may report an error and SQLcl will continue
-- unless the caller has configured WHENEVER SQLERROR EXIT.
drop context taskhub_ctx;

drop user taskhub_app cascade;
drop user taskhub_api cascade;
drop user taskhub_owner cascade;

prompt TaskHub lab users/context drop commands completed.
prompt Re-run 0010, 0020 and 0030 for a clean bootstrap.
