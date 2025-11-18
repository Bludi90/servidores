# Comandos y scripts (resumen)

_Generado: 2025-11-18 03:45_

Este documento es un **índice** para consulta rápida. Las guías completas están enlazadas.

## Índice

- [LANSCAN — Guía rápida](comandos/lan-scan.md)
- [srv-health — Chequeo rápido del servidor](comandos/srv-health.md)
- [WireGuard — Cheatsheet](comandos/wireguard.md)
- [Wake-on-LAN — Cheatsheet](comandos/wol.md)

## LANSCAN — Guía rápida


`lan-scan` lista dispositivos de la LAN con **IP, MAC, IFACE, HOSTNAME, VENDOR**.


[→ Abrir guía completa](comandos/lan-scan.md)

## srv-health — Chequeo rápido del servidor

`srv-health` hace un chequeo rápido del servidor y muestra en unas pocas líneas
el estado de ZFS (pool `tank`), servicios críticos (WireGuard, Docker, cron,
smartd, zfs-zed), WireGuard `wg0`, Docker y algunas métricas básicas
(uptime, carga, memoria, unidades systemd fallidas y logs clave).

Uso típico:

```bash
srv-health        # vista completa, con logs
srv-health --short  # vista reducida, solo estado esencial
```

---

## Uso rápido

- `srv-health`  
  Vista completa, con todas las secciones (incluye logs).

- `srv-health --short`  
- `srv-health -s`  
  Vista reducida, sin sección de logs y sin lista detallada de contenedores.

- `srv-health` se ejecuta siempre como root (se relanza con `sudo` si hace falta).  
- La salida está pensada para revisión rápida: verde (OK), amarillo (WARN), rojo (FAIL).

---

## Opciones y modos principales

- `srv-health`  
  Vista completa. Incluye:
  - Cabecera (host, fecha, uptime, carga, memoria).
  - ZFS (pool `tank`) con umbrales de ocupación.
  - Servicios críticos (WireGuard, Docker, zfs-zed, smartd, cron).
  - WireGuard `wg0` (peers y handshakes recientes).
  - Docker (daemon y contenedores en ejecución).
  - Unidades systemd fallidas.
  - Logs clave (`smart-weekly.log` y `sync.log`).

- `srv-health --short` o `srv-health -s`  
  Vista reducida:
  - No muestra la lista de contenedores por nombre.
  - No muestra la sección de logs clave.
  - Ideal para una comprobación rápida desde terminal o desde otros scripts.

---

## Qué comprueba exactamente

### 1. Cabecera

- `hostname` real del servidor.
- Fecha y hora actuales.
- `uptime` en formato legible.
- Carga media (load average).
- Memoria usada, libre y total según `free -h`.

### 2. ZFS (pool `tank`)

- Requiere ZFS instalado (`zpool`).
- Si existe el pool `tank`, obtiene:
  - `health` (ONLINE, DEGRADED, FAULTED, etc.).
  - Porcentaje de ocupación (`capacity`).

Criterios:

- `HEALTH` distinto de `ONLINE` → **FAIL**.  
- `HEALTH = ONLINE` y uso mayor o igual al 90 % → **FAIL** (“casi lleno”).  
- `HEALTH = ONLINE` y uso entre el 80 % y el 89 % → **WARN** (“alto uso”).  
- `HEALTH = ONLINE` y uso menor del 80 % → **OK**.

Si ZFS no está instalado o el pool `tank` no existe, muestra un **WARN** informativo.

### 3. Servicios críticos (systemd)

Comprueba estas unidades si existen en el sistema:

- `wg-quick@wg0`
- `docker`
- `zfs-zed`
- `smartd`
- `cron`

Para cada unidad:

- Si la unidad existe y está activa → **OK**.  
- Si la unidad existe pero está inactiva → **WARN**.  
- Si la unidad no existe, se ignora (no se muestra nada para no ensuciar la salida).

### 4. WireGuard (`wg0`)

- Requiere el comando `wg` instalado.
- Si `wg show wg0` funciona:
  - Cuenta el número total de peers configurados.
  - Calcula cuántos tienen un *handshake* en los últimos 30 minutos, usando `latest-handshakes`.

Criterios:

- 0 peers → **WARN** (“sin peers configurados”).  
- Peers > 0 y 0 activos recientes → **WARN** (“ninguno con handshake < 30 min”).  
- Peers > 0 y al menos uno activo reciente → **OK**.

Si `wg` no está instalado o `wg0` no está levantado, muestra un **WARN**.

### 5. Docker

- Requiere Docker instalado y el servicio `docker` activo.
- Si el servicio está activo:
  - Cuenta los contenedores en ejecución (`docker ps`).
  - En vista completa (sin `--short`), muestra la lista de nombres en una sola línea.

Criterios:

- Docker activo y contenedores > 0 → **OK**, mostrando el número de contenedores y sus nombres.  
- Docker activo pero sin contenedores en ejecución → **WARN**.  
- Docker instalado pero servicio `docker` inactivo → **WARN**.  
- Docker no instalado → **WARN**.

### 6. Systemd (unidades fallidas)

- Ejecuta `systemctl --failed` y cuenta cuántas unidades están en estado fallido.

Criterios:

- 0 unidades fallidas → **OK**.  
- Una o más unidades fallidas → **WARN**, mostrando:
  - El número de unidades fallidas.
  - En vista completa, una lista de cada unidad con su estado `SUB`.

### 7. Logs clave

Solo se muestra en la vista completa (sin `--short`).

Rutas esperadas, adaptadas a tu repo:

- `state/main1/smart-weekly.log`
- `state/main1/sync.log`

El comando muestra:

- La última línea de `smart-weekly.log` (estado reciente del informe SMART/ZFS semanal).  
- Las últimas 3 líneas de `sync.log` (estado del `commit-and-push` periódico hacia GitHub).

Si alguno de estos ficheros no existe, muestra un **WARN** informativo indicando qué log falta.

---

## Ejemplos de uso

- Vista completa para revisión manual interactiva:  
  `srv-health`

- Vista reducida (sin logs ni lista de contenedores):  
  `srv-health --short`  
  `srv-health -s`

- Uso desde otro script para guardar la salida en un fichero y revisarla:  
  Ejecutar `srv-health --short` redirigiendo la salida a un archivo y revisar el contenido.

---

## Notas y troubleshooting

- `srv-health` se relanza como root si se ejecuta sin `sudo`, para poder consultar ZFS, WireGuard, systemd y Docker sin problemas de permisos.
- El comando no cambia el código de salida en función de OK/WARN/FAIL; toda la información se interpreta leyendo la salida de texto.
- Si aparece un **WARN** o **FAIL** en ZFS:
  - Ejecuta `zpool status -x` para obtener el detalle.
- Si aparece un **WARN** en WireGuard:
  - Revisa `wg show wg0` o tu comando `wg-list-peers` para ver qué peers deberían estar activos.
- Si aparecen unidades systemd fallidas:
  - Ejecuta `systemctl status NOMBRE.service` (o similar) para ver el error concreto.
- Si faltan `smart-weekly.log` o `sync.log`:
  - Comprueba que los cron o timers que los generan siguen activos y que la ruta `state/main1` es la correcta para este host.

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

