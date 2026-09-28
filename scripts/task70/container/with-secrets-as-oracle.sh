#!/usr/bin/env bash

set -euo pipefail
set +x

readonly source_dir=/run/secrets
readonly target_dir=/run/taskhub-secrets

if (( EUID != 0 )); then
  printf 'ERROR: secret handoff must start as container root.\n' >&2
  exit 1
fi
if (( $# == 0 )); then
  printf 'ERROR: secret handoff requires a command.\n' >&2
  exit 1
fi

install -d -m 0700 -o oracle -g oinstall "$target_dir"
secret_count=0
for source_path in "$source_dir"/*; do
  if [[ ! -f "$source_path" ]]; then
    continue
  fi
  target_path="$target_dir/${source_path##*/}"
  install -m 0600 -o oracle -g oinstall "$source_path" "$target_path"
  secret_count=$((secret_count + 1))
done

if (( secret_count == 0 )); then
  printf 'ERROR: no setup secrets were mounted.\n' >&2
  exit 1
fi

exec /usr/sbin/chroot --userspec=oracle:oinstall / "$@"
