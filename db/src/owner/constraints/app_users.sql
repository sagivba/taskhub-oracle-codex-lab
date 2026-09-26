alter table taskhub_owner.app_users
    add constraint app_users_pk
    primary key (id);

alter table taskhub_owner.app_users
    add constraint app_users_uq1
    unique (username);

alter table taskhub_owner.app_users
    add constraint app_users_ck1
    check (is_active in ('Y', 'N'));
