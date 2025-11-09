#!/usr/bin/env bash
set -euo pipefail

SERVER="$(hostname -s || echo server)"
STAMP="$(date +%F_%H%M)"
OUT_DIR="state/${SERVER}"
OUT="${OUT_DIR}/${STAMP}-state.md"

mask_ipv4()  { sed -E 's/\b([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\.[0-9]{1,3}\b/\1.x/g'; }
mask_ports() { sed -E 's/:([0-9]{2,5})([^0-9]|$)/:xxxx\2/g'; }
mask_all()   { mask_ipv4 | mask_ports; }

mkdir -p "$OUT_DIR"

{
  echo "# Estado de ${SERVER} — ${STAMP}"
  echo
  echo "## Sistema"
  uname -a
  if command -v lsb_release >/dev/null 2>&1; then lsb_release -ds; else grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"'; fi
  echo
  echo "Uptime:"; uptime -p
  echo
  echo "## CPU y RAM"
  echo "CPUs: $(nproc)"; free -h
  echo
  echo "## Redes (IPv4 depuradas)"
  ip -br -4 addr | mask_all || true
  echo
  echo "## Almacenamiento"
  df -hT --sync | awk 'NR==1 || $1 ~ "^/dev/"'
  echo
  echo "## Inodos"
  df -i | awk 'NR==1 || $1 ~ "^/dev/"'
  echo
  echo "## Discos y puntos de montaje"
  lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | sed 's/\s\+/ /g'
  echo
  echo "## Servicios clave"
  for s in ssh ufw docker wg-quick@wg0; do
    printf "%s: " "$s"; systemctl is-active "$s" 2>/dev/null || echo "desconocido"
  done
  echo
  echo "## Servicios con fallo (systemd)"
  systemctl --failed || true
  echo
  echo "## UFW"
  if command -v ufw >/dev/null 2>&1; then
    ufw status numbered || true
  else
    echo "UFW no instalado."
  fi
  echo
  echo "## WireGuard"
  if command -v wg >/dev/null 2>&1; then
    wg show | mask_all || true
  else
    echo "WireGuard no instalado."
  fi
  echo
  echo "## Docker"
  if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    echo "Contenedores en ejecución:"
    docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' || true
    echo
    if docker compose version >/dev/null 2>&1; then
      echo "Docker Compose (v2) — stacks:"
      docker compose ls || true
    elif command -v docker-compose >/dev/null 2>&1; then
      echo "Docker Compose (v1) — proyectos:"
      docker-compose ls 2>/dev/null || docker-compose ps || true
    fi
    echo
    echo "Volúmenes:"
    docker volume ls || true
    echo
    echo "Imágenes (top 10 por tamaño):"
    docker images --format '{{.Repository}}:{{.Tag}}\t{{.Size}}' | head -n 10 || true
  else
    echo "Docker no accesible o no instalado."
  fi
  echo
  echo "## VMs (libvirt)"
  if command -v virsh >/dev/null 2>&1; then
    virsh list --all || true
  else
    echo "libvirt/virsh no disponible."
  fi
  echo
  echo "## Backups (restic)"
  LOG="/var/log/backup_restic.log"
  if [ -r "$LOG" ]; then
    echo "Últimas 50 líneas del log (IPs/puertos depurados):"
    tail -n 50 "$LOG" | mask_all
  else
    echo "Log no legible por el usuario actual."
  fi
} > "$OUT"

echo "Escrito: $OUT"
