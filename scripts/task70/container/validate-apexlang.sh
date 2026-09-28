#!/usr/bin/env bash

set -euo pipefail
source /opt/taskhub/scripts/common.sh

if [[ ! -f /opt/taskhub/apexlang/application.apx ]]; then
  printf 'ERROR: TaskHub APEXlang application source is not mounted.\n' >&2
  exit 1
fi

sys_password="$(read_secret "$TASKHUB_SECRETS_DIR/taskhub-sys-password")"
validate_existing_password 'SYS password' "$sys_password"
trap 'unset sys_password' EXIT

printf 'Validating TaskHub APEXlang application 700 without changing database state.\n'
run_sqlcl_checked <<SQL
set echo off verify off feedback on serveroutput on
whenever oserror exit failure
whenever sqlerror exit sql.sqlcode rollback
connect sys/"${sys_password}"@${TASKHUB_DB_HOST}:${TASKHUB_DB_PORT}/${TASKHUB_DB_SERVICE} as sysdba
apex validate -input /opt/taskhub/apexlang -workspace TASKHUB
exit success
SQL

printf 'TaskHub APEXlang validation: PASS\n'
