#!/usr/bin/env bash
set -euo pipefail

REPO="/home/alejandro/servidores"
HOST="main1"
LOG="$REPO/state/$HOST/sync.log"

mkdir -p "$(dirname "$LOG")"
touch "$LOG"
# En caso de que algún día se ejecute como root, devolvé el log al usuario normal
chown alejandro:alejandro "$LOG" || true

cd "$REPO"

# Regenerar docs/ESTADO.md con el último snapshot
if [[ -x scripts/gen-estado-doc.sh ]]; then
  scripts/gen-estado-doc.sh || echo "[WARN] No se pudo regenerar ESTADO.md" >&2
fi

ts() { date '+%Y-%m-%d %H:%M:%S'; }

echo "[$(ts)] === Inicio commit-and-push ===" | tee -a "$LOG"

# Si no hay cambios (ni staged ni unstaged), salimos
if git diff --quiet && git diff --cached --quiet; then
  echo "[$(ts)] No hay cambios; nada que commitear." | tee -a "$LOG"
  echo "[$(ts)] === Fin commit-and-push (sin cambios) ===" | tee -a "$LOG"
  exit 0
fi

echo "[$(ts)] Cambios detectados:" | tee -a "$LOG"
git status --short | tee -a "$LOG" || true

MSG="auto: snapshot $HOST $(date '+%Y-%m-%d %H:%M')"

git add -A
git commit -m "$MSG" | tee -a "$LOG"
echo "[$(ts)] Commit creado: $MSG" | tee -a "$LOG"

git push origin main | tee -a "$LOG"
echo "[$(ts)] git push OK." | tee -a "$LOG"
echo "[$(ts)] === Fin commit-and-push ===" | tee -a "$LOG"
