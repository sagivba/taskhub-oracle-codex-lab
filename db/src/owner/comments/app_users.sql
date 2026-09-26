comment on table taskhub_owner.app_users is
    'Application identities used by TaskHub; rows do not represent Oracle database users.';

comment on column taskhub_owner.app_users.id is
    'Surrogate primary key for an application identity.';

comment on column taskhub_owner.app_users.username is
    'Unique case-sensitive application username used by TASKHUB_API to resolve session identity.';

comment on column taskhub_owner.app_users.display_name is
    'Optional display name for the application user.';

comment on column taskhub_owner.app_users.email is
    'Optional email address for the application user; not an authentication credential.';

comment on column taskhub_owner.app_users.is_active is
    'Application identity status: Y permits context initialization; N denies it.';

comment on column taskhub_owner.app_users.created_at is
    'Database timestamp when the application identity row was created.';

comment on column taskhub_owner.app_users.updated_at is
    'Database timestamp of the most recent update; NULL until the row is updated.';
