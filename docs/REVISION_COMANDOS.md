# Revisión de documentación de comandos (2026-04-10)

## Alcance revisado

Se revisó la consistencia entre:

- `docs/comandos/*.md`
- `scripts/cmd/*` (comandos realmente instalables)
- `scripts/gen-commands-doc.sh` (generador del índice)

## Hallazgos

### 1) Cobertura incompleta de comandos

Actualmente hay **35 comandos** en `scripts/cmd/` y solo **11 guías** en `docs/comandos/`.

Comandos con documentación pendiente (prioridad media/alta):

- `backup1-state-snapshot`
- `dr-wg0-demote`
- `lan2wol`
- `n8n-remediate`
- `n8n-remediate-digest`
- `nut-notify`
- `portal-usage.sh`
- `srv-health-weekly`
- `srv-portal-content`
- `srv-portal-resources`
- `srv-portal-status`
- `srv-portal-updates`
- `srv-portal-weather`
- `srv-urls`
- `wg-add-peer`
- `wg-del-peer`
- `wg-list-peers`
- `wg-migrate-clients`
- `wg-recover.sh`
- `wg-rename-peer`
- `wg-repair`
- `wg-set-name`
- `wg-set-peer-name`
- `wolctl`
- `zfs-retention-plan`
- `zfs-retention-prune`

> Nota: `wireguard.md` y `wol.md` funcionan como cheatsheets paraguas, pero no sustituyen totalmente fichas operativas por comando cuando hay automatizaciones críticas.

### 2) Errores de redacción/sintaxis en documentación

- `docs/comandos/wireguard.md`
  - Typo detectado: `wireguard miragte-clients` → `wireguard migrate-clients`.
- `docs/comandos/wol.md`
  - Cabecera duplicada `# Wake-on-LAN — Cheatsheet`.

### 3) Riesgo conceptual

Hay comandos críticos de operación (DR, retención, estado semanal, portal, WireGuard granular) sin ficha dedicada. Esto incrementa riesgo de:

- uso incorrecto en incidentes,
- dependencia de memoria operativa,
- dificultad para delegar tareas.

## Recomendación de completado (orden sugerido)

1. **DR/backup primero**
   - `dr-wg0-demote`, `srv-health-weekly`, `zfs-retention-plan`, `zfs-retention-prune`, `backup1-state-snapshot`.
2. **WireGuard operativo**
   - `wg-list-peers`, `wg-add-peer`, `wg-del-peer`, `wg-set-peer-name`, `wg-rename-peer`, `wg-repair`, `wg-migrate-clients`.
3. **Portal y utilidades**
   - `srv-portal-*`, `srv-urls`, `lan2wol`, `wolctl`, `nut-notify`, `n8n-remediate*`.

## Plantilla mínima recomendada para cada comando nuevo

- Resumen (`<!-- RESUMEN -->`)
- Qué hace / qué no hace
- Sintaxis exacta
- Parámetros y valores por defecto
- Ejemplos reales (copiar/pegar)
- Códigos de salida (si aplica)
- Ficheros/rutas que toca
- Troubleshooting rápido

## Comprobaciones realizadas durante la revisión

- Verificación de enlaces markdown internos en `docs/`: sin enlaces rotos.
- Cruce automatizado de cobertura: `scripts/cmd/*` vs `docs/comandos/*.md`.
