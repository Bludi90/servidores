#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
OUT="$ROOT/docs/COMANDOS.md"
WG="$ROOT/docs/WIREGUARD.md"
WOL="$ROOT/docs/WOL.md"
H="$ROOT/scripts/help.d"

stamp(){ date +%F\ %H:%M; }
exists(){ command -v "$1" >/dev/null 2>&1; }

mkdir -p "$ROOT/docs"

# =========================
# WIREGUARD.md (ya existía)
# =========================
{
  echo "# WireGuard — Cheatsheet"
  echo; echo "_Generado: $(stamp)_"; echo
  [ -r "$H/wireguard/_index.help" ] && sed 's/^/    /' "$H/wireguard/_index.help" && echo

  echo "## list-peers"; echo
  if exists wg-list-peers; then
    echo "_Disponible: Sí (\`$(command -v wg-list-peers)\`)_" ; echo
  else
    echo "_Disponible: No en este host_" ; echo
  fi
  [ -r "$H/wireguard/list-peers.help" ] && sed 's/^/    /' "$H/wireguard/list-peers.help"; echo

  for s in add-peer del-peer repair; do
    echo "## $s"; echo
    bin="wg-$s"
    if exists "$bin"; then
      echo "_Disponible: Sí (\`$(command -v $bin)\`)_" ; echo
    else
      echo "_Disponible: No en este host_" ; echo
    fi
    [ -r "$H/wireguard/$s.help" ] && sed 's/^/    /' "$H/wireguard/$s.help"; echo
  done
} > "$WG"

# =================
# WOL.md (NUEVO)
# =================
{
  echo "# Wake-on-LAN — Cheatsheet"
  echo; echo "_Generado: $(stamp)_"; echo
  [ -r "$H/wol/_index.help" ] && sed 's/^/    /' "$H/wol/_index.help" && echo

  for s in wolctl wol; do
    echo "## $s"; echo
    if exists "$s"; then
      echo "_Disponible: Sí (\`$(command -v $s)\`)_" ; echo
    else
      echo "_Disponible: No en este host_" ; echo
    fi
    [ -r "$H/wol/$s.help" ] && sed 's/^/    /' "$H/wol/$s.help"; echo
  done
} > "$WOL"

# =================
# COMANDOS.md
# =================
{
  echo "# Comandos personalizados"
  echo; echo "_Generado: $(stamp)_"; echo
  echo "- **Cheatsheet WireGuard:** [WIREGUARD.md](WIREGUARD.md)"
  echo "- **Cheatsheet WOL:** [WOL.md](WOL.md)"
  echo

  # Bloques de ayuda de primer nivel
  for f in $(ls "$H"/*.help 2>/dev/null | sort -f); do
    name="$(basename "$f" .help)"
    echo "## $name"; echo
    sed 's/^/    /' "$f"; echo
  done

  # Resumen rápido (tabla)
  echo "## Resumen rápido"; echo
  echo "| Comando | Para qué sirve |"; echo "|---|---|"
  echo "| \`wg-list-peers\` | Lista peers con nombre, IP/32, HS(min), RX/TX |"
  $(command -v wolctl >/dev/null 2>&1 && echo 'echo "| \`wolctl\` | Gestión WOL (list/show/wake/check/add/set/rename/rm) |"') || true
  $(command -v wol >/dev/null 2>&1 && echo 'echo "| \`wol\` | Atajo de \`wolctl wake\` |"') || true
  $(command -v lan-scan >/dev/null 2>&1 && echo 'echo "| \`lan-scan\` | Descubre IP/MAC/Vendor en la LAN |"') || true
} > "$OUT"

echo "[OK] Generados: $WG, $WOL y $OUT"
