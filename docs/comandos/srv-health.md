# srv-health
<!-- RESUMEN -->
`srv-health` hace un chequeo rápido de salud del servidor y muestra en pocas líneas el estado general de `main1`: cabecera del sistema, ZFS, réplica hacia `backup1`, servicios críticos, UPS/NUT, WireGuard, Docker, DNS, unidades systemd fallidas y logs clave.
Uso típico:
~~~bash
srv-health
srv-health --short
~~~
<!-- /RESUMEN -->

## Uso rápido

- `srv-health`
  - vista completa
  - incluye todas las secciones
  - incluye `Logs clave`

- `srv-health --short`
- `srv-health -s`
  - vista reducida
  - no muestra `Logs clave`
  - no muestra la lista larga de contenedores

## Qué comprueba

### 1. Cabecera del servidor
Muestra:

- host
- fecha
- uptime
- carga media
- memoria usada/libre/total

### 2. ZFS
Comprueba el pool `tank`.

Criterios:

- `HEALTH` distinto de `ONLINE` → `FAIL`
- uso `>= 90%` → `FAIL`
- uso `>= 80%` y `< 90%` → `WARN`
- resto → `OK`

### 3. Réplica ZFS backup1
Muestra el estado operativo del backup mediante:

~~~bash
zfs-repl-backup1-freshness
~~~

Ejemplos de salida:

~~~text
Bak OK (últ. 04/04/26 03:30)
Bak WARN (últ. 02/04/26 03:30)
Bak FAIL (últ. --/--/--)
~~~

Importante:

- aquí **no** se usa la lógica semanal `x/7`
- aquí se usa **frescura operativa**
- sirve para responder a la pregunta:
  - “¿el backup está al día ahora mismo?”

### 4. Servicios críticos (systemd)
Comprueba estas unidades si existen:

- `wg-quick@wg0`
- `docker`
- `zfs-zed`
- `smartd`
- `cron`

Criterios:

- existe y está activa → `OK`
- existe pero no está activa → `WARN`
- no existe → no ensucia la salida

### 5. UPS (NUT)
Comprueba:

- `nut-driver@cyberpower.service`
- `nut-server.service`
- `nut-monitor.service`
- estado `ARMED`
- salida de `upsc`

Criterios generales:

- todo correcto y en línea → `OK`
- servicios inactivos o no armado → `WARN`
- `FSD`, `LOWBATT`, fallo de `upsc` o situación grave → `FAIL`

### 6. WireGuard (`wg0`)
Comprueba:

- si `wg` está instalado
- si `wg0` está levantado
- número total de peers
- cuántos tienen handshake reciente (< 30 min)

Criterios:

- 0 peers → `WARN`
- peers pero ninguno reciente → `WARN`
- al menos uno reciente → `OK`

### 7. Docker
Comprueba:

- si Docker está instalado
- si el servicio `docker` está activo
- número de contenedores corriendo

Criterios:

- Docker activo y contenedores > 0 → `OK`
- Docker activo pero sin contenedores → `WARN`
- Docker instalado pero servicio inactivo → `WARN`
- Docker no instalado → `WARN`

### 8. DNS (Pi-hole + Unbound)
Comprueba:

- contenedor `pihole-pihole-1`
- contenedor `unbound-unbound-1`
- resolución DNS real:
  - Pi-hole
  - Unbound

Criterios:

- ambos contenedores y resolución OK → `OK`
- arrancando / unhealthy / no responde → `WARN` o `FAIL` según caso

### 9. Systemd (unidades fallidas)
Ejecuta:

~~~bash
systemctl --failed
~~~

Criterios:

- 0 unidades fallidas → `OK`
- una o más fallidas → `WARN`

## Logs clave

Solo en modo completo (`srv-health` sin `--short`).

Muestra:

- `state/main1/smart-weekly.log`
  - última línea
- `state/main1/sync.log`
  - últimas 3 líneas
- `state/main1/zfs-repl-backup1-nightly.log`
  - últimas 5 líneas

Si alguno no existe, muestra `WARN`.

## Resumen final

Al final imprime algo como:

~~~text
Estado general: OK (OK=15, WARN=0, FAIL=0)
~~~

o:

~~~text
Estado general: ATENCIÓN (OK=14, WARN=1, FAIL=0)
~~~

o:

~~~text
Estado general: CRÍTICO (OK=12, WARN=1, FAIL=2)
~~~

## Relación con otros comandos del bloque backup

`srv-health` usa indirectamente:

- `zfs-repl-backup1-freshness`
  - para el estado actual del backup

El resumen semanal del backup no sale aquí. Sale en:

~~~bash
srv-health-weekly
~~~

con una línea tipo:

~~~text
📦 Bak: 1/7 (últ. 04/04/26)
~~~

## Ejemplos de uso

Vista completa:

~~~bash
srv-health
~~~

Vista corta:

~~~bash
srv-health --short
~~~

## Troubleshooting rápido

### Sale `Bak WARN`
No significa necesariamente que la semana vaya mal. Significa que la **última réplica OK ya no está fresca** según la ventana definida.

Comprobar:

~~~bash
zfs-repl-backup1-freshness
~~~

### Sale `Bak FAIL`
No hay una réplica OK suficientemente reciente, o no hay ninguna registrada.

Comprobar:

~~~bash
zfs-repl-backup1-freshness
zfs-repl-backup1-status
tail -n 50 ~/servidores/state/main1/zfs-repl-backup1-nightly.log
~~~

### Faltan logs en `Logs clave`
Comprobar que existan:

- `~/servidores/state/main1/smart-weekly.log`
- `~/servidores/state/main1/sync.log`
- `~/servidores/state/main1/zfs-repl-backup1-nightly.log`

### ZFS da `WARN` o `FAIL`
Revisar:

~~~bash
zpool status -x
~~~

### WireGuard da `WARN`
Revisar:

~~~bash
wg show wg0
wg-list-peers
~~~

### Docker da `WARN`
Revisar:

~~~bash
systemctl status docker
docker ps
~~~
