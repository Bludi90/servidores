## 2025-11-20 – main1 – Backups DB Nextcloud

- Añadido script `nextcloud-backup-db.sh` en `scripts/` para generar dumps diarios de la base de datos de Nextcloud (MariaDB).
- Los dumps se guardan en `/srv/storage/nextcloud/db_dumps/nextcloud-db-<host>-YYYYMMDD-HHMMSS.sql.gz` (comprimidos con gzip).
- Credenciales del usuario de la DB en `/root/.config/nextcloud-mariadb.cnf` (permisos 600, propietario root).
- Programado cron de root a las 02:10:
  - `10 2 * * * /home/alejandro/servidores/scripts/nextcloud-backup-db.sh`
- Verificado que el dump se genera correctamente y que el fichero `.sql.gz` es válido (`gunzip -t` + inspección de cabecera).
