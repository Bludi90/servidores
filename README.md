# Servidores privados (main1, backup, etc.)

Repositorio de configuración y estado de mis servidores caseros.  
No contiene datos sensibles: solo scripts, configuración y resúmenes de estado.

---

## Estado actual de los servidores

- 📊 **Índice de snapshots**: [docs/ESTADO.md](docs/ESTADO.md)  
  - Muestra el último snapshot *completo* de cada servidor.
- 📝 **Snapshots detallados** (por host):  
  - `state/main1/AAAA-MM-DD_HHMM-state.md`
  - `state/<OTROHOST>/AAAA-MM-DD_HHMM-state.md`
- 🔁 El snapshot y el índice se regeneran **cada hora** mediante cron.

---

## Estructura del repositorio (resumen)

- `docs/` – Documentación.
  - `docs/ESTADO.md` → índice de snapshots (autogenerado).
  - `docs/DECISIONS.md` → decisiones técnicas importantes.
  - `docs/BACKLOG.md` → tareas pendientes y prioridades.
  - `docs/SCRIPTS.md` → notas sobre scripts y uso.
  - `docs/COMANDOS.md` → resumen de comandos personalizados (autogenerado).
- `scripts/` – Scripts de administración.
  - `snapshot-state.sh` → genera un snapshot de estado para un host.
  - `build-index.sh` → reconstruye `docs/ESTADO.md`.
  - `commit-and-push.sh` → sube cambios a GitHub.
- `state/` – Snapshots generados periódicamente.
  - `state/main1/` → snapshots y logs del host `main1`.
- `common/` – Ficheros compartidos entre scripts (p.ej. registro de comandos).

---

## Automatización (resumen rápido)

- Un cron en `main1` ejecuta periódicamente:
  - `scripts/snapshot-state.sh` → genera `state/main1/current-state.md` y el snapshot horario.
  - `scripts/build-index.sh` → actualiza `docs/ESTADO.md`.
  - `scripts/commit-and-push.sh` → hace commit y push de cambios (snapshots, índice, logs).

Los logs principales están en:

- `state/main1/sync.log` → actividad de `commit-and-push.sh`.
- `state/main1/cron.out` → salida de cron (si se configura).

---

## Comandos habituales (chuleta personal)

Desde la raíz del repo (`~/servidores`):

```bash
# Generar snapshot manual de main1
./scripts/snapshot-state.sh

# Regenerar índice de estado
./scripts/build-index.sh

# Hacer commit + push manual
./scripts/commit-and-push.sh
