# Comandos y scripts (resumen)

_Generado: 2025-11-09 22:04_

Este documento es un **índice** para consulta rápida. Las guías completas están enlazadas.

## Índice

- [build-index.sh — índice de snapshots](docs)
- [commit-and-push.sh — subir cambios con controles](docs)
- [housekeeping.sh — limpieza de artefactos](docs)
- [lan-scan — escaneo rápido de LAN](docs)
- [snapshot-state.sh — foto del sistema](docs)
- [WireGuard (wg) — atajos y estado](docs)
- [wol / wolctl / hib / lan2wol — Wake-on-LAN y energía](docs)

## build-index.sh — índice de snapshots

    Crea `docs/ESTADO.md` con enlaces a snapshots “completos” (WireGuard, Docker, VMs) y avisa si el más reciente está incompleto.

[→ Abrir guía completa](docs)

## commit-and-push.sh — subir cambios con controles

    Automatiza snapshot, limpieza, índice, chequeo anti-secretos y **push**. Aborta si encuentra posibles secretos o ficheros grandes. Úsalo tras cambios relevantes de configuración o docs.

[→ Abrir guía completa](docs)

## housekeeping.sh — limpieza de artefactos

    Compacta `sync.log` y elimina snapshots antiguos conservando los últimos **KEEP** (por defecto 200). Mantiene el repo ligero.

[→ Abrir guía completa](docs)

## lan-scan — escaneo rápido de LAN

    Descubre dispositivos en la red local y muestra **IP, MAC, IFACE, HOSTNAME y VENDOR**. Por defecto es rápido (si la red > /24, limita a /24). Modos: `--fast`, `--deep`, `--wide`. Útil para poblar WOL y diagnosticar conectividad.

[→ Abrir guía completa](docs)

## snapshot-state.sh — foto del sistema

    Genera `state/<host>/<fecha>-state.md` con hardware, red, servicios (SSH, UFW, Docker, WG), discos y logs clave (restic) con anonimización de IP/puertos.

[→ Abrir guía completa](docs)

## WireGuard (wg) — atajos y estado

    Conjunto de atajos para trabajar con WireGuard sin exponer claves: listado legible de peers, utilidades de alta/baja y reparación básica del servicio.
    

[→ Abrir guía completa](docs)

## wol / wolctl / hib / lan2wol — Wake-on-LAN y energía

    Gestión de equipos vía “magic packet”: **despertar (wol/wolctl)**, **hibernar (hib)** y **altas rápidas (lan2wol)** con base de datos en `/etc/wolctl/hosts.tsv`. Operativa recomendada dentro de la **VPN**.

[→ Abrir guía completa](docs)

## Resumen rápido

| Comando/Script | Para qué sirve | Guía | Activo |
|---|---|---|:--:|
| `build-index` | Crea `docs/ESTADO.md` con enlaces a snapshots “completos” (WireGuard, Docker, VMs) y avisa si el más reciente está incompleto. | [Abrir](docs) | Sí |
| `commit-and-push` | Automatiza snapshot, limpieza, índice, chequeo anti-secretos y **push**. Aborta si encuentra posibles secretos o ficheros grandes. Úsalo tras cambios relevantes de configuración o docs. | [Abrir](docs) | Sí |
| `housekeeping` | Compacta `sync.log` y elimina snapshots antiguos conservando los últimos **KEEP** (por defecto 200). Mantiene el repo ligero. | [Abrir](docs) | Sí |
| `lan-scan` | Descubre dispositivos en la red local y muestra **IP, MAC, IFACE, HOSTNAME y VENDOR**. Por defecto es rápido (si la red > /24, limita a /24). Modos: `--fast`, `--deep`, `--wide`. Útil para poblar WOL y diagnosticar conectividad. | [Abrir](docs) | Sí |
| `snapshot-state` | Genera `state/<host>/<fecha>-state.md` con hardware, red, servicios (SSH, UFW, Docker, WG), discos y logs clave (restic) con anonimización de IP/puertos. | [Abrir](docs) | Sí |
| `wg` | Conjunto de atajos para trabajar con WireGuard sin exponer claves: listado legible de peers, utilidades de alta/baja y reparación básica del servicio. | [Abrir](docs) | Sí |
| `wol` | Gestión de equipos vía “magic packet”: **despertar (wol/wolctl)**, **hibernar (hib)** y **altas rápidas (lan2wol)** con base de datos en `/etc/wolctl/hosts.tsv`. Operativa recomendada dentro de la **VPN**. | [Abrir](docs) | Sí |
