#!/usr/bin/env bash

set -euo pipefail

readonly ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly EXPECTED_DB_IMAGE='container-registry.oracle.com/database/free@sha256:8a8084193724b95bc62247e3af4218b357e4f172c78925551b2181dbe2566232'
readonly EXPECTED_BACKUP_SHA='46d50a9654b70f27828cbc77f221e9c3b1e33f5274965f1acdb63e7b1753a6b4'
readonly BACKUP_ARCHIVE="${TASKHUB_BACKUP_ARCHIVE:-$HOME/backups/taskhub/pre-task70-20260927/taskhub-oradata-pre-task70-cold.tar.gz}"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

container_image="$(docker inspect --format '{{.Config.Image}}' taskhub-db)"
[[ "$container_image" == "$EXPECTED_DB_IMAGE" ]] || fail 'taskhub-db image does not match the protected baseline'

container_state="$(docker inspect --format '{{.State.Status}}/{{if .State.Health}}{{.State.Health.Status}}{{else}}no-healthcheck{{end}}' taskhub-db)"
[[ "$container_state" == 'running/healthy' ]] || fail "taskhub-db is not running/healthy ($container_state)"

mount_source="$(docker inspect --format '{{range .Mounts}}{{if eq .Destination "/opt/oracle/oradata"}}{{.Name}}{{end}}{{end}}' taskhub-db)"
[[ "$mount_source" == 'taskhub-oradata' ]] || fail 'taskhub-db does not use taskhub-oradata at /opt/oracle/oradata'

docker volume inspect taskhub-oradata >/dev/null
docker volume inspect taskhub-oradata-pre-task70-cold >/dev/null
docker network inspect taskhub-net >/dev/null

[[ -f "$BACKUP_ARCHIVE" ]] || fail "cold backup archive is missing: $BACKUP_ARCHIVE"
printf '%s  %s\n' "$EXPECTED_BACKUP_SHA" "$BACKUP_ARCHIVE" | sha256sum --check --status \
  || fail 'cold backup archive checksum does not match the recorded rollback point'

docker compose --project-directory "$ROOT" --env-file "$ROOT/.env.example" config --quiet

printf 'PASS: Task 70 read-only Docker and rollback preflight\n'
printf 'Database container: %s\n' "$container_state"
printf 'Live volume: taskhub-oradata\n'
printf 'Protected volume: taskhub-oradata-pre-task70-cold\n'
printf 'Protected archive SHA-256: %s\n' "$EXPECTED_BACKUP_SHA"
