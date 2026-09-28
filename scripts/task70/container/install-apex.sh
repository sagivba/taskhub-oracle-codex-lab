#!/usr/bin/env bash

set -euo pipefail
source /opt/taskhub/scripts/common.sh

readonly apex_source=/opt/taskhub/apex
readonly apex_home=/tmp/taskhub-apex
if [[ ! -f "$apex_source/apxsilentins.sql" ]]; then
  printf 'ERROR: APEX 26.1 source is not mounted at %s.\n' "$apex_source" >&2
  exit 1
fi

sys_password="$(read_secret "$TASKHUB_SECRETS_DIR/taskhub-sys-password")"
apex_public_password="$(read_secret "$TASKHUB_SECRETS_DIR/taskhub-apex-public-password")"
apex_listener_password="$(read_secret "$TASKHUB_SECRETS_DIR/taskhub-apex-listener-password")"
apex_rest_public_password="$(read_secret "$TASKHUB_SECRETS_DIR/taskhub-apex-rest-public-password")"
apex_admin_password="$(read_secret "$TASKHUB_SECRETS_DIR/taskhub-apex-admin-password")"

validate_existing_password 'SYS password' "$sys_password"
validate_apex_installer_password 'APEX_PUBLIC_USER password' "$apex_public_password"
validate_apex_installer_password 'APEX_LISTENER password' "$apex_listener_password"
validate_apex_installer_password 'APEX_REST_PUBLIC_USER password' "$apex_rest_public_password"
validate_apex_account_password 'APEX ADMIN password' "$apex_admin_password"
trap 'unset sys_password apex_public_password apex_listener_password apex_rest_public_password apex_admin_password' EXIT

install -d -m 0700 "$apex_home"
cp -R "$apex_source"/. "$apex_home"/

cd "$apex_home"
printf 'Installing the APEX 26.1 full development environment into %s.\n' "$TASKHUB_DB_SERVICE"
run_sqlcl_checked <<SQL
set echo off verify off feedback on serveroutput on
whenever oserror exit failure
whenever sqlerror exit sql.sqlcode rollback
connect sys/"${sys_password}"@${TASKHUB_DB_HOST}:${TASKHUB_DB_PORT}/${TASKHUB_DB_SERVICE} as sysdba

declare
    l_con_name varchar2(128) := sys_context('USERENV', 'CON_NAME');
    l_count    pls_integer;
    l_verify   varchar2(128);
begin
    if l_con_name <> '${TASKHUB_DB_SERVICE}' then
        raise_application_error(-20990, 'Wrong target container: ' || l_con_name);
    end if;

    select count(*)
      into l_count
      from dba_users
     where username like 'APEX\\_%' escape '\\';
    if l_count <> 0 then
        raise_application_error(-20991, 'APEX schemas already exist; refusing a fresh install');
    end if;

    select limit
      into l_verify
      from dba_profiles
     where profile = 'DEFAULT'
       and resource_name = 'PASSWORD_VERIFY_FUNCTION'
       and resource_type = 'PASSWORD';
    if l_verify <> 'NULL' then
        raise_application_error(-20992, 'DEFAULT password verification is enabled; stop for DBA review');
    end if;
end;
/

@apxsilentins.sql SYSAUX SYSAUX TEMP /i/ '${apex_public_password}' '${apex_listener_password}' '${apex_rest_public_password}' '${apex_admin_password}'

whenever oserror exit failure
whenever sqlerror exit sql.sqlcode rollback
declare
    l_apex_schema varchar2(128);
    l_count       pls_integer;
begin
    select schema
      into l_apex_schema
      from dba_registry
     where comp_id = 'APEX'
       and status = 'VALID'
       and version like '26.1%';

    execute immediate
        'select count(*) from ' || dbms_assert.schema_name(l_apex_schema) ||
        '.wwv_flow_fnd_user u join ' || dbms_assert.schema_name(l_apex_schema) ||
        '.wwv_flow_developers d on d.user_id = u.user_id ' ||
        'where u.security_group_id = 10 and u.user_name = ''ADMIN'' ' ||
        'and nvl(u.account_locked, ''N'') = ''N'' ' ||
        'and instr('':'' || d.developer_role || '':'', '':ADMIN:'') > 0'
      into l_count;

    if l_count <> 1 then
        raise_application_error(-20993, 'APEX ADMIN postcondition failed');
    end if;
end;
/
exit success
SQL

printf 'APEX 26.1 full development installation: PASS\n'
