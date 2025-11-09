# Comandos personalizados

_Generado: 2025-11-09 19:07_

- **Cheatsheet WireGuard:** [WIREGUARD.md](WIREGUARD.md)

## build-index.sh

    build-index.sh
    Genera docs/ESTADO.md con enlaces al último snapshot COMPLETO de cada host.
    Considera “completo” si tiene WireGuard, Docker y VMs.

## commit-and-push.sh

    commit-and-push.sh
    Genera snapshot, housekeeping, reconstruye índices y sube al repo.
    
    Flujo:
      1) snapshot-state.sh
      2) housekeeping.sh (limpia viejos snapshots y compacta sync.log)
      3) build-index.sh (docs/ESTADO.md)
      4) gen-commands-doc.sh (docs/COMANDOS.md)
      5) chequeo anti-secretos / tamaño
      6) commit & push
    
    Logs:
      state/<HOST>/sync.log (depurado)

## housekeeping.sh

    housekeeping.sh
    Conserva por defecto los últimos 200 snapshots por host y recorta sync.log.
    Cambiar con: KEEP=336 ./scripts/housekeeping.sh

## snapshot-state.sh

    snapshot-state.sh
    Crea state/<HOST>/<fecha>-state.md con:
    - Hardware (placa/BIOS/CPU/RAM/GPU/NICs/discos)
    - Sistema, redes depuradas, almacenamiento e inodos
    - Servicios (ssh, ufw, docker, wg-quick@wg0) y fallos
    - UFW (reglas)
    - WireGuard (sin claves) + tabla de peers con iconos (🟢/🟡/⚫)
    - Docker, VMs (libvirt), Backups (restic)
    
    Salida legible en GitHub (bloques de código y tablas).

## wg-list-peers

    wg-list-peers  [IFACE]
    Muestra peers de WireGuard con NOMBRE, IP/32, minutos desde último HS, RX/TX.
    
    Uso:
      wg-list-peers            # asume wg0
      wg-list-peers wg0        # interfaz explícita
    
    Notas:
    - Los nombres se leen de scripts/wg-peers.byip (formato: "10.8.0.11/32 pc-jandro").
    - No imprime claves. Endpoints se enmascaran en los snapshots.

## Resumen rápido

| Comando | Para qué sirve |
|---|---|
| `wg-list-peers` | Lista peers con nombre, IP/32, HS(min), RX/TX |
