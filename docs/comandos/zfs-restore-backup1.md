# zfs-restore-backup1
<!-- RESUMEN -->
Restore controlado desde la réplica ZFS de `backup1` hacia un directorio local de staging. Comprueba que el snapshot exista, crea un clone temporal remoto, empaqueta la subruta pedida, la copia al host local, la extrae en destino y limpia los temporales al final.
<!-- /RESUMEN -->

## Qué hace

`zfs-restore-backup1` sirve para **extraer contenido desde la réplica ZFS de `backup1`** sin tocar producción directamente.

El flujo está pensado para:

- restaurar a un directorio de staging
- poder ejecutarse desde `main1`
- poder ejecutarse también desde otro host Linux, si `main1` hubiera muerto
- no depender del `last_common`
- no escribir nunca sobre la réplica viva de `backup1`

## Qué NO hace

- no restaura directamente sobre producción
- no rehace automáticamente un servicio completo
- no “promociona” datasets
- no usa `last_common` por sí solo
- no decide qué snapshot usar: se le pasa explícitamente con `--tag`

## Flujo que realiza

1. valida argumentos
2. construye rutas temporales y nombres seguros
3. comprueba que el snapshot remoto exista
4. crea un clone temporal remoto en `backup1`
5. monta ese clone temporal
6. genera un tar remoto solo de la subruta pedida
7. copia ese tar al host local
8. limpia la subruta destino previa en local
9. extrae el tar en staging
10. limpia temporales remotos
11. borra el tar local
12. deja el contenido restaurado en `DEST/SUBPATH`

## Ubicación

- **Fuente:** `~/servidores/scripts/cmd/zfs-restore-backup1`
- **Comando instalado:** `/usr/local/bin/zfs-restore-backup1`

## Sintaxis

~~~bash
zfs-restore-backup1 --ssh-target HOST --dataset DATASET --tag TAG --path SUBPATH --dest DESTINO [--dry-run]
~~~

## Argumentos obligatorios

### `--ssh-target HOST`
Host SSH contra el que se ejecutará el restore remoto.

Ejemplo habitual:

~~~bash
--ssh-target backup1
~~~

También permite usar otro hostname o IP si se ejecuta desde otro Linux.

### `--dataset DATASET`
Dataset relativo a la raíz replicada:

~~~text
backup/replicas/main1/tank/
~~~

Ejemplo:

~~~bash
--dataset nextcloud/config
~~~

Eso se traduce internamente a:

~~~text
backup/replicas/main1/tank/nextcloud/config
~~~

### `--tag TAG`
Snapshot concreto que querés usar.

Ejemplo:

~~~bash
--tag replica-20260404-033002
~~~

### `--path SUBPATH`
Subruta dentro del dataset restaurado que querés extraer.

Ejemplo:

~~~bash
--path nginx
~~~

### `--dest DESTINO`
Directorio local donde se extraerá el contenido restaurado.

Ejemplo:

~~~bash
--dest /srv/storage/tmp/restore-staging
~~~

## Opción

### `--dry-run`
No ejecuta el restore. Solo:

- valida argumentos
- construye el plan
- comprueba que el snapshot remoto exista

Es el modo recomendado para revisar antes una restauración.

## Diseño de rutas temporales

El comando genera nombres únicos con timestamp.

Ejemplo de variables internas:

~~~text
REMOTE_DATASET=backup/replicas/main1/tank/nextcloud/config
REMOTE_SNAPSHOT=backup/replicas/main1/tank/nextcloud/config@replica-20260404-033002
REMOTE_CLONE=backup/restore-tests/nextcloud-config-20260404-163730
REMOTE_MOUNT=/mnt/restore-test-nextcloud-config-20260404-163730
REMOTE_TAR=/tmp/zfs-restore-nextcloud-config-nginx-20260404-163730.tar
LOCAL_TAR=/srv/storage/tmp/restore-staging/zfs-restore-nextcloud-config-nginx-20260404-163730.tar
LOCAL_EXTRACT_DIR=/srv/storage/tmp/restore-staging
~~~

## Dependencias

### En el host local (`main1` o el host desde el que ejecutes)
- acceso SSH a `backup1`
- `scp`
- `tar`
- permisos para `sudo rm -rf` sobre la subruta de staging
- destino local escribible

### En `backup1`
- helper:
  - `/usr/local/sbin/backup1-zfs-restore-helper`
- `sudoers` NOPASSWD para ese helper
- pool `backup` operativo
- réplica ZFS presente

## Helper remoto usado

La parte privilegiada en `backup1` se canaliza mediante:

~~~text
/usr/local/sbin/backup1-zfs-restore-helper
~~~

Subcomandos usados por `zfs-restore-backup1`:

