# LANSCAN — Guía rápida

`lan-scan` lista dispositivos de la LAN con **IP, MAC, IFACE, HOSTNAME, VENDOR**.

## Modos
- `lan-scan` → auto (rápido por defecto). Si la red > /24, clampa a /24.
- `lan-scan --fast` → muy rápido (fping/ARP), sin DNS.
- `lan-scan --deep` → exhaustivo (nmap -sn), con DNS.
- `lan-scan --wide` → no clampa: usa el CIDR completo de la interfaz.

## Flags útiles
`-i/--iface IFACE` · `-n/--net CIDR` · `--csv` · `--no-dns` · `--no-vendor` · `--refresh`
`--timeout 1s` (nmap) · `--fping-timeout 80` (ms) · `--debug` (muestra NET/NET_SCAN/engine)

## Requisitos recomendados
fping (rapidez), nmap (deep), ieee-data (fabricantes/OUI).
Instalación: `sudo apt install -y fping nmap ieee-data`
