# Huecos del tooling que bloquean el cierre de Opción B

## Situación actual

El runbook de Opción B está bien orientado, pero el tooling de restore todavía no acompaña del todo.

## Hueco 1 — tar remoto en `/tmp`

### Afecta a

- `scripts/cmd/zfs-restore-backup1-dataset`
- `scripts/cmd/zfs-restore-backup1`

### Problema

Ambos comandos construyen primero un tar remoto antes de copiarlo al host destino.

En el caso de `zfs-restore-backup1-dataset`, ese tar remoto se fija en `/tmp`.

### Consecuencia

Datasets grandes como:

- `nextcloud/data`
- bloques grandes de `media`

fallan por espacio en el host de backup aunque el flujo conceptual sea correcto.

### Cambio mínimo recomendado

Añadir opción:

- `--remote-tar-dir DIR`

con valor por defecto razonable pero configurable, por ejemplo `/srv/replica`.

### Cambio robusto recomendado

Añadir modo:

- `--stream`

para extraer sin tar remoto persistente.

---

## Hueco 2 — root dataset `tank`

### Problema

El acceso a subrutas del root dataset no está resuelto de forma limpia en el CLI actual.

Intentos tipo `--dataset .` no son una interfaz robusta.

### Cambio recomendado

Definir una forma explícita de referirse al root dataset, por ejemplo:

- `--dataset-root`
- o `--dataset ''` manejado explícitamente
- o una sintaxis documentada equivalente

---

## Hueco 3 — helper sin salida por stdout

### Problema

`backup1-zfs-restore-helper` hoy sabe:

- clonar
- montar
- crear tar en fichero
- limpiar

pero no expone una salida pensada para streaming directo.

### Cambio recomendado

Añadir subcomando:

- `tar-stdout <mountpoint> <subpath>`

para poder hacer:

```bash
ssh HOST "sudo -n backup1-zfs-restore-helper tar-stdout ..." | tar -xf -
```

---

## Hueco 4 — documentación de límites reales

### Problema

El runbook general describe bien la arquitectura, pero no deja suficientemente visible el límite actual del helper ante datasets grandes.

### Cambio recomendado

Mantener este hueco documentado de forma explícita hasta que el parche esté validado.

---

## Criterio de cierre del tooling

El tooling podrá considerarse suficiente para cerrar Opción B cuando permita:

1. restaurar `nextcloud/data` sin depender de `/tmp`
2. restaurar subrutas grandes de `media` sin workaround manual frágil
3. restaurar subrutas del root `tank` con una interfaz clara
4. repetir el lab de `Nextcloud` en `legacy` sin bloqueos de método
