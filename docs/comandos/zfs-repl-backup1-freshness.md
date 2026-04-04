# zfs-repl-backup1-freshness
<!-- RESUMEN -->
Chequeo de frescura operativa del sistema de réplicas hacia `backup1`. Lee `zfs-repl-backup1-runs.tsv`, busca la última ejecución real correcta y devuelve `Bak OK`, `Bak WARN` o `Bak FAIL` según la antigüedad de esa última réplica buena.
<!-- /RESUMEN -->

## Qué hace

`zfs-repl-backup1-freshness` responde a esta pregunta:

- **“¿el backup está al día ahora mismo?”**

No calcula cumplimiento semanal.  
Para eso existe:

~~~bash
zfs-repl-backup1-status
~~~

Este comando:

- lee `~/servidores/state/main1/zfs-repl-backup1-runs.tsv`
- ignora checks
- ignora ejecuciones fallidas
- localiza la última ejecución con:
  - `mode=real`
  - `result=OK`
- calcula cuántas horas han pasado desde esa última réplica correcta
- devuelve un estado operativo corto:
  - `Bak OK`
  - `Bak WARN`
  - `Bak FAIL`

## Ubicación

- **Fuente:** `~/servidores/scripts/cmd/zfs-repl-backup1-freshness`
- **Comando instalado:** `/usr/local/bin/zfs-repl-backup1-freshness`

## Fichero de entrada

~~~text
~/servidores/state/main1/zfs-repl-backup1-runs.tsv
~~~

Lo alimenta principalmente:

- `zfs-repl-backup1-nightly`

## Sintaxis

~~~bash
zfs-repl-backup1-freshness
~~~

No recibe argumentos.

## Lógica interna

Usa estas ventanas:

- `OK_HOURS=36`
- `WARN_HOURS=72`

### Criterios

- `Bak OK`
  - si la última réplica `OK` tiene **36 horas o menos**
- `Bak WARN`
  - si la última réplica `OK` tiene **más de 36h y hasta 72h**
- `Bak FAIL`
  - si la última réplica `OK` tiene **más de 72h**
  - o si no existe ninguna réplica `OK`
  - o si no existe el fichero `runs.tsv`

## Qué cuenta como réplica válida

Solo filas con:

~~~text
mode=real
result=OK
~~~

Por tanto:

- **sí** cuenta una réplica real correcta
- **no** cuenta `--check`
- **no** cuenta ejecuciones fallidas

## Formato de salida

Ejemplos típicos:

~~~text
Bak OK (últ. 04/04/26 03:30)
~~~

~~~text
Bak WARN (últ. 02/04/26 03:30)
~~~

~~~text
Bak FAIL (últ. --/--/--)
~~~

o, si hubo una última buena pero demasiado antigua:

~~~text
Bak FAIL (últ. 29/03/26 03:30)
~~~

## Código de salida

- `0` → `Bak OK`
- `1` → `Bak WARN`
- `2` → `Bak FAIL`

## Cuándo usar este comando

### Sí usarlo
- para saber si el backup está fresco ahora mismo
- para monitorización operativa
- para integrarlo en `srv-health`
- para scripts que necesiten una señal rápida del estado del backup

### No usarlo como resumen semanal
Para saber cómo fue la semana usar:

~~~bash
zfs-repl-backup1-status
~~~

Porque ese responde a:
- “¿cuántas réplicas buenas hubo en la ventana?”

y no a:
- “¿la última réplica correcta es suficientemente reciente?”

## Relación con otros comandos

### `zfs-repl-backup1-nightly`
Es quien registra normalmente las ejecuciones reales en `runs.tsv`.

### `zfs-repl-backup1-status`
Resume cumplimiento semanal (`x/7`).

### `srv-health`
`srv-health` usa este comando para mostrar la sección:

~~~text
== Réplica ZFS backup1 ==
[OK]    Bak OK (últ. 04/04/26 03:30)
~~~

### `srv-health-weekly`
No usa esta lógica de frescura; usa un resumen semanal tipo:

~~~text
📦 Bak: 1/7 (últ. 04/04/26)
~~~

## Ejemplos de uso

### Ver estado actual del backup

~~~bash
zfs-repl-backup1-freshness
~~~

### Ver también el código de salida

~~~bash
zfs-repl-backup1-freshness
echo "rc=$?"
~~~

## Troubleshooting rápido

### Sale `Bak WARN`
No significa que la semana haya ido mal. Significa que la última réplica buena ya no entra en la ventana `OK`, pero todavía no está en fallo severo.

### Sale `Bak FAIL` con `últ. --/--/--`
No existe ninguna réplica real correcta registrada, o no existe `runs.tsv`.

### Sale `Bak FAIL` con fecha
Sí hubo una réplica buena, pero ya está demasiado vieja para considerarla operativamente válida.

### El fichero `runs.tsv` no existe
En ese caso devuelve:

~~~text
Bak FAIL (últ. --/--/--)
~~~

y sale con código `2`.

## Nota operativa

Este comando es la referencia correcta para la **salud actual del backup**.

Si querés saber el **cumplimiento semanal**, no mires este comando. Mirá:

~~~bash
zfs-repl-backup1-status
~~~
