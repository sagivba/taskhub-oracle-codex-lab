#!/usr/bin/env bash

set -euo pipefail

readonly ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly STAGE_ROOT="$ROOT/.task70/apex"
readonly ARCHIVE="$STAGE_ROOT/apex_26.1_en.zip"
readonly APEX_HOME="$STAGE_ROOT/apex"
readonly APEX_URL='https://download.oracle.com/otn_software/apex/apex_26.1_en.zip'
readonly APEX_SHA256='b277aa4650d2d4c5e88e8e3738e8098cddd7be7443376ae590ae8fab8b427919'

mkdir -p "$STAGE_ROOT"

if [[ -f "$ARCHIVE" ]]; then
  printf '%s  %s\n' "$APEX_SHA256" "$ARCHIVE" | sha256sum --check --status
else
  partial_archive="$ARCHIVE.part"
  if [[ -e "$partial_archive" ]]; then
    printf 'ERROR: partial download already exists: %s\n' "$partial_archive" >&2
    exit 1
  fi
  curl --fail --location --output "$partial_archive" "$APEX_URL"
  printf '%s  %s\n' "$APEX_SHA256" "$partial_archive" | sha256sum --check --status
  mv "$partial_archive" "$ARCHIVE"
fi

if [[ -d "$APEX_HOME" ]]; then
  if [[ ! -f "$APEX_HOME/apxsilentins.sql" ]]; then
    printf 'ERROR: existing APEX stage is incomplete: %s\n' "$APEX_HOME" >&2
    exit 1
  fi
else
  unzip -q "$ARCHIVE" -d "$STAGE_ROOT"
fi

printf 'APEX 26.1 English source staged and checksum verified: %s\n' "$APEX_HOME"
