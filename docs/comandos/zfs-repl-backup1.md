# zfs-repl-backup1

<!-- RESUMEN -->
Comando manual para replicar incrementalmente el pool `tank` de `main1` hacia `backup1` usando ZFS (`zfs send | zfs receive`). Mantiene en un fichero de estado el último snapshot común, permite `--dry-run`, muestra estimación previa y, si `pv` está instalado, enseña una línea viva de progreso con bytes, velocidad, porcentaje y ETA aproximada.
<!-- /RESUMEN -->

## Qué hace

`zfs-repl-backup1` automatiza el flujo manual de réplica ZFS entre:

- **Origen:** `main1`
- **Dataset origen:** `tank`
- **Destino:** `backup1`
- **Dataset destino:** `backup/replicas/main1/tank`

El comando:

1. lee el último snapshot común desde `state/main1/zfs-repl-backup1.last_common`
2. crea un snapshot nuevo recursivo en `tank`
3. estima el tamaño del incremental
4. opcionalmente pide confirmación
5. ejecuta la réplica incremental por SSH
6. verifica que el snapshot llegó a `backup1`
7. actualiza el fichero de estado con el nuevo snapshot base común

## Ubicación

- **Fuente del comando:** `~/servidores/scripts/cmd/zfs-repl-backup1`
- **Comando publicado:** `/usr/local/bin/zfs-repl-backup1`
- **Estado:** `~/servidores/state/main1/zfs-repl-backup1.last_common`
- **Log:** `~/servidores/state/main1/zfs-repl-backup1.log`

## Requisitos

### En `main1`
- pool ZFS origen: `tank`
- comando instalado en `/usr/local/bin/zfs-repl-backup1`
- acceso SSH a `backup1` con el usuario `alejandro`
- `sudoers` local con permiso `NOPASSWD` para ejecutar el propio script
- `pv` instalado si se quiere barra/línea viva de progreso

### En `backup1`
- pool ZFS destino: `backup`
- dataset receptor: `backup/replicas/main1/tank`
- acceso SSH desde `main1`
- `sudoers` remoto permitiendo `zfs receive` sin contraseña para `alejandro`

## Sintaxis

~~~bash
zfs-repl-backup1 [--from SNAP] [--to SNAP] [--yes] [--no-progress] [--dry-run]
~~~

## Opciones

### `--from SNAP`
Fuerza el snapshot base común de origen.

Se usa sobre todo:
- en la **primera ejecución**
- si hay que **realinear** el estado manualmente
- si querés repetir una réplica partiendo de un snapshot concreto

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

Útil para:
- ejecuciones rápidas manuales
- futuras automatizaciones controladas

Ejemplo:

~~~bash
zfs-repl-backup1 --yes
~~~

### `--no-progress`
Desactiva `pv` aunque esté instalado.

Útil si:
- querés una salida más limpia
- estás depurando el script
- no querés línea viva de progreso

Ejemplo:

~~~bash
zfs-repl-backup1 --yes --no-progress
~~~

### `--dry-run`
Hace una simulación completa:

- crea snapshot nuevo si hace falta
- estima el tamaño del incremental
- **no envía nada**
- en la v2.1, si el snapshot fue creado solo para el dry-run, lo **borra al final**

Ejemplo:

~~~bash
zfs-repl-backup1 --dry-run --yes
~~~

## Flujo normal de uso

### Primera ejecución
Si el fichero de estado todavía no existe, indicar la base común manualmente:

~~~bash
zfs-repl-backup1 --from replica-20260401-182242
~~~

Tras una réplica correcta, el script actualizará automáticamente:

~~~bash
~/servidores/state/main1/zfs-repl-backup1.last_common
~~~

### Ejecución habitual
Una vez inicializado el estado:

~~~bash
zfs-repl-backup1
~~~

o sin pregunta de confirmación:

~~~bash
zfs-repl-backup1 --yes
~~~

### Simulación previa
Para ver cuánto va a viajar sin enviar nada:

~~~bash
zfs-repl-backup1 --dry-run --yes
~~~

## Salida esperada

### Inicio
El script informa de:

- dataset origen
- destino
- snapshot base común
- snapshot nuevo

Ejemplo:

