## Nextcloud (main1) – Plan de backups y DR con servidor de respaldo

### Objetivo

Garantizar que, si el servidor principal **main1** deja de estar disponible, el servidor de respaldo pueda restaurar una copia reciente de Nextcloud (usuarios, configuración y datos críticos) y dar servicio temporal a los usuarios.

### Alcance

Se consideran parte del “núcleo Nextcloud”:

- `/srv/storage/nextcloud/config`      (configuración de Nextcloud, `config.php`, apps)
- `/srv/storage/nextcloud/data`        (directorio de datos de Nextcloud)
- `/srv/storage/nextcloud/db_dumps`    (dumps de la base de datos `nextcloud` en MariaDB)
- `/srv/storage/users`                 (árbol multiusuario: alejandro, familia, etc.)
- `/srv/storage/media/C_critico`       (media crítica: fotos/vídeos importantes)

Opcional (recomendado a medio plazo):

- `/srv/storage/media/I_importante`
- `/srv/storage/archive`
- `/srv/storage/services`
- `/srv/storage/backups`

### Requisitos en el servidor de backups

- Misma estructura base de directorios bajo `/srv/storage`:
  - `nextcloud/`, `users/`, `media/`, `archive/`, `services/`, `backups/`, `tmp/`.
- UID/GID 1000 dueño de:
  - `/srv/storage/users`
  - `/srv/storage/media`
- Docker (o CasaOS) disponible para desplegar contenedores de:
  - MariaDB compatible (misma versión aproximada).
  - Nextcloud (imagen LinuxServer.io o equivalente).
- Acceso al repositorio de backups (restic u otra herramienta) donde **main1** envía las copias de `/srv/storage`.

### Estrategia de backups

1. **En main1** (servidor principal):
   - Incluir en el plan de backups (restic u otro):
     - `/srv/storage/nextcloud/config`
     - `/srv/storage/nextcloud/data`
     - `/srv/storage/nextcloud/db_dumps`
     - `/srv/storage/users`
     - `/srv/storage/media/C_critico`
   - Mantener el script `nextcloud-backup-db.sh` generando dumps diarios de la BD en `db_dumps`.

2. **En el servidor de backups**:
   - Configurar acceso al repositorio de backups (restic, etc.).
   - Programar restauraciones de prueba periódicas (por ejemplo, a `/srv/restore-tests/nextcloud`) para verificar:
     - Que los dumps de la BD (`db_dumps/*.sql.gz`) se descomprimen y son importables.
     - Que la estructura `/srv/storage/nextcloud`, `/srv/storage/users` y `/srv/storage/media/C_critico` se restaura correctamente con permisos coherentes.

### Frecuencia recomendada

- Backups incrementales del núcleo Nextcloud: **diarios**.
- Backups más amplios de `/srv/storage` (media no crítica, archive, etc.): según necesidad, p.ej. **semanales**.
- Prueba de restauración parcial (solo Nextcloud) en el servidor de backups: **cada 3 meses** o tras cambios mayores (actualizaciones importantes de Nextcloud o MariaDB).
