#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
OUT="$ROOT/docs/COMANDOS.md"
WG="$ROOT/docs/WIREGUARD.md"
H="$ROOT/scripts/help.d"
stamp(){ date +%F\ %H:%M; }
exists(){ command -v "$1" >/dev/null 2>&1; }

mkdir -p "$ROOT/docs"

# WIREGUARD.md
{
  echo "# WireGuard — Cheatsheet"; echo; echo "_Generado: $(stamp)_"; echo
  [ -r "$H/wireguard/_index.help" ] && sed 's/^/    /' "$H/wireguard/_index.help" && echo
  echo "## list-peers"; echo
  if exists wg-list-peers; then echo "_Disponible: Sí (\`$(command -v wg-list-peers)\`)_" ; else echo "_Disponible: No en este host_"; fi
  [ -r "$H/wireguard/list-peers.help" ] && sed 's/^/    /' "$H/wireguard/list-peers.help" && echo
  for s in add-peer del-peer repair; do
    echo "## $s"; echo
    bin="wg-$s"; if exists "$bin"; then echo "_Disponible: Sí (\`$(command -v $bin)\`)_" ; else echo "_Disponible: No en este host_"; fi
    [ -r "$H/wireguard/$s.help" ] && sed 's/^/    /' "$H/wireguard/$s.help" && echo
  done
} > "$WG"

# COMANDOS.md
{
  echo "# Comandos personalizados"; echo; echo "_Generado: $(stamp)_"; echo
  echo "- **Cheatsheet WireGuard:** [WIREGUARD.md](WIREGUARD.md)"; echo
  echo "- **Guía LAN Scan:** [LANSCAN.md](LANSCAN.md)"; echo
  for f in $(ls "$H"/*.help 2>/dev/null | sort); do
    name="$(basename "$f" .help)"; echo "## $name"; echo; sed 's/^/    /' "$f"; echo
  done
  echo "## Resumen rápido"; echo
  echo "| Comando | Para qué sirve |"; echo "|---|---|"
  echo "| \`wg-list-peers\` | Lista peers con nombre, IP/32, HS(min), RX/TX |"
} > "$OUT"
