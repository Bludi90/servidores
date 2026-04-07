#!/usr/bin/env bash
set -euo pipefail
umask 022
export LC_ALL=C

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
docs_dir="${repo_root}/docs"
estado_file="${docs_dir}/ESTADO.md"
state_root="${repo_root}/state"

mkdir -p "${docs_dir}"
mkdir -p "${state_root}"

now_ts="$(date '+%Y-%m-%d %H:%M')"

{
  echo "# Estado de servidores (índice)"
  echo
  echo "_Generado: ${now_ts}_"
  echo

  found_any=0

  for host_dir in "${state_root}"/*; do
    [[ -d "${host_dir}" ]] || continue
    host="$(basename "${host_dir}")"
    current_abs="${host_dir}/current-state.md"
    sync_log_abs="${host_dir}/sync.log"

    [[ -f "${current_abs}" ]] || continue

    found_any=1
    nice_ts="$(date -r "${current_abs}" '+%Y-%m-%d %H:%M' 2>/dev/null || echo desconocido)"
    current_rel="$(realpath --relative-to="${docs_dir}" "${current_abs}")"

    if [[ -f "${sync_log_abs}" ]]; then
      sync_rel="$(realpath --relative-to="${docs_dir}" "${sync_log_abs}")"
      echo "- **${host}**: Último completo: [${nice_ts}](${current_rel}) — [sync.log](${sync_rel})"
    else
      echo "- **${host}**: Último completo: [${nice_ts}](${current_rel})"
    fi
  done

  if [[ "${found_any}" -eq 0 ]]; then
    echo "_No se han encontrado snapshots actuales en state/*/current-state.md_"
    echo
  else
    echo
  fi

  echo "### Criterio de 'completo'"
  echo "- El snapshot contiene secciones: ZFS, WireGuard, DNS interno y Docker."
} > "${estado_file}"
