-- Task: Documentation hardening
-- Target schema: TASKHUB_OWNER
-- Purpose: Improve canonical comments and add structured Oracle Annotations for all five business tables.
-- Preconditions: Task 10 tables and Task 20 security boundary are deployed; execute as TASKHUB_OWNER on Oracle 26ai.
-- Verification: db/tests/structure/0350_owner_annotations.sql and db/export/0010_annotations.sql
-- Notes: Documentation-only DDL; no table structure, data, behavior or privilege changes.

comment on table taskhub_owner.app_users is
    'Canonical TaskHub application identities; these rows are not Oracle database users or login credentials.';

comment on column taskhub_owner.app_users.id is
    'Surrogate primary key for an application identity.';

comment on column taskhub_owner.app_users.username is
    'Unique case-sensitive application username resolved by TASKHUB_API during trusted context initialization.';

comment on column taskhub_owner.app_users.display_name is
    'Optional display name for the application user.';

comment on column taskhub_owner.app_users.email is
    'Optional contact email; it is not an authentication credential or identity source.';

comment on column taskhub_owner.app_users.is_active is
    'Application identity status: Y permits trusted context initialization; N rejects it while preserving history.';

comment on column taskhub_owner.app_users.created_at is
    'Database timestamp when the application identity row was created.';

comment on column taskhub_owner.app_users.updated_at is
    'Database timestamp of the most recent update; NULL until the row is updated.';

comment on table taskhub_owner.todo_lists is
    'Canonical task lists owned by TaskHub application users and written only through approved API operations.';

comment on column taskhub_owner.todo_lists.id is
    'Surrogate primary key for a task list.';

comment on column taskhub_owner.todo_lists.app_user_id is
    'Canonical owner derived by TASKHUB_API from TASKHUB_CTX; callers must not supply or override it.';

comment on column taskhub_owner.todo_lists.list_name is
    'Required user-visible task-list name supplied by the caller.';

comment on column taskhub_owner.todo_lists.created_at is
    'Database timestamp when the task list was created.';

comment on column taskhub_owner.todo_lists.created_by_user_id is
    'Creator identity derived by TASKHUB_API from TASKHUB_CTX, never accepted from the caller.';

comment on column taskhub_owner.todo_lists.updated_at is
    'Database timestamp of the most recent update; NULL until the task list is updated.';

comment on column taskhub_owner.todo_lists.updated_by_user_id is
    'Most recent updater derived from TASKHUB_CTX; NULL until the task list is updated.';

comment on column taskhub_owner.todo_lists.deleted_at is
    'Soft-delete timestamp; NULL while the task list is active.';

comment on column taskhub_owner.todo_lists.deleted_by_user_id is
    'Soft-delete actor derived from TASKHUB_CTX; NULL while the task list is active.';

comment on table taskhub_owner.tags is
    'Canonical reusable tags scoped to one TaskHub application user and managed through the API boundary.';

comment on column taskhub_owner.tags.id is
    'Surrogate primary key for a tag.';

comment on column taskhub_owner.tags.app_user_id is
    'Canonical owner derived by TASKHUB_API from TASKHUB_CTX; callers must not supply or override it.';

comment on column taskhub_owner.tags.tag_name is
    'Caller-visible tag name; active names are unique per owner after trim and case normalization.';

comment on column taskhub_owner.tags.created_at is
    'Database timestamp when the tag was created.';

comment on column taskhub_owner.tags.created_by_user_id is
    'Creator identity derived by TASKHUB_API from TASKHUB_CTX, never accepted from the caller.';

comment on column taskhub_owner.tags.updated_at is
    'Database timestamp of the most recent update; NULL until the tag is updated.';

comment on column taskhub_owner.tags.updated_by_user_id is
    'Most recent updater derived from TASKHUB_CTX; NULL until the tag is updated.';

comment on column taskhub_owner.tags.deleted_at is
    'Soft-delete timestamp; NULL while the tag is active.';

comment on column taskhub_owner.tags.deleted_by_user_id is
    'Soft-delete actor derived from TASKHUB_CTX; NULL while the tag is active.';

comment on table taskhub_owner.todo_list_tags is
    'Canonical list/tag associations; API authorization requires both referenced objects to share the context owner.';

comment on column taskhub_owner.todo_list_tags.id is
    'Surrogate primary key for a list/tag association.';

comment on column taskhub_owner.todo_list_tags.todo_list_id is
    'Associated task list; TASKHUB_API must validate that it belongs to the current context user.';

comment on column taskhub_owner.todo_list_tags.tag_id is
    'Associated tag; TASKHUB_API must validate the same owner as the list and current context.';

comment on column taskhub_owner.todo_list_tags.created_at is
    'Database timestamp when the list/tag association was created.';

