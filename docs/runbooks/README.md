# Índice de runbooks de DR

Este directorio reúne la documentación operativa de **disaster recovery (DR)** del proyecto `servidores`.

Su objetivo es que, en una situación de incidencia real, no haya que adivinar por dónde empezar.

---

## Empezar aquí

### 1. Entender el bloque base de datos y restore

Leer primero:

- [Réplica y restore ZFS con backup1](./replica-restore-backup1.md)

Ese runbook cubre:

- la réplica `main1 -> backup1`
- la pasividad de la réplica
- los comandos de frescura, estado y restore
- el bloque base sobre el que descansan las demás opciones de DR

### 2. Elegir estrategia de recuperación

Una vez entendido el bloque base, elegir una de estas rutas:

#### Opción A — `backup1` asume temporalmente el rol de `main1`

- [DR Opción A con backup1 takeover](./dr-option-a-backup1-takeover.md)

Usarla cuando:

- `main1` no vuelve rápido
- interesa recuperar servicio cuanto antes
- `backup1` puede sostener temporalmente los servicios críticos

#### Opción B — host nuevo reconstruido desde `backup1`

- [DR Opción B desde backup1 hacia host nuevo](./dr-option-b-backup1-host-nuevo.md)

Usarla cuando:

- compensa reconstruir limpio
- se quiere separar claramente backup y producción
- se dispone de otro host Debian

---

## Mapa rápido de decisión

### Si necesitas...

- **restaurar un dataset, ruta o servicio concreto** → ir al runbook base de réplica/restore
- **devolver servicio rápido con `backup1`** → Opción A
- **reconstruir en máquina nueva** → Opción B

---

## Estado actual de madurez

### Validado hoy

- réplica ZFS `main1 -> backup1`
- restore controlado desde `backup1`
- kits DR de `Nextcloud`, `Immich` y `Jellyfin`
- runbook base de réplica/restore
- runbook de Opción B como hoja de ruta unificada

### Aún no validado end-to-end

- takeover completo de Opción A
- retorno completo desde takeover a estado pasivo
- publicación final de servicios durante takeover con red redirigida completa

---

## Prioridad de negocio actual

Orden de recuperación acordado:

1. archivos personales / familiares
2. fotos
3. multimedia

Servicios asociados:

1. `Nextcloud`
2. `Immich`
3. `Jellyfin`

---

## Kits reutilizables relacionados

Los laboratorios DR por servicio viven en `docker/dr/`.

Actualmente hay material reutilizable para:

- `Jellyfin`
- `Nextcloud`
- `Immich`

Estos kits no sustituyen a los runbooks, pero los complementan.

---

## Checklist mental en una incidencia real

1. confirmar si `main1` puede volver rápido o no
2. congelar escrituras residuales si `main1` sigue medio vivo
3. validar frescura de la réplica
4. elegir Opción A u Opción B
5. recuperar primero servicios críticos
6. dejar fuera los servicios secundarios hasta estabilizar

---

## Documentos relacionados recomendados

- [DR Matrix](./DR-MATRIX.md)
- [README principal del repo](../../README.md)
