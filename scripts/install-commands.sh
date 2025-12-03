#!/usr/bin/env bash
set -euo pipefail

# Directorio raíz del repo (scripts/ → repo)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

BIN_DIR="/usr/local/bin"
SBIN_DIR="/usr/local/sbin"

echo "Instalando comandos desde $REPO_DIR"
echo "  BIN  -> $BIN_DIR"
echo "  SBIN -> $SBIN_DIR"

mkdir -p "$BIN_DIR" "$SBIN_DIR"

# 1) scripts/cmd → /usr/local/bin (comandos normales)
if [[ -d "$REPO_DIR/scripts/cmd" ]]; then
  for f in "$REPO_DIR"/scripts/cmd/*; do
    [[ -f "$f" && -x "$f" ]] || continue
    cmd="$(basename "$f")"
    target="$BIN_DIR/$cmd"
    if [[ -L "$target" || -f "$target" ]]; then
      echo "  [*] Reemplazando $target"
      rm -f "$target"
    fi
    ln -s "$f" "$target"
    echo "  [+] $cmd -> $target"
  done
fi

# 2) Algunos scripts "de sistema" en /usr/local/sbin (si existen)
for name in srv-health-weekly smart-weekly-report; do
  f="$REPO_DIR/scripts/$name"
  if [[ -f "$f" && -x "$f" ]]; then
    cmd="$name"
    target="$SBIN_DIR/$cmd"
    if [[ -L "$target" || -f "$target" ]]; then
      echo "  [*] Reemplazando $target"
      rm -f "$target"
    fi
    ln -s "$f" "$target"
    echo "  [+] $cmd -> $target"
  fi
done

echo "Instalación de comandos completada."
