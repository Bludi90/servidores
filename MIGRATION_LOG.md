## 2025-11-20 – main1 – Backups DB Nextcloud

- Añadido script `nextcloud-backup-db.sh` en `scripts/` para generar dumps diarios de la base de datos de Nextcloud (MariaDB).
- Los dumps se guardan en `/srv/storage/nextcloud/db_dumps/nextcloud-db-<host>-YYYYMMDD-HHMMSS.sql.gz` (comprimidos con gzip).
- Credenciales del usuario de la DB en `/root/.config/nextcloud-mariadb.cnf` (permisos 600, propietario root).
- Programado cron de root a las 02:10:
  - `10 2 * * * /home/alejandro/servidores/scripts/nextcloud-backup-db.sh`
- Verificado que el dump se genera correctamente y que el fichero `.sql.gz` es válido (`gunzip -t` + inspección de cabecera).

## 2025-11-26 – main1 – Despliegue inicial de Jellyfin

- Jellyfin instalado vía CasaOS con un archivo .yml
- Bibliotecas de películas y series creadas usando la estructura existente: /srv/storage/media/N_Normal/.."
- Acceso probado desde la Xiaomi TV Box Por WireGuard y reproducción correcta de vídeos de prueba
- Las bibliotecas de Jellyfin se replicarán en el servidor de backups futuro

2025-12-02 – Cockpit + DNS interno (Pi-hole + Unbound) en main1

- Instalado y habilitado Cockpit como panel web del servidor:
  - Paquete `cockpit` desde los repos de Debian.
  - Activado `cockpit.socket` (`systemctl enable --now cockpit.socket`).
  - Acceso confirmado desde LAN y WireGuard en `https://<IP-main1>:9090` con usuario `alejandro`.

- Desplegado stack DNS interno con Pi-hole + Unbound en Docker:
  - `docker-compose` en `~/servidores/docker/dns/docker-compose.yml`.
  - Contenedores `pihole` y `unbound` en la red bridge `dns-net`.
  - Datos persistentes en:
    - `/srv/storage/services/dns/pihole/etc-pihole`
    - `/srv/storage/services/dns/pihole/etc-dnsmasq.d`
    - `/srv/storage/services/dns/unbound`

- Configuración de Pi-hole:
  - Puerto 53 (TCP/UDP) del host expuesto al contenedor `pihole`.
  - Panel web en `http://<IP-main1>:8081/admin`.
  - Unbound configurado como único upstream (`unbound#53`) sin resolvers públicos (Google/Cloudflare desmarcados).
  - Comprobado desde main1 con `dig @127.0.0.1 google.com`.

- Política de privacidad DNS:
  - No se ha cambiado el DNS del router: la LAN sigue usando el DNS del ISP/externo.
  - Solo los clientes WireGuard que se configuran con `DNS = 10.8.0.1, 1.1.1.1` pasan por Pi-hole.
  - Verificado en el Query Log de Pi-hole que:
    - Sin túnel activo no aparecen consultas.
    - Con túnel activo sí se registran dominios del cliente (IP 10.8.0.x).

- Nombres internos y Nextcloud:
  - Añadidos registros locales en Pi-hole:
    - `nextcloud.srv`  → `10.8.0.1`
    - `jellyfin.srv`   → `10.8.0.1`
    - `firefly.srv`    → `10.8.0.1`
  - Desde un cliente WireGuard:
    - `ping nextcloud.srv` resuelve a `10.8.0.1`.
    - Acceso confirmado a `https://nextcloud.srv:10443`.
  - En el contenedor `big-bear-nextcloud-ls`:
    - Actualizada la lista de `trusted_domains` para incluir `nextcloud.srv` vía `occ`.
    - Verificado que ya no aparece aviso de dominio no confiable.
