# DR Matrix

Esta matriz resume el estado actual del proyecto de recuperación de `main1`.

No sustituye a los runbooks. Sirve para ver, de un vistazo:

- qué estrategia existe
- qué servicios entran primero
- qué está validado
- qué piezas faltan aún

---

## Estrategias principales

| Estrategia | Idea base | Cuándo usarla | Ventaja principal | Riesgo principal | Runbook |
|---|---|---|---|---|---|
| Opción A | `backup1` asume temporalmente el rol de `main1` | caída prolongada de `main1` y necesidad de volver rápido | recuperación más rápida | mezcla backup + producción temporal | [Opción A](./dr-option-a-backup1-takeover.md) |
| Opción B | host nuevo reconstruido desde `backup1` | cuando compensa reconstruir limpio | separación más segura entre backup y servicio vivo | recuperación algo más lenta | [Opción B](./dr-option-b-backup1-host-nuevo.md) |
| Restore puntual | extraer dataset/ruta/servicio concreto desde `backup1` | incidencias parciales o recuperación selectiva | mínimo impacto | no devuelve servicio completo por sí sola | [Réplica y restore](./replica-restore-backup1.md) |

---

## Estado por servicio crítico

| Servicio | Prioridad | Datos críticos | Opción A | Opción B | Kit reutilizable | Validación actual | Observaciones |
|---|---|---|---|---|---|---|---|
| Nextcloud | Alta | `config`, `data`, `db`, `/srv/storage` | Base definida, takeover no validado end-to-end | Sí, bien orientada | Sí | Parcialmente validado | depende también de `files_external` y del árbol `/srv/storage` |
| Immich | Alta | PostgreSQL + uploads | Base definida, takeover no validado end-to-end | Sí, bien orientada | Sí | Parcialmente validado | para primer DR no hace falta `machine-learning` |
| Jellyfin | Media | config + media + custom init | Base definida, takeover no validado end-to-end | Sí, bien orientada | Sí | Parcialmente validado | GPU no es requisito mínimo del DR |
| Firefly III | Baja | DB + app config | No definido | No definido | No | No validado | queda fuera del primer bloque de DR |
| Ghostfolio | Baja | DB + app config | No definido | No definido | No | No validado | fuera del bloque crítico |
| n8n | Baja | config + workflows + credenciales | No definido | No definido | No | No validado | fuera del bloque crítico |
| portal | Baja | config + recursos generados | No definido | No definido | No | No validado | útil, pero no crítico para continuidad inicial |
| Stirling-PDF | Baja | config + volúmenes | No definido | No definido | No | No validado | servicio secundario |

---

## Dependencias transversales

| Componente | Papel en DR | Estado |
|---|---|---|
| Réplica ZFS `main1 -> backup1` | base de continuidad de datos | validada |
| `zfs-restore-backup1` | restore controlado a staging o a otro host | validado |
| helpers de `backup1` | soporte de apagado y restore | validados a nivel base |
| Docker + Compose | runtime mínimo de servicios | asumido en Opción A y Opción B |
| WireGuard / acceso remoto | administración remota y posible continuidad de acceso | parcialmente definido |
| DNS / Caddy / publicación | entrada final de usuarios durante takeover o reconstrucción | pendiente de cierre |

---

## Qué está cerrado y qué no

### Cerrado a nivel base

- réplica ZFS
- restore controlado
- runbook base de réplica/restore
- runbook de Opción B como hoja de ruta
- runbook de Opción A como base documental inicial
- kits reutilizables de `Nextcloud`, `Immich` y `Jellyfin`

### Pendiente importante

- ensayo controlado real de Opción A
- mecánica exacta de promoción de datasets para takeover
- estrategia de red temporal durante takeover
- vuelta documentada a estado pasivo tras takeover
- ampliar DR a servicios secundarios

---

## Recomendación operativa actual

### Si el problema afecta solo a un bloque concreto

Usar primero **restore puntual**.

### Si `main1` cae y hace falta volver rápido

Valorar **Opción A**, pero con alcance mínimo y mucha disciplina.

### Si hay host alternativo disponible y tiempo razonable

Preferir **Opción B**, porque mantiene una separación más limpia entre backup y servicio vivo.