comment on table taskhub_owner.tasks is
    'Canonical tasks and subtasks whose ownership is inherited from their containing TaskHub list.';

comment on column taskhub_owner.tasks.id is
    'Surrogate primary key for a task or subtask.';

comment on column taskhub_owner.tasks.todo_list_id is
    'Containing list and source of task ownership; TASKHUB_API must authorize it against TASKHUB_CTX.';

comment on column taskhub_owner.tasks.parent_task_id is
    'Parent task in the same list; NULL for a top-level task and never valid across list boundaries.';

comment on column taskhub_owner.tasks.title is
    'Task title.';

comment on column taskhub_owner.tasks.description is
    'Optional task description.';

comment on column taskhub_owner.tasks.status is
    'Lifecycle status: OPEN, IN_PROGRESS, DONE or CANCELED.';

comment on column taskhub_owner.tasks.priority is
    'Numeric priority: 1 high, 2 medium, 3 low.';

comment on column taskhub_owner.tasks.due_at is
    'Optional due timestamp.';

comment on column taskhub_owner.tasks.completed_at is
    'Completion timestamp; populated while status is DONE and otherwise NULL.';

comment on column taskhub_owner.tasks.created_at is
    'Database timestamp when the task was created.';

comment on column taskhub_owner.tasks.created_by_user_id is
    'Creator identity derived by TASKHUB_API from TASKHUB_CTX, never accepted from the caller.';

comment on column taskhub_owner.tasks.updated_at is
    'Database timestamp of the most recent update; NULL until the task is updated.';

comment on column taskhub_owner.tasks.updated_by_user_id is
    'Most recent updater derived from TASKHUB_CTX; NULL until the task is updated.';

comment on column taskhub_owner.tasks.deleted_at is
    'Soft-delete timestamp; NULL while the task is active.';

comment on column taskhub_owner.tasks.deleted_by_user_id is
    'Soft-delete actor derived from TASKHUB_CTX; NULL while the task is active.';

alter table taskhub_owner.app_users annotations (
    add "DESCRIPTION" 'Canonical TaskHub application identities; not Oracle accounts or authentication credentials.',
    add "PURPOSE" 'Maps an external application username to the stable surrogate identity used by context, ownership and audit columns.',
    add "DOMAIN" 'Application identity and authorization.',
    add "OWNERSHIP" 'TASKHUB_OWNER is the canonical data owner; ordinary runtime CRUD does not manage these rows.',
    add "SECURITY_MODEL" 'TASKHUB_API may resolve active identities. TASKHUB_APP has no direct table access so it cannot invent or alter canonical user IDs.',
    add "LIFECYCLE" 'Rows are retained for referential and audit history; access is disabled with IS_ACTIVE=N rather than soft deletion.'
);

alter table taskhub_owner.app_users modify id annotations (
    add "DESCRIPTION" 'Stable surrogate identifier referenced by ownership and audit foreign keys.',
    add "IDENTITY_SOURCE" 'Generated always by the database identity mechanism; never caller supplied.'
);

alter table taskhub_owner.app_users modify username annotations (
    add "DESCRIPTION" 'Case-sensitive application username resolved during trusted context initialization.',
    add "BUSINESS_KEY" 'Unique canonical lookup key for application identity.',
    add "IDENTITY_SOURCE" 'Production receives APEX$SESSION.APP_USER; DEV tests pass a username only through the isolated test facade.',
    add "SECURITY_SENSITIVE" 'A username is accepted only by trusted context facades and must resolve to one active canonical row.'
);

alter table taskhub_owner.app_users modify is_active annotations (
    add "DESCRIPTION" 'Controls whether this canonical identity may initialize TASKHUB_CTX.',
    add "SECURITY_SENSITIVE" 'N causes initialization to fail closed and clear prior session identity, preventing disabled users from retaining access.'
);

alter table taskhub_owner.app_users modify created_at annotations (
    add "DESCRIPTION" 'Timestamp when the canonical identity row was created.',
    add "AUDIT_FIELD" 'Database generated from SYSTIMESTAMP by the column default.'
);

alter table taskhub_owner.app_users modify updated_at annotations (
    add "DESCRIPTION" 'Timestamp of the most recent administrative identity update.',
    add "AUDIT_FIELD" 'Managed by the identity-administration path; NULL until an update occurs.'
);

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

