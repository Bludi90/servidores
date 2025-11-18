# Comandos y scripts (resumen)

_Generado: 2025-11-18 01:47_

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

Wake-on-LAN (WOL) te permite encender equipos a distancia usando paquetes mágicos
dirigidos a su MAC. En mi entorno lo gestiono con `wolctl` y un fichero de hosts
centralizado en `/etc/wolctl/hosts.tsv`.

[→ Abrir guía completa](comandos/wol.md)

