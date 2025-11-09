#!/usr/bin/env bash
set -euo pipefail
OUT="docs/ESTADO.md"
echo "# Estado de servidores (índice)" > "$OUT"
echo "" >> "$OUT"
echo "_Generado: $(date +%F\ %H:%M)_" >> "$OUT"
echo "" >> "$OUT"

is_complete() {
  f="$1"
  grep -q '^## WireGuard' "$f" && grep -q '^## Docker' "$f" && grep -q '^## VMs' "$f"
}

for d in $(ls -d state/* 2>/dev/null | sort); do
  [ -d "$d" ] || continue
  host="$(basename "$d")"
  latest="$(ls -t "$d"/*-state.md 2>/dev/null | head -1 || true)"
  complete="$(ls -t "$d"/*-state.md 2>/dev/null | while read f; do is_complete "$f" && { echo "$f"; break; }; done)"

  if [ -n "${complete:-}" ]; then
    m1="$(date -r "$complete" '+%F %H:%M' 2>/dev/null || echo '(fecha)')"
    echo "- **${host}**: Último completo: [${m1}](../${complete}) — [sync.log](../${d}/sync.log)" >> "$OUT"
    if [ -n "${latest:-}" ] && [ "$latest" != "$complete" ]; then
      m2="$(date -r "$latest" '+%F %H:%M' 2>/dev/null || echo '(fecha)')"
      echo "  - Nota: el más reciente es [${m2}](../${latest}), pero está **incompleto**." >> "$OUT"
    fi
  elif [ -n "${latest:-}" ]; then
    m3="$(date -r "$latest" '+%F %H:%M' 2>/dev/null || echo '(fecha)')"
    echo "- **${host}**: [${m3}](../${latest}) — [sync.log](../${d}/sync.log) _(incompleto)_" >> "$OUT"
  else
    echo "- **${host}**: (sin snapshots) — [sync.log](../${d}/sync.log)" >> "$OUT"
  fi
done

echo "" >> "$OUT"
echo "### Criterio de 'completo'" >> "$OUT"
echo "- El snapshot contiene secciones: WireGuard, Docker y VMs." >> "$OUT"
