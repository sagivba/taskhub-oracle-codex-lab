-- Enforces case-insensitive, trim-normalized tag-name uniqueness for active
-- tags per application user. Soft-deleted rows produce only NULL keys and do
-- not prevent recreation of the same normalized tag name.
create unique index taskhub_owner.tags_uq1
    on taskhub_owner.tags (
        case when deleted_at is null then app_user_id end,
        case when deleted_at is null then upper(trim(tag_name)) end
    );

-- TAGS_PK is the unique index created for the TAGS primary key.
