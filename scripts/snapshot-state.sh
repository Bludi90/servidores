#!/usr/bin/env bash
set -euo pipefail
umask 022
export LC_ALL=C
export PATH="$PATH:/usr/local/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/alejandro/bin:/home/alejandro/servidores/scripts"

SERVER="$(hostname -s || echo server)"
STAMP="$(date +%F_%H%M)"

REPO_DIR="/home/alejandro/servidores"
OUT_DIR="${REPO_DIR}/state/${SERVER}"
OUT="${OUT_DIR}/${STAMP}-state.md"
CURRENT="${OUT_DIR}/current-state.md"

mask_ipv4()  { sed -E 's/\b([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\.[0-9]{1,3}\b/\1.x/g'; }
mask_ports() { sed -E 's/:([0-9]{2,5})([^0-9]|$)/:xxxx\2/g'; }
mask_all()   { mask_ipv4 | mask_ports; }

find_wg_list_peers() {
  for c in \
    wg-list-peers \
    /usr/local/bin/wg-list-peers /usr/local/sbin/wg-list-peers /usr/sbin/wg-list-peers \
    /home/alejandro/servidores/scripts/wg-list-peers /home/alejandro/bin/wg-list-peers
  do
    [ -x "$c" ] && { echo "$c"; return; }
    command -v "$c" >/dev/null 2>&1 && { command -v "$c"; return; }
  done
  return 1
}

# --- helpers hardware (sin root) ---
board() { for f in vendor name version; do p="/sys/class/dmi/id/board_$f"; [ -r "$p" ] && cat "$p" || echo "?"; done; }
bios()  { for f in bios_vendor bios_version bios_date; do p="/sys/class/dmi/id/$f"; [ -r "$p" ] && cat "$p" || echo "?"; done; }

mkdir -p "$OUT_DIR"

