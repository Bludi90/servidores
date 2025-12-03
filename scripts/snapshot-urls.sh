#!/usr/bin/env bash
set -euo pipefail

# Directorio del repo (scripts/ → repo raíz)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOSTNAME="$(hostname -s)"

DATA_FILE="$REPO_DIR/common/urls-proxy.tsv"
OUT_DIR="$REPO_DIR/state/$HOSTNAME"
OUT_FILE="$OUT_DIR/urls-proxy.md"

mkdir -p "$OUT_DIR"

if [[ ! -f "$DATA_FILE" ]]; then
  echo "ERROR: no encuentro el fichero de URLs: $DATA_FILE" >&2
  exit 1
fi

{
  echo "# URLs internas del reverse proxy – $HOSTNAME"
  echo
  echo "_Generado automáticamente por $(basename "$0") el $(date '+%Y-%m-%d %H:%M:%S')_"
  echo
  echo "| ID | Host | URL externa | Backend | Contenedor | Estado | Descripción |"
  echo "|----|------|------------|---------|------------|--------|-------------|"

  # Saltamos la cabecera y procesamos solo servicios activos
  tail -n +2 "$DATA_FILE" | while IFS=$'\t' read -r ID HOST URL BACKEND CONTAINER STATUS DESC; do
    case "$STATUS" in
      on|ON|enabled|ENABLED|1|true|TRUE)
        printf "| %s | %s | %s | %s | %s | %s | %s |\n" \
          "$ID" "$HOST" "$URL" "$BACKEND" "$CONTAINER" "$STATUS" "$DESC"
        ;;
      *)
        # ignoramos servicios apagados/planificados
        :
        ;;
    esac
  done
} > "${OUT_FILE}.tmp"

mv "${OUT_FILE}.tmp" "$OUT_FILE"
