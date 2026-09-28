#!/usr/bin/env bash

set -euo pipefail

readonly TASKHUB_DB_HOST=db
readonly TASKHUB_DB_PORT=1521
readonly TASKHUB_DB_SERVICE=FREEPDB1
readonly TASKHUB_ORDS_CONFIG=/etc/ords/config
readonly TASKHUB_ORDS_BIN=/opt/oracle/ords/bin/ords
readonly TASKHUB_SECRETS_DIR=/run/taskhub-secrets

read_secret() {
  local secret_path="$1"
  local secret_value

  if [[ ! -r "$secret_path" ]]; then
    printf 'ERROR: required secret is not readable: %s\n' "$secret_path" >&2
    return 1
  fi

  IFS= read -r secret_value < "$secret_path" || true
  if [[ -z "$secret_value" ]]; then
    printf 'ERROR: required secret is empty: %s\n' "$secret_path" >&2
    return 1
  fi
  printf '%s' "$secret_value"
}

validate_existing_password() {
  local label="$1"
  local secret_value="$2"

  if [[ -z "$secret_value" ]]; then
    printf 'ERROR: %s must not be empty.\n' "$label" >&2
    return 1
  fi
}

validate_ords_password() {
  validate_existing_password "$@"
}

validate_apex_installer_password() {
  local label="$1"
  local secret_value="$2"

  if [[ -z "$secret_value" || ${#secret_value} -gt 128 ]]; then
    printf 'ERROR: %s must contain 1 to 128 characters.\n' "$label" >&2
    return 1
  fi
  if [[ "$secret_value" =~ [^A-Za-z0-9#_-] ]]; then
    printf 'ERROR: %s must use only letters, digits, #, _, or -.\n' "$label" >&2
    return 1
  fi
}

validate_apex_account_password() {
  local label="$1"
  local secret_value="$2"

  if [[ -z "$secret_value" ]]; then
    printf 'ERROR: %s must not be empty.\n' "$label" >&2
    return 1
  fi
}

run_sqlcl_checked() {
  local sql_log
  local -a pipeline_status

  sql_log="$(mktemp /tmp/taskhub-sqlcl.XXXXXX)"
  chmod 0600 "$sql_log"

  set +e
  sql -s /nolog 2>&1 | tee "$sql_log"
  pipeline_status=("${PIPESTATUS[@]}")
  set -e

  if (( pipeline_status[0] != 0 || pipeline_status[1] != 0 )); then
    printf 'ERROR: SQLcl exited unsuccessfully (sql=%d, tee=%d).\n' \
      "${pipeline_status[0]}" "${pipeline_status[1]}" >&2
    rm -f "$sql_log"
    return 1
  fi

  if grep -Eq '(^|[^[:alnum:]_])(ORA-[0-9]{5}|SP2-[0-9]{4}|PLS-[0-9]{5})([^[:digit:]]|$)|^ERROR at line' "$sql_log"; then
    printf 'ERROR: SQLcl output contained an Oracle, PL/SQL, or SQLcl error.\n' >&2
    rm -f "$sql_log"
    return 1
  fi

  rm -f "$sql_log"
}

require_empty_or_initialized_config() {
  mkdir -p "$TASKHUB_ORDS_CONFIG"
  if find "$TASKHUB_ORDS_CONFIG" -mindepth 1 -maxdepth 1 -print -quit | grep -q .; then
    printf 'ERROR: ORDS configuration volume is not empty; refusing a fresh install.\n' >&2
    return 1
  fi
}

set_ords_security_defaults() {
  "$TASKHUB_ORDS_BIN" --config "$TASKHUB_ORDS_CONFIG" config set feature.sdw false
  "$TASKHUB_ORDS_BIN" --config "$TASKHUB_ORDS_CONFIG" config set restEnabledSql.active false
  "$TASKHUB_ORDS_BIN" --config "$TASKHUB_ORDS_CONFIG" config set mongo.enabled false
  "$TASKHUB_ORDS_BIN" --config "$TASKHUB_ORDS_CONFIG" config set plsql.gateway.mode proxied
  "$TASKHUB_ORDS_BIN" --config "$TASKHUB_ORDS_CONFIG" config set security.requestValidationFunction ords_util.authorize_plsql_gateway
  "$TASKHUB_ORDS_BIN" --config "$TASKHUB_ORDS_CONFIG" config set standalone.http.port 8181
  "$TASKHUB_ORDS_BIN" --config "$TASKHUB_ORDS_CONFIG" config set standalone.context.path /ords
}
