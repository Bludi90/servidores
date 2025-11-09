#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

HOST="$(hostname -s || echo server)"
NOW(){ date +%F_%T; }
LOG_DIR="state/${HOST}"
LOG_FILE="${LOG_DIR}/sync.log"
mkdir -p "$LOG_DIR"

mask_ipv4()  { sed -E 's/\b([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\.[0-9]{1,3}\b/\1.x/g'; }
mask_ports() { sed -E 's/:([0-9]{2,5})([^0-9]|$)/:xxxx\2/g'; }
mask_all()   { mask_ipv4 | mask_ports; }
log(){ printf "[%s] %s\n" "$(NOW)" "$1" | mask_all | tee -a "$LOG_FILE" >/dev/null; }

# 1) Snapshot (salida detallada a archivo; aquí solo anotamos)
./scripts/snapshot-state.sh >/dev/null || true
log "snapshot: generado"

# 2) Chequeo anti-secretos (solo archivos del proyecto; excluye nuestros scripts)
echo "Chequeando posibles secretos..."
PATTERN='(BEGIN [A-Z ]*PRIVATE KEY|ssh-ed25519|AWS_SECRET_ACCESS_KEY|AWS_ACCESS_KEY_ID|ghp_[A-Za-z0-9]{30,}|Authorization: Bearer|password\s*=|token\s*=|RESTIC_PASSWORD|WG_PRIVATE_KEY)'
FILES="$(git ls-files -co --exclude-standard | grep -vE '^scripts/(commit-and-push\.sh|snapshot-state\.sh)$' || true)"
if [ -n "$FILES" ] && grep -nIE -E "$PATTERN" $FILES >/tmp/servidores-secret-hits 2>/dev/null; then
  log "ABORT: posibles secretos (revisa la consola para detalles)"
  cat /tmp/servidores-secret-hits
  exit 2
fi

# 3) Bloqueo de tamaño (>2MB) fuera de .git/scripts y del propio LOG_DIR
BIG=$(find . -type f -size +2M ! -path './.git/*' ! -path './scripts/*' ! -path "./${LOG_DIR}/*" -printf '%P\n' | wc -l)
if [ "$BIG" -gt 0 ]; then
  log "ABORT: $BIG archivo(s) >2MB"
  find . -type f -size +2M ! -path './.git/*' ! -path './scripts/*' ! -path "./${LOG_DIR}/*" -printf ' - %P (%k KB)\n' | head -n 20 >&2
  exit 3
fi

# 4) Commit & push
git add README.md MIGRATION_LOG.md docs/ scripts/ state/ .gitignore
if git diff --cached --quiet; then
  log "no-changes"
  echo "No hay cambios que subir."
  exit 0
fi

STAMP="$(date +%F_%H:%M)"
git commit -m "chore(state): foto depurada ${HOST} @ ${STAMP}"
GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519_github -o IdentitiesOnly=yes' git push origin main
log "push: OK"
echo "✅ Subido a GitHub."
