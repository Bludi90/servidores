# Comandos y scripts (resumen)

_Generado: 2025-11-17 04:07_

Este documento es un **índice** para consulta rápida. Las guías completas están enlazadas.

## Índice

- [LANSCAN — Guía rápida](docs)
- [WireGuard — Cheatsheet](docs)
- [Wake-on-LAN — Cheatsheet](docs)

## LANSCAN — Guía rápida

    `lan-scan` lista dispositivos de la LAN con **IP, MAC, IFACE, HOSTNAME, VENDOR**.
    

**Opciones y subcomandos principales**

    - `lan-scan` → auto (rápido por defecto). Si la red > /24, clampa a /24.
    - `lan-scan --fast` → muy rápido (fping/ARP), sin DNS.
    - `lan-scan --deep` → exhaustivo (nmap -sn), con DNS.
    - `lan-scan --wide` → no clampa: usa el CIDR completo de la interfaz.

[→ Abrir guía completa](docs)

## WireGuard — Cheatsheet

    _Generado: 2025-11-09 21:41_
    

[→ Abrir guía completa](docs)

## Wake-on-LAN — Cheatsheet

    _Generado: 2025-11-09 19:27_
    

[→ Abrir guía completa](docs)

## Resumen rápido

| Comando/Script | Para qué sirve | Guía | Activo |
|---|---|---|:--:|
| `lan-scan` | `lan-scan` lista dispositivos de la LAN con **IP, MAC, IFACE, HOSTNAME, VENDOR**. | [Abrir](docs) | Sí |
| `wg` | _Generado: 2025-11-09 21:41_ | [Abrir](docs) | Sí |
| `wol` | _Generado: 2025-11-09 19:27_ | [Abrir](docs) | Sí |
