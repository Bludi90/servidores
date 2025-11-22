#!/usr/bin/env bash
set -euo pipefail

# Raíz del repo = carpeta padre de scripts/
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

state_dir="${repo_root}/state/main1"
docs_dir="${repo_root}/docs"
estado_file="${docs_dir}/ESTADO.md"

sync_log_abs="${state_dir}/sync.log"

best_state=""

# 1) Buscar SOLO archivos de estado tipo 2025-11-11_1607-state.md
if compgen -G "${state_dir}"/*-state.md > /dev/null; then
  best_state="$(ls -1t "${state_dir}"/*-state.md | head -n1)"
else
  # 2) Fallback: si algún día no hay *-state.md, usamos el último .md que no sea current-state.md
  latest_non_current="$(
    ls -1t "${state_dir}"/*.md 2>/dev/null \
      | grep -v '/current-state\.md$' \
      | head -n1 || true
  )"

  if [[ -n "$latest_non_current" ]]; then
    best_state="$latest_non_current"
  fi
fi

# Fecha "bonita": la del snapshot si existe, si no, ahora
if [[ -n "$best_state" && -f "$best_state" ]]; then
  nice_ts="$(date -r "$best_state" "+%Y-%m-%d %H:%M")"
else
  nice_ts="$(date "+%Y-%m-%d %H:%M")"
fi

# Paths relativos desde docs/ hacia el snapshot y el sync.log
if [[ -n "$best_state" && -f "$best_state" ]]; then
  snap_rel="$(realpath --relative-to="$docs_dir" "$best_state")"
else
  snap_rel="../state/main1/"   # fallback genérico
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
- El snapshot enlazado incluye el estado completo del servidor (hardware, servicios, ZFS, WireGuard, etc.).
- Si algo crítico falla, se ve marcado en ese snapshot, no en este índice.
EOF
