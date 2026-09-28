#!/usr/bin/env bash

set -euo pipefail
source /opt/taskhub/scripts/common.sh

if [[ ! -d "$TASKHUB_ORDS_CONFIG/databases/default" ]]; then
  printf 'ERROR: ORDS default-pool configuration is missing.\n' >&2
  exit 1
fi

sys_password="$(read_secret "$TASKHUB_SECRETS_DIR/taskhub-sys-password")"
validate_existing_password 'SYS password' "$sys_password"
trap 'unset sys_password' EXIT

printf 'Repairing ORDS metadata after the APEX installation.\n'
printf '%s\n' "$sys_password" | \
  "$TASKHUB_ORDS_BIN" --config "$TASKHUB_ORDS_CONFIG" install repair \
    --admin-user SYS \
    --password-stdin \
    --db-hostname "$TASKHUB_DB_HOST" \
    --db-port "$TASKHUB_DB_PORT" \
    --db-servicename "$TASKHUB_DB_SERVICE"

set_ords_security_defaults
printf 'ORDS repair and restricted configuration: PASS\n'
