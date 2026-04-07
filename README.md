# Servidores privados (main1, backup, etc.)

Repositorio de configuración y estado de mis servidores caseros (main1 y futuros servidores de backup).  
Los datos de usuario viven en `/srv/storage` sobre ZFS (`tank`); aquí **no** hay datos sensibles ni secretos, solo scripts, configuración y resúmenes de estado.

---

## Estado actual de los servidores

- 📊 **Índice de snapshots**: [docs/ESTADO.md](docs/ESTADO.md)  
  - Muestra el último snapshot *completo* de cada servidor.
- 📝 **Snapshots detallados** (por host):  
  - `state/main1/AAAA-MM-DD_HHMM-state.md`
  - `state/<OTROHOST>/AAAA-MM-DD_HHMM-state.md`
- 🔁 El snapshot y el índice se regeneran **cada hora** mediante cron en `main1`.

---

### Servicios en producción (main1)

- 🧭 **Portal**: `portal.srv` (Homepage + `portal-api`).
- 🌐 **DNS interno**: Pi-hole + Unbound (resolver para `*.srv`; pensado para clientes LAN y WireGuard).
- 🔒 **Reverse proxy**: Caddy en Docker (TLS interno para servicios `*.srv`).
- 🔌 **SAI/UPS**: NUT operativo con notificaciones a Telegram y apagado controlado (armado mediante `/etc/nut/enable-shutdown`).

### Estado operativo actual (resumen)

- 🔐 **Acceso administrativo**: LAN + WireGuard (`llobregat6.duckdns.org`).
- 📊 **Estado horario**: snapshots en `state/main1/` + índice en `docs/ESTADO.md`.
- 🗂️ **Almacenamiento principal**: ZFS (`tank`) en producción.
- 🔁 **Réplica**: copia prevista/nocturna hacia `backup1`.

## Estructura del repositorio (resumen)

- `docs/` – Documentación.
  - `docs/ESTADO.md` → índice de snapshots (autogenerado).
  - `docs/DECISIONS.md` → decisiones técnicas importantes.
  - `docs/BACKLOG.md` → tareas pendientes y prioridades.
  - `docs/SCRIPTS.md` → notas sobre scripts y uso.
  - `docs/COMANDOS.md` → resumen de comandos personalizados (autogenerado).

- `scripts/` – Scripts de administración y utilidades.
  - `snapshot-state.sh` → genera un snapshot de estado para un host.
  - `build-index.sh` → reconstruye `docs/ESTADO.md`.
  - `commit-and-push.sh` → sube cambios a GitHub.
  - Otros scripts de apoyo (informes SMART/ZFS, generación de docs, etc.).

- `scripts/cmd/` – Comandos del ecosistema (se instalan como *symlinks* en el sistema).
  - Instalar/actualizar: `sudo ./scripts/install-commands.sh`
  - Destinos: `/usr/local/bin` y `/usr/local/sbin` (por ejemplo `srv-health`, `wol`, `lan-scan`, etc.).

- `state/` – Snapshots generados periódicamente.
  - `state/main1/` → snapshots, `current-state.md` y logs del host `main1`.

- `reports/` – Informes periódicos (SMART, ZFS, salud del servidor, etc.).

- `common/` – Ficheros compartidos entre scripts (p.ej. registro de comandos o plantillas).

- `hosts/` – Configuración/estado específico por host (si aplica).

- `root/`, `private/` – Material auxiliar específico para root o interno del proyecto  
  (sin datos sensibles ni secretos).

---

## Automatización (resumen rápido)

En `main1` hay varios cron jobs:

- Cada hora:
  - `scripts/snapshot-state.sh` → genera `state/main1/current-state.md` y el snapshot horario.
  - `scripts/build-index.sh` → actualiza `docs/ESTADO.md`.
  - `scripts/commit-and-push.sh` → hace commit y push de cambios (snapshots, índice, logs).

- Periódicamente (semanal, etc.):
  - Scripts de monitorización generan informes SMART/ZFS en `reports/`  
    y envían avisos (por ejemplo, vía Telegram) si se detectan problemas.

Los logs principales están en:

- `state/main1/sync.log` → actividad de `commit-and-push.sh`.
- `state/main1/cron.out` → salida de cron horario (si se configura).
- `reports/` → informes de salud del sistema.

---

## Comandos habituales (chuleta personal)

Desde la raíz del repo (`~/servidores`):

```bash
# Generar snapshot manual de main1
./scripts/snapshot-state.sh

# Ver resumen rápido del estado del servidor (ZFS, servicios, WG, etc.)
srv-health


# (Re)instalar comandos del ecosistema en /usr/local/bin y /usr/local/sbin
sudo ./scripts/install-commands.sh
# Ver actividad reciente del sistema de snapshots/commits
tail -40 state/main1/sync.log
```
