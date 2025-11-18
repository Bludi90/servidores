# LAN-Scan — Guía rápida

<!-- RESUMEN -->
`lan-scan` escanea la red local y muestra una tabla con IP, MAC, interfaz
(IFACE), hostname y fabricante (VENDOR), usando ARP/fping/nmap según el modo.

Uso típico:

- `lan-scan` → escaneo rápido equilibrado (clampa a /24 si la red es más grande).
- `lan-scan --fast` → muy rápido (fping/ARP, sin DNS).
- `lan-scan --deep` → exhaustivo (nmap -sn, con DNS).
<!-- /RESUMEN -->

---

## Descripción general

`lan-scan` es un comando de inventario rápido de la LAN.  
Muestra por cada host detectado:

- IP
- MAC
- IFACE (interfaz usada para el escaneo)
- HOSTNAME (si se resuelve)
- VENDOR (fabricante de la tarjeta de red, vía OUI)

Se ejecuta siempre como root (se relanza con `sudo` si hace falta) para poder
consultar la tabla ARP y usar herramientas de red sin problemas de permisos.

---

## Modos principales

- `lan-scan`  
  Modo por defecto (auto).  
  - Detecta la interfaz de salida (p. ej. `enp10s0`).
  - Detecta la red (CIDR) de la interfaz.
  - Si la red es más grande que /24, **clampa a /24** para un escaneo rápido.
  - El motor de escaneo se elige en este orden:
    - `fping` (si está disponible),
    - si no, ARP (`ip neigh`),
    - si no, `nmap -sn` como último recurso.

- `lan-scan --fast`  
  - Fuerza motor `fping` si está instalado.
  - Pensado para escaneos muy rápidos.
  - No hace resolución DNS (no intenta obtener hostname).
  - Apto para usar en bucles o scripts recurrentes.

- `lan-scan --deep`  
  - Usa `nmap -sn` (ping scan) con DNS activado.
  - Más lento pero más completo.
  - Ideal cuando se quiere una visión más detallada de qué responde en la red.

- `lan-scan --wide`  
  - No clampa a /24.
  - Usa el CIDR completo de la interfaz (por ejemplo, /23 o /22) si es el caso.
  - Útil en redes donde realmente se usa un rango más grande que /24.

---

## Flags útiles

- `-i IFACE`, `--iface IFACE`  
  Fuerza la interfaz a usar (por ejemplo `-i enp10s0`).

- `-n CIDR`, `--net CIDR`  
  Fuerza la red a escanear (por ejemplo `-n 192.168.1.0/24`).  
  Si no se especifica, se detecta a partir de la interfaz.

- `--csv`  
  Salida en formato CSV (cabecera `ip,mac,iface,hostname,vendor`).  
  Muy útil para volcar resultados a ficheros o procesarlos con otras
  herramientas (`grep`, `awk`, hojas de cálculo, etc.).

- `--no-dns`  
  Desactiva la resolución de nombres.  
  Reduce el tiempo de escaneo cuando no interesa el hostname.

- `--no-vendor`  
  No intenta resolver el fabricante (VENDOR) a partir de la MAC.  
  Útil si quieres máxima velocidad o si no tienes instalados ficheros OUI.

- `--refresh`  
  Opcionalmente “calienta” la red:
  - En modo `fping`, lanza un barrido rápido antes.
  - En otros modos, puede enviar pings para poblar la tabla ARP.
  Útil si acabas de encender equipos y la tabla ARP aún está vacía.

- `--timeout 1s`  
  Ajusta el tiempo de espera por host en modo `nmap`.  
  Valores mayores pueden detectar más dispositivos, pero harán el escaneo más
  lento.

- `--fping-timeout 80`  
  Ajusta el timeout de `fping` en milisegundos.  
  Un valor más alto aumenta la fiabilidad en redes lentas a costa de tiempo.

- `--debug`  
  Muestra información interna:
  - IFACE detectada.
  - NET original y NET_SCAN (tras clamp).
  - Motor usado (`engine`).
  Muy útil para diagnósticos cuando algo no cuadra.

---

## Notas sobre detección de MAC y VENDOR

- `lan-scan` intenta obtener la dirección MAC de cada IP usando la tabla ARP
  (`ip neigh`).
- Si no hay entrada ARP para una IP, puede realizar un ping corto para
  “despertar” el host y volver a consultar la tabla.
- Para el campo VENDOR (fabricante), busca en ficheros de OUI típicos:
  - `/usr/share/ieee-data/oui.txt`
  - `/usr/share/arp-scan/ieee-oui.txt`
  - `/usr/share/misc/oui.txt`
- El fabricante se resuelve **a partir de los 3 primeros octetos** de la MAC
  (prefijo OUI). No siempre estará disponible para todos los dispositivos.

---

## Requisitos recomendados

Para sacar el máximo partido:

- `fping` → escaneos rápidos (`--fast` y modo auto).
- `nmap` → escaneos profundos (`--deep`).
- Paquetes de OUI (por ejemplo `ieee-data`) → columna VENDOR informativa.

En Debian/Ubuntu:

```bash
sudo apt install -y fping nmap ieee-data
```

## Ejemplos de uso

Escaneo rápido por defecto (auto, clamp a /24 si hace falta):  
`lan-scan`

Escaneo muy rápido, sin DNS, ideal para ver qué está vivo:  
`lan-scan --fast --no-dns`

Escaneo profundo con DNS para ver nombres de host:  
`lan-scan --deep`

Escanear una red concreta desde una interfaz específica:  
`lan-scan -i enp10s0 -n 192.168.1.0/24`

Obtener salida en CSV para procesar en otra herramienta:  
`lan-scan --csv > lan-inventory.csv`

---

## Notas y troubleshooting

- Si no se detecta interfaz automáticamente, especifica `-i IFACE`.

- Si el listado de IP/MAC es incompleto:
  - Usa `--refresh` para “calentar” la red.
  - Prueba `--deep` si sospechas que hay hosts que no responden a pings rápidos.

- Si VENDOR aparece vacío:
  - Comprueba que tienes instalado algún fichero de OUI (por ejemplo `ieee-data`).

- Recuerda que algunos dispositivos pueden ignorar pings ICMP o estar detrás de
  otros equipos, por lo que nunca verás el 100 % de todo lo que hay físicamente
  conectado solo con ICMP/ARP.