alter table taskhub_owner.tags annotations (
    add "DESCRIPTION" 'Canonical reusable tags scoped to one TaskHub application user.',
    add "PURPOSE" 'Classifies lists without allowing tags or associations to cross application-user ownership boundaries.',
    add "DOMAIN" 'Task-list classification.',
    add "OWNERSHIP" 'APP_USER_ID identifies the canonical owner and is derived by TASKHUB_API from TASKHUB_CTX.',
    add "SECURITY_MODEL" 'Direct runtime DML is denied; API ownership checks prevent attaching one user''s tag to another user''s list.',
    add "LIFECYCLE" 'Tags are soft deleted. Active-only normalized uniqueness permits reuse of a name after deletion.'
);

alter table taskhub_owner.tags modify id annotations (
    add "DESCRIPTION" 'Stable surrogate identifier for a tag.',
    add "IDENTITY_SOURCE" 'Generated always by the database identity mechanism.'
);

alter table taskhub_owner.tags modify app_user_id annotations (
    add "DESCRIPTION" 'Canonical application user that owns the tag.',
    add "IDENTITY_SOURCE" 'Resolved from APP_USERS after trusted context validation.',
    add "DERIVED_FROM_CONTEXT" 'TASKHUB_API sets ownership from TASKHUB_CTX; callers must not provide it.',
    add "SECURITY_SENSITIVE" 'Prevents cross-user tag ownership spoofing and association leakage.'
);

alter table taskhub_owner.tags modify tag_name annotations (
    add "DESCRIPTION" 'Caller-visible tag label normalized for active uniqueness within one owner.',
    add "BUSINESS_KEY" 'Together with APP_USER_ID, its trimmed case-normalized value is unique for active tags.'
);

alter table taskhub_owner.tags modify created_at annotations (
    add "DESCRIPTION" 'Timestamp when the tag was created.',
    add "AUDIT_FIELD" 'Database generated from SYSTIMESTAMP by the column default.'
);

alter table taskhub_owner.tags modify created_by_user_id annotations (
    add "DESCRIPTION" 'Canonical application identity that created the tag.',
    add "AUDIT_FIELD" 'Written by TASKHUB_API from validated context identity.',
    add "DERIVED_FROM_CONTEXT" 'Never accepted from the caller.'
);

alter table taskhub_owner.tags modify updated_at annotations (
    add "DESCRIPTION" 'Timestamp of the most recent tag update.',
    add "AUDIT_FIELD" 'Maintained by TASKHUB_API; NULL until an update occurs.'
);

alter table taskhub_owner.tags modify updated_by_user_id annotations (
    add "DESCRIPTION" 'Canonical application identity that most recently updated the tag.',
    add "AUDIT_FIELD" 'Maintained by TASKHUB_API on update.',
    add "DERIVED_FROM_CONTEXT" 'Resolved from validated TASKHUB_CTX identity.'
);

alter table taskhub_owner.tags modify deleted_at annotations (
    add "DESCRIPTION" 'Timestamp marking the tag as soft deleted; NULL means active.',
    add "LIFECYCLE" 'Makes the tag invisible to active reads and releases its active-only normalized name.'
);

alter table taskhub_owner.tags modify deleted_by_user_id annotations (
    add "DESCRIPTION" 'Canonical application identity that soft deleted the tag.',
    add "AUDIT_FIELD" 'Maintained together with DELETED_AT.',
    add "DERIVED_FROM_CONTEXT" 'Resolved from validated TASKHUB_CTX identity.'
);

alter table taskhub_owner.todo_list_tags annotations (
    add "DESCRIPTION" 'Canonical many-to-many associations between task lists and tags.',
    add "PURPOSE" 'Attaches reusable tags to lists while preserving a unique pair for each association.',
    add "DOMAIN" 'Task-list classification association.',
    add "OWNERSHIP" 'Ownership is inherited from the referenced list and tag; TASKHUB_API requires both to belong to the same context user.',
    add "SECURITY_MODEL" 'The runtime principal has no direct DML. API validation prevents cross-user list/tag associations.',
    add "LIFECYCLE" 'Association rows are physically removed when detached; the referenced list and tag retain their own soft-delete lifecycle.'
);

alter table taskhub_owner.todo_list_tags modify id annotations (
    add "DESCRIPTION" 'Surrogate identifier for one list/tag association.',
    add "IDENTITY_SOURCE" 'Generated always by the database identity mechanism.'
);

alter table taskhub_owner.todo_list_tags modify todo_list_id annotations (
    add "DESCRIPTION" 'Referenced list participating in the association.',
    add "SECURITY_SENSITIVE" 'TASKHUB_API must resolve the list and verify it belongs to TASKHUB_CTX before association.',
    add "AUTHORIZATION" 'Must have the same canonical owner as TAG_ID.'
);

alter table taskhub_owner.todo_list_tags modify tag_id annotations (
    add "DESCRIPTION" 'Referenced tag participating in the association.',
    add "SECURITY_SENSITIVE" 'TASKHUB_API must resolve the tag and verify it belongs to TASKHUB_CTX before association.',
    add "AUTHORIZATION" 'Must have the same canonical owner as TODO_LIST_ID.'
);

