#!/usr/bin/env bash
set -Eeuo pipefail

UPLOADS_PATH=""
DB_PATH=""

usage() {
  cat <<'USAGE'
Uso:
  bash docker/dr/immich-lab/precheck-immich.sh \
    --uploads PATH \
    --db PATH

Comprueba el host DR mínimo para levantar Immich desde datos restaurados o clones ZFS.

Opciones:
  --uploads   Ruta del árbol de uploads real que se montará como /data
  --db        Ruta del directorio de PostgreSQL de Immich
  -h, --help  Mostrar ayuda
USAGE
}

docker_cmd() {
  if docker version >/dev/null 2>&1; then
    docker "$@"
  elif sudo -n docker version >/dev/null 2>&1; then
    sudo -n docker "$@"
  else
    sudo docker "$@"
  fi
}

require_dir() {
  local path="$1"
  [[ -d "$path" ]] || { echo "FAIL no existe directorio: $path" >&2; exit 1; }
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --uploads)
      UPLOADS_PATH="${2:?Falta valor para --uploads}"
      shift 2
      ;;
    --db)
      DB_PATH="${2:?Falta valor para --db}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: argumento no reconocido: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

[[ -n "$UPLOADS_PATH" ]] || { echo 'ERROR: falta --uploads' >&2; usage >&2; exit 2; }
[[ -n "$DB_PATH" ]] || { echo 'ERROR: falta --db' >&2; usage >&2; exit 2; }

require_dir "$UPLOADS_PATH"
require_dir "$DB_PATH"

echo '== Docker =='
docker_cmd version >/dev/null
echo 'OK docker'

echo '== Compose =='
docker_cmd compose version

echo '== Paths =='
echo "OK $(stat -c '%U:%G %a %n' "$UPLOADS_PATH")"
echo "OK $(stat -c '%U:%G %a %n' "$DB_PATH")"

echo '== Estructura uploads =='
for d in upload library thumbs profile; do
  if [[ -d "$UPLOADS_PATH/$d" ]]; then
    echo "OK $UPLOADS_PATH/$d"
  else
    echo "WARN falta $UPLOADS_PATH/$d"
  fi
done
if [[ -d "$UPLOADS_PATH/backups" ]]; then
  echo "OK $UPLOADS_PATH/backups"
else
  echo "WARN falta $UPLOADS_PATH/backups"
fi

echo '== Acceso root a DB =='
sudo test -r "$DB_PATH" && sudo test -x "$DB_PATH"
echo "OK acceso root $DB_PATH"

echo 'OK precheck immich'
