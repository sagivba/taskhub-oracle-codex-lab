#!/usr/bin/env bash

set -euo pipefail
source /opt/taskhub/scripts/common.sh

require_empty_or_initialized_config

sys_password="$(read_secret "$TASKHUB_SECRETS_DIR/taskhub-sys-password")"
ords_public_password="$(read_secret "$TASKHUB_SECRETS_DIR/taskhub-ords-public-password")"
validate_existing_password 'SYS password' "$sys_password"
validate_ords_password 'ORDS_PUBLIC_USER password' "$ords_public_password"

install_log_dir="$(mktemp -d /tmp/taskhub-ords-install.XXXXXX)"
trap 'unset sys_password ords_public_password' EXIT

printf 'Installing the ORDS repository into %s:%s/%s.\n' \
  "$TASKHUB_DB_HOST" "$TASKHUB_DB_PORT" "$TASKHUB_DB_SERVICE"
printf '%s\n%s\n' "$sys_password" "$ords_public_password" | \
  "$TASKHUB_ORDS_BIN" --config "$TASKHUB_ORDS_CONFIG" install \
    --admin-user SYS \
    --proxy-user \
    --password-stdin \
    --db-hostname "$TASKHUB_DB_HOST" \
    --db-port "$TASKHUB_DB_PORT" \
    --db-servicename "$TASKHUB_DB_SERVICE" \
    --feature-sdw false \
    --log-folder "$install_log_dir"

set_ords_security_defaults
printf 'ORDS repository installation and restricted standalone configuration: PASS\n'