alter table taskhub_owner.todo_list_tags modify created_at annotations (
    add "DESCRIPTION" 'Timestamp when the association was created.',
    add "AUDIT_FIELD" 'Database generated from SYSTIMESTAMP; no separate actor column is required because creation is authorized through the API.'
);

alter table taskhub_owner.tasks annotations (
    add "DESCRIPTION" 'Canonical tasks and subtasks contained by a TaskHub list.',
    add "PURPOSE" 'Stores task lifecycle, priority, due/completion state and bounded parent-child hierarchy.',
    add "DOMAIN" 'Task execution and hierarchy.',
    add "OWNERSHIP" 'A task inherits ownership from TODO_LIST_ID; API authorization resolves the containing list against TASKHUB_CTX.',
    add "SECURITY_MODEL" 'TASKHUB_APP has no direct DML. TASKHUB_API validates list ownership and hierarchy so callers cannot cross user or list boundaries.',
    add "LIFECYCLE" 'Tasks are soft deleted; status DONE controls COMPLETED_AT and later maintenance physically purges eligible hierarchies.'
);

alter table taskhub_owner.tasks modify id annotations (
    add "DESCRIPTION" 'Stable surrogate identifier for a task or subtask.',
    add "IDENTITY_SOURCE" 'Generated always by the database identity mechanism.'
);

alter table taskhub_owner.tasks modify todo_list_id annotations (
    add "DESCRIPTION" 'Containing list and transitive source of task ownership.',
    add "SECURITY_SENSITIVE" 'TASKHUB_API must verify the list belongs to TASKHUB_CTX before every task operation.',
    add "AUTHORIZATION" 'Caller may select a list identifier only within the current context owner.'
);

alter table taskhub_owner.tasks modify parent_task_id annotations (
    add "DESCRIPTION" 'Optional parent task used to form the bounded subtask hierarchy.',
    add "SECURITY_SENSITIVE" 'Parent must be authorized, remain in the same list, avoid cycles and respect maximum depth.'
);

alter table taskhub_owner.tasks modify status annotations (
    add "DESCRIPTION" 'Task lifecycle state: OPEN, IN_PROGRESS, DONE or CANCELED.',
    add "LIFECYCLE" 'Transition to DONE populates COMPLETED_AT; leaving DONE clears it.'
);

alter table taskhub_owner.tasks modify priority annotations (
    add "DESCRIPTION" 'Business ordering value where 1 is high, 2 medium and 3 low.',
    add "BUSINESS_RULE" 'Ascending numeric order produces the intended high-to-low priority order.'
);

alter table taskhub_owner.tasks modify completed_at annotations (
    add "DESCRIPTION" 'Timestamp at which the task entered DONE status.',
    add "LIFECYCLE" 'API-managed from status transitions rather than independently caller controlled.'
);

alter table taskhub_owner.tasks modify created_at annotations (
    add "DESCRIPTION" 'Timestamp when the task was created.',
    add "AUDIT_FIELD" 'Database generated from SYSTIMESTAMP by the column default.'
);

alter table taskhub_owner.tasks modify created_by_user_id annotations (
    add "DESCRIPTION" 'Canonical application identity that created the task.',
    add "AUDIT_FIELD" 'Written by TASKHUB_API from validated context identity.',
    add "DERIVED_FROM_CONTEXT" 'Never accepted from the caller.'
);

alter table taskhub_owner.tasks modify updated_at annotations (
    add "DESCRIPTION" 'Timestamp of the most recent task update.',
    add "AUDIT_FIELD" 'Maintained by TASKHUB_API; NULL until an update occurs.'
);

alter table taskhub_owner.tasks modify updated_by_user_id annotations (
    add "DESCRIPTION" 'Canonical application identity that most recently updated the task.',
    add "AUDIT_FIELD" 'Maintained by TASKHUB_API on update.',
    add "DERIVED_FROM_CONTEXT" 'Resolved from validated TASKHUB_CTX identity.'
);

alter table taskhub_owner.tasks modify deleted_at annotations (
    add "DESCRIPTION" 'Timestamp marking the task as soft deleted; NULL means active.',
    add "LIFECYCLE" 'Soft deletion hides the task before retention-based hierarchy-safe purge.'
);

alter table taskhub_owner.tasks modify deleted_by_user_id annotations (
    add "DESCRIPTION" 'Canonical application identity that soft deleted the task.',
    add "AUDIT_FIELD" 'Maintained together with DELETED_AT.',
    add "DERIVED_FROM_CONTEXT" 'Resolved from validated TASKHUB_CTX identity.'
);

