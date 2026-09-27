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
