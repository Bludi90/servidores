#!/usr/bin/env bash
set -euo pipefail
OUT="docs/ESTADO.md"
echo "# Estado de servidores (índice)" > "$OUT"
echo "" >> "$OUT"
echo "_Generado: $(date +%F\ %H:%M)_" >> "$OUT"
echo "" >> "$OUT"

# Recorre hosts ordenados
for d in $(ls -d state/* 2>/dev/null | sort); do
  [ -d "$d" ] || continue
  host="$(basename "$d")"
  latest="$(ls -t "$d"/*-state.md 2>/dev/null | head -1 || true)"
  total="$(ls "$d"/*-state.md 2>/dev/null | wc -l || echo 0)"

  # Enlaces correctos desde docs/: anteponer "../"
  if [ -n "${latest:-}" ]; then
    mtime="$(date -r "$latest" "+%F %H:%M" 2>/dev/null || echo "(fecha)")"
    echo "- **${host}**: ${total} snapshots. Último: [${mtime}](../${latest}) — [sync.log](../${d}/sync.log)" >> "$OUT"
  else
    echo "- **${host}**: (sin snapshots) — [sync.log](../${d}/sync.log)" >> "$OUT"
  fi
done

echo "" >> "$OUT"
echo "### Nota" >> "$OUT"
echo "- El contenido técnico de cada snapshot está en bloques \`\`\` para que sea legible en GitHub." >> "$OUT"
