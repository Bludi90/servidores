#!/usr/bin/env bash
set -euo pipefail

link_path="comandos/${base}"
CMD_DIR="docs/comandos"
OUT="docs/COMANDOS.md"

# Comprobar que existe el directorio de comandos
if [ ! -d "$CMD_DIR" ]; then
  echo "ERROR: No existe \$CMD_DIR: $CMD_DIR" >&2
  exit 1
fi

{
  echo "# Comandos y scripts (resumen)"
  echo
  echo "_Generado: $(date '+%F %H:%M')_"
  echo
  echo "Este documento es un **índice** para consulta rápida. Las guías completas están enlazadas."
  echo
  echo "## Índice"
  echo

  # Índice
  for f in "$CMD_DIR"/*.md; do
    [ -e "$f" ] || continue
    base="$(basename "$f")"
    title="$(grep -m1 '^# ' "$f" | sed 's/^# //')"
    [ -z "$title" ] && title="$base"
    echo "- [${title}](${link_path})"
  done

  echo

  # Secciones resumen
  for f in "$CMD_DIR"/*.md; do
    [ -e "$f" ] || continue
    base="$(basename "$f")"
    title="$(grep -m1 '^# ' "$f" | sed 's/^# //')"
    [ -z "$title" ] && title="$base"

    echo "## ${title}"
    echo

    # Resumen: líneas entre el primer encabezado y la primera línea en blanco
    awk '
      /^# / {in_header=1; next}
      in_header && NF==0 {exit}
      in_header {print}
    ' "$f"

    echo
    echo "[→ Abrir guía completa](${link_path})"
    echo
  done
} > "$OUT"
