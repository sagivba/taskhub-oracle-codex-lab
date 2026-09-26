-- TaskHub POC manual DBA bootstrap
-- Purpose: create the three database schemas used by the DEV lab.
-- Run manually as a DBA while connected to the target PDB.
-- Do not commit real passwords to Git.

set verify off
set echo off

accept TASKHUB_OWNER_PWD char prompt 'Password for TASKHUB_OWNER: ' hide
accept TASKHUB_API_PWD   char prompt 'Password for TASKHUB_API:   ' hide
accept TASKHUB_APP_PWD   char prompt 'Password for TASKHUB_APP:   ' hide

prompt Creating TASKHUB_OWNER...
create user taskhub_owner
    identified by "&TASKHUB_OWNER_PWD"
    default tablespace users
    temporary tablespace temp
    quota unlimited on users;

grant create session to taskhub_owner;
grant create table to taskhub_owner;
grant create sequence to taskhub_owner;

prompt Creating TASKHUB_API...
create user taskhub_api
    identified by "&TASKHUB_API_PWD"
    default tablespace users
    temporary tablespace temp;

grant create session to taskhub_api;
grant create procedure to taskhub_api;
grant create view to taskhub_api;
grant create job to taskhub_api;

prompt Creating TASKHUB_APP...
create user taskhub_app
    identified by "&TASKHUB_APP_PWD"
    default tablespace users
    temporary tablespace temp;

grant create session to taskhub_app;

undefine TASKHUB_OWNER_PWD
undefine TASKHUB_API_PWD
undefine TASKHUB_APP_PWD

prompt Manual user bootstrap complete.
prompt Next: run 0020_create_application_context.sql as DBA.
