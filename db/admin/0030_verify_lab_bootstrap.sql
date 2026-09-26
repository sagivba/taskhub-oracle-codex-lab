-- Read-only verification. Requires DBA dictionary access.

set pagesize 200
set linesize 220

prompt === Users ===
select username,
       account_status,
       default_tablespace,
       temporary_tablespace
from dba_users
where username in ('TASKHUB_OWNER','TASKHUB_API','TASKHUB_APP')
order by username;

prompt === System privileges ===
select grantee,
       privilege,
       admin_option
from dba_sys_privs
where grantee in ('TASKHUB_OWNER','TASKHUB_API','TASKHUB_APP')
order by grantee, privilege;

prompt === Context ===
select namespace,
       schema,
       package
from dba_context
where namespace = 'TASKHUB_CTX';

prompt Expected: no broad ANY privileges and context package TASKHUB_API.PKG_TASKHUB_CONTEXT_CORE.