{
  echo "# Estado de ${SERVER} — ${STAMP}"
  echo

  echo "## Índice"
  echo
  echo "- [Hardware](#hardware)"
  echo "- [Sistema](#sistema)"
  echo "- [CPU y RAM](#cpu-y-ram)"
  echo "- [Redes (IPv4 depuradas)](#redes-ipv4-depuradas)"
  echo "- [Almacenamiento](#almacenamiento-consolidado)"
  echo "- [Servicios](#servicios-clave-y-fallos)"
  echo "- [UFW](#ufw)"
  echo "- [WireGuard](#wireguard)"
  echo "- [Peers WireGuard](#peers-wireguard)"
  echo "- [Docker](#docker)"
  echo "- [VMs (libvirt)](#vms-libvirt)"
  echo "- [Backups (restic)](#backups-restic)"
  echo

  ########################################################################
  # Hardware
  ########################################################################
  echo "## Hardware"
  BV=$(board | sed -n '1p'); BN=$(board | sed -n '2p'); BVER=$(board | sed -n '3p')
  BIOSVEN=$(bios | sed -n '1p'); BIOSV=$(bios | sed -n '2p'); BIOSD=$(bios | sed -n '3p')

  CPU_MODEL="$(lscpu 2>/dev/null | awk -F: '/Model name/ {sub(/^ /,"",$2); print $2}' || echo "?")"
  S=$(lscpu 2>/dev/null | awk -F: '/Socket\(s\)/{gsub(/ /,"",$2);print $2}')
  C=$(lscpu 2>/dev/null | awk -F: '/Core\(s\) per socket/{gsub(/ /,"",$2);print $2}')
  T=$(lscpu 2>/dev/null | awk -F: '/Thread\(s\) per core/{gsub(/ /,"",$2);print $2}')
  TOT="$(nproc || echo "?")"
  MEMT="$(awk '/MemTotal/{printf "%.1f GiB",$2/1048576}' /proc/meminfo 2>/dev/null || echo "? GiB")"
  SWAPT="$(awk '/SwapTotal/{printf "%.1f GiB",$2/1048576}' /proc/meminfo 2>/dev/null || echo "? GiB")"

  echo
  echo "| Componente | Detalle |"
  echo "|---|---|"
  echo "| Placa base | ${BV} ${BN} (rev ${BVER}) |"
  echo "| BIOS | ${BIOSVEN} ${BIOSV} (${BIOSD}) |"
  echo "| CPU | ${CPU_MODEL} — topología ${S}×${C}×${T} (${TOT} hilos) |"
  echo "| RAM/Swap | ${MEMT} / ${SWAPT} |"
  echo

  echo "**GPU(s):**"
  echo '```'
  (lspci -nn 2>/dev/null | grep -Ei 'vga|3d|display' || echo "No detectado")
  echo '```'
  echo

  echo "**Interfaz(es) de red:**"
  echo '```'
  (lspci -nn 2>/dev/null | grep -Ei 'ethernet' || echo "No detectado")
  echo '```'
  echo

  echo "**Discos (modelo/tamaño):**"
  echo '```'
  lsblk -d -o NAME,MODEL,SERIAL,SIZE,ROTA,TYPE 2>/dev/null | sed 's/\s\+/ /g' || echo "lsblk no disponible"
  echo '```'
  echo

  ########################################################################
  # Sistema
  ########################################################################
  echo "## Sistema"
  echo '```'
  uname -a 2>/dev/null || echo "uname no disponible"
  if command -v lsb_release >/dev/null 2>&1; then
    lsb_release -ds 2>/dev/null || true
  else
    grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"' || echo "OS desconocido"
  fi
  echo
  echo "Uptime:"
  uptime -p 2>/dev/null || echo "uptime no disponible"
  echo '```'
  echo

  ########################################################################
  # CPU y RAM
  ########################################################################
  echo "## CPU y RAM"
  echo '```'
  echo "CPUs: $(nproc 2>/dev/null || echo '?')"
  free -h 2>/dev/null || echo "free no disponible"
  echo '```'
  echo

  ########################################################################
  # Redes
  ########################################################################
  echo "## Redes (IPv4 depuradas)"
  echo '```'
  ip -br -4 addr 2>/dev/null | mask_all || echo "ip -4 no disponible"
  echo '```'
  echo

  ########################################################################
  # Almacenamiento
  ########################################################################
  echo "## Almacenamiento (consolidado)"
  echo
  echo '```'
  echo "df -hT:"
  df -hT 2>/dev/null | sed 's/\s\+/ /g' || echo "df -hT no disponible"
  echo
  echo "---"
  echo "lsblk:"
  lsblk -o NAME,FSTYPE,SIZE,TYPE,MOUNTPOINT 2>/dev/null | sed 's/\s\+/ /g' || echo "lsblk no disponible"
  echo '```'
  echo

  ########################################################################
  # Servicios
  ########################################################################
  echo "## Servicios (clave y fallos)"
  echo '```'
  echo "ssh: $(systemctl is-active ssh 2>/dev/null || echo desconocido)"
  echo "ufw: $(systemctl is-active ufw 2>/dev/null || echo desconocido)"

  if command -v docker >/dev/null 2>&1; then
    if systemctl is-active --quiet docker 2>/dev/null && docker info >/dev/null 2>&1; then
      echo "docker: active"
    elif systemctl is-active --quiet docker 2>/dev/null; then
      echo "docker: servicio activo (pero 'docker info' falló)"
    else
      echo "docker: instalado (servicio inactivo)"
    fi
  else
    if systemctl list-unit-files 2>/dev/null | grep -q '^docker\.service'; then
      echo "docker: servicio instalado, CLI no presente"
    else
      echo "docker: no instalado"
    fi
  fi

  echo "wg-quick@wg0: $(systemctl is-active wg-quick@wg0 2>/dev/null || echo desconocido)"
  echo
  echo "Unidades con fallo:"
  systemctl --failed 2>/dev/null || echo "No se pudo obtener systemctl --failed"
  echo '```'
  echo

  ########################################################################
  # UFW
  ########################################################################
  echo "## UFW"
  echo '```'
  if command -v ufw >/dev/null 2>&1 || [ -x /usr/sbin/ufw ]; then
    sudo -n ufw status numbered 2>/dev/null \
      || /usr/sbin/ufw status numbered 2>/dev/null \
      || ufw status numbered 2>/dev/null \
      || echo "UFW instalado pero sin permisos para ver el estado."
  else
    echo "UFW no instalado."
  fi
  echo '```'
  echo

  ########################################################################
  # WireGuard (resumen)
  ########################################################################
  echo "## WireGuard"
  echo '```'
  if command -v wg >/dev/null 2>&1; then
    wg show 2>/dev/null | mask_all || echo "wg show falló o no hay interfaces."
  else
    echo "WireGuard (wg) no disponible."
  fi
  echo '```'
  echo

  ########################################################################
  # Peers WireGuard (wg-list-peers si existe)
  ########################################################################
  echo "## Peers WireGuard"
  if WGPEERS="$(find_wg_list_peers)"; then
    echo
    echo "Salida wg-list-peers (IPs/puertos depurados):"
    echo
    echo '```'
    sudo -n "$WGPEERS" 2>/dev/null | mask_all \
      || "$WGPEERS" 2>/dev/null | mask_all \
      || echo "wg-list-peers no devolvió datos (¿falta NOPASSWD en sudoers?)."
    echo '```'
  else
    echo
    echo "_wg-list-peers no encontrado en PATH._"
  fi
  echo

  ########################################################################
  # Docker
  ########################################################################
  echo "## Docker"
  echo '```'
  if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    echo "Contenedores en ejecución:"
    docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' 2>/dev/null || true
    echo
    if docker compose version >/dev/null 2>&1; then
      echo "Docker Compose (v2) — stacks:"
      docker compose ls 2>/dev/null || true
    elif command -v docker-compose >/dev/null 2>&1; then
      echo "Docker Compose (v1) — proyectos:"
      docker-compose ls 2>/dev/null || docker-compose ps 2>/dev/null || true
    fi
    echo
    echo "Volúmenes:"
    docker volume ls 2>/dev/null || true
    echo
    echo "Imágenes (top 10 por tamaño):"
    docker images --format '{{.Repository}}:{{.Tag}}\t{{.Size}}' 2>/dev/null | head -n 10 || true
  else
    echo "Docker no accesible o no instalado."
  fi
  echo '```'
  echo

  ########################################################################
  # VMs
  ########################################################################
  echo "## VMs (libvirt)"
  echo '```'
  if command -v virsh >/dev/null 2>&1; then
    virsh list --all 2>/dev/null || echo "virsh list falló."
  else
    echo "libvirt/virsh no disponible."
  fi
  echo '```'
  echo

  ########################################################################
  # Backups (restic)
  ########################################################################
  echo "## Backups (restic)"
  echo '```'
  LOG="/var/log/backup_restic.log"
  if [ -r "$LOG" ]; then
    echo "Últimas 50 líneas del log (IPs/puertos depurados):"
    tail -n 50 "$LOG" 2>/dev/null | mask_all || echo "No se pudo leer el log."
  else
    echo "Log no legible por el usuario actual."
  fi
  echo '```'
} > "$OUT"

# Actualizar puntero al snapshot actual como archivo normal (no symlink)
if [ -L "$CURRENT" ]; then
  rm -f "$CURRENT"
fi
cp "$OUT" "$CURRENT"

echo "Escrito: $OUT"
