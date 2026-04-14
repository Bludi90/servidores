# Manifest operativo — Opción B

## Prioridad de negocio

1. archivos personales / familiares
2. fotos
3. multimedia

## Prioridad de recuperación

1. `Nextcloud`
2. `Immich`
3. `Jellyfin`

---

## 1. Nextcloud

### Contenedores

- `linuxserver/nextcloud:32.0.1`
- `linuxserver/mariadb:11.4.5`

### Datasets / rutas críticas

- `tank/nextcloud/config`
  - host: `/srv/storage/nextcloud/config`
  - contenedor app: `/config`

- `tank/nextcloud/data`
  - host: `/srv/storage/nextcloud/data`
  - contenedor app: `/data`

- `tank/nextcloud/db`
  - host: `/srv/storage/nextcloud/db`
  - contenedor DB: `/config`

- root `tank`
  - host: `/srv/storage`
  - contenedor app: `/srv/storage`

### Observación crítica

`Nextcloud` no depende solo de `config + data + db`.

También necesita el árbol `/srv/storage` por el uso de `files_external`.

### Validación mínima esperada

- `occ status`
- `files_external:list`
- acceso HTTPS local o por túnel

---

## 2. Immich

### Contenedores

- `ghcr.io/immich-app/immich-server:v2`
- `ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0`
- `valkey`

### Datasets / rutas críticas

- root `tank`
  - `/srv/storage/services/immich/postgres`

- `tank/media`
  - `/srv/storage/media/C_critico/Immich`

### Validación mínima esperada

- HTTP `200`
- logs sin error de DB
- interfaz usable

---

## 3. Jellyfin

### Contenedores

- `lscr.io/linuxserver/jellyfin`

### Datasets / rutas críticas

- root `tank`
  - `/srv/storage/services/jellyfin/config`
  - `/srv/storage/services/jellyfin/custom-cont-init.d`

- `tank/media`
  - `/srv/storage/media`

### Validación mínima esperada

- HTTP `200` o `302`
- biblioteca visible
- logs sin error crítico

---

## Dependencias transversales

### Host mínimo

- Debian limpio
- usuario admin con `sudo`
- SSH
- Docker Engine
- Docker Compose

### Restore

- snapshots recientes en `backup1`
- helpers de clone / cleanup
- método robusto de extracción para datasets grandes

### Acceso

- SSH operativo
- WireGuard básico deseable para escenario real

---

## Punto débil actual del manifest

La estructura lógica está clara, pero el método de restore todavía no es robusto para datasets grandes.

Ese hueco se documenta en:

- `TOOLING-GAPS.md`
