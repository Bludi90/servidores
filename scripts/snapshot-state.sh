#!/usr/bin/env bash
set -euo pipefail
umask 022
export LC_ALL=C
export PATH="$PATH:/usr/local/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/alejandro/bin"

SERVER="$(hostname -s || echo server)"
STAMP="$(date +%F_%H%M)"
OUT_DIR="state/${SERVER}"
OUT="${OUT_DIR}/${STAMP}-state.md"

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

  echo "## Hardware"
  BV=$(board | sed -n '1p'); BN=$(board | sed -n '2p'); BVER=$(board | sed -n '3p')
  BIOSVEN=$(bios | sed -n '1p'); BIOSV=$(bios | sed -n '2p'); BIOSD=$(bios | sed -n '3p')
  CPU_MODEL="$(lscpu | awk -F: '/Model name/ {sub(/^ /,"",$2); print $2}')"
  S=$(lscpu | awk -F: '/Socket\(s\)/{gsub(/ /,"",$2);print $2}')
  C=$(lscpu | awk -F: '/Core\(s\) per socket/{gsub(/ /,"",$2);print $2}')
  T=$(lscpu | awk -F: '/Thread\(s\) per core/{gsub(/ /,"",$2);print $2}')
  TOT=$(lscpu | awk -F: '/^CPU\(s\)/{gsub(/ /,"",$2);print $2}')
  MEMT="$(awk '/MemTotal/{printf "%.1f GiB",$2/1048576}' /proc/meminfo)"
  SWAPT="$(awk '/SwapTotal/{printf "%.1f GiB",$2/1048576}' /proc/meminfo)"
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
  (lspci -nn | grep -Ei 'vga|3d|display' || echo "No detectado")
  echo '```'
  echo
  echo "**Interfaz(es) de red:**"
  echo '```'
  (lspci -nn | grep -Ei 'ethernet' || echo "No detectado")
  echo '```'
  echo
  echo "**Discos (modelo/tamaño):**"
  echo '```'
  lsblk -d -o NAME,MODEL,SERIAL,SIZE,ROTA,TYPE | sed 's/\s\+/ /g'
  echo '```'
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
  if lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS >/dev/null 2>&1; then
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS | sed 's/\s\+/ /g'
  else
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | sed 's/\s\+/ /g'
  fi
  echo '```'
  echo

  echo "## Servicios (clave y fallos)"
  echo '```'
  for s in ssh ufw docker wg-quick@wg0; do
    st="$(systemctl is-active "$s" 2>/dev/null || true)"; [ -n "$st" ] || st="desconocido"
    echo "$s: $st"
  done
  echo; echo "Unidades con fallo:"; systemctl --failed || true
  echo '```'
  echo

  echo "## UFW"
  echo '```'
  if [ -x /usr/sbin/ufw ] || command -v ufw >/dev/null 2>&1; then
    sudo -n ufw status numbered 2>/dev/null \
      || /usr/sbin/ufw status numbered 2>/dev/null \
      || echo "UFW instalado pero sin permisos para ver el estado."
  else
    echo "UFW no instalado."
  fi
  echo '```'
  echo

  echo "## WireGuard (sin claves)"
  echo '```'
  ip -br addr show wg0 2>/dev/null | mask_all || echo "wg0 no configurada."
  printf "Interfaces: "; (sudo -n wg show interfaces 2>/dev/null || wg show interfaces 2>/dev/null || echo "no disponibles")
  printf "Listen-port (wg0): "; (sudo -n wg show wg0 listen-port 2>/dev/null || echo "desconocido") | mask_ports
  echo
  echo '```'
  echo

  echo "**Peers (nombres)**"
  if WGPEERS="$(find_wg_list_peers)"; then
    echo
    echo "| Estado | Nombre | IP | HS (min) | RX | TX |"
    echo "|:--:|---|---|---:|---:|---:|"
    (sudo -n "$WGPEERS" 2>/dev/null || "$WGPEERS" 2>/dev/null) | awk '
      function tosec(hs,   sum,rest,n,u,s) {
        gsub(/ /,"",hs)
        if (hs=="now" || hs=="0s" || hs=="0m") return 0
        if (hs=="-" || hs=="" || hs=="n/a") return 999999
        sum=0; rest=hs
        while (match(rest,/([0-9]+)([smhd])/,a)) {
          n=a[1]; u=a[2]
          s=(u=="s"?n:(u=="m"?n*60:(u=="h"?n*3600:n*86400)))
          sum+=s
          rest=substr(rest,RSTART+RLENGTH)
        }
        if (sum==0 && rest ~ /^[0-9]+m$/) return (rest+0)*60
        return sum ? sum : 999999
      }
      BEGIN{ namec=1; ipc=2; hsc=5; rxc=6; txc=7 }
      NR==1 {
        for (i=1;i<=NF;i++) {
          if ($i ~ /^NOMBRE/) namec=i
          else if ($i=="IP") ipc=i
          else if ($i ~ /^HS/) hsc=i
          else if ($i=="RX") rxc=i
          else if ($i=="TX") txc=i
        }
        next
      }
      {
        name=$namec; ip=$ipc; hs=$(hsc); rx=$(rxc); tx=$(txc)
        secs=tosec(hs)
        stat=(secs<=600?"🟢":(secs<=3600?"🟡":"⚫"))
        rxm=rx; txm=tx
        if (rx ~ /^[0-9]+$/) rxm=sprintf("%.1f MiB", rx/1048576)
        if (tx ~ /^[0-9]+$/) txm=sprintf("%.1f MiB", tx/1048576)
        hsm=(secs<999999 ? sprintf("%.0fm", secs/60.0) : hs)
        printf("| %s | %s | %s | %s | %s | %s |\n", stat, name, ip, hsm, rxm, txm)
      }'
    echo
  else
    echo
    echo "_wg-list-peers no encontrado en PATH._"
    echo
  fi
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
  if command -v virsh >/dev/null 2%; then virsh list --all || true; else echo "libvirt/virsh no disponible."; fi
  echo '```'
  echo

  echo "## Backups (restic)"
  echo '```'
  LOG="/var/log/backup_restic.log"
  if [ -r "$LOG" ]; then
    echo "Últimas 50 líneas del log (IPs/puertos depurados):"; tail -n 50 "$LOG" | mask_all
  else
    echo "Log no legible por el usuario actual."
  fi
  echo '```'
} > "$OUT"

echo "Escrito: $OUT"
