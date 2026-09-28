#!/usr/bin/env bash

set -euo pipefail
set +x

readonly ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly SECRETS_DIR="$ROOT/.secrets"

validate_existing_secret() {
  local label="$1"
  local secret_value="$2"

  if [[ -z "$secret_value" ]]; then
    printf 'ERROR: %s must not be empty.\n' "$label" >&2
    return 1
  fi
}

validate_new_secret() {
  local label="$1"
  local secret_value="$2"

  if [[ -z "$secret_value" ]]; then
    printf 'ERROR: %s must not be empty.\n' "$label" >&2
    return 1
  fi
}

validate_apex_account_secret() {
  local label="$1"
  local secret_value="$2"

  if [[ -z "$secret_value" ]]; then
    printf 'ERROR: %s must not be empty.\n' "$label" >&2
    return 1
  fi
}

write_secret() {
  local filename="$1"
  local label="$2"
  local validator="$3"
  local validator_arg="${4:-}"
  local first_value
  local second_value

  while true; do
    IFS= read -r -s -p "$label: " first_value
    printf '\n'
    if [[ -n "$validator_arg" ]]; then
      "$validator" "$label" "$first_value" "$validator_arg" || {
        unset first_value
        continue
      }
    elif ! "$validator" "$label" "$first_value"; then
      unset first_value
      continue
    fi

    IFS= read -r -s -p "Confirm $label: " second_value
    printf '\n'
    if [[ "$first_value" != "$second_value" ]]; then
      printf 'ERROR: values do not match; try again.\n' >&2
      unset first_value second_value
      continue
    fi

    install -m 0600 /dev/null "$SECRETS_DIR/$filename"
    printf '%s\n' "$first_value" > "$SECRETS_DIR/$filename"
    unset first_value second_value
    return 0
  done
}

if [[ ! -f "$ROOT/.env" ]]; then
  cp "$ROOT/.env.example" "$ROOT/.env"
fi

install -d -m 0700 "$SECRETS_DIR"
umask 077

prepare_apex_account_secrets() {
  write_secret apex-admin-password.txt 'New APEX instance ADMIN password' validate_apex_account_secret
  write_secret apex-alice-password.txt 'New TASKHUB_TEST_ALICE APEX password' validate_apex_account_secret
  write_secret apex-bob-password.txt 'New TASKHUB_TEST_BOB APEX password' validate_apex_account_secret
}

case "${1:-all}" in
  all)
    write_secret sys-password.txt 'Existing FREEPDB1 SYS password' validate_existing_secret
    write_secret ords-public-password.txt 'New ORDS_PUBLIC_USER password' validate_new_secret
    write_secret apex-public-password.txt 'New APEX_PUBLIC_USER password' validate_new_secret
    write_secret apex-listener-password.txt 'New APEX_LISTENER password' validate_new_secret
    write_secret apex-rest-public-password.txt 'New APEX_REST_PUBLIC_USER password' validate_new_secret
    prepare_apex_account_secrets
    ;;
  apex-accounts)
    prepare_apex_account_secrets
    ;;
  *)
    printf 'Usage: %s [all|apex-accounts]\n' "$0" >&2
    exit 2
    ;;
esac

printf 'Local Task 70 secret files created with mode 0600.\n'
