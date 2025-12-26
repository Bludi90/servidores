# WireGuard — Cheatsheet

_Generado: 2025-11-09 21:41_

    WireGuard — CHEATSHEET (comandos personalizados)
    
    Objetivo: operaciones habituales sin exponer claves.
    Convención: IP/32 = IP interna WG del peer. Nombres ↔ IP/32 en scripts/wg-peers.byip
    
    Subcomandos:
      list-peers         → Lista peers con NOMBRE, IP/32, HS(min), RX/TX, estado (🟢/🟡/⚫)
      add-peer <NOMBRE>  → Alta de peer nuevo (IP/32, claves, conf cliente, QR opcional)
      del-peer <NOMBRE>  → Baja de peer (elimina su IP/32)
      repair             → Repara wg0 (unidad, permisos, rutas)

## Convenciones de nombres (importante)

- **ID técnico (sin espacios):** se usa para rutas y archivos en `/etc/wireguard/clients/<id>/...`.
  - Recomendado: minúsculas + guiones, p.ej. `nuria-tv-figueres`.
- **Nombre visible (con espacios):** se muestra en `wg-list-peers` y UIs.
  - Se gestiona en `/etc/wireguard/names.tsv` mediante el mapeo **PublicKey → Nombre visible**.
  - Ejemplo: `Nuria - TV Figueres`.

## list-peers

_Disponible: Sí (`/usr/bin/wg-list-peers`)_
    wireguard list-peers
    Binario real: wg-list-peers (usable como 'wg list-peers')
    
    Uso:
      wg list-peers [-h] [IFACE]     # ayuda con -h
      wg list-peers                   # ejecuta listado
      wg-peer-list [IFACE]            # alias (si existe)
    
    Descripción:
      Lista peers con NOMBRE, IP/32, minutos desde último HS, RX/TX y estado:
       - 🟢 HS ≤ 10 min, 🟡 10–60 min, ⚫ > 60 min o sin HS.

## add-peer

_Disponible: Sí (`/usr/local/sbin/wg-add-peer`)_
    wireguard add-peer
    Uso:
      wg-add-peer <id_tecnico> [--ip 10.8.0.X/32] [--qr] [--out ./client.conf]
    
    Descripción:
      Da de alta un peer:
       1) busca IP/32 libre (o usa --ip),
       2) genera claves del cliente,
       3) añade el peer a wg0 y recarga,
       4) guarda el .conf del cliente (y QR si --qr).
    
    Archivos implicados:
      scripts/wg-peers.byip         # mapeo IP/32 ↔ NOMBRE
      /etc/wireguard/wg0.conf       # configuración del servidor (aplicación con wg-quick)

## del-peer

_Disponible: Sí (`/usr/local/sbin/wg-del-peer`)_
    wireguard del-peer
    Uso:
      wg-del-peer <NOMBRE>
    
    Descripción:
      Da de baja un peer, quita su IP/32 y lo elimina del wg0.
      Mantiene copia de seguridad del bloque eliminado.

## wg-set-peer-name — asignar nombre visible (PublicKey → Nombre)

Asigna o actualiza el nombre visible que muestra `wg-list-peers`, sin tocar claves manualmente.
El comando obtiene automáticamente la **PublicKey** desde:
- `/etc/wireguard/clients/<id>/<id>.pub` (esquema carpeta), o
- `/etc/wireguard/clients/<id>.pub` (esquema plano antiguo),

y escribe/actualiza `/etc/wireguard/names.tsv` en formato `PUBKEY  <Nombre visible>`.

**Uso:**
```bash
sudo wg-set-peer-name <id_tecnico> "Nombre visible con espacios"
```

**Ejemplo:**
```bash
sudo wg-set-peer-name nuria-tv-figueres "Nuria - TV Figueres"
```

**Verificación**
```bash
wg-list-peers | grep -i "Nuria - TV Figueres" || true
```

## wg-rename-peer — renombrar ID técnico (archivos de cliente)

Renombra el **ID técnico** del cliente (carpeta/archivos en `/etc/wireguard/clients`).
Soporta:
- esquema nuevo: `/etc/wireguard/clients/<id>/<id>.*`
- esquema viejo: `/etc/wireguard/clients/<id>.*`

**Importante:** el nuevo ID debe ser **sin espacios**. Para el nombre visible con espacios usar `wg-set-peer-name`.

**Uso:**
```bash
sudo wg-rename-peer <id_antiguo> <id_nuevo_sin_espacios>
```

**Ejemplo (recomendado):**
```bash
sudo wg-rename-peer tv-nuria nuria-tv-figueres
sudo wg-set-peer-name nuria-tv-figueres "Nuria - TV Figueres"
```


## repair

_Disponible: Sí (`/usr/local/sbin/wg-repair`)_
    wireguard repair
    Binario real: wg-repair
    
    Uso:
      wg-repair           # solo diagnóstico
      wg-repair --fix     # intenta levantar wg0 (wg-quick down/up, systemctl enable/start)
    
    Descripción:
      Revisa servicio wg-quick@wg0, ip_forward, socket UDP 51820 y estado de wg.
      Si hay sudo sin contraseña, puede relanzar el servicio (sin tocar claves).

## migrate-clients

_Disponible: Sí (`/usr/local/sbin/wg-migrate-clients`)_
    wireguard miragte-clients
    Binario real: wg-migrate-clients
    Objetivo: normalizar estructura (carpeta por cliente) y generar un .tgz en /tmp para copiar a otro servidor.

    Uso:
      sudo wg-migrate-clients
      ls -lh /tmp | grep -E 'wg|wireguard|clients' || true

    Descripción:
      Esto empaqueta clientes/perfiles, pero para DR completo también hay que conservar:
     /etc/wireguard/wg0.conf
     y las claves del servidor (según tu estructura actual: server.key/server.pub o /etc/wireguard/keys/)
