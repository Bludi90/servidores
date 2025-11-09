# WireGuard — Cheatsheet

_Generado: 2025-11-09 18:48_

    WireGuard — CHEATSHEET (comandos personalizados)
    
    Objetivo: operaciones habituales sin exponer claves.
    Convención: IP/32 = IP interna wg del peer. Los nombres se mapean en scripts/wg-peers.byip
    
    Subcomandos:
      list-peers         → Lista peers con NOMBRE, IP/32, HS(min), RX/TX, estado (🟢/🟡/⚫)
      add-peer <NOMBRE>  → Alta de peer nuevo (asigna IP/32 libre, genera conf, opcional QR)
      del-peer <NOMBRE>  → Baja de peer (desactiva y elimina su IP/32 del wg0)
      repair             → Repara wg0: permisos, unidad, rutas, re-levanta interfaz
    
    Notas:
    - Los nombres ↔ IP/32 viven en scripts/wg-peers.byip
    - “HS(min)” = minutos desde último handshake
    - Nada de claves privadas en pantallas ni en snapshots

## add-peer

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

    wireguard del-peer
    Uso:
      wg-del-peer <NOMBRE>
    
    Descripción:
      Da de baja un peer, quita su IP/32 y lo elimina del wg0.
      Mantiene copia de seguridad del bloque eliminado.

## list-peers

    wireguard list-peers
    Uso:
      wg-list-peers [IFACE]
      wg-peer-list  [IFACE]      # alias compatible
    
    Descripción:
      Lista peers con NOMBRE, IP/32, minutos desde último HS, RX/TX y estado:
       - 🟢 HS ≤ 10 min, 🟡 10–60 min, ⚫ > 60 min o sin HS.

## repair

    wireguard repair
    Uso:
      wg-repair
    
    Descripción:
      Revisa y repara wg0 (permisos, unidad systemd, rutas binarios, levanta interfaz).
      Útil si hay fallos tras cambios o actualizaciones.

