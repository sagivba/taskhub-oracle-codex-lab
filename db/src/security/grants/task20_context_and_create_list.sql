-- TASKHUB_API needs only direct object grants used by definer-rights code; roles do
-- not satisfy stored-code compilation and broader DML would exceed current behavior.
grant select on taskhub_owner.app_users to taskhub_api;
grant select, insert on taskhub_owner.todo_lists to taskhub_api;

-- TASKHUB_APP receives approved executable interfaces instead of owner-table DML so
-- it cannot bypass context-derived ownership, audit values or business validation.
grant execute on taskhub_api.pkg_taskhub_context to taskhub_app;
grant execute on taskhub_api.pkg_taskhub_api to taskhub_app;

-- Deliberately absent: EXECUTE on PKG_TASKHUB_CONTEXT_CORE and
-- PKG_TASKHUB_TEST_CONTEXT. Either grant would expose identity-setting capability.
