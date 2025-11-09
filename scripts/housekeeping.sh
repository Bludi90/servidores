#!/usr/bin/env bash
set -euo pipefail
KEEP="${KEEP:-200}"   # cambia con: KEEP=336 ./scripts/housekeeping.sh (por ej. 2 semanas horarias)

for d in state/*; do
  [ -d "$d" ] || continue

  # Compactar sync.log a las últimas 2000 líneas
  if [ -f "$d/sync.log" ]; then
    tail -n 2000 "$d/sync.log" > "$d/.sync.log.new" && mv "$d/.sync.log.new" "$d/sync.log"
  fi

  # Eliminar snapshots antiguos, conservar solo los KEEP más recientes
  snaps=( "$d"/*-state.md )
  [ -e "${snaps[0]}" ] || continue
  total=${#snaps[@]}
  if [ "$total" -gt "$KEEP" ]; then
    ls -1t "$d"/*-state.md | tail -n +"$((KEEP+1))" | xargs -r rm -f
  fi
done
