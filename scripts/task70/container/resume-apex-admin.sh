#!/usr/bin/env bash

set -euo pipefail
source /opt/taskhub/scripts/common.sh

sys_password="$(read_secret "$TASKHUB_SECRETS_DIR/taskhub-sys-password")"
apex_admin_password="$(read_secret "$TASKHUB_SECRETS_DIR/taskhub-apex-admin-password")"
validate_existing_password 'SYS password' "$sys_password"
validate_apex_account_password 'APEX ADMIN password' "$apex_admin_password"
trap 'unset sys_password apex_admin_password' EXIT

printf 'Resuming from the failed APEX ADMIN account configuration step.\n'
run_sqlcl_checked <<SQL
set echo off verify off feedback on serveroutput on
whenever oserror exit failure
whenever sqlerror exit sql.sqlcode rollback
connect sys/"${sys_password}"@${TASKHUB_DB_HOST}:${TASKHUB_DB_PORT}/${TASKHUB_DB_SERVICE} as sysdba
define TASKHUB_APEX_ADMIN_PASSWORD = '${apex_admin_password}'
@/opt/taskhub/db/changes/0320_set_apex_admin_account.sql
undefine TASKHUB_APEX_ADMIN_PASSWORD
exit success
SQL

printf 'APEX ADMIN account configuration and postcondition: PASS\n'
