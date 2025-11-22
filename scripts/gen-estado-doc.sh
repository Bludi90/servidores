#!/usr/bin/env bash
set -euo pipefail

# Raíz del repo
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

docs_dir="${repo_root}/docs"
estado_file="${docs_dir}/ESTADO.md"
state_dir="${repo_root}/state/main1"
sync_log_abs="${state_dir}/sync.log"

current_state_abs=""

# 1) Preferimos un current-state.md explícito si existe
if [[ -f "${state_dir}/current-state.md" ]]; then
  current_state_abs="${state_dir}/current-state.md"
else
  # 2) Si no existe, buscamos el último .md en state/main1
  latest="$(ls -1t "${state_dir}"/*.md 2>/dev/null | head -n1 || true)"
  if [[ -n "$latest" ]]; then
    current_state_abs="$latest"
  fi
fi

# Fecha "bonita"
if [[ -n "$current_state_abs" && -f "$current_state_abs" ]]; then
  nice_ts="$(date -r "$current_state_abs" "+%Y-%m-%d %H:%M")"
else
  nice_ts="$(date "+%Y-%m-%d %H:%M")"
fi

# Paths relativos desde docs/ hacia el snapshot y el sync.log
if [[ -n "$current_state_abs" && -f "$current_state_abs" ]]; then
  current_state_rel="$(realpath --relative-to="$docs_dir" "$current_state_abs")"
else
  current_state_rel="../state/main1/current-state.md"
fi

if [[ -f "$sync_log_abs" ]]; then
  sync_log_rel="$(realpath --relative-to="$docs_dir" "$sync_log_abs")"
else
  sync_log_rel="../state/main1/sync.log"
fi

cat >"$estado_file" <<EOF
# Estado de servidores (índice)

_Generado: ${nice_ts}_

- **main1**: Último completo: [${nice_ts}](${current_state_rel}) — [sync.log](${sync_log_rel})

### Criterio de 'completo'
- El snapshot contiene secciones: WireGuard y Docker.
EOF
