comment on table taskhub_owner.tags is
    'Reusable tags owned by TaskHub application users.';

comment on column taskhub_owner.tags.id is
    'Surrogate primary key for a tag.';

comment on column taskhub_owner.tags.app_user_id is
    'Application user that owns the tag.';

comment on column taskhub_owner.tags.tag_name is
    'Tag name; active names are unique per owner after trim and case normalization.';

comment on column taskhub_owner.tags.created_at is
    'Database timestamp when the tag was created.';

comment on column taskhub_owner.tags.created_by_user_id is
    'Application user that created the tag.';

comment on column taskhub_owner.tags.updated_at is
    'Database timestamp of the most recent update; NULL until the tag is updated.';

comment on column taskhub_owner.tags.updated_by_user_id is
    'Application user that performed the most recent update; NULL until the tag is updated.';

comment on column taskhub_owner.tags.deleted_at is
    'Soft-delete timestamp; NULL while the tag is active.';

comment on column taskhub_owner.tags.deleted_by_user_id is
    'Application user that soft-deleted the tag; NULL while the tag is active.';
