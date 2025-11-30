#!/usr/bin/env bash
set -euo pipefail

# import-peli.sh
# Importa una película a la biblioteca de Jellyfin siguiendo:
#   DESTINO_BASE/TITULO (ANIO)/TITULO (ANIO).ext
#
# Ejemplo:
#   import-peli.sh \
#     -s "/media/devmon/WD4TB/Vuze downloads/Se7en (1995)" \
#     -d "/srv/storage/media/N_normal/peliculas" \
#     -t "Se7en" \
#     -y 1995

show_help() {
  cat <<EOF
Uso: $(basename "$0") -s ORIGEN -d DESTINO_BASE -t TITULO -y ANIO

Importa una película a la biblioteca de Jellyfin siguiendo el esquema:
  DESTINO_BASE/TITULO (ANIO)/TITULO (ANIO).ext

Parámetros:
  -s ORIGEN        Ruta de origen (archivo o carpeta) en el disco externo.
  -d DESTINO_BASE  Carpeta base de destino (ej. /srv/storage/media/N_normal/peliculas).
  -t TITULO        Título de la película (sin año).
  -y ANIO          Año (4 dígitos).

Opciones:
  -h               Mostrar esta ayuda y salir.

Notas:
  - Si ORIGEN es una carpeta, se copiará TODO su contenido dentro de la carpeta de la película.
  - El script intentará localizar el archivo de vídeo principal y renombrarlo a "TITULO (ANIO).ext".
  - También intentará mover y renombrar subtítulos (.srt, .ass, .sub, .vtt) si están junto al vídeo.
EOF
}

SRC=""
DEST_BASE=""
TITLE=""
YEAR=""

while getopts ":s:d:t:y:h" opt; do
  case "$opt" in
    s) SRC="$OPTARG" ;;
    d) DEST_BASE="$OPTARG" ;;
    t) TITLE="$OPTARG" ;;
    y) YEAR="$OPTARG" ;;
    h)
      show_help
      exit 0
      ;;
    \?)
      echo "Opción inválida: -$OPTARG" >&2
      show_help >&2
      exit 1
      ;;
    :)
      echo "La opción -$OPTARG requiere un valor." >&2
      show_help >&2
      exit 1
      ;;
  esac
done

if [[ -z "${SRC}" || -z "${DEST_BASE}" || -z "${TITLE}" || -z "${YEAR}" ]]; then
  echo "Faltan parámetros obligatorios." >&2
  show_help >&2
  exit 1
fi

if [[ ! -e "$SRC" ]]; then
  echo "El origen '$SRC' no existe." >&2
  exit 1
fi

if [[ ! -d "$DEST_BASE" ]]; then
  echo "La carpeta base de destino '$DEST_BASE' no existe." >&2
  exit 1
fi

# Normalizar ruta (quitar barra final si la hay)
SRC="${SRC%/}"

MOVIE_DIR_NAME="${TITLE} (${YEAR})"
DEST_DIR="${DEST_BASE%/}/${MOVIE_DIR_NAME}"

echo ">>> Origen:       $SRC"
echo ">>> Destino base: $DEST_BASE"
echo ">>> Carpeta peli: $DEST_DIR"

mkdir -p "$DEST_DIR"

echo ">>> Copiando archivos..."
if [[ -d "$SRC" ]]; then
  # Si es carpeta, copia SOLO el contenido (sin crear doble nivel)
  rsync -avh --info=progress2 "$SRC"/ "$DEST_DIR"/
else
  # Si es archivo suelto
  rsync -avh --info=progress2 "$SRC" "$DEST_DIR"/
fi

