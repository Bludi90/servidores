# Runbook — Réplica y restore ZFS con backup1

## Objetivo

Este runbook documenta el bloque operativo de **réplica ZFS y restore controlado** entre:

- `main1` → servidor principal
- `backup1` → servidor de backup / réplica pasiva

Sirve para:

- entender la arquitectura actual
- operar la réplica diaria
- diagnosticar problemas
- ejecutar restores controlados
- reproducir la instalación en `backup1`
- tener una base clara para futuro DR y futuras políticas de retención

---

## Estado actual del sistema

### Origen
- Host principal: `main1`
- Pool origen: `tank`

### Destino
- Host de backup: `backup1`
- Pool destino: `backup`
- Dataset receptor:
  - `backup/replicas/main1/tank`

### Estado pasivo de la réplica en backup1
La réplica se mantiene como:

- `readonly=on`
- `mounted=no`
- `canmount=noauto`

Esto evita usar accidentalmente la réplica como dataset vivo.

---

## Arquitectura lógica

### Réplica
La réplica real del contenido se hace con:

~~~bash
zfs-repl-backup1
~~~

### Orquestación diaria
El flujo nocturno completo se hace con:

~~~bash
zfs-repl-backup1-nightly
~~~

Este wrapper:

1. comprueba dependencias
2. verifica `sv-backup1` en `wolctl`
3. enciende `backup1` por WOL si está apagado
4. espera ping y SSH
5. valida apagado remoto no interactivo
6. lanza la réplica real
7. registra resultado
8. apaga `backup1` si lo encendió él

### Estado operativo
- frescura actual:
  - `zfs-repl-backup1-freshness`
- cumplimiento semanal:
  - `zfs-repl-backup1-status`

### Restore
La extracción controlada desde la réplica se hace con:

~~~bash
zfs-restore-backup1
~~~

---

## Comandos principales del bloque

### En main1

- `zfs-repl-backup1`
- `zfs-repl-backup1-nightly`
- `zfs-repl-backup1-status`
- `zfs-repl-backup1-freshness`
- `zfs-restore-backup1`
- `srv-health`
- `srv-health-weekly`
- `wol`
- `wolctl`

### En backup1
Helpers de soporte:

- `/usr/local/sbin/backup1-safe-poweroff`
- `/usr/local/sbin/backup1-zfs-restore-helper`

---

## Ficheros importantes

### Estado y logs en main1

- Base común:
  - `~/servidores/state/main1/zfs-repl-backup1.last_common`
- Log manual:
  - `~/servidores/state/main1/zfs-repl-backup1.log`
- Log wrapper nocturno:
  - `~/servidores/state/main1/zfs-repl-backup1-nightly.log`
- Registro estructurado:
  - `~/servidores/state/main1/zfs-repl-backup1-runs.tsv`
- Salida del cron:
  - `~/servidores/state/main1/cron-zfs-repl-backup1-nightly.out`
- Log weekly:
  - `~/servidores/state/main1/srv-health-weekly.log`

### Scripts versionados en repo

#### main1
- `scripts/cmd/zfs-repl-backup1`
- `scripts/cmd/zfs-repl-backup1-nightly`
- `scripts/cmd/zfs-repl-backup1-status`
- `scripts/cmd/zfs-repl-backup1-freshness`
- `scripts/cmd/zfs-restore-backup1`

#### backup1
- `scripts/backup1/backup1-safe-poweroff`
- `scripts/backup1/backup1-zfs-restore-helper`
- `scripts/backup1/sudoers/alejandro-backup1-poweroff`
- `scripts/backup1/sudoers/alejandro-backup1-zfs-restore-helper`
- `scripts/install-backup1-helpers.sh`

---

## Automatización diaria actual

La réplica diaria corre a las **03:30**.

Cron vigente:

~~~cron
30 3 * * * /usr/local/bin/zfs-repl-backup1-nightly >> /home/alejandro/servidores/state/main1/cron-zfs-repl-backup1-nightly.out 2>&1
~~~

### Comportamiento esperado
- si `backup1` ya está encendido:
  - no manda WOL
  - replica
  - lo deja encendido
- si `backup1` está apagado:
  - manda WOL
  - espera a que vuelva
  - replica
  - lo apaga al final

---

## Monitorización actual

### Salud actual
`srv-health --short` muestra una sección tipo:

~~~text
== Réplica ZFS backup1 ==
[OK]    Bak OK (últ. 04/04/26 03:30)
~~~

Eso se basa en:

~~~bash
zfs-repl-backup1-freshness
~~~

### Resumen semanal
`srv-health-weekly` incluye una línea tipo:

~~~text
📦 Bak: 1/7 (últ. 04/04/26)
~~~

Eso se basa en la lógica de:

~~~bash
zfs-repl-backup1-status
~~~

### Logs visibles en srv-health
En modo completo, `srv-health` muestra también:

- `smart-weekly.log`
- `sync.log`
- `zfs-repl-backup1-nightly.log`

---

## WOL y apagado remoto

### Identidad WOL del backup
Actualmente el host de backup está dado de alta como:

~~~text
sv-backup1
~~~

### Comprobaciones útiles

~~~bash
wolctl show sv-backup1
wol sv-backup1
~~~

### Apagado remoto
El wrapper usa en `backup1`:

~~~bash
sudo -n /usr/local/sbin/backup1-safe-poweroff
~~~

Y su chequeo:

~~~bash
sudo -n /usr/local/sbin/backup1-safe-poweroff --check
~~~

---

## Flujo estándar de réplica

### Comprobación previa
~~~bash
zfs-repl-backup1-nightly --check
~~~

### Réplica manual simple
~~~bash
zfs-repl-backup1
~~~

### Réplica manual sin confirmación
~~~bash
zfs-repl-backup1 --yes
~~~

