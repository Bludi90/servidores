# DR WireGuard wg0 (main1 -> backup1)

<!-- RESUMEN -->
Failover de emergencia del WireGuard principal (wg0) desde main1 a backup1. Si main1 cae: entrar por wgr0 (rescue), conmutar el port-forward UDP/51820 al backup1 y ejecutar `dr-wg0-promote --force`. Para volver atrás: devolver el port-forward a main1 y ejecutar `dr-wg0-demote`.
<!-- /RESUMEN -->

## Failover (main1 caído)
1) Conectar a backup1 por `wgr0` (rescue) o por LAN.
2) Router: cambiar port-forward **UDP 51820 → IP LAN de backup1**.
3) En backup1:
   - `sudo dr-wg0-promote --force`
   - `sudo wg show wg0`

## Failback (main1 recuperado)
1) Router: devolver port-forward **UDP 51820 → main1**.
2) En backup1:
   - `sudo dr-wg0-demote`

## Notas
- `dr-wg0-promote` usa: `/srv/replica/main1/etc-wireguard/wg0.conf`
- Staging: `/etc/wireguard/dr-main1/`
- No toca `wgr0` ni `/etc/wireguard/clients-rescue/`.
