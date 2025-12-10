#!/usr/bin/env bash
set -euo pipefail

# ==============================
# Comprobación de permisos
# ==============================

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  echo "Este script debe ejecutarse como root (usa sudo)." >&2
  exit 1
fi

# ==============================
# Configuración
# ==============================

# Archivo JSON de salida que leerá el portal
OUT="/srv/storage/services/portal/data/apps-usage.json"

# Directorios que queremos medir.
# AJUSTÁ ESTO a tu realidad si hace falta.
declare -A PATHS=(
  # Pelis/series de Jellyfin (ajusta si usás otra ruta)
  [jellyfin]="/srv/storage/media/N_normal/peliculas"

  # Biblioteca de fotos de Immich (ajusta si usás otra ruta)
  [immich]="/srv/storage/media/C_critico/Immich"

  # Datos de usuarios de Nextcloud
  [nextcloud]="/srv/storage/nextcloud/data"
)

# ==============================
# Lógica
# ==============================

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

# Forzamos formato numérico con punto decimal
export LC_ALL=C

{
  echo '{'
  echo '  "apps": {'

  first=1
  for app in "${!PATHS[@]}"; do
    path="${PATHS[$app]}"

    if [[ -d "$path" ]]; then
      # Tamaño en bytes del directorio
      size_bytes="$(du -sb "$path" | awk '{print $1}')"
    else
      size_bytes=0
    fi

    # GiB con una cifra decimal
    size_gib="$(awk -v b="$size_bytes" 'BEGIN { printf "%.1f", b/1024/1024/1024 }')"

    if (( first == 0 )); then
      echo ','
    fi
    first=0

    printf '    "%s": { "bytes": %s, "gib": %s }' \
      "$app" "$size_bytes" "$size_gib"
  done

  echo
  echo '  }'
  echo '}'
} > "$tmp"

# Movimiento atómico para no dejar archivos a medio escribir
mv "$tmp" "$OUT"

# Permisos: legible por cualquiera (el contenedor, el usuario alejandro, etc.)
chmod 644 "$OUT"