echo ">>> Buscando archivo de vídeo principal..."
mapfile -t VIDEO_FILES < <(find "$DEST_DIR" -type f \( \
  -iname '*.mkv' -o -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mov' -o -iname '*.m4v' \
\))

if (( ${#VIDEO_FILES[@]} == 0 )); then
  echo "ERROR: No se encontraron archivos de vídeo en '$DEST_DIR'." >&2
  exit 1
fi

SELECTED_VIDEO=""

if (( ${#VIDEO_FILES[@]} == 1 )); then
  SELECTED_VIDEO="${VIDEO_FILES[0]}"
  echo ">>> Se encontró un único vídeo:"
  echo "    $SELECTED_VIDEO"
else
  echo "Se encontraron varios vídeos. Elige uno:"
  i=1
  for vf in "${VIDEO_FILES[@]}"; do
    size=$(du -h "$vf" | cut -f1)
    printf "  [%d] %s (%s)\n" "$i" "$vf" "$size"
    ((i++))
  done
  read -rp "Número de vídeo principal: " choice
  if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#VIDEO_FILES[@]} )); then
    echo "Selección inválida." >&2
    exit 1
  fi
  SELECTED_VIDEO="${VIDEO_FILES[choice-1]}"
fi

VIDEO_EXT="${SELECTED_VIDEO##*.}"
TARGET_VIDEO_PATH="${DEST_DIR}/${MOVIE_DIR_NAME}.${VIDEO_EXT}"

# Mover vídeo al raíz de la carpeta de la peli con el nombre estándar
if [[ "$SELECTED_VIDEO" != "$TARGET_VIDEO_PATH" ]]; then
  echo ">>> Moviendo vídeo a:"
  echo "    $TARGET_VIDEO_PATH"
  mv "$SELECTED_VIDEO" "$TARGET_VIDEO_PATH"
fi

# Subtítulos junto al vídeo original
VIDEO_DIR_OLD="$(dirname "$SELECTED_VIDEO")"
if [[ -d "$VIDEO_DIR_OLD" ]]; then
  echo ">>> Buscando subtítulos junto al vídeo original..."
  mapfile -t SUB_FILES < <(find "$VIDEO_DIR_OLD" -maxdepth 1 -type f \( \
    -iname '*.srt' -o -iname '*.ass' -o -iname '*.ssa' -o -iname '*.sub' -o -iname '*.vtt' \
  \))

  for sf in "${SUB_FILES[@]}"; do
    SUB_EXT="${sf##*.}"
    TARGET_SUB="${DEST_DIR}/${MOVIE_DIR_NAME}.${SUB_EXT}"
    echo "    Moviendo subtítulo:"
    echo "      $sf -> $TARGET_SUB"
    mv "$sf" "$TARGET_SUB"
  done
fi

# Mover vídeos extra fuera de la biblioteca (para que Jellyfin no los vea)
if (( ${#VIDEO_FILES[@]} > 1 )); then
  echo ">>> Moviendo vídeos extra a carpeta de extras..."
  EXTRAS_BASE="${DEST_BASE%/}/peliculas_extras"
  mkdir -p "$EXTRAS_BASE"

  for vf in "${VIDEO_FILES[@]}"; do
    # Saltar el vídeo principal (ruta vieja y ruta nueva)
    if [[ "$vf" == "$SELECTED_VIDEO" ]] || [[ "$vf" == "$TARGET_VIDEO_PATH" ]]; then
      continue
    fi
    echo "    Extra: $vf -> $EXTRAS_BASE/"
    mv "$vf" "$EXTRAS_BASE"/
  done
fi

echo ">>> Limpiando directorios vacíos dentro de la carpeta de la película..."
find "$DEST_DIR" -type d -empty -mindepth 1 -delete

# Ajustar propietario y permisos (adaptado a tu entorno)
DEST_USER="alejandro"
DEST_GROUP="alejandro"

echo ">>> Ajustando propietario y permisos..."
sudo chown -R "${DEST_USER}:${DEST_GROUP}" "$DEST_DIR"
sudo find "$DEST_DIR" -type d -exec chmod 770 {} \;
sudo find "$DEST_DIR" -type f -exec chmod 660 {} \;

echo ">>> Importación completada."
echo "Película importada en: $DEST_DIR"
