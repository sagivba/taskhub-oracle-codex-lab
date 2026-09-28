#!/usr/bin/env bash

set -euo pipefail
source /opt/taskhub/scripts/common.sh

if [[ ! -f /opt/taskhub/apex/taskhub_app.sql ]]; then
  printf 'ERROR: apex/taskhub_app.sql is not mounted.\n' >&2
  exit 1
fi

sys_password="$(read_secret "$TASKHUB_SECRETS_DIR/taskhub-sys-password")"
validate_existing_password 'SYS password' "$sys_password"
trap 'unset sys_password' EXIT

printf 'Importing TaskHub application 700 into workspace TASKHUB with parsing schema TASKHUB_APP.\n'
run_sqlcl_checked <<SQL
set echo off verify off feedback on serveroutput on
whenever oserror exit failure
whenever sqlerror exit sql.sqlcode rollback
connect sys/"${sys_password}"@${TASKHUB_DB_HOST}:${TASKHUB_DB_PORT}/${TASKHUB_DB_SERVICE} as sysdba
@/opt/taskhub/db/deploy/task70/import_apex_app.sql
exit success
SQL

printf 'TaskHub APEX application import: PASS\n'
