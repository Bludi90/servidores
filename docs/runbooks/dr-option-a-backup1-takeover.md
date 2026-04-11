# Runbook — DR Opción A con `backup1` asumiendo temporalmente el rol de `main1`

## Objetivo

Este runbook documenta la **Opción A** de DR del proyecto:

- `backup1` deja de ser una réplica pasiva temporalmente
- `backup1` asume el rol operativo de `main1`
- el objetivo es restablecer cuanto antes los **servicios críticos de negocio** mientras `main1` está caído o en mantenimiento mayor

Este documento **no sustituye** al runbook de réplica/restore ZFS ni al runbook de Opción B.  
Se apoya en ambos y define el takeover temporal de `backup1`.

Runbooks relacionados:

- `docs/runbooks/replica-restore-backup1.md`
- `docs/runbooks/dr-option-b-backup1-host-nuevo.md`

---

## Qué es exactamente la Opción A

### Definición

La Opción A consiste en que:

1. se detiene la idea de `backup1` como réplica pasiva
2. se promocionan los datos necesarios en `backup1`
3. se levantan en `backup1` los servicios críticos
4. la red y el acceso remoto se reorientan para que los usuarios lleguen a `backup1`

### Cuándo tiene sentido

Usar Opción A cuando:

- `main1` no puede arrancar o no es recuperable a corto plazo
- interesa recuperar servicio rápido sin esperar a host nuevo
- `backup1` tiene capacidad suficiente para sostener temporalmente los servicios esenciales

### Cuándo NO es la mejor opción

- si `backup1` no puede asumir la carga mínima
- si el problema de `main1` se resuelve en muy poco tiempo
- si compensa más reconstruir limpio en otro host

---

## Estado actual conocido

## Lo que sí está validado

Ya existe y está validado:

- réplica ZFS `main1 -> backup1`
- restore controlado desde `backup1`
- helpers y automatización base de réplica
- kits de laboratorio para:
  - `Jellyfin`
  - `Nextcloud`
  - `Immich`
- runbook unificado de Opción B

## Lo que NO está validado todavía

A día de hoy **no está validado end-to-end** un takeover real completo de `backup1` como `main1`.

Por tanto, este runbook debe entenderse como:

- guía operativa priorizada
- checklist realista
- base para futuros ensayos de Opción A

No como procedimiento ya ensayado al 100% en producción.

---

## Prioridad de negocio para takeover

Orden actual de prioridad:

1. archivos personales / familiares
2. fotos
3. multimedia

Servicios asociados:

1. `Nextcloud`
2. `Immich`
3. `Jellyfin`

Servicios secundarios quedan fuera del takeover inicial:

- `Ghostfolio`
- `Firefly`
- `n8n`
- `portal`
- `*arr`
- `Stirling-PDF`
- etc.

---

## Diferencia clave respecto a Opción B

## Opción A

- `backup1` pasa a ser host vivo temporal
- implica **promoción** de datos y servicios sobre el propio backup
- es más rápida para volver a servir, pero más invasiva

## Opción B

- `backup1` sigue siendo fuente de datos
- el servicio vivo se reconstruye en otro host
- es más limpia y más segura a largo plazo, pero suele ser más lenta

---

## Riesgos principales de la Opción A

1. mezclar el rol de backup con el rol de producción temporal
2. romper la pasividad de la réplica si no se controla bien el proceso
3. introducir divergencia entre lo que se escriba en `backup1` y el estado previo de `main1`
4. alargar demasiado el takeover y convertirlo en “producción improvisada”

### Principio operativo

La Opción A debe tratarse como:

- **temporal**
- **controlada**
- **con alcance mínimo**

---

## Prerrequisitos mínimos antes de activar Opción A

## 1. Confirmar necesidad real

Antes de hacer takeover:

- confirmar que `main1` no vuelve rápido
- decidir expresamente que compensa takeover en vez de Opción B

## 2. Confirmar frescura de la réplica

En `main1` o desde donde proceda:

- `zfs-repl-backup1-freshness`
- `zfs-repl-backup1-status`
- revisión del último snapshot común

## 3. Congelar cualquier escritura residual de `main1`

Si `main1` sigue medio vivo pero inestable:

- parar servicios críticos
- evitar escrituras concurrentes
- no seguir usando `main1` como si nada

## 4. Confirmar capacidad mínima de `backup1`

Antes de takeover revisar en `backup1`:

- RAM
- CPU
- espacio libre
- Docker / Compose
- conectividad LAN y/o VPN

## 5. Decidir alcance del takeover

Recomendación inicial:

- **solo servicios críticos**
- no levantar servicios secundarios hasta estabilizar

---

## Datos y rutas críticas para takeover

## Nextcloud

- `/srv/storage/nextcloud/config`
- `/srv/storage/nextcloud/data`
- `/srv/storage/nextcloud/db`
- `/srv/storage` por `files_external`

## Immich

- `/srv/storage/services/immich/postgres`
- `/srv/storage/media/C_critico/Immich`

## Jellyfin

- config persistente
- `custom-cont-init.d`
- biblioteca multimedia

---

## Preparación conceptual del takeover

## Capa 1 — datos

La réplica pasiva en `backup1` está diseñada como:

- `readonly=on`
- `mounted=no`
- `canmount=noauto`

Para takeover no se trabaja directamente sobre la réplica pasiva “tal cual”.  
Hay que crear una **capa viva temporal**, por ejemplo mediante:

