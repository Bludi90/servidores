#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
OUT="$ROOT/docs/COMANDOS.md"

# 1) Fuente de guías: docs/comandos/*.md + guías sueltas conocidas
collect_guides() {
  local f
  # docs/comandos/*.md
  for f in "$ROOT"/docs/comandos/*.md; do
    [ -f "$f" ] && echo "$f"
  done
  # guías sueltas (añade aquí más si quieres)
  [ -f "$ROOT/docs/LANSCAN.md" ]   && echo "$ROOT/docs/LANSCAN.md"
  [ -f "$ROOT/docs/WIREGUARD.md" ] && echo "$ROOT/docs/WIREGUARD.md"
}

stamp()   { date +%F' '%H:%M; }
relpath() { python3 - "$ROOT" "$1" <<'PY'
import os,sys
print(os.path.relpath(sys.argv[2], start=sys.argv[1]))
PY
}

title_of() {
  awk 'NR==1 && /^# /{sub(/^# /,""); print; exit}' "$1"
}

# Primer bloque descriptivo (respeta saltos y evita compactar a una línea)
first_block() {
  awk '
    BEGIN{code=0; started=0}
    NR==1 && /^# / {next}
    NR==2 && /^_Generado:/ {next}
    /^```/ {code=!code; next}
    code {next}
    /^#/ { if(started) exit; next }    # si aparece otra cabecera, paramos si ya empezamos
    /^[[:space:]]*$/ && !started {next}
    { started=1; print "    " $0 }
    /^[[:space:]]*$/ && started {exit}
  ' "$1"
}

# Extrae la PRIMERA lista de viñetas que siga a una cabecera con estas palabras
bullet_list_from() {
  awk '
    BEGIN{code=0;cap=0;printed=0}
    /^```/ {code=!code; next}
    code {next}
    # activar captura cuando aparezca cabecera relevante
    tolower($0) ~ /^##[[:space:]]*(modos|flags|opciones|subcomandos|atajos|uso rápido)/ {cap=1; next}
    # si llega otra cabecera y ya imprimimos algo, terminamos
    cap && /^##[[:space:]]/ && printed {exit}
    cap {
      if ($0 ~ /^[ \t]*[-*][ \t]+/) { print "    " $0; printed=1; next }
      if (printed && $0 ~ /^[[:space:]]*$/) { exit }   # fin de la lista
      next
    }
  ' "$1"
}

exists(){ command -v "$1" >/dev/null 2>&1; }

is_active(){
  key="$1"
  case "$key" in
    lan-scan)         exists lan-scan ;;
    wol|wolctl|hib|lan2wol) exists wolctl || exists wol || exists hib || exists lan2wol ;;
    wireguard|wg)     exists wg-list-peers || exists wg || [ -r /etc/wireguard/wg0.conf ] ;;
    commit-and-push)  [ -x "$ROOT/scripts/commit-and-push.sh" ] ;;
    snapshot-state)   [ -x "$ROOT/scripts/snapshot-state.sh" ] ;;
    build-index)      [ -x "$ROOT/scripts/build-index.sh" ] ;;
    housekeeping)     [ -x "$ROOT/scripts/housekeeping.sh" ] ;;
    *)                exists "$key" ;;
  esac
}

mapfile -t DOCS < <(collect_guides | sort)

mkdir -p "$ROOT/docs"

# Si no hay guías
if [ ${#DOCS[@]} -eq 0 ]; then
  {
    echo "# Comandos y scripts"
    echo
    echo "_Generado: $(stamp)_"
    echo
    echo "No se encontraron guías."
  } > "$OUT"
  echo "OK: $OUT (sin guías)"; exit 0
fi

{
  echo "# Comandos y scripts (resumen)"
  echo
  echo "_Generado: $(stamp)_"
  echo
  echo "Este documento es un **índice** para consulta rápida. Las guías completas están enlazadas."
  echo

  echo "## Índice"
  echo
  for f in "${DOCS[@]}"; do
    t="$(title_of "$f")"; [ -z "$t" ] && t="$(basename "$f" .md)"
    r="$(relpath "$ROOT/docs" "$f")"
    echo "- [$t]($r)"
  done
  echo

  # Sección por guía
  for f in "${DOCS[@]}"; do
    bn="$(basename "$f")"
    key="$(basename "$f" .md)"
    t="$(title_of "$f")"; [ -z "$t" ] && t="$key"
    r="$(relpath "$ROOT/docs" "$f")"

    echo "## $t"
    echo
    fb="$(first_block "$f")"
    [ -n "$fb" ] && echo "$fb" && echo

    bl="$(bullet_list_from "$f")"
    if [ -n "$bl" ]; then
      echo "**Opciones y subcomandos principales**"
      echo
      echo "$bl"
      echo
    fi

    echo "[→ Abrir guía completa]($r)"
    echo
  done

  # Tabla resumen
  echo "## Resumen rápido"
  echo
  echo "| Comando/Script | Para qué sirve | Guía | Activo |"
  echo "|---|---|---|:--:|"
  for f in "${DOCS[@]}"; do
    key="$(basename "$f" .md)"
    t="$(title_of "$f")"; [ -z "$t" ] && t="$key"
    r="$(relpath "$ROOT/docs" "$f")"
    # primera línea del bloque como descripción corta
    desc="$(first_block "$f" | sed -n 's/^    //p' | head -n1)"
    [ -z "$desc" ] && desc="Guía de $t"
    cmd="$key"; [ "$key" = "wireguard" ] && cmd="wg"
    active="No"; is_active "$key" && active="Sí"
    # escapar barras verticales
    desc="${desc//|/\\|}"
    echo "| \`$cmd\` | $desc | [Abrir]($r) | $active |"
  done
} > "$OUT"

echo "OK: generado $OUT"