~~~text
[2026-04-01 18:06:17] Origen:  tank
[2026-04-01 18:06:17] Destino: alejandro@backup1:backup/replicas/main1/tank
[2026-04-01 18:06:17] Base común: tank@replica-20260331-185657
[2026-04-01 18:06:17] Nuevo snapshot: tank@replica-20260401-180617
~~~

### Estimación
Antes de enviar, enseña la estimación de ZFS:

~~~text
total estimated size is 530M
~~~

### Progreso
Si `pv` está instalado y no se usa `--no-progress`, se muestra una sola línea viva con algo parecido a:

~~~text
zfs-repl-backup1: 13,4MiB 0:00:05 [2,63MiB/s] [=====================>] 94%
~~~

### Final correcto
Al terminar, deja constancia del nuevo snapshot base común y actualiza el fichero de estado:

~~~text
[2026-04-01 18:06:36] Réplica completada correctamente
[2026-04-01 18:06:36] Nuevo snapshot base común: tank@replica-20260401-180617
~~~

## Ficheros de estado

### `state/main1/zfs-repl-backup1.last_common`
Contiene **solo el nombre** del último snapshot común, sin `tank@`.

Ejemplo:

~~~text
replica-20260401-180617
~~~

### `state/main1/zfs-repl-backup1.log`
Log acumulado de ejecuciones del comando.

## Diseño de seguridad

### En `main1`
El comando se autoeleva con `sudo` al arrancar.

Se configuró una regla `NOPASSWD` **solo** para este script, en lugar de abrir permisos generales a `zfs`. Así el usuario puede ejecutar el comando cómodamente, pero no obtiene vía libre a otros subcomandos arbitrarios de ZFS.

### En `backup1`
El `zfs receive` remoto se ejecuta con:

~~~bash
sudo -n /usr/bin/zfs receive -u -F backup/replicas/main1/tank
~~~

La réplica en destino se mantiene como:

- `readonly=on`
- `mounted=no`
- `canmount=noauto`

Esto permite que `backup1` actúe como **destino pasivo** de réplica.

## Comprobaciones útiles

### Ver el snapshot base actual
~~~bash
cat ~/servidores/state/main1/zfs-repl-backup1.last_common
~~~

### Ver si el pool origen está sano
~~~bash
zpool status tank
~~~

### Ver si el pool destino está sano
~~~bash
ssh alejandro@backup1 'zpool status backup'
~~~

### Ver snapshots recibidos en destino
~~~bash
ssh alejandro@backup1 'zfs list -t snapshot -r backup/replicas/main1/tank | tail -n 20'
~~~

### Ver estado pasivo de la réplica en `backup1`
~~~bash
ssh alejandro@backup1 'zfs get -r readonly,mounted,canmount backup/replicas/main1/tank | head -n 20'
~~~

## Problemas conocidos / errores típicos

### `No hay SSH funcional hacia backup1`
Suele significar:
- alias SSH no disponible
- conectividad rota
- problema de clave SSH

El script está preparado para lanzar SSH usando el usuario original (`alejandro`) para aprovechar su `~/.ssh/config`.

### `sudo: a password is required` en `backup1`
Indica que la regla remota de `sudoers` para `zfs receive` no está aplicando bien.

### `No existe ... last_common`
Pasa en la primera ejecución si todavía no se ha inicializado el fichero de estado. Se resuelve lanzando el comando con `--from SNAP`.

### Dry-run dejando snapshots
Corregido en la **v2.1**: si el snapshot nuevo fue creado solo para la simulación, se destruye automáticamente al salir.

## Ejemplos reales

### Réplica interactiva
~~~bash
zfs-repl-backup1
~~~

### Réplica directa
~~~bash
zfs-repl-backup1 --yes
~~~

### Simulación sin enviar
~~~bash
zfs-repl-backup1 --dry-run --yes
~~~

### Reanclar base común manualmente
~~~bash
zfs-repl-backup1 --from replica-20260401-182242 --yes
~~~

## Notas de mantenimiento

- Este comando está pensado para seguir usándose **manual** por ahora.
- Antes de automatizarlo por cron/systemd timer, conviene haber validado varias ejecuciones manuales sin incidencias.
- Si más adelante se automatiza, convendrá añadir:
  - bloqueo con `flock`
  - rotación/limpieza de snapshots
  - alertas si falla la réplica
  - política explícita de retención

