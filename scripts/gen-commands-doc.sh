#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
OUT="$ROOT/docs/COMANDOS.md"
DIR="$ROOT/docs/comandos"

stamp() { date +%F' '%H:%M; }
exists(){ command -v "$1" >/dev/null 2>&1; }

title_of() { awk 'NR==1 && /^# /{sub(/^# /,""); print; exit}' "$1"; }

first_para() {
  awk '
    NR==1 && /^# / {next}
    NR==2 && /^_Generado:/ {next}
    /^```/ {code = !code; next}
    code {next}
    /^#/ {next}
    /^[[:space:]]*$/ && !seen {next}
    /^_/ && !seen {next}
    { seen=1; buf = (buf?buf" " : "") $0 }
    END{ print buf }
  ' "$1"
}

is_active(){
  key="$1"
  case "$key" in
    lan-scan)         exists lan-scan ;;
    wol)              exists wolctl || exists wol || exists hib || exists lan2wol ;;
    wireguard)        exists wg-list-peers || exists wg || [ -r /etc/wireguard/wg0.conf ] ;;
    commit-and-push)  [ -x "$ROOT/scripts/commit-and-push.sh" ] ;;
    snapshot-state)   [ -x "$ROOT/scripts/snapshot-state.sh" ] ;;
    build-index)      [ -x "$ROOT/scripts/build-index.sh" ] ;;
    housekeeping)     [ -x "$ROOT/scripts/housekeeping.sh" ] ;;
    *)                exists "$key" ;;
  esac
}

mapfile -t DOCS < <(ls "$DIR"/*.md 2>/dev/null | sort || true)

mkdir -p "$ROOT/docs"

if [ ${#DOCS[@]} -eq 0 ]; then
  {
    echo "# Comandos y scripts"
    echo
    echo "_Generado: $(stamp)_"
    echo
    echo "No se encontraron guías en **docs/comandos/**."
  } > "$OUT"
  echo "OK: $OUT (sin guías aún)"; exit 0
fi

{
  echo "# Comandos y scripts (resumen)"
  echo
  echo "_Generado: $(stamp)_"
  echo
  echo "Este documento es un **índice**. Las guías completas viven en **docs/comandos/**."
  echo

  echo "## Índice de guías"
  echo
  for f in "${DOCS[@]}"; do
    t="$(title_of "$f")"; [ -z "$t" ] && t="$(basename "$f" .md)"
    echo "- [$t](comandos/$(basename "$f"))"
  done
  echo

  for f in "${DOCS[@]}"; do
    bn="$(basename "$f")"
    key="$(basename "$f" .md)"
    t="$(title_of "$f")"; [ -z "$t" ] && t="$key"
    echo "## $t"
    echo
    desc="$(first_para "$f")"; [ -n "$desc" ] && echo "    $desc" && echo
    if [[ "$key" == "wireguard" ]]; then
      subs="$(awk '
        BEGIN{cap=0}
        /^Subcomandos:/ {cap=1; next}
        cap && NF==0 {cap=0}
        cap { s=$0; sub(/^[-*[:space:]]+/, "", s); if(length(s)) print s }
      ' "$f")"
      if [ -n "$subs" ]; then
        echo "Subcomandos:"; echo
        while IFS= read -r s; do echo "- $s"; done <<< "$subs"
        echo
      fi
    fi
    echo "[→ Abrir guía completa](comandos/$bn)"
    echo
  done

  echo "## Resumen rápido"
  echo
  echo "| Comando/Script | Para qué sirve | Guía | Activo |"
  echo "|---|---|---|:--:|"
  for f in "${DOCS[@]}"; do
    key="$(basename "$f" .md)"
    cmd="$key"; [ "$key" = "wireguard" ] && cmd="wg"
    d="$(first_para "$f")"; d="${d//|/\\|}"
    active="No"; is_active "$key" && active="Sí"
    echo "| \`$cmd\` | ${d:-Guía de $cmd} | [Abrir](comandos/$(basename "$f")) | $active |"
  done
} > "$OUT"

echo "OK: generado $OUT desde $DIR"
