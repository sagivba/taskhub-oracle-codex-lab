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
