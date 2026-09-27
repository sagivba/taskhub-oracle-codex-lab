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
