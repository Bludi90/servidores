#!/usr/bin/env bash
set -euo pipefail
umask 022
export LC_ALL=C

# Raíz del repo = carpeta padre de scripts/
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SERVER="$(hostname -s || echo main1)"

docs_dir="${repo_root}/docs"
estado_file="${docs_dir}/ESTADO.md"

state_dir="${repo_root}/state/${SERVER}"
current_abs="${state_dir}/current-state.md"
sync_log_abs="${state_dir}/sync.log"

mkdir -p "${docs_dir}"

# Fecha "bonita" basada en current-state.md (si existe y no está vacío)
if [[ -s "${current_abs}" ]]; then
  nice_ts="$(date -r "${current_abs}" "+%Y-%m-%d %H:%M")"
else
  nice_ts="desconocido"
fi

# Paths relativos desde docs/ hacia current-state y sync.log
if [[ -f "${current_abs}" ]]; then
  current_rel="$(realpath --relative-to="${docs_dir}" "${current_abs}")"
else
  current_rel="../state/${SERVER}/current-state.md"
fi

if [[ -f "${sync_log_abs}" ]]; then
  sync_rel="$(realpath --relative-to="${docs_dir}" "${sync_log_abs}")"
else
  sync_rel="../state/${SERVER}/sync.log"
fi

cat > "${estado_file}" <<EOF
# Estado de servidores (índice)

_Generado: ${nice_ts}_

- **${SERVER}**: Último completo: [${nice_ts}](${current_rel}) — [sync.log](${sync_rel})

### Criterio de 'completo'
- El snapshot contiene secciones: WireGuard y Docker.
EOF
