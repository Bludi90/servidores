#!/usr/bin/env bash
set -euo pipefail

# Directorio raíz del repo (scripts/ → repo)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

BIN_DIR="/usr/local/bin"
SBIN_DIR="/usr/local/sbin"

# Comandos que, aunque vivan en scripts/cmd, deben instalarse en /usr/local/sbin
SBIN_CMDS=("nut-notify")

is_in_list() {
  local needle="$1"; shift
  local x
  for x in "$@"; do [[ "$x" == "$needle" ]] && return 0; done
  return 1
}

echo "Instalando comandos desde $REPO_DIR"
echo "  BIN  -> $BIN_DIR"
echo "  SBIN -> $SBIN_DIR"

mkdir -p "$BIN_DIR" "$SBIN_DIR"

# 1) scripts/cmd → /usr/local/bin (o /usr/local/sbin si está en SBIN_CMDS)
if [[ -d "$REPO_DIR/scripts/cmd" ]]; then
  for f in "$REPO_DIR"/scripts/cmd/*; do
    [[ -f "$f" && -x "$f" ]] || continue
    cmd="$(basename "$f")"

    if is_in_list "$cmd" "${SBIN_CMDS[@]}"; then
      target="$SBIN_DIR/$cmd"
      rm -f "$BIN_DIR/$cmd" 2>/dev/null || true
    else
      target="$BIN_DIR/$cmd"
      rm -f "$SBIN_DIR/$cmd" 2>/dev/null || true
    fi

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
