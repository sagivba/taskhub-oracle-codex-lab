#!/usr/bin/env bash

set -euo pipefail
source /opt/taskhub/scripts/common.sh

sys_password="$(read_secret "$TASKHUB_SECRETS_DIR/taskhub-sys-password")"
alice_password="$(read_secret "$TASKHUB_SECRETS_DIR/taskhub-apex-alice-password")"
bob_password="$(read_secret "$TASKHUB_SECRETS_DIR/taskhub-apex-bob-password")"
validate_existing_password 'SYS password' "$sys_password"
validate_apex_account_password 'TASKHUB_TEST_ALICE APEX password' "$alice_password"
validate_apex_account_password 'TASKHUB_TEST_BOB APEX password' "$bob_password"
trap 'unset sys_password alice_password bob_password' EXIT

printf 'Configuring the TaskHub APEX workspace and test accounts.\n'
run_sqlcl_checked <<SQL
set echo off verify off feedback on serveroutput on
whenever oserror exit failure
whenever sqlerror exit sql.sqlcode rollback
connect sys/"${sys_password}"@${TASKHUB_DB_HOST}:${TASKHUB_DB_PORT}/${TASKHUB_DB_SERVICE} as sysdba
define TASKHUB_APEX_ALICE_PASSWORD = '${alice_password}'
define TASKHUB_APEX_BOB_PASSWORD = '${bob_password}'
@/opt/taskhub/db/changes/0300_create_taskhub_apex_workspace.sql
@/opt/taskhub/db/changes/0310_create_taskhub_apex_accounts.sql
undefine TASKHUB_APEX_ALICE_PASSWORD
undefine TASKHUB_APEX_BOB_PASSWORD
@/opt/taskhub/db/tests/structure/0410_task70_apex_platform.sql
exit success
SQL

printf 'TaskHub APEX workspace and account configuration: PASS\n'
