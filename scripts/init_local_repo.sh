#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [ -d .git ]; then
  printf 'Git repository already initialized: %s\n' "$ROOT"
else
  git init
  git branch -M main
  printf 'Initialized local Git repository: %s\n' "$ROOT"
fi

printf '\nNext steps:\n'
printf '1. Read AGENTS.md and docs/status/CURRENT_STATUS.md\n'
printf '2. Run scripts/validate_repo_structure.sh\n'
printf '3. Run scripts/check_environment.sh\n'
printf '4. Review the output before building the Oracle container\n'