- `snapshot-exists`
- `clone-mount`
- `tar-path`
- `cleanup`

Esto evita pedir múltiples contraseñas y deja el flujo más reproducible.

## Ejemplos de uso

### Verificar sin restaurar nada

~~~bash
zfs-restore-backup1 \
  --ssh-target backup1 \
  --dataset nextcloud/config \
  --tag replica-20260404-033002 \
  --path nginx \
  --dest /srv/storage/tmp/restore-staging \
  --dry-run
~~~

### Restore real a staging

~~~bash
zfs-restore-backup1 \
  --ssh-target backup1 \
  --dataset nextcloud/config \
  --tag replica-20260404-033002 \
  --path nginx \
  --dest /srv/storage/tmp/restore-staging
~~~

## Resultado esperado

Si todo va bien, el contenido quedará en:

~~~text
/srv/storage/tmp/restore-staging/nginx
~~~

Nota: en la ruta real no hay espacio; aquí solo se separa visualmente:
~~~text
/srv/storage/tmp/restore-staging/nginx
~~~

## Salida esperada

### `--dry-run`
Ejemplo:

~~~text
zfs-restore-backup1 (plan)
DRY_RUN=1
SSH_TARGET=backup1
REMOTE_DATASET=backup/replicas/main1/tank/nextcloud/config
REMOTE_SNAPSHOT=backup/replicas/main1/tank/nextcloud/config@replica-20260404-033002
...
[check] Comprobando snapshot remoto...
NAME  ...
backup/replicas/main1/tank/nextcloud/config@replica-20260404-033002
~~~

### Restore real
Ejemplo abreviado:

~~~text
[check] Comprobando snapshot remoto...
[run] Creando clone remoto...
[run] Creando tar remoto de la subruta...
[run] Copiando tar a destino local...
[run] Limpiando subruta destino previa...
[run] Extrayendo tar en destino local...
[run] Limpiando temporales remotos...
[run] Limpiando tar local...
Restore completado.
~~~

## Limpieza automática

Al final del flujo real, el comando limpia:

### En `backup1`
- clone temporal bajo:
  - `backup/restore-tests/...`
- tar remoto en:
  - `/tmp/...`

### En local
- tar local temporal
- **no** borra el contenido restaurado
- sí borra previamente la subruta destino si ya existía, para evitar errores de permisos o mezcla de contenidos

## Seguridad y diseño operativo

### Producción no se toca
La restauración está pensada para staging, no para sobreescribir servicios vivos.

### La réplica viva no se monta en producción
Se usa un **clone temporal** de snapshot, no el dataset pasivo de réplica directamente.

### El snapshot se pasa explícitamente
Esto hace el restore más transparente y reproducible, especialmente en DR.

## Casos de uso recomendados

### Sí usarlo
- recuperar config o archivos concretos
- extraer una subruta desde la réplica
- validar recovery desde otro host Linux
- ensayar restores controlados

### No usarlo
- para rehacer automáticamente todo `main1`
- para copiar datasets completos en caliente a producción
- para usarlo como sustituto de un plan de DR completo

## Relación con otros comandos

### `zfs-repl-backup1`
Replica manualmente datos hacia `backup1`.

### `zfs-repl-backup1-nightly`
Hace la réplica diaria automática.

### `zfs-repl-backup1-status`
Resume el cumplimiento semanal.

### `zfs-repl-backup1-freshness`
Mide si la última réplica buena es suficientemente reciente.

## Troubleshooting rápido

### `Falta --dataset`, `--tag`, etc.
Falta un argumento obligatorio.

### `--dataset no debe empezar por /`
El dataset debe ir relativo a `backup/replicas/main1/tank`.

Correcto:

~~~bash
--dataset nextcloud/config
~~~

Incorrecto:

~~~bash
--dataset /backup/replicas/main1/tank/nextcloud/config
~~~

### `--path no debe empezar por /`
La subruta debe ser relativa al dataset restaurado.

### Falla en `[check] Comprobando snapshot remoto...`
El snapshot no existe, el helper no está bien desplegado en `backup1`, o no hay conectividad SSH.

### Falla en la extracción local por permisos
La subruta previa en staging puede haber quedado con permisos restrictivos. El comando ya intenta limpiarla con `sudo rm -rf`, pero si falla, revisar permisos del destino.

### Quedan clones viejos en `backup/restore-tests`
No debería pasar en el flujo actual, porque el comando limpia al final. Si ocurrió por pruebas antiguas o abortos intermedios, revisar manualmente en `backup1`.

## Nota operativa

Este comando deja el contenido restaurado en staging, pero **la decisión de compararlo, moverlo o aplicarlo a producción sigue siendo manual**.

Ese comportamiento es intencional.
