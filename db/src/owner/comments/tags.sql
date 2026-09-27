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
