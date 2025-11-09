#!/usr/bin/env bash
set -euo pipefail
# Añade rutas sbin para que encuentre ufw, wg, etc. aunque seas usuario normal
export PATH="$PATH:/usr/sbin:/sbin"

SERVER="$(hostname -s || echo server)"
STAMP="$(date +%F_%H%M)"
OUT_DIR="state/${SERVER}"
OUT="${OUT_DIR}/${STAMP}-state.md"

mask_ipv4()  { sed -E 's/\b([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\.[0-9]{1,3}\b/\1.x/g'; }
mask_ports() { sed -E 's/:([0-9]{2,5})([^0-9]|$)/:xxxx\2/g'; }
mask_all()   { mask_ipv4 | mask_ports; }

# ---- Utilidad: sacar tabla de peers activos de WireGuard (últimos 10 min) ----
wg_active_table() {
  local IF=wg0
  local NOW THRESH PUB TS ALLOWED NAME MAP="scripts/wg-peers.map"
  NOW="$(date +%s)"; THRESH=600

  # Carga opcional de nombres desde scripts/wg-peers.map  (formato: "<pubkey> <Nombre>")
  declare -A N; if [ -r "$MAP" ]; then while read -r k v; do [ -n "${k:-}" ] && N["$k"]="$v"; done < "$MAP"; fi

  # Obtiene "public_key  unix_timestamp" de cada peer
  local HS
  HS="$(sudo -n wg show "$IF" latest-handshakes 2>/dev/null || wg show "$IF" latest-handshakes 2>/dev/null || true)"
  [ -z "$HS" ] && { echo "_No se pudo leer el estado de WireGuard (sin permisos o sin interfaz)._"; return 0; }

  echo "| Cliente | IP wg | Último handshake |"
  echo "|---|---|---|"

  # Para cada peer con handshake reciente, muestra nombre e IP
  while read -r PUB TS; do
    [ -z "${PUB:-}" ] && continue
    # peers sin handshake tienen TS=0
    if [ "${TS:-0}" -gt 0 ] && [ $((NOW-TS)) -le $THRESH ]; then
      ALLOWED="$(sudo -n wg show "$IF" allowed-ips 2>/dev/null || wg show "$IF" allowed-ips 2>/dev/null | awk -v k="$PUB" '$1==k{print $2}')"
      NAME="${N[$PUB]:-peer-${PUB:0:6}}"
      echo "| ${NAME} | ${ALLOWED} | $(date -d @"$TS" +%H:%M:%S) |"
    fi
  done <<< "$HS"
}

mkdir -p "$OUT_DIR"

{
  echo "# Estado de ${SERVER} — ${STAMP}"
  echo

  echo "## Sistema"
  echo '```'
  uname -a
  if command -v lsb_release >/dev/null 2>&1; then lsb_release -ds; else grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"'; fi
  echo; echo "Uptime:"; uptime -p
  echo '```'
  echo

  echo "## CPU y RAM"
  echo '```'
  echo "CPUs: $(nproc)"; free -h
  echo '```'
  echo

  echo "## Redes (IPv4 depuradas)"
  echo '```'
  ip -br -4 addr | mask_all || true
  echo '```'
  echo

  echo "## Almacenamiento"
  echo '```'
  df -hT --sync | awk 'NR==1 || $1 ~ "^/dev/"'
  echo '```'
  echo

  echo "## Inodos"
  echo '```'
  df -i | awk 'NR==1 || $1 ~ "^/dev/"'
  echo '```'
  echo

  echo "## Discos y puntos de montaje"
  echo '```'
  lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | sed 's/\s\+/ /g'
  echo '```'
  echo

  echo "## Servicios clave"
  echo '```'
  for s in ssh ufw docker wg-quick@wg0; do
    printf "%s: " "$s"; systemctl is-active "$s" 2>/dev/null || echo "desconocido"
  done
  echo; echo "Unidades con fallo:"; systemctl --failed || true
  echo '```'
  echo

  echo "## UFW"
  echo '```'
  if [ -x /usr/sbin/ufw ] || command -v ufw >/dev/null 2>&1; then
    sudo -n ufw status numbered 2>/dev/null || /usr/sbin/ufw status numbered 2>/dev/null || echo "UFW instalado pero sin permisos para ver el estado."
  else
    echo "UFW no instalado."
  fi
  echo '```'
  echo

  echo "## WireGuard"
  echo '```'
  ( sudo -n wg show 2>/dev/null || wg show 2>/dev/null || echo "WireGuard instalado pero sin permisos o sin interfaz." ) | mask_all
  echo '```'
  echo
  echo "**Clientes activos (últimos 10 min):**"
  wg_active_table
  echo

  echo "## Docker"
  echo '```'
  if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    echo "Contenedores en ejecución:"; docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' || true
    echo
    if docker compose version >/dev/null 2>&1; then
      echo "Docker Compose (v2) — stacks:"; docker compose ls || true
    elif command -v docker-compose >/dev/null 2>&1; then
      echo "Docker Compose (v1) — proyectos:"; docker-compose ls 2>/dev/null || docker-compose ps || true
    fi
    echo; echo "Volúmenes:"; docker volume ls || true
    echo; echo "Imágenes (top 10 por tamaño):"; docker images --format '{{.Repository}}:{{.Tag}}\t{{.Size}}' | head -n 10 || true
  else
    echo "Docker no accesible o no instalado."
  fi
  echo '```'
  echo

  echo "## VMs (libvirt)"
  echo '```'
  if command -v virsh >/dev/null 2>&1; then
    virsh list --all || true
  else
    echo "libvirt/virsh no disponible."
  fi
  echo '```'
  echo

  echo "## Backups (restic)"
  echo '```'
  LOG="/var/log/backup_restic.log"
  if [ -r "$LOG" ]; then
    echo "Últimas 50 líneas del log (IPs/puertos depurados):"
    tail -n 50 "$LOG" | mask_all
  else
    echo "Log no legible por el usuario actual."
  fi
  echo '```'
} > "$OUT"

echo "Escrito: $OUT"
