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
