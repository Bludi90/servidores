# zfs-repl-backup1
<!-- RESUMEN -->
Comando manual para replicar incrementalmente el pool `tank` de `main1` hacia `backup1` usando ZFS (`zfs send | zfs receive`). Mantiene el último snapshot común en un fichero de estado, permite `--dry-run`, estima el tamaño antes de enviar y, si `pv` está instalado, muestra una línea viva de progreso.
<!-- /RESUMEN -->

## Qué hace

`zfs-repl-backup1` ejecuta la **réplica manual** del dataset origen `tank` de `main1` hacia el dataset destino `backup/replicas/main1/tank` en `backup1`.

Es el comando base del sistema de réplica. Sobre él se apoyan después:

- `zfs-repl-backup1-nightly` → flujo nocturno completo con WOL, réplica y apagado
- `zfs-repl-backup1-status` → resumen semanal `x/7`
- `zfs-repl-backup1-freshness` → estado operativo actual (`Bak OK/WARN/FAIL`)
- `zfs-restore-backup1` → restore controlado a staging

## Flujo que realiza

1. Lee el último snapshot común desde:
   - `~/servidores/state/main1/zfs-repl-backup1.last_common`
2. Crea un snapshot nuevo recursivo en `tank`
3. Estima el tamaño del incremental
4. Pide confirmación, salvo que se use `--yes`
5. Ejecuta la réplica incremental por SSH hacia `backup1`
6. Verifica que el snapshot llegó al destino
7. Actualiza el fichero `last_common` con el nuevo snapshot base común

## Ubicación

- **Fuente:** `~/servidores/scripts/cmd/zfs-repl-backup1`
- **Comando instalado:** `/usr/local/bin/zfs-repl-backup1`

## Ficheros y estado asociados

- **Estado base común:**
  - `~/servidores/state/main1/zfs-repl-backup1.last_common`
- **Log manual de réplicas:**
  - `~/servidores/state/main1/zfs-repl-backup1.log`

### Relacionados con la automatización
- **Wrapper nocturno:**
  - `~/servidores/scripts/cmd/zfs-repl-backup1-nightly`
- **Log del wrapper nocturno:**
  - `~/servidores/state/main1/zfs-repl-backup1-nightly.log`
- **Registro estructurado de ejecuciones:**
  - `~/servidores/state/main1/zfs-repl-backup1-runs.tsv`
- **Salida de cron del wrapper:**
  - `~/servidores/state/main1/cron-zfs-repl-backup1-nightly.out`

## Origen y destino

### En `main1`
- pool origen: `tank`

### En `backup1`
- pool destino: `backup`
- dataset receptor: `backup/replicas/main1/tank`

La réplica en `backup1` se mantiene en modo pasivo:

- `readonly=on`
- `mounted=no`
- `canmount=noauto`

Esto evita montar o modificar accidentalmente la réplica viva.

## Requisitos

### En `main1`
- ZFS operativo
- acceso SSH a `backup1` con el usuario `alejandro`
- `pv` instalado si se quiere progreso visual
- permisos suficientes para ejecutar el propio comando

### En `backup1`
- pool `backup` operativo
- dataset `backup/replicas/main1/tank` creado y funcional
- `sudoers` remoto permitiendo `zfs receive` sin contraseña para `alejandro`

## Sintaxis

~~~bash
zfs-repl-backup1 [--from SNAP] [--to SNAP] [--yes] [--no-progress] [--dry-run]
~~~

## Opciones

### `--from SNAP`
Fuerza el snapshot base común de origen.

Uso típico:
- inicialización manual
- realinear el estado
- repetir una réplica desde un snapshot concreto

Ejemplo:

~~~bash
zfs-repl-backup1 --from replica-20260401-182242
~~~

### `--to SNAP`
Fuerza el nombre del snapshot nuevo.

Si no se indica, el script crea uno automáticamente con formato:

~~~text
replica-YYYYMMDD-HHMMSS
~~~

Ejemplo:

~~~bash
zfs-repl-backup1 --to replica-20260401-210000
~~~

### `--yes`
No pide confirmación interactiva antes de enviar.

