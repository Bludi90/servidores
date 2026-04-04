# zfs-repl-backup1-status
<!-- RESUMEN -->
Resumen semanal del sistema de réplicas hacia `backup1`, calculado a partir de `zfs-repl-backup1-runs.tsv`. Cuenta solo ejecuciones reales (`mode=real`) y devuelve una línea compacta tipo `Snpsht OK/WARN/FAIL`, útil para monitorización, revisión manual y consumo desde otros scripts.
<!-- /RESUMEN -->

## Qué hace

`zfs-repl-backup1-status` calcula el **cumplimiento semanal** de las réplicas hacia `backup1`.

No mira directamente snapshots ZFS ni el estado actual del host, sino el histórico de ejecuciones registrado en:

~~~text
~/servidores/state/main1/zfs-repl-backup1-runs.tsv
~~~

A partir de ese fichero:

- filtra solo filas con `mode=real`
- se queda con la ventana de días indicada
- cuenta cuántas ejecuciones fueron `OK`
- cuenta cuántas fueron fallo
- calcula cuántas faltan respecto a la expectativa semanal
- localiza la última réplica `OK`

## Ubicación

- **Fuente:** `~/servidores/scripts/cmd/zfs-repl-backup1-status`
- **Comando instalado:** `/usr/local/bin/zfs-repl-backup1-status`

## Fichero de entrada

~~~text
~/servidores/state/main1/zfs-repl-backup1-runs.tsv
~~~

Ese fichero lo escribe principalmente:

- `zfs-repl-backup1-nightly`

## Sintaxis

~~~bash
zfs-repl-backup1-status [WINDOW_DAYS]
~~~

## Parámetro

### `WINDOW_DAYS`
Número de días a revisar hacia atrás.

Si no se indica, usa:

~~~text
7
~~~

Ejemplos:

~~~bash
zfs-repl-backup1-status
zfs-repl-backup1-status 7
zfs-repl-backup1-status 14
~~~

## Lógica de cálculo

Internamente usa estas reglas:

- ventana por defecto:
  - `7` días
- expectativa semanal:
  - `7` ejecuciones

### Criterios de estado

- `OK`
  - si `ok_count >= 7`
- `WARN`
  - si `ok_count >= 1` pero `< 7`
- `FAIL`
  - si `ok_count = 0`

### Qué cuenta como ejecución válida
Solo filas con:

~~~text
mode=real
~~~

Es decir:

- **sí** cuenta ejecuciones reales del wrapper
- **no** cuenta `--check`

## Formato de salida

Devuelve una sola línea tipo:

~~~text
Snpsht OK (OK=7/7, FAIL=0, MISS=0, últ OK: D:06/04/26)
~~~

o:

~~~text
Snpsht WARN (OK=1/7, FAIL=0, MISS=6, últ OK: S:04/04/26)
~~~

o:

~~~text
Snpsht FAIL (OK=0/7, FAIL=0, MISS=7, últ OK: ---)
~~~

## Código de salida

- `0` → `OK`
- `1` → `WARN`
- `2` → `FAIL`

Esto permite usarlo desde otros scripts o chequeos.

## Qué significan los campos

### `OK=x/7`
Número de réplicas reales correctas dentro de la ventana.

### `FAIL=y`
Número de ejecuciones reales fallidas dentro de la ventana.

### `MISS=z`
Diferencia entre lo esperado (`7`) y el total de ejecuciones reales vistas en la ventana.

### `últ OK: X:dd/mm/aa`
Fecha de la última réplica `OK`, con inicial del día:

- `L`
- `M`
- `X`
- `J`
- `V`
- `S`
- `D`

Ejemplo:

~~~text
J:02/04/26
~~~

## Cuándo usar este comando

### Sí usarlo
- para ver cómo fue la semana de backups
- para alimentar resúmenes semanales
- para comprobar si hubo al menos una réplica buena en la ventana
- para uso desde otros scripts

### No usarlo para salud actual
Para salud operativa actual del backup no usar este comando. Usar:

~~~bash
zfs-repl-backup1-freshness
~~~

Porque `zfs-repl-backup1-status` responde a:
- “¿cómo fue la semana?”

y no a:
- “¿el backup está al día ahora mismo?”

## Relación con otros comandos

### `zfs-repl-backup1-nightly`
Es quien genera la mayoría de las filas `mode=real` del `runs.tsv`.

### `zfs-repl-backup1-freshness`
Usa una lógica distinta:
- frescura actual
- no cumplimiento semanal

### `srv-health-weekly`
El weekly usa una versión resumida de este concepto para mostrar algo como:

~~~text
📦 Bak: 1/7 (últ. 04/04/26)
~~~

## Ejemplos de uso

### Resumen semanal normal

~~~bash
zfs-repl-backup1-status
~~~

### Ventana de 14 días

~~~bash
zfs-repl-backup1-status 14
~~~

### Ver también el código de salida

~~~bash
zfs-repl-backup1-status
echo "rc=$?"
~~~

## Troubleshooting rápido

### Sale `FAIL` pero hubo checks correctos
Es normal si no hubo ejecuciones con `mode=real`. Los checks no cuentan.

### Sale `WARN` con `1/7`
También es normal: hubo al menos una réplica buena en la semana, pero no se completó la expectativa semanal.

### `últ OK: ---`
No se ha encontrado ninguna ejecución real correcta en la ventana.

### El fichero `runs.tsv` no existe
En ese caso devuelve:

~~~text
Snpsht FAIL (OK=0/7, FAIL=0, MISS=7, últ OK: ---)
~~~

y sale con código `2`.

## Nota operativa

Este comando es útil para resúmenes y monitorización semanal, pero no debe confundirse con el estado operativo actual del sistema de backup. Para eso, la referencia correcta es:

~~~bash
zfs-repl-backup1-freshness
~~~
