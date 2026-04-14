# Opción B — estructura de cierre

Este directorio aterriza el cierre operativo de la **Opción B**:

- `backup1` como fuente de snapshots y material de recuperación
- un host Debian alternativo como destino de reconstrucción
- recuperación priorizada de servicios críticos sin depender de CasaOS

## Objetivo de esta capa

Pasar de un runbook general a una estructura de trabajo más robusta para cerrar Opción B de forma reproducible.

## Archivos de esta carpeta

- `CHECKPOINT-legacy-2026-04-14.md`
  - estado real del ensayo en `legacy`
  - qué quedó validado
  - qué bloqueó el avance

- `MANIFEST.md`
  - mapa de datasets, rutas, servicios y orden de recuperación
  - referencia rápida para saber qué hay que restaurar realmente

- `TOOLING-GAPS.md`
  - huecos concretos del tooling actual
  - motivo técnico del bloqueo con datasets grandes
  - cambios mínimos necesarios en scripts

- `CLOSURE-PLAN.md`
  - hoja de ruta para dar Opción B por cerrada a nivel base

## Criterio de uso

1. leer primero el runbook general:
   - `docs/runbooks/dr-option-b-backup1-host-nuevo.md`
2. usar esta carpeta para el cierre práctico
3. no seguir intentando restores grandes manuales con el helper actual hasta cerrar los huecos del tooling

## Estado resumido

- `legacy` queda validado como host de ensayo razonable
- el bloqueo actual no está en `legacy`, sino en el método de restore
- el siguiente desarrollo prioritario es mejorar los scripts de restore antes de reintentar `Nextcloud` completo
