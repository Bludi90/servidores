#!/usr/bin/env bash
set -euo pipefail

REPO="/home/alejandro/servidores"
HOST="$(hostname -s 2>/dev/null || echo main1)"
LOG="$REPO/state/$HOST/sync.log"

mkdir -p "$(dirname "$LOG")"
touch "$LOG"
chown alejandro:alejandro "$LOG" 2>/dev/null || true

cd "$REPO"

ts() { date '+%Y-%m-%d %H:%M:%S'; }

BRANCH="$(git branch --show-current || true)"
if [ -z "$BRANCH" ]; then
  echo "[$(ts)] ERROR: no se pudo detectar la rama actual." >> "$LOG"
  exit 1
fi

echo "[$(ts)] === Inicio commit-and-push ===" >> "$LOG"
echo "[$(ts)] Rama actual: $BRANCH" >> "$LOG"

# Publicar solo la foto actual, no el histórico horario ni los logs
git add docs/ESTADO.md 2>/dev/null || true
git add "state/$HOST/current-state.md" 2>/dev/null || true
[ -f "state/backup1/current-state.md" ] && git add "state/backup1/current-state.md" || true
[ -d "reports/current" ] && git add reports/current || true

if git diff --cached --quiet; then
  echo "[$(ts)] No hay cambios publicados; nada que commitear." >> "$LOG"
  echo "[$(ts)] === Fin commit-and-push (sin cambios) ===" >> "$LOG"
  exit 0
fi

MSG="auto: current-state $HOST $(date '+%Y-%m-%d %H:%M')"
git commit -m "$MSG" >> "$LOG" 2>&1
echo "[$(ts)] Commit creado: $MSG" >> "$LOG"

git push -u origin "$BRANCH" >> "$LOG" 2>&1
echo "[$(ts)] git push OK hacia $BRANCH." >> "$LOG"
echo "[$(ts)] === Fin commit-and-push ===" >> "$LOG"
