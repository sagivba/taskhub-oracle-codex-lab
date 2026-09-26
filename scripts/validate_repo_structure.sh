#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required=(
  'AGENTS.md'
  'README.md'
  'docs/spec/TaskHub_POC_Specification_HE_v3.md'
  'docs/status/CURRENT_STATUS.md'
  'docs/task_order.md'
  'db/admin/0010_create_lab_users.sql'
  'db/admin/0020_create_application_context.sql'
  'db/changes'
  'db/src'
  'db/tests'
  'db/deploy/install'
)

failed=0
for item in "${required[@]}"; do
  if [ ! -e "$ROOT/$item" ]; then
    printf 'MISSING: %s\n' "$item"
    failed=1
  fi
done

mapfile -t changes < <(find "$ROOT/db/changes" -maxdepth 1 -type f -name '*.sql' -printf '%f\n' | sort)
for file in "${changes[@]}"; do
  if [[ "$file" == _TEMPLATE.sql ]]; then
    continue
  fi
  if [[ ! "$file" =~ ^[0-9]{4}_[A-Za-z0-9._-]+\.sql$ ]]; then
    printf 'INVALID CHANGE FILENAME: %s\n' "$file"
    failed=1
  fi
done

if grep -RIl --exclude='*.svg' --exclude='*.html' -E '(BEGIN (RSA|OPENSSH|EC) PRIVATE KEY|password[[:space:]]*=[[:space:]]*[^<[:space:]]+)' "$ROOT" >/tmp/taskhub_secret_scan.txt 2>/dev/null; then
  printf 'REVIEW: possible secret-like content found:\n'
  cat /tmp/taskhub_secret_scan.txt
  failed=1
fi
rm -f /tmp/taskhub_secret_scan.txt

if [ "$failed" -ne 0 ]; then
  exit 1
fi
printf 'Repository structure validation: PASS\n'
