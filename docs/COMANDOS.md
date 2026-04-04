# Comandos y scripts (resumen)

_Generado: 2026-04-04 19:08_

Este documento es un **índice** para consulta rápida. Las guías completas están enlazadas.

## Índice

- [DR WireGuard wg0 (main1 -> backup1)](comandos/dr-wg0-promote.md)
- [import-peli](comandos/import-peli.md)
- [LAN-Scan — Guía rápida](comandos/lan-scan.md)
- [srv-health](comandos/srv-health.md)
- [WireGuard — Cheatsheet](comandos/wireguard.md)
- [Wake-on-LAN — Cheatsheet](comandos/wol.md)
- [zfs-repl-backup1-freshness](comandos/zfs-repl-backup1-freshness.md)
- [zfs-repl-backup1](comandos/zfs-repl-backup1.md)
- [zfs-repl-backup1-nightly](comandos/zfs-repl-backup1-nightly.md)
- [zfs-repl-backup1-status](comandos/zfs-repl-backup1-status.md)
- [zfs-restore-backup1](comandos/zfs-restore-backup1.md)

## DR WireGuard wg0 (main1 -> backup1)

Failover de emergencia del WireGuard principal (wg0) desde main1 a backup1. Si main1 cae: entrar por wgr0 (rescue), conmutar el port-forward UDP/51820 al backup1 y ejecutar `dr-wg0-promote --force`. Para volver atrás: devolver el port-forward a main1 y ejecutar `dr-wg0-demote`.

[→ Abrir guía completa](comandos/dr-wg0-promote.md)

## import-peli

Importa una película desde un disco externo a la biblioteca de Jellyfin, creando la carpeta `Título (Año)`, copiando el vídeo y los subtítulos, renombrándolos y ajustando permisos en `/srv/storage/media`.

[→ Abrir guía completa](comandos/import-peli.md)

## LAN-Scan — Guía rápida

`lan-scan` escanea la red local y muestra una tabla con IP, MAC, interfaz
(IFACE), hostname y fabricante (VENDOR), usando ARP/fping/nmap según el modo.

Uso típico:

- `lan-scan` → escaneo rápido equilibrado (clampa a /24 si la red es más grande).
- `lan-scan --fast` → muy rápido (fping/ARP, sin DNS).
- `lan-scan --deep` → exhaustivo (nmap -sn, con DNS).

[→ Abrir guía completa](comandos/lan-scan.md)

## srv-health

`srv-health` hace un chequeo rápido de salud del servidor y muestra en pocas líneas el estado general de `main1`: cabecera del sistema, ZFS, réplica hacia `backup1`, servicios críticos, UPS/NUT, WireGuard, Docker, DNS, unidades systemd fallidas y logs clave.
Uso típico:
~~~bash
srv-health
srv-health --short
~~~

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

## zfs-repl-backup1-freshness

Chequeo de frescura operativa del sistema de réplicas hacia `backup1`. Lee `zfs-repl-backup1-runs.tsv`, busca la última ejecución real correcta y devuelve `Bak OK`, `Bak WARN` o `Bak FAIL` según la antigüedad de esa última réplica buena.

[→ Abrir guía completa](comandos/zfs-repl-backup1-freshness.md)

## zfs-repl-backup1

Comando manual para replicar incrementalmente el pool `tank` de `main1` hacia `backup1` usando ZFS (`zfs send | zfs receive`). Mantiene el último snapshot común en un fichero de estado, permite `--dry-run`, estima el tamaño antes de enviar y, si `pv` está instalado, muestra una línea viva de progreso.

[→ Abrir guía completa](comandos/zfs-repl-backup1.md)

## zfs-repl-backup1-nightly

Wrapper operativo para la réplica diaria hacia `backup1`. Comprueba requisitos, enciende `backup1` por WOL si hace falta, espera a que vuelva por ping/SSH, lanza `zfs-repl-backup1`, registra el resultado en log y en `runs.tsv`, y apaga `backup1` al final si lo encendió este mismo wrapper.

[→ Abrir guía completa](comandos/zfs-repl-backup1-nightly.md)

## zfs-repl-backup1-status

Resumen semanal del sistema de réplicas hacia `backup1`, calculado a partir de `zfs-repl-backup1-runs.tsv`. Cuenta solo ejecuciones reales (`mode=real`) y devuelve una línea compacta tipo `Snpsht OK/WARN/FAIL`, útil para monitorización, revisión manual y consumo desde otros scripts.

[→ Abrir guía completa](comandos/zfs-repl-backup1-status.md)

## zfs-restore-backup1

Restore controlado desde la réplica ZFS de `backup1` hacia un directorio local de staging. Comprueba que el snapshot exista, crea un clone temporal remoto, empaqueta la subruta pedida, la copia al host local, la extrae en destino y limpia los temporales al final.

[→ Abrir guía completa](comandos/zfs-restore-backup1.md)

