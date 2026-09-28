#!/usr/bin/env bash

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export_file="$root/apex/taskhub_app.sql"

if [[ ! -s "$export_file" ]]; then
  printf 'MISSING: apex/taskhub_app.sql\n' >&2
  exit 1
fi

require() {
  local expression="$1"
  local label="$2"
  if ! rg -qi -- "$expression" "$export_file"; then
    printf 'MISSING: %s\n' "$label" >&2
    exit 1
  fi
}

forbid() {
  local expression="$1"
  local label="$2"
  if rg -qi -- "$expression" "$export_file"; then
    printf 'FORBIDDEN: %s\n' "$label" >&2
    exit 1
  fi
}

require 'p_default_application_id[[:space:]]*=>[[:space:]]*700' 'application ID 700'
require 'TASKHUB_API\.PKG_TASKHUB_CONTEXT\.INIT_FROM_APEX' 'INIT_FROM_APEX lifecycle call'
require 'TASKHUB_API\.V_TODO_LISTS' 'filtered TODO Lists view'
require 'TASKHUB_API\.PKG_TASKHUB_API\.CREATE_LIST' 'Create TODO List API call'
forbid 'TASKHUB_OWNER\.' 'direct TASKHUB_OWNER reference'

printf 'TaskHub APEX application export validation: PASS\n'
