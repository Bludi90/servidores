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
      wg-add-peer <NOMBRE> [--ip 10.8.0.X/32] [--qr] [--out ./client.conf]
    
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