### Simulación manual
~~~bash
zfs-repl-backup1 --dry-run --yes
~~~

### Flujo completo manual (equivalente al cron)
~~~bash
zfs-repl-backup1-nightly
~~~

---

## Flujo estándar de restore

## Principio
**Nunca restaurar directamente sobre producción.**  
Siempre restaurar primero a staging.

## Ejemplo de restore controlado

~~~bash
zfs-restore-backup1 \
  --ssh-target backup1 \
  --dataset nextcloud/config \
  --tag replica-20260404-033002 \
  --path nginx \
  --dest /srv/storage/tmp/restore-staging
~~~

### Qué hace ese ejemplo
- usa el snapshot indicado
- clona temporalmente el dataset en `backup1`
- empaqueta solo `nginx`
- lo copia a `main1`
- lo extrae en:
  - `/srv/storage/tmp/restore-staging/nginx`
- limpia temporales remotos y tar local

### Dry-run previo
~~~bash
zfs-restore-backup1 \
  --ssh-target backup1 \
  --dataset nextcloud/config \
  --tag replica-20260404-033002 \
  --path nginx \
  --dest /srv/storage/tmp/restore-staging \
  --dry-run
~~~

---

## Restore desde otro host (DR básico)

El diseño actual de `zfs-restore-backup1` permite usarlo desde **otro Linux**, no solo desde `main1`, siempre que:

- exista conectividad SSH a `backup1`
- el host tenga `scp`, `ssh`, `tar`
- el host tenga permiso para usar su staging local
- el alias o IP de `backup1` sea resoluble/accesible

### Requisitos mínimos del host de sustitución
- acceso SSH como `alejandro` a `backup1`
- `zfs-restore-backup1` disponible
- destino local de staging

### Idea operativa
Si `main1` muere:

1. preparar un Linux temporal
2. copiar o desplegar `zfs-restore-backup1`
3. conectarse a `backup1`
4. extraer config o datos necesarios a staging
5. reconstruir servicios manualmente o mediante DR posterior

---

## Instalación reproducible en backup1

Los helpers de `backup1` ya están versionados en el repo.

### Despliegue
En `backup1`:

~~~bash
cd /home/alejandro/servidores
sudo ./scripts/install-backup1-helpers.sh
~~~

### Qué instala
- `/usr/local/sbin/backup1-safe-poweroff`
- `/usr/local/sbin/backup1-zfs-restore-helper`
- `/etc/sudoers.d/alejandro-backup1-poweroff`
- `/etc/sudoers.d/alejandro-backup1-zfs-restore-helper`

### Comprobaciones
~~~bash
sudo -n /usr/local/sbin/backup1-safe-poweroff --check
sudo -n /usr/local/sbin/backup1-zfs-restore-helper --check
~~~

---

## Validaciones mínimas recomendadas

### Validación rápida diaria
~~~bash
srv-health --short
~~~

### Validación del flujo nocturno
~~~bash
zfs-repl-backup1-nightly --check
~~~

### Validación de cumplimiento semanal
~~~bash
zfs-repl-backup1-status
~~~

### Validación de frescura
~~~bash
zfs-repl-backup1-freshness
~~~

### Validación de restore
Hacer periódicamente un restore controlado a staging con:

~~~bash
zfs-restore-backup1 --dry-run ...
zfs-restore-backup1 ...
~~~

---

## Troubleshooting rápido

### `backup1` no responde
Revisar:
- `wolctl show sv-backup1`
- IP `192.168.1.122`
- conectividad LAN
- BIOS / WOL / NIC

### El `--check` del nightly falla
Revisar:
- `wol`
- `wolctl`
- alias `backup1`
- acceso SSH
- `backup1-safe-poweroff --check`

### La frescura sale `Bak WARN` o `Bak FAIL`
Revisar:
- `zfs-repl-backup1-freshness`
- `zfs-repl-backup1-status`
- `tail -n 50 ~/servidores/state/main1/zfs-repl-backup1-nightly.log`

### `runs.tsv` no cuadra
Revisar:
- si hubo `mode=real`
- si fueron `OK`
- si hubo abortos o tests solo con `--check`

### El restore falla por permisos en staging
Revisar permisos del destino local y que el comando pueda usar:

~~~bash
sudo rm -rf DEST/SUBPATH
~~~

### Quedan clones viejos en `backup/restore-tests`
No debería pasar normalmente, pero puede ocurrir por pruebas antiguas o abortos. Limpiar manualmente en `backup1`.

---

## Transparencia del sistema

Este bloque cubre cuatro planos distintos:

### 1. Réplica de datos
- `zfs-repl-backup1`
- `zfs-repl-backup1-nightly`

### 2. Estado operativo actual
- `zfs-repl-backup1-freshness`
- `srv-health`

### 3. Cumplimiento histórico / semanal
- `zfs-repl-backup1-status`
- `srv-health-weekly`

### 4. Recuperación controlada
- `zfs-restore-backup1`

---

## Qué queda pendiente después de cerrar este bloque

Este runbook cierra el bloque **réplica + restore básico**, pero quedan pendientes futuras mejoras:

- política de retención histórica:
  - diaria
  - semanal
  - mensual / semestral
- integración visual en `portal.srv`
- posible registro explícito de:
  - último restore test OK
- DR más completo para reconstrucción de servicios completos

---

## Criterio de cierre de este bloque

Este bloque puede considerarse **cerrado operativamente** cuando se cumplen estas condiciones:

- réplica diaria funcional
- wake + apagado automáticos funcionales
- logs y `runs.tsv` funcionales
- `srv-health` y `srv-health-weekly` reflejan bien el estado
- restore a staging funcional
- helpers de `backup1` versionados en repo
- instalador reproducible de `backup1` validado
