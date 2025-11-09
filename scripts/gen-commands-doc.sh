#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
OUT="$ROOT/docs/COMANDOS.md"
WG="$ROOT/docs/WIREGUARD.md"
H="$ROOT/scripts/help.d"

stamp(){ date +%F\ %H:%M; }

# WIREGUARD.md
{
  echo "# WireGuard — Cheatsheet"
  echo; echo "_Generado: $(stamp)_"; echo
  if [ -r "$H/wireguard/_index.help" ]; then
    sed 's/^/    /' "$H/wireguard/_index.help"; echo
  fi
  for f in $(ls "$H/wireguard/"*.help 2>/dev/null | grep -v '/_index.help' | sort); do
    name="$(basename "$f" .help)"
    echo "## $name"; echo
    sed 's/^/    /' "$f"; echo
  done
} > "$WG"

# COMANDOS.md (comandos sueltos + enlace a WG)
{
  echo "# Comandos personalizados"
  echo; echo "_Generado: $(stamp)_"; echo
  echo "- **Cheatsheet WireGuard:** [docs/WIREGUARD.md](WIREGUARD.md)"
  echo
  # comandos sueltos (no categorizados)
  for f in $(ls "$H"/*.help 2>/dev/null | sort); do
    name="$(basename "$f" .help)"
    echo "## $name"; echo
    sed 's/^/    /' "$f"; echo
  done
  echo "## Resumen rápido"; echo
  echo "| Comando | Para qué sirve |"; echo "|---|---|"
  for f in $(ls "$H"/*.help 2>/dev/null | sort); do
    name="$(basename "$f" .help)"
    desc="$(head -n 2 "$f" | tail -n 1 | sed 's/^[[:space:]]*//')"
    echo "| \`$name\` | $desc |"
  done
} > "$OUT"
