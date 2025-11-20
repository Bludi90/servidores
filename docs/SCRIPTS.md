### nextcloud-backup-db.sh (main1)

- **Ruta**: `/home/alejandro/servidores/scripts/nextcloud-backup-db.sh`
- **Host**: `main1`
- **Descripción**: Realiza un dump de la base de datos de Nextcloud (MariaDB) y lo comprime en `db_dumps`, aplicando una política de retención de 30 días.

- **Entradas / salidas**:
  - **DB origen**: base de datos `nextcloud` en el MariaDB del contenedor `mariadb` (puerto 3306 publicado en el host).
  - **Destino**: `/srv/storage/nextcloud/db_dumps/nextcloud-db-<host>-YYYYMMDD-HHMMSS.sql.gz`
  - **Log**: `/var/log/nextcloud_backup_db.log`

- **Dependencias**:
  - Paquete `mariadb-client` instalado en el host.
  - Fichero de credenciales `/root/.config/nextcloud-mariadb.cnf` con:
    ```ini
    [client]
    user=nextcloud
    password=********
    host=127.0.0.1
    port=3306
    ```
    (permisos `600`, propietario `root`).

- **Ejecución manual**:
  ```bash
  sudo /home/alejandro/servidores/scripts/nextcloud-backup-db.sh
  ```

- **Cron (root)**:
  ```bash
  10 2 * * * /home/alejandro/servidores/scripts/nextcloud-backup-db.sh
  ```
- **Retención**:
  El propio script borra automáticamente los ficheros nextcloud-db-*.sql.gz con más de 30 días en db_dumps

- **Notas**:
  - No toca los datos de Nextcloud (/srv/storage/nextcloud/data) ni la configuración (/srv/storage/nextcloud/config).
  - Pensado para poder recrear el contenedor de Nextcloud importando el dump más reciente y reutilizando los volúmenes existentes.
