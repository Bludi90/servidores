#!/usr/bin/env bash
set -euo pipefail

# === Configuración ===
BACKUP_DIR="/srv/storage/nextcloud/db_dumps"
LOG_FILE="/var/log/nextcloud_backup_db.log"
MYSQL_CNF="/root/.config/nextcloud-mariadb.cnf"
DB_NAME="nextcloud"          # cámbialo si tu DB se llama distinto
RETENTION_DAYS=30            # dumps más antiguos se borran
HOSTNAME_TAG="$(hostname -s)"

timestamp() {
  date '+%Y-%m-%d %H:%M:%S'
}

log() {
  echo "[$(timestamp)] $*" | tee -a "$LOG_FILE"
}

# === Comprobaciones previas ===
mkdir -p "$BACKUP_DIR"

if [ ! -f "$MYSQL_CNF" ]; then
  log "ERROR: No existe el fichero de credenciales $MYSQL_CNF"
  exit 1
fi

# === Generar nombre de dump ===
DATE_TAG="$(date +%Y%m%d-%H%M%S)"
DUMP_FILE="$BACKUP_DIR/nextcloud-db-${HOSTNAME_TAG}-${DATE_TAG}.sql.gz"

log "=== Inicio backup DB Nextcloud (${DB_NAME}) ==="
log "Destino: $DUMP_FILE"

# === Ejecutar mysqldump + gzip ===
# Importante: --defaults-extra-file DEBE ir primero
if mysqldump --defaults-extra-file="$MYSQL_CNF" \
             --single-transaction --quick --lock-tables=false \
             "$DB_NAME" | gzip > "$DUMP_FILE"; then
  log "Dump creado correctamente."
else
  log "ERROR: fallo al crear el dump de la base de datos."
  rm -f "$DUMP_FILE"
  exit 1
fi

# === Aplicar retención ===
log "Aplicando retención: borrar dumps con más de ${RETENTION_DAYS} días..."
find "$BACKUP_DIR" -name 'nextcloud-db-*.sql.gz' -type f -mtime "+$RETENTION_DAYS" -print -delete \
  >> "$LOG_FILE" 2>&1 || true

log "=== Fin backup DB Nextcloud ==="
