# zfs-repl-backup1-nightly
<!-- RESUMEN -->
Wrapper operativo para la réplica diaria hacia `backup1`. Comprueba requisitos, enciende `backup1` por WOL si hace falta, espera a que vuelva por ping/SSH, lanza `zfs-repl-backup1`, registra el resultado en log y en `runs.tsv`, y apaga `backup1` al final si lo encendió este mismo wrapper.
<!-- /RESUMEN -->

## Qué hace

`zfs-repl-backup1-nightly` es el comando que orquesta el flujo completo de réplica nocturna.

A diferencia de `zfs-repl-backup1`, este comando no se limita a enviar el incremental, sino que además:

- valida dependencias y conectividad
- comprueba que `sv-backup1` está registrado en `wolctl`
- enciende `backup1` por WOL si está apagado
- espera a que `backup1` recupere ping y SSH
- valida el apagado remoto no interactivo
- ejecuta la réplica real mediante `zfs-repl-backup1`
- registra cada ejecución en un fichero estructurado
- apaga `backup1` si lo había encendido este mismo wrapper

## Modos de uso

### Comprobación previa

~~~bash
zfs-repl-backup1-nightly --check
~~~

Sirve para validar:

- comando `wol`
- comando `wolctl`
- presencia de `zfs-repl-backup1`
- alta de `sv-backup1` en `wolctl`
- si `backup1` está encendido:
  - ping
  - SSH
  - `backup1-safe-poweroff --check`

### Ejecución real

~~~bash
zfs-repl-backup1-nightly
~~~

Hace el flujo completo:

1. comprobaciones comunes
2. si `backup1` está apagado:
   - envía magic packet
   - espera ping
   - espera SSH
3. comprobaciones online
4. lanza `zfs-repl-backup1`
5. si `backup1` fue encendido por este wrapper:
   - ordena apagado
   - espera caída completa
   - deja un margen post-apagado

## Ubicación

- **Fuente:** `~/servidores/scripts/cmd/zfs-repl-backup1-nightly`
- **Comando instalado:** `/usr/local/bin/zfs-repl-backup1-nightly`

## Ficheros asociados

- **Log principal:**
  - `~/servidores/state/main1/zfs-repl-backup1-nightly.log`
- **Registro estructurado de ejecuciones:**
  - `~/servidores/state/main1/zfs-repl-backup1-runs.tsv`
- **Estado base común de la réplica:**
  - `~/servidores/state/main1/zfs-repl-backup1.last_common`
- **Salida del cron diario:**
  - `~/servidores/state/main1/cron-zfs-repl-backup1-nightly.out`

## Dependencias operativas

### En `main1`

- `wol`
- `wolctl`
- `zfs-repl-backup1`
- acceso SSH a `backup1` como `alejandro`
- entrada `sv-backup1` en `wolctl`

### En `backup1`

- helper:
  - `/usr/local/sbin/backup1-safe-poweroff`
- regla `sudoers` para usarlo sin contraseña
- ZFS destino operativo
- acceso SSH funcional desde `main1`

## Parámetros internos importantes

El script trabaja actualmente con estos valores:

- host WOL:
  - `sv-backup1`
- IP esperada:
  - `192.168.1.122`
- host SSH:
  - `backup1`
- usuario SSH local:
  - `alejandro`

Temporizadores:

- espera de ping tras wake:
  - `300s`
- espera de SSH tras wake:
  - `300s`
- espera de apagado:
  - `180s`
- margen post-apagado:
  - `30s`
- reintentos WOL:
  - `3`
- separación entre reintentos WOL:
  - `10s`

## Lock

Para evitar ejecuciones concurrentes usa:

~~~text
/var/lock/zfs-repl-backup1-nightly.lock
~~~

Si detecta otra ejecución en curso, deja constancia en log y termina con estado `LOCKED`.

## Registro estructurado `runs.tsv`

Cada ejecución queda registrada con estos campos:

- `start_iso`
- `end_iso`
- `mode`
- `rc`
- `result`
- `phase`
- `host_started`
- `wake_ok`
- `repl_ok`
- `shutdown_ok`
- `base_common_pre`
- `base_common_post`
- `duration_s`
- `note`

Este fichero es la base para:

- `zfs-repl-backup1-status`
- `zfs-repl-backup1-freshness`
- resumen semanal de `srv-health-weekly`

## Significado de algunos campos

- `mode`
  - `check`
  - `real`

- `host_started`
  - `yes` si el wrapper encendió `backup1`
  - `no` si ya estaba encendido

- `wake_ok`
  - `yes` si el wake completó ping+SSH
  - `no` si no hizo falta o no llegó a completarse

