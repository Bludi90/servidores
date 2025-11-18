# Comandos y scripts (resumen)

_Generado: 2025-11-18 07:07_

Este documento es un **índice** para consulta rápida. Las guías completas están enlazadas.

## Índice

- [LAN-Scan — Guía rápida](comandos/lan-scan.md)
- [Server-Health — Chequeo rápido del servidor - Cheatsheet](comandos/srv-health.md)
- [WireGuard — Cheatsheet](comandos/wireguard.md)
- [Wake-on-LAN — Cheatsheet](comandos/wol.md)

## LAN-Scan — Guía rápida

`lan-scan` escanea la red local y muestra una tabla con IP, MAC, interfaz
(IFACE), hostname y fabricante (VENDOR), usando ARP/fping/nmap según el modo.

Uso típico:

- `lan-scan` → escaneo rápido equilibrado (clampa a /24 si la red es más grande).
- `lan-scan --fast` → muy rápido (fping/ARP, sin DNS).
- `lan-scan --deep` → exhaustivo (nmap -sn, con DNS).

[→ Abrir guía completa](comandos/lan-scan.md)

## Server-Health — Chequeo rápido del servidor - Cheatsheet

`srv-health` hace un chequeo rápido del servidor y muestra en unas pocas líneas
el estado de ZFS (pool `tank`), servicios críticos (WireGuard, Docker, cron,
smartd, zfs-zed), WireGuard `wg0`, Docker y algunas métricas básicas
(uptime, carga, memoria, unidades systemd fallidas y logs clave).

Uso típico:

```bash
srv-health        # vista completa, con logs
srv-health --short  # vista reducida, solo estado esencial
```

[→ Abrir guía completa](comandos/srv-health.md)

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
dirigidos a su MAC. En este entorno se gestiona con `wolctl` y un fichero de hosts
centralizado en `/etc/wolctl/hosts.tsv`.

Uso típico abreviado:
```bash
wol nombre-host
```
Donde "nombre-host" es el NAME definido en el fichero de hosts (por ejemplo,
un pc-sobremesa o un pt-lenovo).

[→ Abrir guía completa](comandos/wol.md)

