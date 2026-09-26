#!/usr/bin/env bash
set -u

section() {
  printf '\n============================================================\n'
  printf '%s\n' "$1"
  printf '============================================================\n'
}

section "TaskHub Codex + Oracle SQLcl MCP - Read-only environment check"

printf 'Timestamp (local shell): '
date '+%Y-%m-%d %H:%M:%S %z' 2>/dev/null || true
printf 'User: %s\n' "${USER:-UNKNOWN}"
printf 'HOME: %s\n' "${HOME:-UNKNOWN}"
printf 'PWD: %s\n' "$PWD"

section "OS / WSL"
uname -a || true
if grep -qi microsoft /proc/version 2>/dev/null; then
  printf 'WSL detected: YES\n'
else
  printf 'WSL detected: NO / UNKNOWN\n'
fi

section "Codex"
if command -v codex >/dev/null 2>&1; then
  printf 'Path: %s\n' "$(command -v codex)"
  printf 'Resolved: '
  readlink -f "$(command -v codex)" 2>/dev/null || true
  codex --version || true
else
  printf 'codex: NOT FOUND\n'
fi

section "SQLcl"
if command -v sql >/dev/null 2>&1; then
  printf 'Path: %s\n' "$(command -v sql)"
  printf 'Resolved: '
  readlink -f "$(command -v sql)" 2>/dev/null || true
  sql -version || true
else
  printf 'sql: NOT FOUND\n'
fi

section "Java"
if command -v java >/dev/null 2>&1; then
  printf 'Path: %s\n' "$(command -v java)"
  printf 'Resolved: '
  readlink -f "$(command -v java)" 2>/dev/null || true
  java -version 2>&1 || true
else
  printf 'java: NOT FOUND\n'
fi
printf 'JAVA_HOME=%s\n' "${JAVA_HOME:-NOT_SET}"

section "Docker"
if command -v docker >/dev/null 2>&1; then
  printf 'Path: %s\n' "$(command -v docker)"
  docker --version || true
  docker compose version 2>/dev/null || true
else
  printf 'docker: NOT FOUND\n'
fi

section "PATH entries"
printf '%s\n' "${PATH:-}" | tr ':' '\n'

section "~/.dbtools metadata only"
DBTOOLS="${HOME}/.dbtools"
if [ -d "$DBTOOLS" ]; then
  printf '%s exists.\n' "$DBTOOLS"
  printf 'No file contents or credentials are printed.\n\n'
  find "$DBTOOLS" -mindepth 1 -maxdepth 3 -printf '%M %u %g %p\n' 2>/dev/null | sort
else
  printf '%s does not exist.\n' "$DBTOOLS"
fi

section "Potential connection/security-related filenames only"
if [ -d "$DBTOOLS" ]; then
  find "$DBTOOLS" -type f \
    \( -iname '*connection*' \
       -o -iname '*credential*' \
       -o -iname '*wallet*' \
       -o -iname '*tns*' \
       -o -iname '*password*' \) \
    -print 2>/dev/null | sort
else
  printf 'No ~/.dbtools directory.\n'
fi

section "Check complete"
printf 'Paste the output into the planning conversation before container/MCP setup.\n'
