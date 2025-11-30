#!/usr/bin/env bash
# wg-recover.sh — reactivar WireGuard de forma segura y mostrar diagnóstico breve
# Uso: sudo wg-recover.sh [iface] [puerto]
set -euo pipefail

IFACE="${1:-wg0}"
WG_PORT="${2:-51820}"
SERVICE="wg-quick@${IFACE}.service"

log(){ printf "[%s] %s\n" "$(date -Iseconds)" "$*"; }

# 0) Comprobaciones
if [[ $EUID -ne 0 ]]; then
  echo "Ejecuta como root: sudo $0 [iface] [puerto]" >&2; exit 1
fi
command -v wg >/dev/null || { echo "WireGuard no está instalado (falta 'wg')."; exit 1; }

log "Recuperación de ${IFACE} (puerto UDP ${WG_PORT})"

# 1) Bajamos interfaz y limpiamos estado de systemd
log "Bajando interfaz (si estaba arriba)..."
wg-quick down "${IFACE}" 2>/dev/null || true
systemctl reset-failed "${SERVICE}" 2>/dev/null || true

# 2) Subimos interfaz y, si falla, mostramos logs útiles
log "Levantando interfaz..."
if ! wg-quick up "${IFACE}"; then
  echo "=== ERROR: wg-quick up ${IFACE} falló. Últimos logs ==="
  journalctl -u "${SERVICE}" -n 120 --no-pager || true
  exit 1
fi

# 3) Ajustes rápidos no destructivos
# 3.1) Habilitar reenvío IPv4 (temporal, por si se perdió)
if [[ "$(sysctl -n net.ipv4.ip_forward 2>/dev/null || echo 0)" != "1" ]]; then
  log "Activando net.ipv4.ip_forward=1 (temporal; persiste en sysctl.d si lo deseas)..."
  sysctl -w net.ipv4.ip_forward=1 >/dev/null || true
fi

# 3.2) UFW: abrir 51820/udp si está activo y no existe regla
if command -v ufw >/dev/null && ufw status | grep -qE "Status: active"; then
  if ! ufw status | grep -qE "\b${WG_PORT}/udp\b.*ALLOW"; then
    log "Añadiendo regla UFW ${WG_PORT}/udp..."
    ufw allow "${WG_PORT}/udp" || true
  fi
fi

# 4) Diagnóstico breve
log "Estado wg:"
wg show "${IFACE}" || true
log "IP de interfaz:"
ip -brief addr show "${IFACE}" || true
log "Puerto en escucha (UDP):"
ss -H -ulpn | grep -E "(^|:)${WG_PORT}\b" || echo "No se ve ${WG_PORT}/udp en escucha (revisa firewall/router)."

# 5) Escucha rápida de tráfico (si está tcpdump)
if command -v tcpdump >/dev/null; then
  log "Escucha 5s en udp/${WG_PORT} (activa el cliente ahora para ver paquetes):"
  timeout 5 tcpdump -ni any "udp port ${WG_PORT}" -c 1 || echo "Sin tráfico en 5s (puede ser normal si el cliente no habló)."
fi

log "Recuperación finalizada."
