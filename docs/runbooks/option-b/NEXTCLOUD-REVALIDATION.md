# Revalidación de `Nextcloud` en Opción B

## Objetivo

Cerrar el primer servicio crítico de Opción B después de endurecer el tooling de restore.

## Prerrequisitos

### Host alternativo

- Debian limpio
- Docker + Compose
- SSH operativo
- staging local disponible

### Restore v2 ya disponible

Debe estar resuelto al menos uno de estos dos caminos:

- `--remote-tar-dir` funcional
- `--stream` funcional

## Material necesario

### Datasets

- `nextcloud/config`
- `nextcloud/data`
- `nextcloud/db`

### Subrutas adicionales

- `users` desde root `tank`
- `media-root` mínimo o selectivo

### Secretos / entorno

- `.env.db` generado a partir del contenedor MariaDB real o equivalente
- `trusted_domains` del lab ajustables

---

## Secuencia recomendada

### Paso 1 — restore de datos

1. restaurar `nextcloud/config`
2. restaurar `nextcloud/data`
3. restaurar `nextcloud/db`
4. restaurar `users`
5. preparar `media-root`

### Paso 2 — permisos

1. `config` escribible por `www-data`
2. `data` escribible por `www-data`
3. `db` escribible por usuario DB previsto
4. `storage-root` legible por `www-data`

### Paso 3 — precheck

Pasar `docker/dr/nextcloud-lab/precheck-nextcloud.sh` sin fallos.

### Paso 4 — arranque

1. levantar `mariadb`
2. levantar `nextcloud`
3. exponer solo en localhost o túnel SSH

### Paso 5 — validación funcional

1. `occ status`
2. `files_external:list`
3. login web
4. revisión de logs

---

## Criterio de éxito

`Nextcloud` podrá considerarse validado en Opción B cuando:

- arranque sin depender de producción
- la DB abra correctamente
- el árbol de `files_external` sea coherente
- el acceso web local funcione
- no queden clones ni temporales remotos colgados

---

## Resultado esperado para el proyecto

Una vez validado `Nextcloud`, Opción B deja de ser una promesa general y pasa a tener su primer servicio crítico cerrado en host alternativo.
