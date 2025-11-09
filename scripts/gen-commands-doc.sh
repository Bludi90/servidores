#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
OUT="$ROOT/docs/COMANDOS.md"
DIR="$ROOT/docs/comandos"

stamp() { date +%F' '%H:%M; }

# Devuelve el título (# ...) o el nombre de archivo si no hay título
title_of() {
  awk 'NR==1 && /^# /{sub(/^# /,""); print; exit}' "$1"
}

# Devuelve el primer párrafo descriptivo (salta título, línea _Generado:, y bloques de código)
first_para() {
  awk '
    NR==1 && /^# / {next}
    NR==2 && /^_Generado:/ {next}
    /^```/ {code = !code; next}
    code {next}
    /^#/ {next}
    # ignora líneas vacías iniciales y metadatos/itálicas
    /^[[:space:]]*$/ && !seen {next}
    /^_/ && !seen {next}
    { seen=1; buf = (buf?buf" " : "") $0 }
    END{ print buf }
  ' "$1"
}

# Construye el índice a partir de DIR/*.md
mapfile -t DOCS < <(ls "$DIR"/*.md 2>/dev/null | sort || true)

# Mensaje si no hay docs
if [ ${#DOCS[@]} -eq 0 ]; then
  mkdir -p "$ROOT/docs"
  {
    echo "# Comandos personalizados"
    echo
    echo "_Generado: $(stamp)_"
    echo
    echo "No se encontraron guías en **docs/comandos/**."
  } > "$OUT"
  echo "OK: $OUT (sin guías aún)"
  exit 0
fi

# Generar COMANDOS.md
{
  echo "# Comandos personalizados"
  echo
  echo "_Generado: $(stamp)_"
  echo
  echo "Este documento es un **índice**. Las guías completas viven en **docs/comandos/**."
  echo

  # Índice simple
  echo "## Índice de guías"
  echo
  for f in "${DOCS[@]}"; do
    t="$(title_of "$f")"
    [ -z "$t" ] && t="$(basename "$f" .md)"
    echo "- [$t](comandos/$(basename "$f"))"
  done
  echo

  # Secciones breves (una por guía)
  for f in "${DOCS[@]}"; do
    bn="$(basename "$f")"
    key="$(basename "$f" .md)"
    t="$(title_of "$f")"; [ -z "$t" ] && t="$key"
    echo "## $t"
    echo
    desc="$(first_para "$f")"
    [ -n "$desc" ] && echo "    $desc" && echo

    # WireGuard: mostrar subcomandos si aparecen (bloque 'Subcomandos:' o cabeceras ##)
    if [[ "$key" == "wireguard" || "$t" =~ [Ww]ire[Gg]uard || "$t" == "wg" ]]; then
      subs="$(awk '
        BEGIN{cap=0}
        /^Subcomandos:/ {cap=1; next}
        cap && NF==0 {cap=0}
        cap { s=$0; sub(/^[-*[:space:]]+/, "", s); sub(/→.*/, "", s); if(length(s)) print s }
      ' "$f")"
      if [ -n "$subs" ]; then
        echo "Subcomandos:"
        echo
        while IFS= read -r s; do echo "- $s"; done <<< "$subs"
        echo
      else
        subs2="$(awk '/^##[[:space:]]+/ {sub(/^##[[:space:]]+/, ""); print}' "$f")"
        if [ -n "$subs2" ]; then
          echo "Subcomandos:"
          echo
          while IFS= read -r s; do echo "- $s"; done <<< "$subs2"
          echo
        fi
      fi
    fi

    echo "[→ Abrir guía completa](comandos/$bn)"
    echo
  done

  # Tabla resumen
  echo "## Resumen rápido"
  echo
  echo "| Comando | Para qué sirve | Guía |"
  echo "|---|---|---|"
  for f in "${DOCS[@]}"; do
    key="$(basename "$f" .md)"
    cmd="$key"; [ "$key" = "wireguard" ] && cmd="wg"
    d="$(first_para "$f")"; d="${d//|/\\|}"
    echo "| \`$cmd\` | ${d:-Guía de $cmd} | [Abrir](comandos/$(basename "$f")) |"
  done
} > "$OUT"

echo "OK: generado $OUT desde $DIR"
