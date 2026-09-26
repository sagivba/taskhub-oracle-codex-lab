-- TaskHub POC manual DBA bootstrap
-- Purpose: create the application-context namespace.
-- Run manually as a DBA in the same PDB as TASKHUB_API.
-- Oracle allows the trusted package to be absent at CREATE CONTEXT time.
-- The package must exist when DBMS_SESSION.SET_CONTEXT is used at runtime.

create context taskhub_ctx
    using taskhub_api.pkg_taskhub_context_core;

prompt TASKHUB_CTX created.
