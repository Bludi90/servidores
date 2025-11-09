# Wake-on-LAN — Cheatsheet

_Generado: 2025-11-09 19:27_

    WOL (Wake-on-LAN)
    - Fichero de hosts: /etc/wolctl/hosts.tsv (TSV con cabecera)
      Campos: NAME  IF_LAN  MAC  IP  WINUSER  RUSTDESK_PORT  NOTES
      - NAME: se recomienda minúsculas (case-insensitive).
      - IF_LAN: interfaz LAN (p.ej. enp10s0). Si está vacío o "-" se autodetecta por IP.
    - Envío: combina L2 (etherwake broadcast) + UDP (wakeonlan, por defecto puerto 9).
    - Requisitos: etherwake, wakeonlan, tcpdump (para 'check').
    - Consejos:
      * BIOS: WOL/PME activo; ErP/DeepSleep desactivado; "Power on by PCI-E" activo.
      * Windows: desactivar Inicio rápido; permitir reactivar por adaptador; "Wake on magic packet".
      * Mejor hibernación S4 (no apagado S5).

## wolctl

_Disponible: Sí (`/usr/local/bin/wolctl`)_

    wolctl — gestor Wake-on-LAN con /etc/wolctl/hosts.tsv
    
    USO
      wolctl list
      wolctl show <name>
      wolctl wake <name> [name2 ...] [--iface IFACE] [--broadcast|--unicast] [--port 7|9]
      wolctl wake --all
      wolctl check <name>
      wolctl add <name> <mac> <ip> [IFACE|-]
      wolctl set <name> iface|ip|mac|user|port|notes <valor>
      wolctl rename <old> <new>
      wolctl rm <name>
      wolctl -h | --help | -help
    
    EJEMPLOS
      wolctl list
      wolctl show pc-main1
      wolctl wake pc-main1
      wolctl wake --all
      wolctl add pc-lenovo aa:bb:cc:11:22:33 192.168.1.50 enp10s0
      wolctl check pc-main1

## wol

_Disponible: Sí (`/usr/local/bin/wol`)_

    wol — atajo de "wolctl wake"
    USO
      wol <name ...>        # igual que 'wolctl wake <name ...>'
      wol -h | --help       # muestra la ayuda de wolctl
