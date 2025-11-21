#!/usr/bin/env bash
set -euo pipefail

# Detectar raíz del repo en función de la ubicación del propio script
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

HOST="main1"
STATE_DIR="state/$HOST"
DOC_FILE="docs/ESTADO.md"

# Buscar todos los snapshots tipo *-state.md
shopt -s nullglob
state_files=( "$STATE_DIR"/*-state.md )
shopt -u nullglob

# Si no hay snapshots, salimos sin romper nada
if (( ${#state_files[@]} == 0 )); then
  echo "No se han encontrado snapshots en $STATE_DIR" >&2
  exit 0
fi

# Ordenar y quedarnos con el último
IFS=$'\n' sorted=( $(printf '%s\n' "${state_files[@]}" | sort) )
latest_state_file="${sorted[-1]}"

# Nombre de archivo (ej: 2025-11-19_0949-state.md)
fname="$(basename "$latest_state_file")"

# Quitar el sufijo -state.md → 2025-11-19_0949
ts_part="${fname%-state.md}"

# Separar fecha y hora
date_part="${ts_part%%_*}"   # 2025-11-19
time_raw="${ts_part#*_}"     # 0949

# Formatear "bonito"
if [[ ${#time_raw} -ge 4 ]]; then
  hh="${time_raw:0:2}"
  mm="${time_raw:2:2}"
  nice_ts="$date_part ${hh}:${mm}"
else
  # Por si algún día el nombre no lleva hora
  nice_ts="$date_part"
fi

# Ruta relativa desde docs/ hasta el snapshot
rel_path="../$STATE_DIR/$fname"

mkdir -p "$(dirname "$DOC_FILE")"

cat > "$DOC_FILE" <<EOF
# Estado de servidores (índice)

_Generado: ${nice_ts}_

- **${HOST}**: Último completo: [${nice_ts}](${rel_path}) — [sync.log](../${STATE_DIR}/sync.log)

### Criterio de 'completo'
- El snapshot contiene secciones: WireGuard y Docker.
EOF
