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

## 2025-12-02 – Cockpit + DNS interno (Pi-hole + Unbound) en main1

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

## 2025-12-10 – WireGuard en main1: reorganización de clientes y wg-migrate-cli>

- Entre el 10 y el 16 de diciembre se completa el troubleshooting de WireGuard >
- Creado el comando personalizado wg-migrate-clients para reorganizar todos los>
- wg-migrate-clients, sin parámetros extra, mueve cada cliente a su carpeta cor>

## 2025-12-11 – Despliegue de Immich (backup de fotos del móvil)

- Instalado y configurado Immich en main1 como servicio Docker, accesible únicamente desde la LAN/VPN.
- Creado usuario principal y verificada la conexión desde la app móvil oficial (Android) apuntando al servidor self-hosted.
- Configurada la copia de seguridad automática de fotos y vídeos del móvil: subida solo por Wi-Fi y preferentemente cuando el dispositivo está cargando.
- Organizados los álbumes de WhatsApp: las fotos de distintos álbumes de origen se agrupan en un único álbum "WhatsApp" en Immich; se valora desactivar la opción de "Sincronizar álbumes" en la app para evitar la proliferación de álbumes automáticos.
- Pendiente: integrar Immich en el dominio/DNS interno (*.srv) y en el reverse proxy (Caddy), y definir la política de almacenamiento y backups para el dataset de fotos de Immich dentro de /srv/storage/media (nivel C_critico) y su futura réplica en el servidor de backups.

## 2025-12-13 — Portal.srv (Homepage) + widgets + red media_media

- Portal de usuarios desplegado con Homepage (`ghcr.io/gethomepage/homepage`) bajo `portal.srv`, accesible por DNS interno *.srv.
- Stack `docker/portal`: contenedor `homepage` (UI) + `portal-api` (nginx) sirviendo JSON desde `/srv/storage/services/portal/data/`.
- Config de Homepage en `/srv/storage/services/portal/homepage` (services/settings/layout/bookmarks/widgets). Iconos personalizados montados desde `/srv/storage/services/portal/assets/services`.
- Widgets CustomAPI operativos: `status.json` (estado/resumen), `resources.json` (CPU/RAM/ZFS) y `updates.json` (historial/últimos cambios). Contadores/uso para Jellyfin/Immich/Nextcloud vía `content.json`/`apps-usage.json`.
- Para que los widgets nativos de Radarr/qBittorrent funcionen sin timeouts: `homepage` unido a la red Docker externa `media_media` y acceso por hostname de contenedor.
- Cron: generación periódica de JSON (recursos/actualizaciones) y meteorología (OpenWeather). Ajustes de permisos en `/srv/storage/services/portal/data/` para lectura estable desde el portal.
- Nota: Firefly III quedó pendiente (servicio caído / revisión posterior).


## 2025-12-14 – main1 – SAI/UPS (CyberPower) con NUT + apagado controlado

- Configurado NUT con el UPS (CyberPower) y verificados servicios: `nut-driver@cyberpower`, `nut-server`, `nut-monitor`.
- Integradas notificaciones a Telegram mediante `nut-notify` + `upssched` (NOTIFYCMD en `/etc/nut/upsmon.conf`).
- `upssched.conf`: eventos ONBATT (30s, 60s) y lógica de apagado (FSD) con ventana objetivo de ~8 minutos (timer `fsd_120s` a 480s).
- Armado/desarmado del apagado real controlado con flag `/etc/nut/enable-shutdown` (ARMED). En modo desarmado se generan eventos `FSD_NOT_ARMED` para validar sin apagar.
- Pruebas verificadas con `journalctl -t nut-notify` y `journalctl -t nut-upssched` (mensajes ONBATT/ONLINE llegan a Telegram).

## 2025-12-15 – main1 – srv-health (UPS) + estabilización DNS Pi-hole/Unbound

- `srv-health`: añadida sección UPS (NUT) en formato compacto con `[OK]/[WARN]/[FAIL]`, mostrando estado ARMED, métricas clave (status/carga/autonomía/voltaje/batería) y estado de servicios NUT.
- DNS: validada resolución por Pi-hole (en 10.8.0.1) y por Unbound (IP interna Docker) tras reinicios/pruebas.
- Nota de implementación: en esta versión de Pi-hole no existe `/etc/pihole/setupVars.conf`; la configuración relevante está en `/etc/pihole/pihole.toml` y `/etc/pihole/dnsmasq.conf` (upstream a Unbound `172.18.0.2#53`).
- `srv-health`: el estado “health: starting” de Pi-hole puede aparecer durante segundos tras `docker restart`; el chequeo se basa también en la respuesta DNS para evitar falsos WARN transitorios.

## 2025-12-22 — backup1: réplica + WireGuard rescue + DR de wg0

- backup1 instalado (Debian) y accesible por LAN; DHCP reservation en el router (IP fija).
- Réplica periódica main1 → backup1 configurada:
  - usuario `replica` con key restringida (from=IP main1 + sin PTY/forwarding) y sudo NOPASSWD solo para `/usr/bin/rsync`
  - script en main1: `/usr/local/sbin/replicate-main1-to-backup1`
  - cron: `0 7 * * * root flock -n /var/lock/replicate-backup1.lock /usr/local/sbin/replicate-main1-to-backup1 >> /var/log/replicate-backup1.log 2>&1`
  - log: `/var/log/replicate-backup1.log` + logrotate
- WireGuard “rescue” en backup1 (`wgr0`) operativo como túnel secundario de emergencia:
  - puerto UDP 51821 con port-forward en router hacia backup1
  - UFW permite 51821/udp y SSH desde `10.81.0.0/24`
  - perfiles en `/etc/wireguard/clients-rescue/`
- DR (failover) del WireGuard principal de main1 (`wg0`) preparado en backup1:
  - scripts: `/usr/local/sbin/dr-wg0-promote` y `/usr/local/sbin/dr-wg0-demote`
  - `dr-wg0-promote --force` usa staging `/etc/wireguard/dr-main1`, parchea PostUp/PostDown al interfaz WAN real (ej. `eno1`),
    habilita forwarding IPv4 y levanta `wg0`.
  - `dr-wg0-demote` apaga y enmascara `wg0`.
  - Nota: el DR evita tocar `wgr0` y `clients-rescue` (no se sincroniza todo `/etc/wireguard` para no borrar rescue).
