#!/usr/bin/env bash
set -euo pipefail

# Raíz del repo = carpeta padre de scripts/
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

state_dir="${repo_root}/state/main1"
docs_dir="${repo_root}/docs"
estado_file="${docs_dir}/ESTADO.md"

sync_log_abs="${state_dir}/sync.log"

best_state=""

# 1) Preferimos archivos tipo state-*.md (los snapshots “de verdad”)
if compgen -G "${state_dir}/state-*.md" > /dev/null; then
  best_state="$(ls -1t "${state_dir}"/state-*.md | head -n1)"
else
  # 2) Si no hay state-*.md, buscamos el último .md ignorando current-state.md
  latest_non_current="$(
    ls -1t "${state_dir}"/*.md 2>/dev/null \
      | grep -v '/current-state\.md$' \
      | head -n1 || true
  )"

  if [[ -n "$latest_non_current" ]]; then
    best_state="$latest_non_current"
  fi
fi

# Fecha "bonita" (si no hay snapshot, usamos fecha actual)
if [[ -n "$best_state" && -f "$best_state" ]]; then
  nice_ts="$(date -r "$best_state" "+%Y-%m-%d %H:%M")"
else
  nice_ts="$(date "+%Y-%m-%d %H:%M")"
fi

# Paths relativos desde docs/ hacia el snapshot y el sync.log
if [[ -n "$best_state" && -f "$best_state" ]]; then
  snap_rel="$(realpath --relative-to="$docs_dir" "$best_state")"
else
  snap_rel="../state/main1/"  # fallback genérico
fi

if [[ -f "$sync_log_abs" ]]; then
  sync_rel="$(realpath --relative-to="$docs_dir" "$sync_log_abs")"
else
  sync_rel="../state/main1/sync.log"
fi

cat >"$estado_file" <<EOF
# Estado de servidores (índice)

_Generado: ${nice_ts}_

- **main1**: Último snapshot: [${nice_ts}](${snap_rel}) — [sync.log](${sync_rel})

### Cómo leer este estado
- El snapshot incluye secciones de hardware, ZFS, WireGuard y Docker.
- Si algo crítico falla, se verá marcado en el snapshot, no en este índice.
- Usa siempre el último snapshot enlazado para ver el detalle.
EOF
