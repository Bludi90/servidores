#!/usr/bin/env bash
set -euo pipefail
umask 022
export LC_ALL=C

REPO_DIR="/home/alejandro/servidores"
OUT_DIR="${REPO_DIR}/state/backup1"
OUT="${OUT_DIR}/current-state.md"
SSH_TARGET="${1:-backup1}"
STAMP="$(date '+%F %H:%M')"

mkdir -p "${OUT_DIR}"

if ! ssh -o BatchMode=yes -o ConnectTimeout=5 "${SSH_TARGET}" 'echo ok' >/dev/null 2>&1; then
echo "ERROR: no se puede conectar por SSH a ${SSH_TARGET}" >&2
exit 1
fi

REPL_STATUS="$(/usr/local/bin/zfs-repl-backup1-status 7 2>/dev/null || true)"
REPL_FRESH="$(/usr/local/bin/zfs-repl-backup1-freshness 2>/dev/null || true)"

{
echo "# Estado de backup1 — ${STAMP}"
echo
echo "## Índice"
echo
echo "- [Sistema](#sistema)"
echo "- [Red](#red)"
echo "- [Almacenamiento](#almacenamiento)"
echo "- [Servicios](#servicios)"
echo "- [Réplica vista desde main1](#réplica-vista-desde-main1)"
echo
ssh -o BatchMode=yes "${SSH_TARGET}" 'bash -s' <<'REMOTE'
set -euo pipefail

echo "## Sistema"
printf '%s\n' '~~~'
hostname -s
uname -a 2>/dev/null || true
echo
echo "Uptime:"
uptime -p 2>/dev/null || true
printf '%s\n' '~~~'
echo

echo "## Red"
printf '%s\n' '~~~'
ip -br -4 addr 2>/dev/null || true
printf '%s\n' '~~~'
echo

echo "## Almacenamiento"
printf '%s\n' '~~~'
echo "zpool status -x:"
zpool status -x 2>/dev/null || true
echo
echo "---"
echo "zpool list:"
zpool list 2>/dev/null || true
echo
echo "---"
echo "datasets backup:"
zfs list -o name,used,avail,refer,mountpoint 2>/dev/null | awk 'NR==1 || /^backup/ {print}'
echo
echo "---"
echo "últimos snapshots:"
zfs list -t snapshot -o name -s creation 2>/dev/null | grep '^backup/' | tail -n 10 || true
printf '%s\n' '~~~'
echo

echo "## Servicios"
printf '%s\n' '~~~'
echo "ssh: $(systemctl is-active ssh 2>/dev/null || echo desconocido)"
echo "cron: $(systemctl is-active cron 2>/dev/null || echo desconocido)"
echo "smartd: $(systemctl is-active smartd 2>/dev/null || echo desconocido)"
echo "zfs-zed: $(systemctl is-active zfs-zed 2>/dev/null || echo desconocido)"
printf '%s\n' '~~~'
echo
REMOTE

echo "## Réplica vista desde main1"
printf '%s\n' '~~~'
echo "Estado semanal:"
echo "${REPL_STATUS:-no disponible}"
echo
echo "Frescura:"
echo "${REPL_FRESH:-no disponible}"
printf '%s\n' '~~~'
} > "${OUT}"

echo "Escrito: ${OUT}"
