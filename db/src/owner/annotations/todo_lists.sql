alter table taskhub_owner.todo_lists annotations (
    add "DESCRIPTION" 'Canonical user-owned TaskHub task lists.',
    add "PURPOSE" 'Provides the ownership root for lists, their tasks and list/tag associations.',
    add "DOMAIN" 'Task organization.',
    add "OWNERSHIP" 'APP_USER_ID identifies the canonical application owner and is derived by TASKHUB_API from TASKHUB_CTX.',
    add "SECURITY_MODEL" 'TASKHUB_APP writes only through approved definer-rights API operations; direct table DML is denied to prevent ownership and audit spoofing.',
    add "LIFECYCLE" 'Lists are soft deleted with DELETED_AT and DELETED_BY_USER_ID; later maintenance may physically purge eligible rows.'
);

alter table taskhub_owner.todo_lists modify id annotations (
    add "DESCRIPTION" 'Stable surrogate identifier returned by list creation and referenced by child objects.',
    add "IDENTITY_SOURCE" 'Generated always by the database identity mechanism; never caller supplied on create.'
);

alter table taskhub_owner.todo_lists modify app_user_id annotations (
    add "DESCRIPTION" 'Canonical application user that owns the list.',
    add "IDENTITY_SOURCE" 'Resolved from APP_USERS after reading TASKHUB_CTX.APP_USER_ID and APP_USERNAME.',
    add "DERIVED_FROM_CONTEXT" 'TASKHUB_API sets this from validated TASKHUB_CTX identity; callers cannot supply or override ownership.',
    add "SECURITY_SENSITIVE" 'Caller-controlled ownership would allow cross-user data creation and is deliberately prohibited.'
);

alter table taskhub_owner.todo_lists modify list_name annotations (
    add "DESCRIPTION" 'Required user-visible name of the task list.',
    add "CALLER_CONTROL" 'Caller supplied and validated by the public API; it does not influence ownership.'
);

alter table taskhub_owner.todo_lists modify created_at annotations (
    add "DESCRIPTION" 'Timestamp when the list row was created.',
    add "AUDIT_FIELD" 'Database generated from SYSTIMESTAMP by the column default.'
);

alter table taskhub_owner.todo_lists modify created_by_user_id annotations (
    add "DESCRIPTION" 'Canonical application identity that created the list.',
    add "AUDIT_FIELD" 'Written by TASKHUB_API from the same validated context identity as APP_USER_ID.',
    add "DERIVED_FROM_CONTEXT" 'Never accepted from the caller, preventing creator-audit spoofing.'
);

alter table taskhub_owner.todo_lists modify updated_at annotations (
    add "DESCRIPTION" 'Timestamp of the most recent list update.',
    add "AUDIT_FIELD" 'Maintained by TASKHUB_API; NULL until an update occurs.'
);

alter table taskhub_owner.todo_lists modify updated_by_user_id annotations (
    add "DESCRIPTION" 'Canonical application identity that most recently updated the list.',
    add "AUDIT_FIELD" 'Maintained by TASKHUB_API when an update occurs.',
    add "DERIVED_FROM_CONTEXT" 'Resolved from validated TASKHUB_CTX identity, never caller supplied.'
);

alter table taskhub_owner.todo_lists modify deleted_at annotations (
    add "DESCRIPTION" 'Timestamp marking the list as soft deleted; NULL means active.',
    add "LIFECYCLE" 'Set by API delete behavior so reads can hide the row before retention-based physical purge.'
);

alter table taskhub_owner.todo_lists modify deleted_by_user_id annotations (
    add "DESCRIPTION" 'Canonical application identity that soft deleted the list.',
    add "AUDIT_FIELD" 'Maintained together with DELETED_AT.',
    add "DERIVED_FROM_CONTEXT" 'Resolved from validated TASKHUB_CTX identity, never caller supplied.'
);
