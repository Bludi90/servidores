# Runbook — DR Opción B desde `backup1` hacia host nuevo

## Objetivo

Este runbook documenta la **Opción B** de DR del proyecto:

- `backup1` actúa como **fuente de datos y laboratorio de validación**
- un **host nuevo** (Debian limpio) se reconstruye desde `backup1`
- el objetivo es recuperar primero los **servicios críticos de negocio**

Este documento **no sustituye** al runbook de réplica y restore ZFS.  
Se apoya en él y lo extiende con la reconstrucción operativa de servicios.

Runbook base relacionado:

- `docs/runbooks/replica-restore-backup1.md`

---

## Alcance de esta Opción B

### Prioridad de negocio validada

Orden de prioridad actual:

1. archivos personales / familiares
2. fotos
3. multimedia

Traducción a servicios:

1. `Nextcloud`
2. `Immich`
3. `Jellyfin`

### Filosofía operativa

La Opción B sigue este orden:

1. host base manual / recreable
2. pool o datos restaurados
3. acceso remoto básico
4. servicios críticos
5. servicios de soporte
6. servicios secundarios

### Lo que NO pretende este runbook

- no reconstruye el host entero “de golpe”
- no depende de `CasaOS`
- no hace takeover automático de `backup1`
- no cubre aún `Caddy`, DNS final, ni publicación bonita
- no cubre aún todos los servicios secundarios

---

## Estado validado a día de hoy

### Bloque base de datos
Ya están validados:

- réplica ZFS `main1 -> backup1`
- restore controlado desde `backup1`
- export seguro de configuración root-owned

### Servicios críticos validados en laboratorio
En `backup1` ya se han validado, **sin takeover**, estos servicios:

- `Jellyfin`
- `Nextcloud`
- `Immich`

Todos con el patrón:

1. host mínimo con Docker + Compose
2. datos desde réplica ZFS / clones
3. compose limpio
4. validación funcional real por HTTP/HTTPS o app

---

## Prerrequisitos mínimos del host nuevo

## Capa 0 — base del sistema

- Debian limpio
- usuario administrador con `sudo`
- `openssh-server`
- acceso por clave SSH

## Capa 1 — datos

El host nuevo debe poder usar una de estas vías:

- importar pool local restaurado
- restaurar datasets desde `backup1`
- o, en fase de ensayo, trabajar contra clones temporales en `backup1`

## Capa 2 — runtime

- Docker Engine
- Docker Compose plugin

## Capa 3 — acceso remoto útil

- WireGuard básico (deseable para DR real)

## Capa 4 — utilidades mínimas

- `curl`
- `ca-certificates`
- `git`
- `rsync`
- `tmux` o `screen`

---

## Dependencias de datos por servicio

## 1. Nextcloud

### Componentes críticos

- app: `linuxserver/nextcloud:32.0.1`
- DB: `linuxserver/mariadb:11.4.5`

### Rutas críticas validadas

- `/srv/storage/nextcloud/config -> /config`
- `/srv/storage/nextcloud/data -> /data`
- `/srv/storage/nextcloud/db -> /config` del contenedor MariaDB
- `/srv/storage -> /srv/storage` dentro del contenedor app

### Observación clave

`Nextcloud` **no depende solo de `config + data + db`**.

También depende de `/srv/storage` porque usa `files_external` con rutas locales del host, por ejemplo:

- `/srv/storage/users/...`
- y potencialmente otras rutas del árbol de almacenamiento

### Patrón validado de laboratorio

Para un lab funcional se ha validado:

- clone de `tank` root
- clone de `tank/media`
- clone de `tank/nextcloud/config`
- clone de `tank/nextcloud/data`
- clone de `tank/nextcloud/db`

### Validación buena mínima

- `occ status` correcto
- `files_external:list` correcto
- HTTPS local responde
- login posible tras ajustar `trusted_domains` del lab

---

## 2. Immich

### Componentes críticos

- app: `ghcr.io/immich-app/immich-server:v2`
- DB: `ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0`
- `redis` / `valkey`

### Rutas críticas validadas

- uploads: `/srv/storage/media/C_critico/Immich -> /data`
- PostgreSQL: `/srv/storage/services/immich/postgres -> /var/lib/postgresql/data`

### Observación clave

Para el primer DR funcional de `Immich` **no hace falta** `immich-machine-learning`.

El patrón mínimo válido es:

- `database`
- `redis`
- `immich-server`
- uploads reales

### Valor añadido confirmado

En el árbol de uploads existen además backups SQL diarios en:

- `.../Immich/backups`

Eso da un plan B adicional, aunque el patrón principal validado usa el directorio PostgreSQL real.

### Validación buena mínima

- HTTP `200 OK`
- interfaz usable
- logs sin error de conexión a PostgreSQL

---

## 3. Jellyfin

### Componentes críticos

- app: `lscr.io/linuxserver/jellyfin`

### Rutas críticas validadas

- config persistente
- biblioteca multimedia
- `custom-cont-init.d`
- cache / transcode efímeros

### Patrón validado de laboratorio

- config desde clone persistente
- media desde clone persistente
- cache y transcode locales/efímeros
- bind local por `127.0.0.1`

### Validación buena mínima

