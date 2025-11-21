## Nextcloud – Plan de recuperación usando el servidor de backups

### Escenario

El servidor principal **main1** está caído (fallo hardware o mantenimiento prolongado) y se requiere mantener operativo el servicio de Nextcloud para los usuarios, utilizando el servidor de backups como plataforma temporal.

### Condiciones previas

- Existe al menos una copia reciente de las rutas clave de Nextcloud en el repositorio de backups:
  - `/srv/storage/nextcloud/config`
  - `/srv/storage/nextcloud/data`
  - `/srv/storage/nextcloud/db_dumps`
  - `/srv/storage/users`
  - `/srv/storage/media/C_critico`
- El servidor de backups dispone de:
  - Estructura `/srv/storage` creada.
  - Docker (o CasaOS) instalado.
  - Capacidad para restaurar datos desde el repositorio (restic u otro).

### Procedimiento de recuperación en el servidor de backups

1. **Restaurar datos en `/srv/storage`**
   - Restaurar desde el repositorio de backups a las rutas definitivas:
     - `/srv/storage/nextcloud/config`
     - `/srv/storage/nextcloud/data`
     - `/srv/storage/nextcloud/db_dumps`
     - `/srv/storage/users`
     - `/srv/storage/media/C_critico`
   - Verificar permisos:
     - Dueño UID/GID 1000 en `users/` y `media/`.
     - Permisos adecuados en `nextcloud/config` y `nextcloud/data` para el usuario del contenedor.

2. **Restaurar la base de datos de Nextcloud**
   - Levantar un contenedor MariaDB limpio en el servidor de backups, con:
     - Base de datos `nextcloud` vacía.
     - Usuario y contraseña idénticos a los definidos en `config.php`.
   - Elegir el dump apropiado desde `/srv/storage/nextcloud/db_dumps` (normalmente el más reciente).
   - Importar el dump en la base de datos `nextcloud`:
     - `gunzip -c <dump>.sql.gz | mysql ... nextcloud`

3. **Levantar el contenedor de Nextcloud**
   - Desplegar un contenedor de Nextcloud apuntando a:
     - `/srv/storage/nextcloud/config` → `/config`
     - `/srv/storage/nextcloud/data`   → `/data`
   - Usar la misma PUID/PGID que en main1 para preservar permisos.
   - Nextcloud debería arrancar con:
     - mismos usuarios y contraseñas,
     - mismos almacenamientos externos (`/srv/storage/users/...`, `/srv/storage/media/C_critico`, `/srv/storage/users/familia/...`),
     - misma configuración general.

4. **Redirigir acceso de los usuarios al servidor de backups**
   - En LAN:
     - Ajustar DNS local o registros de `hosts` para que el nombre de servidor (por ejemplo `servidor.local`) apunte a la IP del servidor de backups.
   - Desde el exterior (WireGuard / puerto expuesto):
     - Actualizar redirecciones en el router/Firewall para que el puerto HTTPS de Nextcloud apunte al servidor de backups.
   - Verificar acceso con el usuario admin y con varios usuarios finales.

### Vuelta a main1 tras la incidencia (idea general)

1. Detener el contenedor de Nextcloud en el servidor de backups.
2. Reparar main1 y restaurar allí, desde el servidor de backups o desde el repositorio central, las mismas rutas:
   - `/srv/storage/nextcloud/config`
   - `/srv/storage/nextcloud/data`
   - `/srv/storage/nextcloud/db_dumps`
   - `/srv/storage/users`
   - `/srv/storage/media/C_critico`
3. Importar en la base de datos de main1 el dump más reciente utilizado en el servidor de backups (si hubo cambios mientras este estuvo en producción).
4. Volver a apuntar DNS / WireGuard / puertos al main1 y validar acceso de los usuarios.

> Nota: la sincronización de cambios realizados durante el periodo de funcionamiento en el servidor de backups puede requerir procedimientos adicionales (replicación ZFS, restic con cuidado, etc.). Este plan cubre la ruta estándar de recuperación; los casos de “merge” de cambios deberán definirse según la estrategia de backup elegida.
