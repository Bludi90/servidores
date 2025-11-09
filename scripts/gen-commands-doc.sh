#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
OUT="$ROOT/docs/COMANDOS.md"
H="$ROOT/scripts/help.d"

echo "# Comandos personalizados" > "$OUT"
echo "" >> "$OUT"
echo "_Generado: $(date +%F\ %H:%M)_" >> "$OUT"
echo "" >> "$OUT"

for f in $(ls "$H"/*.help 2>/dev/null | sort); do
  name="$(basename "$f" .help)"
  echo "## $name" >> "$OUT"
  echo "" >> "$OUT"
  sed 's/^/    /' "$f" >> "$OUT"
  echo "" >> "$OUT"
done

# Pequeña tabla-resumen al final
echo "## Resumen rápido" >> "$OUT"
echo "" >> "$OUT"
echo "| Comando | Para qué sirve |" >> "$OUT"
echo "|---|---|" >> "$OUT"
for f in $(ls "$H"/*.help 2>/dev/null | sort); do
  name="$(basename "$f" .help)"
  desc="$(head -n 2 "$f" | tail -n 1 | sed 's/^[[:space:]]*//')"
  echo "| \`$name\` | $desc |" >> "$OUT"
done