- HTTP `302` o `200`
- interfaz accesible por túnel SSH
- biblioteca visible

---

## Kits reutilizables ya creados en repo

### Jellyfin

- `docker/dr/jellyfin-lab/docker-compose.yml`
- `docker/dr/jellyfin-lab/.env.example`
- `scripts/cmd/dr-host-precheck-jellyfin`

### Nextcloud

- `docker/dr/nextcloud-lab/docker-compose.yml`
- `docker/dr/nextcloud-lab/.env.example`
- `docker/dr/nextcloud-lab/.env.db.example`
- `docker/dr/nextcloud-lab/precheck-nextcloud.sh`

### Immich

- `docker/dr/immich-lab/docker-compose.yml`
- `docker/dr/immich-lab/.env.example`
- `docker/dr/immich-lab/.env.server.example`
- `docker/dr/immich-lab/.env.db.example`
- `docker/dr/immich-lab/precheck-immich.sh`

---

## Orden recomendado de recuperación real

## Fase 1 — host base

En host nuevo:

1. instalar Debian
2. crear usuario admin y SSH
3. instalar Docker + Compose
4. asegurar conectividad con `backup1`

## Fase 2 — capa de datos

1. decidir si se trabajará con:
   - restore de datasets a host nuevo
   - o import de pool restaurado
2. restaurar primero los datasets/rutas críticas de:
   - `nextcloud`
   - `immich`
   - `media`
   - y el root `tank` cuando sea necesario

## Fase 3 — acceso remoto

1. recuperar SSH y, si procede, WireGuard básico
2. confirmar que el host ya es administrable de forma remota

## Fase 4 — servicios críticos

Orden recomendado:

1. `Nextcloud`
2. `Immich`
3. `Jellyfin`

### Motivo

- `Nextcloud` cubre archivos familiares y personales
- `Immich` cubre fotos
- `Jellyfin` cubre multimedia, importante pero por debajo del resto

## Fase 5 — servicios de soporte

Después de estabilizar los críticos:

- `Caddy`
- `UFW`
- DNS interno si procede
- otras piezas auxiliares

## Fase 6 — servicios secundarios

Solo al final:

- `Ghostfolio`
- `Firefly`
- `n8n`
- `portal`
- `*arr`
- `Stirling-PDF`
- etc.

---

## Secuencia operativa por servicio

## Nextcloud

1. preparar `config`, `data`, `db`, `storage-root` y `media`
2. levantar `mariadb`
3. levantar `nextcloud`
4. comprobar:
   - `occ status`
   - `files_external:list`
   - `trusted_domains`
5. publicar solo en localhost o túnel SSH durante la validación inicial

## Immich

1. preparar directorio PostgreSQL real
2. preparar uploads reales
3. levantar `database`
4. levantar `redis`
5. levantar `immich-server`
6. validar por HTTP local
7. dejar `machine-learning` para fase 2

## Jellyfin

1. preparar config persistente y media
2. usar cache/transcode locales
3. levantar `jellyfin`
4. validar por HTTP local y biblioteca visible

---

## Validaciones mínimas obligatorias antes de dar DR por bueno

## Host

- SSH operativo
- Docker operativo
- Compose operativo
- acceso administrativo estable

## Nextcloud

- `occ status` OK
- `files_external:list` OK
- acceso web OK

## Immich

- HTTP `200` OK
- login o pantalla principal accesible
- logs sin error de DB

## Jellyfin

- acceso web OK
- biblioteca visible
- logs sin error crítico

---

## Rollback básico de laboratorio

Si un lab falla:

1. parar el compose del servicio afectado
2. revisar logs
3. no tocar producción
4. destruir clones de laboratorio si se desea volver a empezar limpio

### Principio constante

**Nunca operar directamente sobre producción al probar DR.**

Siempre:

- clones
- staging
- host alternativo
- o `backup1` como laboratorio

---

## Límites conocidos de la Opción B actual

### Nextcloud

- trusted domains del lab deben ajustarse temporalmente
- la capa de proxy y publicación final no está integrada aún

### Immich

- `immich-machine-learning` no forma parte de la fase 1
- `redis` arranca con warning de `vm.overcommit_memory`, no bloqueante para el lab

### Jellyfin

- aceleración por GPU no forma parte de la validación mínima

### General

- no existe aún un orquestador único de DR
- el proceso sigue siendo guiado y controlado, no automático extremo a extremo

---

## Criterio de cierre de esta Opción B

La Opción B puede considerarse **cerrada a nivel base** cuando se cumpla todo esto:

- host base reproducible
- ruta clara de datos desde `backup1`
- `Nextcloud` validado
- `Immich` validado
- `Jellyfin` validado
- kits reutilizables en repo para los tres
- orden de recuperación real definido

---

## Próximo nivel después de cerrar este runbook

Cuando este nivel base esté consolidado, los siguientes desarrollos naturales son:

1. integrar o enlazar este runbook con el runbook de réplica/restore ZFS
2. decidir política de merge de los PR de kits DR
3. probar Opción B en host Debian realmente nuevo, no solo en `backup1`
4. añadir capa de publicación / acceso final (`Caddy`, DNS, etc.)
5. estudiar automatización adicional de prechecks y lanzamiento