- clones ZFS del snapshot elegido
- o promoción controlada de datasets temporales de servicio

### Principio

**No convertir a la ligera la réplica base en producción viva.**

Lo razonable es trabajar con una capa explícita de takeover temporal.

## Capa 2 — runtime

En `backup1` deben estar disponibles:

- Docker
- Docker Compose
- kits DR de los servicios críticos

## Capa 3 — red / acceso

La Opción A exige decidir cómo llegarán los usuarios a `backup1`.

Opciones típicas:

- acceso solo por LAN/VPN con puertos temporales
- cambio del endpoint de WireGuard
- cambio del port-forward del router
- ajuste temporal de DNS interno
- publicación temporal mediante `Caddy` o acceso directo por puerto

---

## Orden recomendado de takeover

## Fase 0 — decisión y congelación

1. declarar Opción A activa
2. congelar escrituras residuales en `main1`
3. identificar snapshot base de takeover

## Fase 1 — preparar datos vivos temporales en `backup1`

1. elegir snapshot base
2. crear clones o datasets temporales necesarios
3. verificar mounts y permisos

## Fase 2 — acceso mínimo de administración

1. SSH estable en `backup1`
2. si procede, WireGuard o acceso LAN definido
3. confirmar que el host es administrable de forma remota

## Fase 3 — levantar servicios críticos

Orden recomendado:

1. `Nextcloud`
2. `Immich`
3. `Jellyfin`

### Motivo

- `Nextcloud` cubre el bloque más crítico de archivos y documentación
- `Immich` cubre fotos
- `Jellyfin` cubre multimedia

## Fase 4 — red de usuarios

1. decidir URLs / puertos temporales
2. comunicar acceso a usuarios
3. validar login y uso mínimo

## Fase 5 — soporte opcional

Solo si el takeover va a durar más de lo previsto:

- `Caddy`
- DNS interno
- `UFW`
- piezas auxiliares mínimas

---

## Secuencia operativa mínima por servicio en takeover

## Nextcloud

1. preparar capa viva temporal de:
   - `config`
   - `data`
   - `db`
   - `storage-root`
   - `media` si hace falta
2. levantar `mariadb`
3. levantar `nextcloud`
4. comprobar:
   - `occ status`
   - `files_external:list`
   - acceso web
5. ajustar `trusted_domains` si el acceso cambia

## Immich

1. preparar PostgreSQL real o clon vivo
2. preparar uploads reales
3. levantar `database`
4. levantar `redis`
5. levantar `immich-server`
6. validar HTTP y acceso web
7. dejar `machine-learning` para fase 2 del takeover si es necesario

## Jellyfin

1. preparar config viva temporal y media
2. usar cache/transcode locales
3. levantar `jellyfin`
4. validar acceso web y biblioteca mínima

---

## Validaciones mínimas para considerar takeover funcional

## Host

- `backup1` estable
- SSH estable
- Docker y Compose OK

## Nextcloud

- `occ status` OK
- `files_external:list` OK
- acceso web usable

## Immich

- HTTP `200` OK
- login o pantalla principal accesible
- logs sin error de DB

## Jellyfin

- acceso web OK
- biblioteca visible
- logs sin error crítico

---

## Red y entrada de usuarios durante takeover

## Opción mínima y más segura

Durante la fase inicial, publicar solo por:

- LAN
- VPN
- o túneles temporales

## Opción de continuidad más completa

Si el takeover debe servir a usuarios como sustituto real de `main1`, habrá que decidir:

1. si `backup1` tomará el endpoint de WireGuard
2. si se cambia el port-forward del router
3. si se ajusta el DNS interno (`*.srv`)
4. si `Caddy` entra ya en el takeover

### Principio

No hacer cambios de red grandes hasta que los servicios críticos estén levantados y validados localmente.

---

## Rollback de Opción A

## Cuándo hacer rollback

- si `backup1` no aguanta mínimamente la carga
- si la promoción de datos no es estable
- si compensa más pasar a Opción B
- si `main1` vuelve antes de lo previsto

## Principio de rollback

1. parar servicios levantados en `backup1`
2. documentar qué datasets o clones temporales se han usado
3. no seguir escribiendo sobre la capa viva temporal
4. decidir retorno a:
   - `main1`
   - o reconstrucción por Opción B

---

## Límites conocidos de esta Opción A

1. takeover completo no validado aún end-to-end
2. no existe todavía automatización integral de promoción y publicación
3. riesgo de divergencia de datos si el takeover se prolonga
4. `backup1` debe seguir tratándose como infraestructura de contingencia, no como producción permanente

---

## Criterio de cierre de la Opción A base

La Opción A puede considerarse **cerrada a nivel base** cuando se haya validado, al menos en ensayo controlado:

- decisión y freeze de `main1`
- creación de capa viva temporal en `backup1`
- arranque de `Nextcloud`
- arranque de `Immich`
- arranque de `Jellyfin`
- acceso de usuarios por ruta temporal definida
- rollback o retorno claramente documentado

---

## Próximo nivel después de este runbook

1. definir la mecánica exacta de promoción de datasets en `backup1`
2. decidir estrategia de red temporal para takeover
3. ensayar Opción A con alcance mínimo, empezando por un servicio
4. añadir checklist de vuelta a estado pasivo tras takeover