Ejemplo:

~~~bash
zfs-repl-backup1 --yes
~~~

### `--no-progress`
Desactiva `pv` aunque esté instalado.

Ejemplo:

~~~bash
zfs-repl-backup1 --yes --no-progress
~~~

### `--dry-run`
Hace una simulación completa:

- crea snapshot nuevo si hace falta
- estima el tamaño del incremental
- no envía nada
- si el snapshot fue creado solo para el dry-run, lo borra al final

Ejemplo:

~~~bash
zfs-repl-backup1 --dry-run --yes
~~~

## Uso normal

### Inicialización / realineación
Si el fichero de estado todavía no existe o hay que forzarlo:

~~~bash
zfs-repl-backup1 --from replica-20260401-182242
~~~

### Ejecución manual habitual

~~~bash
zfs-repl-backup1
~~~

o sin confirmación:

~~~bash
zfs-repl-backup1 --yes
~~~

### Simulación previa

~~~bash
zfs-repl-backup1 --dry-run --yes
~~~

## Salida esperada

### Inicio
Muestra dataset origen, destino, base común y snapshot nuevo.

Ejemplo:

~~~text
[2026-04-01 18:06:17] Origen:  tank
[2026-04-01 18:06:17] Destino: alejandro@backup1:backup/replicas/main1/tank
[2026-04-01 18:06:17] Base común: tank@replica-20260331-185657
[2026-04-01 18:06:17] Nuevo snapshot: tank@replica-20260401-180617
~~~

### Estimación
Antes de enviar, enseña el tamaño estimado de ZFS:

~~~text
total estimated size is 530M
~~~

### Progreso
Si `pv` está instalado y no se usa `--no-progress`, se muestra una línea viva.

Ejemplo:

~~~text
zfs-repl-backup1: 13,4MiB 0:00:05 [2,63MiB/s] [=====================>] 94%
~~~

### Final correcto
Al terminar, actualiza `last_common`.

Ejemplo:

~~~text
[2026-04-01 18:06:36] Réplica completada correctamente
[2026-04-01 18:06:36] Nuevo snapshot base común: tank@replica-20260401-180617
~~~

## Fichero `last_common`

Contiene **solo el nombre** del último snapshot común, sin `tank@`.

Ejemplo:

~~~text
replica-20260404-033002
~~~

## Cuándo usar este comando y cuándo no

### Sí usar `zfs-repl-backup1`
- para lanzar una réplica manual controlada
- para depurar el flujo base
- para validar incremental, tamaño y base común
- para pruebas manuales antes de automatizar

### No usarlo como restore
Para recuperación de contenido no se usa este comando, sino:

~~~bash
zfs-restore-backup1
~~~

### No usarlo como automatización nocturna directa
Para el flujo diario con wake + réplica + apagado se usa:

~~~bash
zfs-repl-backup1-nightly
~~~

## Notas operativas

- El comando manual replica, pero no enciende ni apaga `backup1`.
- La automatización diaria corre aparte por cron a las **03:30** mediante `zfs-repl-backup1-nightly`.
- El estado semanal y la frescura actual se calculan a partir de:
  - `zfs-repl-backup1-runs.tsv`
- `srv-health --short` muestra la frescura actual como:
  - `Bak OK`
  - `Bak WARN`
  - `Bak FAIL`
- `srv-health-weekly` muestra el cumplimiento semanal como:
  - `📦 Bak: x/7 (últ. dd/mm/aa)`

## Troubleshooting rápido

### El `dry-run` crea snapshot pero no envía
Es normal. En ese modo no hay réplica real.

### `backup1` no responde
No es problema de este comando en sí. Revisar:
- conectividad SSH
- estado de `backup1`
- si la réplica se quería hacer de forma automática, revisar `zfs-repl-backup1-nightly`

### El estado base común no cuadra
Comprobar:
- `~/servidores/state/main1/zfs-repl-backup1.last_common`
- snapshots presentes en origen y destino

### Hay que recuperar archivos o config
No usar `zfs-repl-backup1`. Usar:

~~~bash
zfs-restore-backup1
~~~
