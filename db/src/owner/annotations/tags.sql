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
