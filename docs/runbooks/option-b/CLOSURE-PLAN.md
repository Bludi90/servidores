# Plan de cierre — Opción B

## Objetivo

Cerrar Opción B a nivel base de forma realmente operativa, no solo conceptual.

## Fase 1 — congelar el checkpoint actual

### Resultado esperado

- `legacy` confirmado como host de ensayo válido
- limitación del helper documentada
- restos de laboratorio limpiados

### Estado

- alcanzado

---

## Fase 2 — endurecer el tooling de restore

### Objetivo

Eliminar la dependencia rígida de `/tmp` para datasets grandes y clarificar el acceso al root `tank`.

### Cambios mínimos

1. `zfs-restore-backup1-dataset`
   - añadir `--remote-tar-dir`
2. `zfs-restore-backup1`
   - añadir `--remote-tar-dir`
3. `backup1-zfs-restore-helper`
   - añadir `tar-stdout`
4. definir interfaz clara para root `tank`

### Criterio de salida

- `nextcloud/data` puede restaurarse sin fallo por espacio en `/tmp`

---

## Fase 3 — revalidar `Nextcloud` en `legacy`

### Objetivo

Cerrar el primer servicio crítico de Opción B en host nuevo simulado.

### Pasos

1. restaurar `config`
2. restaurar `data`
3. restaurar `db`
4. restaurar `users`
5. preparar `media-root` mínimo o selectivo
6. pasar `precheck-nextcloud`
7. levantar `mariadb + nextcloud`
8. validar:
   - `occ status`
   - `files_external:list`
   - acceso web local

### Criterio de salida

- `Nextcloud` validado de punta a punta en `legacy`

---

## Fase 4 — cerrar `Immich`

### Objetivo

Validar el segundo servicio crítico en el mismo patrón.

### Pasos

1. restaurar PostgreSQL real
2. preparar uploads reales o subset suficiente
3. levantar `database + redis + immich-server`
4. validar HTTP local y logs

### Criterio de salida

- `Immich` validado en `legacy`

---

## Fase 5 — cerrar `Jellyfin`

### Objetivo

Validar el tercer servicio crítico con la misma disciplina.

### Pasos

1. restaurar config persistente
2. restaurar media mínima o representativa
3. usar cache/transcode locales
4. levantar `jellyfin`
5. validar acceso y biblioteca

### Criterio de salida

- `Jellyfin` validado en `legacy`

---

## Fase 6 — consolidación final del runbook

### Objetivo

Convertir la experiencia de laboratorio en un runbook realmente cerrable.

### Entregables

- runbook general actualizado
- estructura de Opción B enlazada
- límites conocidos reducidos o eliminados
- comandos de restore robustos
- checklist final de validación

## Definición de Done de Opción B base

Opción B quedará cerrada a nivel base cuando se cumpla todo esto:

- restore robusto para datasets grandes
- `Nextcloud` validado en host alternativo
- `Immich` validado en host alternativo
- `Jellyfin` validado en host alternativo
- runbook y tooling coherentes entre sí
