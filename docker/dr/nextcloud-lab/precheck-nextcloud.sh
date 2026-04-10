#!/usr/bin/env bash
set -Eeuo pipefail

APP_USER="www-data"
DB_USER="alejandro"
CONFIG_PATH=""
DATA_PATH=""
DB_PATH=""
STORAGE_ROOT_PATH=""
MEDIA_PATH=""

usage() {
  cat <<'USAGE'
Uso:
  bash docker/dr/nextcloud-lab/precheck-nextcloud.sh \
    --config PATH \
    --data PATH \
    --db PATH \
    --storage-root PATH \
    [--media PATH] \
    [--app-user USUARIO] \
    [--db-user USUARIO]

Comprueba el host DR mínimo para levantar Nextcloud desde datos restaurados o clones ZFS.

Opciones:
  --config         Ruta persistente de /config (escritura por usuario app)
  --data           Ruta persistente de /data (escritura por usuario app)
  --db             Ruta persistente de MariaDB (/config del contenedor DB; escritura por usuario DB)
  --storage-root   Ruta que se montará como /srv/storage (lectura/travesía por usuario app)
  --media          Ruta opcional para /srv/storage/media (lectura/travesía por usuario app)
  --app-user       Usuario que corre Nextcloud en el host DR (por defecto: www-data)
  --db-user        Usuario que corre MariaDB en el host DR (por defecto: alejandro)
  -h, --help       Mostrar ayuda
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

run_as_user() {
  local user="$1"
  local script="$2"
  if [[ "$(id -un)" == "$user" ]]; then
    bash -c "$script"
  else
    sudo -u "$user" bash -c "$script"
  fi
}

require_dir() {
  local path="$1"
  [[ -d "$path" ]] || { echo "FAIL no existe directorio: $path" >&2; exit 1; }
}

check_read_dir() {
  local user="$1"
  local path="$2"
  run_as_user "$user" "test -r '$path' && test -x '$path'"
}

check_write_dir() {
  local user="$1"
  local path="$2"
  local probe="$path/.dr-write-test.$$"
  run_as_user "$user" "touch '$probe' && rm -f '$probe'"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config)
      CONFIG_PATH="${2:?Falta valor para --config}"
      shift 2
      ;;
    --data)
      DATA_PATH="${2:?Falta valor para --data}"
      shift 2
      ;;
    --db)
      DB_PATH="${2:?Falta valor para --db}"
      shift 2
      ;;
    --storage-root)
      STORAGE_ROOT_PATH="${2:?Falta valor para --storage-root}"
      shift 2
      ;;
    --media)
      MEDIA_PATH="${2:?Falta valor para --media}"
      shift 2
      ;;
    --app-user)
      APP_USER="${2:?Falta valor para --app-user}"
      shift 2
      ;;
    --db-user)
      DB_USER="${2:?Falta valor para --db-user}"
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

[[ -n "$CONFIG_PATH" ]] || { echo 'ERROR: falta --config' >&2; usage >&2; exit 2; }
[[ -n "$DATA_PATH" ]] || { echo 'ERROR: falta --data' >&2; usage >&2; exit 2; }
[[ -n "$DB_PATH" ]] || { echo 'ERROR: falta --db' >&2; usage >&2; exit 2; }
[[ -n "$STORAGE_ROOT_PATH" ]] || { echo 'ERROR: falta --storage-root' >&2; usage >&2; exit 2; }

for u in "$APP_USER" "$DB_USER"; do
  id -u "$u" >/dev/null 2>&1 || { echo "ERROR: usuario inexistente: $u" >&2; exit 1; }
done

for p in "$CONFIG_PATH" "$DATA_PATH" "$DB_PATH" "$STORAGE_ROOT_PATH"; do
  require_dir "$p"
done
if [[ -n "$MEDIA_PATH" ]]; then
  require_dir "$MEDIA_PATH"
fi

echo '== Docker =='
docker_cmd version >/dev/null
echo 'OK docker'

echo '== Compose =='
docker_cmd compose version

echo '== Paths =='
for p in "$CONFIG_PATH" "$DATA_PATH" "$DB_PATH" "$STORAGE_ROOT_PATH"; do
  stat_out="$(stat -c '%U:%G %a %n' "$p")"
  echo "OK $stat_out"
done
if [[ -n "$MEDIA_PATH" ]]; then
  stat_out="$(stat -c '%U:%G %a %n' "$MEDIA_PATH")"
  echo "OK $stat_out"
fi

echo '== Permisos app =='
check_write_dir "$APP_USER" "$CONFIG_PATH"
echo "OK escritura config ($APP_USER)"
check_write_dir "$APP_USER" "$DATA_PATH"
echo "OK escritura data ($APP_USER)"
check_read_dir "$APP_USER" "$STORAGE_ROOT_PATH"
echo "OK lectura storage-root ($APP_USER)"
if [[ -n "$MEDIA_PATH" ]]; then
  check_read_dir "$APP_USER" "$MEDIA_PATH"
  echo "OK lectura media ($APP_USER)"
fi

echo '== Permisos DB =='
check_write_dir "$DB_USER" "$DB_PATH"
echo "OK escritura db ($DB_USER)"

echo 'OK precheck nextcloud'
