# Comandos y scripts (resumen)

_Generado: 2025-11-18 01:35_

Este documento es un **índice** para consulta rápida. Las guías completas están enlazadas.

## Índice

- [LANSCAN — Guía rápida](comandos/lan-scan.md)
- [WireGuard — Cheatsheet](comandos/wireguard.md)
- [Wake-on-LAN — Cheatsheet](comandos/wol.md)

## LANSCAN — Guía rápida


`lan-scan` lista dispositivos de la LAN con **IP, MAC, IFACE, HOSTNAME, VENDOR**.


[→ Abrir guía completa](comandos/lan-scan.md)

## WireGuard — Cheatsheet


_Generado: 2025-11-09 21:41_

    WireGuard — CHEATSHEET (comandos personalizados)
    
    Objetivo: operaciones habituales sin exponer claves.
    Convención: IP/32 = IP interna WG del peer. Nombres ↔ IP/32 en scripts/wg-peers.byip
    
    Subcomandos:
      list-peers         → Lista peers con NOMBRE, IP/32, HS(min), RX/TX, estado (🟢/🟡/⚫)
      add-peer <NOMBRE>  → Alta de peer nuevo (IP/32, claves, conf cliente, QR opcional)
      del-peer <NOMBRE>  → Baja de peer (elimina su IP/32)
      repair             → Repara wg0 (unidad, permisos, rutas)


[→ Abrir guía completa](comandos/wireguard.md)

## Wake-on-LAN — Cheatsheet


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


[→ Abrir guía completa](comandos/wol.md)

