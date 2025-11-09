# Comandos personalizados

_Generado: 2025-11-09 21:42_

## Guías y hojas rápidas
- **Cheatsheet WireGuard:** [WIREGUARD.md](WIREGUARD.md)
- **Guía LAN Scan:** [LANSCAN.md](LANSCAN.md)
- **Guía Wake-on-LAN:** [WOL.md](WOL.md)

## wg


_Generado: 2025-11-09 21:41_

    WireGuard — CHEATSHEET (comandos personalizados)
    
    Objetivo: operaciones habituales sin exponer claves.
    Convención: IP/32 = IP interna WG del peer. Nombres ↔ IP/32 en scripts/wg-peers.byip
    
    Subcomandos:
      list-peers         → Lista peers con NOMBRE, IP/32, HS(min), RX/TX, estado (🟢/🟡/⚫)
      add-peer <NOMBRE>  → Alta de peer nuevo (IP/32, claves, conf cliente, QR opcional)
      del-peer <NOMBRE>  → Baja de peer (elimina su IP/32)
      repair             → Repara wg0 (unidad, permisos, rutas)

## list-peers

_Disponible: Sí (`/usr/bin/wg-list-peers`)_
    wireguard list-peers
    Binario real: wg-list-peers (usable como 'wg list-peers')
    
    Uso:
      wg list-peers [-h] [IFACE]     # ayuda con -h
      wg list-peers                   # ejecuta listado
      wg-peer-list [IFACE]            # alias (si existe)
    
    Descripción:
      Lista peers con NOMBRE, IP/32, minutos desde último HS, RX/TX y estado:
       - 🟢 HS ≤ 10 min, 🟡 10–60 min, ⚫ > 60 min o sin HS.

## add-peer

_Disponible: Sí (`/usr/local/sbin/wg-add-peer`)_
    wireguard add-peer
    Uso:
      wg-add-peer <NOMBRE> [--ip 10.8.0.X/32] [--qr] [--out ./client.conf]
    
    Descripción:
      Da de alta un peer:
       1) busca IP/32 libre (o usa --ip),
       2) genera claves del cliente,
       3) añade el peer a wg0 y recarga,
       4) guarda el .conf del cliente (y QR si --qr).
    
    Archivos implicados:
      scripts/wg-peers.byip         # mapeo IP/32 ↔ NOMBRE
      /etc/wireguard/wg0.conf       # configuración del servidor (aplicación con wg-quick)

## del-peer

_Disponible: Sí (`/usr/local/sbin/wg-del-peer`)_
    wireguard del-peer
    Uso:
      wg-del-peer <NOMBRE>
    
    Descripción:
      Da de baja un peer, quita su IP/32 y lo elimina del wg0.
      Mantiene copia de seguridad del bloque eliminado.

## repair

_Disponible: Sí (`/usr/local/sbin/wg-repair`)_
    wireguard repair
    Binario real: wg-repair
    
    Uso:
      wg-repair           # solo diagnóstico
      wg-repair --fix     # intenta levantar wg0 (wg-quick down/up, systemctl enable/start)
    
    Descripción:
      Revisa servicio wg-quick@wg0, ip_forward, socket UDP 51820 y estado de wg.
      Si hay sudo sin contraseña, puede relanzar el servicio (sin tocar claves).


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

## lan-scan

    lan-scan — descubre IP/MAC/Vendor en la LAN (ARP/Nmap)
    USO
      lan-scan                    # autodetecta interfaz/red
      lan-scan -i enp10s0         # fuerza interfaz
      lan-scan -n 192.168.1.0/24  # fuerza red
      lan-scan --engine arp-scan  # usa arp-scan (recomendado en LAN)
      lan-scan --engine nmap      # usa Nmap (ARP discovery)
      lan-scan --refresh          # ping sweep para poblar ARP si hace falta
      lan-scan --debug            # muestra decisiones (iface/red/engine)
    Ejemplos
      lan-scan --debug
      lan-scan -i enp10s0 --engine arp-scan --debug
      lan-scan -i enp10s0 -n 192.168.1.0/24 --engine nmap

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

## wolctl

    wolctl — gestor WOL (list/show/wake/check/add/set/rename/rm). Hosts en /etc/wolctl/hosts.tsv

## wol

    wol — atajo de "wolctl wake". Ej: 'wol pc-main1'

## Resumen rápido

