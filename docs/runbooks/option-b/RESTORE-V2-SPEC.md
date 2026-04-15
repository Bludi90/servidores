# Restore v2 — especificación mínima

## Objetivo

Definir una interfaz nueva o ampliada de restore que permita cerrar Opción B sin depender de workarounds frágiles.

## Principios

- no depender rígidamente de `/tmp`
- soportar datasets grandes
- soportar subrutas grandes
- soportar el root dataset `tank`
- mantener cleanup seguro de clones temporales
- seguir siendo usable desde otro host Linux por SSH

---

## 1. `backup1-zfs-restore-helper`

### Subcomandos existentes útiles

- `snapshot-exists`
- `clone-mount`
- `cleanup`

### Subcomandos nuevos propuestos

#### `tar-path-stdout <mountpoint> <subpath>`

Emite un tar por stdout sin crear fichero remoto.

Uso previsto:

```bash
ssh HOST "sudo -n backup1-zfs-restore-helper tar-path-stdout MOUNT SUBPATH" | tar -xf -
```

#### `tar-dataset-stdout <mountpoint>`

Emite el dataset entero por stdout.

Uso previsto:

```bash
ssh HOST "sudo -n backup1-zfs-restore-helper tar-dataset-stdout MOUNT" | tar -xf -
```

#### `tar-path-file <mountpoint> <subpath> <tarfile>`

Alias más explícito del patrón actual de `tar-path`.

#### `tar-dataset-file <mountpoint> <tarfile>`

Empaqueta dataset entero en fichero remoto usando ruta configurable.

---

## 2. `zfs-restore-backup1-dataset`

### Cambios mínimos

Añadir:

- `--remote-tar-dir DIR`

para que el tar remoto no quede forzado a `/tmp`.

### Cambios robustos

Añadir:

- `--stream`

Comportamiento:

- crea clone remoto
- emite dataset por stdout
- extrae directamente en destino local
- limpia clone remoto

### Interfaz propuesta

```bash
zfs-restore-backup1-dataset \
  --ssh-target backup1 \
  --dataset nextcloud/data \
  --tag replica-YYYYMMDD-HHMMSS \
  --dest /ruta/local \
  [--remote-tar-dir /srv/replica] \
  [--stream]
```

### Regla

- si `--stream` está activo, ignorar `--remote-tar-dir`
- si no hay `--stream`, usar `--remote-tar-dir` o un default documentado

---

## 3. `zfs-restore-backup1`

### Cambios mínimos

Añadir:

- `--remote-tar-dir DIR`

### Cambios robustos

Añadir:

- `--stream`

### Root dataset `tank`

Resolver de forma explícita una interfaz válida para subrutas del root dataset.

Opciones válidas de diseño:

- `--dataset-root`
- `--dataset-root --path users`
- o `--dataset tank-root` como alias lógico documentado

La interfaz no debería depender de hacks tipo `.`.

### Interfaz propuesta

```bash
zfs-restore-backup1 \
  --ssh-target backup1 \
  --dataset-root \
  --tag replica-YYYYMMDD-HHMMSS \
  --path users \
  --dest /ruta/local \
  [--remote-tar-dir /srv/replica] \
  [--stream]
```

---

## 4. Criterios de validación de restore v2

### Dataset completo

Debe poder restaurar sin error:

- `nextcloud/config`
- `nextcloud/data`
- `nextcloud/db`

### Subruta grande

Debe poder restaurar sin error:

- `media/C_critico`

### Root dataset

Debe poder restaurar sin error:

- `users`
- y otras subrutas necesarias del árbol `/srv/storage`

### Limpieza

Tras cada restore:

- no deben quedar clones huérfanos en `backup/restore-tests`
- no deben quedar tars remotos si se usó modo fichero

---

## 5. Orden de adopción sugerido

1. añadir subcomandos stdout en helper
2. añadir `--remote-tar-dir`
3. añadir `--stream`
4. añadir interfaz limpia para root dataset
5. revalidar `Nextcloud` en `legacy`
