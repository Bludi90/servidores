# Checkpoint — ensayo Opción B en `legacy` (2026-04-14)

## Contexto

Host de ensayo:

- `legacy` / `Llobregat6`
- Debian 13
- Docker y Compose operativos

Fuente de datos:

- `backup1`
- snapshots `replica-20260413-033145`

## Qué quedó validado

### Host destino

- Debian limpio usable
- conectividad SSH a `backup1`
- staging local en `/srv/storage/tmp/dr-labs/`
- comandos DR instalados desde repo

### Restore parcial

Se validó que sí se pueden recuperar desde `backup1`:

- `nextcloud/config`
- `nextcloud/db`
- `users` desde el root `tank`

### Conclusión positiva

`legacy` sirve como banco de pruebas de Opción B.

El host no es el bloqueo principal.

## Qué falló

### 1. `nextcloud/data`

El restore con `zfs-restore-backup1-dataset` falló al crear el tar remoto en `/tmp` de `backup1` por falta de espacio.

### 2. `media/C_critico`

El restore de la media crítica mostró el mismo patrón:

- el método funciona conceptualmente
- pero el empaquetado remoto en tar grande no escala bien para este flujo

### 3. Root dataset `tank`

El acceso al dataset raíz mediante intentos tipo `--dataset .` no quedó resuelto de forma robusta.

## Diagnóstico exacto

El callejón sin salida no es `legacy`.

El bloqueo real es este:

- los helpers de restore actuales dependen de crear tar remoto antes de copiar
- por defecto se apoyan en rutas temporales que no son adecuadas para datasets grandes
- por tanto, el runbook va por delante del tooling

## Decisión técnica tomada

No seguir insistiendo con restores grandes manuales mientras el helper siga así.

El siguiente desarrollo prioritario es mejorar el tooling DR.

## Resultado útil de este checkpoint

Este ensayo no se considera fallido.

Se considera una validación útil que descubre el límite real del método actual y marca el siguiente bloque de trabajo:

- endurecer `zfs-restore-backup1-dataset`
- endurecer `zfs-restore-backup1`
- reintentar después `Nextcloud` en `legacy`