- `repl_ok`
  - `yes` si `zfs-repl-backup1` terminó bien

- `shutdown_ok`
  - `yes` si el wrapper apagó `backup1` correctamente
  - `no` si no lo encendió él y por tanto lo dejó encendido

## Ejemplos de salida

### `--check` correcto

~~~text
[2026-04-03 20:44:54] INFO  check: iniciando comprobaciones previas
[2026-04-03 20:44:54] OK    check: comando wol encontrado
[2026-04-03 20:44:54] OK    check: comando wolctl encontrado
[2026-04-03 20:44:54] OK    check: comando de réplica encontrado: /usr/local/bin/zfs-repl-backup1
[2026-04-03 20:44:54] OK    check: host WOL registrado: sv-backup1
[2026-04-03 20:44:54] OK    check: ping a 192.168.1.122 responde
[2026-04-03 20:44:55] OK    check: SSH a backup1 responde
[2026-04-03 20:44:55] OK    check: poweroff remoto no interactivo validado
[2026-04-03 20:44:55] INFO  check: todas las comprobaciones críticas pasaron
~~~

### ejecución real con wake + réplica + apagado

~~~text
[2026-04-03 21:24:54] INFO  main: sv-backup1 estaba apagado; se iniciará por WOL
[2026-04-03 21:24:54] INFO  wake: enviando magic packet a sv-backup1
[2026-04-03 21:27:52] OK    wake: ping recuperado
[2026-04-03 21:27:53] OK    wake: SSH recuperado
[2026-04-03 21:27:53] INFO  repl: lanzando réplica real
[2026-04-03 21:28:19] OK    repl: réplica finalizada
[2026-04-03 21:28:19] INFO  shutdown: ordenando apagado remoto
[2026-04-03 21:28:25] OK    shutdown: host apagado
[2026-04-03 21:28:55] INFO  main: flujo completado correctamente
~~~

### ejecución real con `backup1` ya encendido

~~~text
[2026-04-04 03:30:00] INFO  main: sv-backup1 ya estaba encendido; no se enviará WOL
[2026-04-04 03:30:00] INFO  repl: lanzando réplica real
[2026-04-04 03:30:29] OK    repl: réplica finalizada
[2026-04-04 03:30:29] INFO  main: el host ya estaba encendido al inicio; se deja encendido
[2026-04-04 03:30:29] INFO  main: flujo completado correctamente
~~~

## Cron actual

El wrapper se ejecuta diariamente a las **03:30** desde `root`.

La línea vigente de cron es:

~~~cron
30 3 * * * /usr/local/bin/zfs-repl-backup1-nightly >> /home/alejandro/servidores/state/main1/cron-zfs-repl-backup1-nightly.out 2>&1
~~~

## Cuándo usar este comando

### Sí usarlo
- para la automatización diaria normal
- para una ejecución manual completa equivalente al cron
- para validar el flujo real de wake + réplica + apagado

### No usarlo
- para un restore
- para una réplica manual “quirúrgica” sin WOL/apagado
- para pruebas de incremental puro

En esos casos usar mejor:

~~~bash
zfs-repl-backup1
zfs-restore-backup1
~~~

## Troubleshooting rápido

### `--check` falla en `ping`
`backup1` está apagado o no responde en la IP esperada.

Revisar:

- `wolctl show sv-backup1`
- IP fija DHCP
- conectividad LAN

### `--check` falla en `SSH`
El host puede haber despertado pero aún no tener SSH listo, o el alias `backup1` no resuelve correctamente.

Revisar:

- `ping 192.168.1.122`
- `ssh backup1`
- configuración SSH local de `alejandro`

### el wake no funciona
Revisar:

- BIOS / UEFI
- soporte WOL de la NIC
- `sv-backup1` dado de alta en `wolctl`
- tiempos de espera suficientes
- que `backup1` esté realmente apagado y no caído por otra causa

### la réplica termina pero `backup1` no se apaga
Revisar:

- `/usr/local/sbin/backup1-safe-poweroff`
- `sudoers` de `backup1-safe-poweroff`
- salida de:
  - `sudo -n /usr/local/sbin/backup1-safe-poweroff --check`

### aparece `LOCKED`
Hay otra ejecución en curso o quedó el lock durante una ejecución real. Revisar primero si de verdad hay una sesión activa antes de tocar el lock.

## Relación con la monitorización

Este wrapper alimenta directamente:

- `zfs-repl-backup1-status`
- `zfs-repl-backup1-freshness`
- sección `Réplica ZFS backup1` de `srv-health`
- línea `📦 Bak: x/7 (últ. dd/mm/aa)` de `srv-health-weekly`