| Comando | Para qué sirve |
|---|---|
| `wg list-peers` | Ver ayuda |
| `wg add-peer` | Ver ayuda |
| `wg del-peer` | Ver ayuda |
| `wg repair` | Ver ayuda |
| `build-index.sh` | build-index.sh |
| `commit-and-push.sh` | commit-and-push.sh |
| `housekeeping.sh` | housekeeping.sh |
| `lan-scan` | lan-scan — descubre IP/MAC/Vendor en la LAN (ARP/Nmap) |
| `snapshot-state.sh` | snapshot-state.sh |
| `wg-list-peers` | wg-list-peers  [IFACE] |
| `wolctl` | wolctl — gestor WOL (list/show/wake/check/add/set/rename/rm). Hosts en /etc/wolctl/hosts.tsv |
| `wol` | wol — atajo de "wolctl wake". Ej: 'wol pc-main1' |

## Listado final — contenidos de ayuda (snapshot)

```text
--- docs/WIREGUARD.md ---
# WireGuard — Cheatsheet

_Generado: 2025-11-09 21:41_

    WireGuard — CHEATSHEET (comandos personalizados)
    
    Objetivo: operaciones habituales sin exponer claves.
    Convención: IP/32 = IP interna WG del peer. Nombres ↔ IP/32 en scripts/wg-peers.byip
    
    Subcomandos:
      list-peers         → Lista peers con NOMBRE, IP/32, HS(min), RX/TX, estado (🟢/🟡/⚫)
      add-peer <NOMBRE>  → Alta de peer nuevo (IP/32, claves, conf cliente, QR opcional)
      del-peer <NOMBRE>  → Baja de peer (elimina su IP/32)
      repair             → Repara wg0 (unidad, permisos, rutas)

## list-peers

_Disponible: Sí (`/usr/bin/wg-list-peers`)_
    wireguard list-peers
    Binario real: wg-list-peers (usable como 'wg list-peers')
    
    Uso:
      wg list-peers [-h] [IFACE]     # ayuda con -h
      wg list-peers                   # ejecuta listado
      wg-peer-list [IFACE]            # alias (si existe)
    
    Descripción:
      Lista peers con NOMBRE, IP/32, minutos desde último HS, RX/TX y estado:
       - 🟢 HS ≤ 10 min, 🟡 10–60 min, ⚫ > 60 min o sin HS.

## add-peer

_Disponible: Sí (`/usr/local/sbin/wg-add-peer`)_
    wireguard add-peer
    Uso:
      wg-add-peer <NOMBRE> [--ip 10.8.0.X/32] [--qr] [--out ./client.conf]
    
    Descripción:
      Da de alta un peer:
       1) busca IP/32 libre (o usa --ip),
       2) genera claves del cliente,
       3) añade el peer a wg0 y recarga,
       4) guarda el .conf del cliente (y QR si --qr).
    
    Archivos implicados:
      scripts/wg-peers.byip         # mapeo IP/32 ↔ NOMBRE
      /etc/wireguard/wg0.conf       # configuración del servidor (aplicación con wg-quick)

## del-peer

_Disponible: Sí (`/usr/local/sbin/wg-del-peer`)_
    wireguard del-peer
    Uso:
      wg-del-peer <NOMBRE>
    
    Descripción:
      Da de baja un peer, quita su IP/32 y lo elimina del wg0.
      Mantiene copia de seguridad del bloque eliminado.

## repair

_Disponible: Sí (`/usr/local/sbin/wg-repair`)_
    wireguard repair
    Binario real: wg-repair
    
    Uso:
      wg-repair           # solo diagnóstico
      wg-repair --fix     # intenta levantar wg0 (wg-quick down/up, systemctl enable/start)
    
    Descripción:
      Revisa servicio wg-quick@wg0, ip_forward, socket UDP 51820 y estado de wg.
      Si hay sudo sin contraseña, puede relanzar el servicio (sin tocar claves).


--- scripts/help.d/wireguard/add-peer.help ---
wireguard add-peer
Uso:
  wg-add-peer <NOMBRE> [--ip 10.8.0.X/32] [--qr] [--out ./client.conf]

Descripción:
  Da de alta un peer:
   1) busca IP/32 libre (o usa --ip),
   2) genera claves del cliente,
   3) añade el peer a wg0 y recarga,
   4) guarda el .conf del cliente (y QR si --qr).

Archivos implicados:
  scripts/wg-peers.byip         # mapeo IP/32 ↔ NOMBRE
  /etc/wireguard/wg0.conf       # configuración del servidor (aplicación con wg-quick)

--- scripts/help.d/wireguard/del-peer.help ---
wireguard del-peer
Uso:
  wg-del-peer <NOMBRE>

Descripción:
  Da de baja un peer, quita su IP/32 y lo elimina del wg0.
  Mantiene copia de seguridad del bloque eliminado.

--- scripts/help.d/wireguard/_index.help ---
WireGuard — CHEATSHEET (comandos personalizados)

Objetivo: operaciones habituales sin exponer claves.
Convención: IP/32 = IP interna WG del peer. Nombres ↔ IP/32 en scripts/wg-peers.byip

Subcomandos:
  list-peers         → Lista peers con NOMBRE, IP/32, HS(min), RX/TX, estado (🟢/🟡/⚫)
  add-peer <NOMBRE>  → Alta de peer nuevo (IP/32, claves, conf cliente, QR opcional)
  del-peer <NOMBRE>  → Baja de peer (elimina su IP/32)
  repair             → Repara wg0 (unidad, permisos, rutas)

--- scripts/help.d/wireguard/list-peers.help ---
wireguard list-peers
Binario real: wg-list-peers (usable como 'wg list-peers')

Uso:
  wg list-peers [-h] [IFACE]     # ayuda con -h
  wg list-peers                   # ejecuta listado
  wg-peer-list [IFACE]            # alias (si existe)

Descripción:
  Lista peers con NOMBRE, IP/32, minutos desde último HS, RX/TX y estado:
   - 🟢 HS ≤ 10 min, 🟡 10–60 min, ⚫ > 60 min o sin HS.

--- scripts/help.d/wireguard/repair.help ---
wireguard repair
Binario real: wg-repair

Uso:
  wg-repair           # solo diagnóstico
  wg-repair --fix     # intenta levantar wg0 (wg-quick down/up, systemctl enable/start)

Descripción:
  Revisa servicio wg-quick@wg0, ip_forward, socket UDP 51820 y estado de wg.
  Si hay sudo sin contraseña, puede relanzar el servicio (sin tocar claves).

--- scripts/help.d/build-index.sh.help ---
build-index.sh
Genera docs/ESTADO.md con enlaces al último snapshot COMPLETO de cada host.
Considera “completo” si tiene WireGuard, Docker y VMs.

--- scripts/help.d/commit-and-push.sh.help ---
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

--- scripts/help.d/housekeeping.sh.help ---
housekeeping.sh
Conserva por defecto los últimos 200 snapshots por host y recorta sync.log.
Cambiar con: KEEP=336 ./scripts/housekeeping.sh

--- scripts/help.d/lan-scan.help ---
lan-scan — descubre IP/MAC/Vendor en la LAN (ARP/Nmap)
USO
  lan-scan                    # autodetecta interfaz/red
  lan-scan -i enp10s0         # fuerza interfaz
  lan-scan -n 192.168.1.0/24  # fuerza red
  lan-scan --engine arp-scan  # usa arp-scan (recomendado en LAN)
  lan-scan --engine nmap      # usa Nmap (ARP discovery)
  lan-scan --refresh          # ping sweep para poblar ARP si hace falta
  lan-scan --debug            # muestra decisiones (iface/red/engine)
Ejemplos
  lan-scan --debug
  lan-scan -i enp10s0 --engine arp-scan --debug
  lan-scan -i enp10s0 -n 192.168.1.0/24 --engine nmap

--- scripts/help.d/snapshot-state.sh.help ---
snapshot-state.sh
Crea state/<HOST>/<fecha>-state.md con:
- Hardware (placa/BIOS/CPU/RAM/GPU/NICs/discos)
- Sistema, redes depuradas, almacenamiento e inodos
- Servicios (ssh, ufw, docker, wg-quick@wg0) y fallos
- UFW (reglas)
- WireGuard (sin claves) + tabla de peers con iconos (🟢/🟡/⚫)
- Docker, VMs (libvirt), Backups (restic)

Salida legible en GitHub (bloques de código y tablas).

--- scripts/help.d/wg-list-peers.help ---
wg-list-peers  [IFACE]
Muestra peers de WireGuard con NOMBRE, IP/32, minutos desde último HS, RX/TX.

Uso:
  wg-list-peers            # asume wg0
  wg-list-peers wg0        # interfaz explícita

Notas:
- Los nombres se leen de scripts/wg-peers.byip (formato: "10.8.0.11/32 pc-jandro").
- No imprime claves. Endpoints se enmascaran en los snapshots.

--- scripts/help.d/wolctl.help ---
wolctl — gestor WOL (list/show/wake/check/add/set/rename/rm). Hosts en /etc/wolctl/hosts.tsv

--- scripts/help.d/wol.help ---
wol — atajo de "wolctl wake". Ej: 'wol pc-main1'

```
