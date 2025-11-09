# Comandos y scripts (resumen)

_Generado: 2025-11-09 21:59_

Este documento es un **índice**. Las guías completas viven en **docs/comandos/**.

## Índice de guías

- [build-index.sh — índice de snapshots](comandos/build-index.md)
- [commit-and-push.sh — subir cambios con controles](comandos/commit-and-push.md)
- [housekeeping.sh — limpieza de artefactos](comandos/housekeeping.md)
- [lan-scan — escaneo rápido de LAN](comandos/lan-scan.md)
- [snapshot-state.sh — foto del sistema](comandos/snapshot-state.md)
- [WireGuard (wg) — atajos y estado](comandos/wireguard.md)
- [wol / wolctl / hib / lan2wol — Wake-on-LAN y energía](comandos/wol.md)

## build-index.sh — índice de snapshots

    Crea `docs/ESTADO.md` con enlaces a snapshots “completos” (WireGuard, Docker, VMs) y avisa si el más reciente está incompleto.

[→ Abrir guía completa](comandos/build-index.md)

## commit-and-push.sh — subir cambios con controles

    Automatiza snapshot, limpieza, índice, chequeo anti-secretos y **push**. Aborta si encuentra posibles secretos o ficheros grandes. Úsalo tras cambios relevantes de configuración o docs.

[→ Abrir guía completa](comandos/commit-and-push.md)

## housekeeping.sh — limpieza de artefactos

    Compacta `sync.log` y elimina snapshots antiguos conservando los últimos **KEEP** (por defecto 200). Mantiene el repo ligero.

[→ Abrir guía completa](comandos/housekeeping.md)

## lan-scan — escaneo rápido de LAN

    Descubre dispositivos en la red local y muestra **IP, MAC, IFACE, HOSTNAME y VENDOR**. Por defecto es rápido (si la red > /24, limita a /24). Modos: `--fast`, `--deep`, `--wide`. Útil para poblar WOL y diagnosticar conectividad.

[→ Abrir guía completa](comandos/lan-scan.md)

## snapshot-state.sh — foto del sistema

    Genera `state/<host>/<fecha>-state.md` con hardware, red, servicios (SSH, UFW, Docker, WG), discos y logs clave (restic) con anonimización de IP/puertos.

[→ Abrir guía completa](comandos/snapshot-state.md)

## WireGuard (wg) — atajos y estado

    Conjunto de atajos para trabajar con WireGuard sin exponer claves: listado legible de peers, utilidades de alta/baja y reparación básica del servicio.  Subcomandos: - list-peers - add-peer - del-peer - repair

Subcomandos:

- list-peers
- add-peer
- del-peer
- repair

[→ Abrir guía completa](comandos/wireguard.md)

## wol / wolctl / hib / lan2wol — Wake-on-LAN y energía

    Gestión de equipos vía “magic packet”: **despertar (wol/wolctl)**, **hibernar (hib)** y **altas rápidas (lan2wol)** con base de datos en `/etc/wolctl/hosts.tsv`. Operativa recomendada dentro de la **VPN**.

[→ Abrir guía completa](comandos/wol.md)

## Resumen rápido

| Comando/Script | Para qué sirve | Guía | Activo |
|---|---|---|:--:|
| `build-index` | Crea `docs/ESTADO.md` con enlaces a snapshots “completos” (WireGuard, Docker, VMs) y avisa si el más reciente está incompleto. | [Abrir](comandos/build-index.md) | Sí |
| `commit-and-push` | Automatiza snapshot, limpieza, índice, chequeo anti-secretos y **push**. Aborta si encuentra posibles secretos o ficheros grandes. Úsalo tras cambios relevantes de configuración o docs. | [Abrir](comandos/commit-and-push.md) | Sí |
| `housekeeping` | Compacta `sync.log` y elimina snapshots antiguos conservando los últimos **KEEP** (por defecto 200). Mantiene el repo ligero. | [Abrir](comandos/housekeeping.md) | Sí |
| `lan-scan` | Descubre dispositivos en la red local y muestra **IP, MAC, IFACE, HOSTNAME y VENDOR**. Por defecto es rápido (si la red > /24, limita a /24). Modos: `--fast`, `--deep`, `--wide`. Útil para poblar WOL y diagnosticar conectividad. | [Abrir](comandos/lan-scan.md) | Sí |
| `snapshot-state` | Genera `state/<host>/<fecha>-state.md` con hardware, red, servicios (SSH, UFW, Docker, WG), discos y logs clave (restic) con anonimización de IP/puertos. | [Abrir](comandos/snapshot-state.md) | Sí |
| `wg` | Conjunto de atajos para trabajar con WireGuard sin exponer claves: listado legible de peers, utilidades de alta/baja y reparación básica del servicio.  Subcomandos: - list-peers - add-peer - del-peer - repair | [Abrir](comandos/wireguard.md) | Sí |
| `wol` | Gestión de equipos vía “magic packet”: **despertar (wol/wolctl)**, **hibernar (hib)** y **altas rápidas (lan2wol)** con base de datos en `/etc/wolctl/hosts.tsv`. Operativa recomendada dentro de la **VPN**. | [Abrir](comandos/wol.md) | Sí |
