# DNS interno: Pi-hole + Unbound + Caddy

## 1. Resumen de arquitectura

- **Clientes WireGuard**

Red VPN: 10.8.0.0/24

DNS en los .conf:
DNS = 10.8.0.1, 1.1.1.1

- **Pi-hole**

Contenedor: pihole-pihole-1

IP vista desde los clientes: 10.8.0.1:53

Datos en el host: /srv/storage/services/dns/pihole

Upstream configurado mediante variable de entorno:
FTLCONF_dns_upstreams=172.18.0.2#53

- **Unbound**

Contenedor: unbound-unbound-1

Red Docker: dns_dns-net

IP actual (consultar con):
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' unbound-unbound-1

Datos en el host: /srv/storage/services/dns/unbound

- **Caddy (reverse proxy)**

Escucha en los puertos 80 y 443 del host.

Usa dominios internos (casaos.srv, nextcloud.srv, jellyfin.srv, etc.) que Pi-hole resuelve a 10.8.0.1.

## 2. Comandos rápidos de verificación
### 2.1. Estado de los contenedores

- Comando:
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | egrep -i 'pihole|unbound'
```

- Esperado:

pihole-pihole-1 en estado “Up … (healthy)”.

unbound-unbound-1 en estado “Up … (healthy)”.

### 2.2. DNS vía Pi-hole (10.8.0.1)

- Comandos:
```bash
nslookup google.es 10.8.0.1
nslookup casaos.srv 10.8.0.1
```
Esperado:

google.es devuelve IPs públicas.

casaos.srv devuelve 10.8.0.1.

### 2.3. DNS directo contra Unbound

- Comandos:
```bash
UNBOUND_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' unbound-unbound-1)
nslookup google.es "$UNBOUND_IP"
```

- Esperado: IPs de google.es.
Si esto falla, el problema está en Unbound (no en Pi-hole).

## 3. Receta de recuperación rápida
### 3.1. Pi-hole unhealthy o 10.8.0.1 sin responder

Ver estado de contenedores:
```bash
docker ps --format "table {{.Names}}\t{{.Status}}" | egrep -i 'pihole|unbound'
```

- **Si Pi-hole no está healthy:**

Ver logs rápidos:
```bash
docker logs --tail 40 pihole-pihole-1
```

Levantarlo desde la app de CasaOS o desde la carpeta de la app:
```bash
cd /var/lib/casaos/apps/pihole
sudo docker compose up -d pihole
```

Probar de nuevo:
```bash
nslookup google.es 10.8.0.1
```

### 3.2. Unbound roto, Pi-hole OK (volver temporalmente a 1.1.1.1)

- **Probar Unbound directo:**
```bash
UNBOUND_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' unbound-unbound-1)
nslookup google.es "$UNBOUND_IP"
```

Si falla, volver temporalmente a 1.1.1.1 editando el compose de CasaOS:
```bash
sudo nano /var/lib/casaos/apps/pihole/docker-compose.yml
```

Cambiar esta línea:
```bash
FTLCONF_dns_upstreams: 172.18.0.2#53
```
por esta otra:
```bash
FTLCONF_dns_upstreams: 1.1.1.1
```

y luego:
```bash
cd /var/lib/casaos/apps/pihole
sudo docker compose up -d pihole
nslookup google.es 10.8.0.1
```

Cuando Unbound vuelva a estar bien, volver a poner la IP correcta en:

/var/lib/casaos/apps/pihole/docker-compose.yml

/home/alejandro/servidores/docker/dns/.env (variable PIHOLE_DNS_UPSTREAMS)

### 3.2. Unbound roto, Pi-hole OK (volver temporalmente a 1.1.1.1)

- **Probar Unbound directo:**
```bash
UNBOUND_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' unbound-unbound-1)
nslookup google.es "$UNBOUND_IP"
```

Si falla, volver temporalmente a 1.1.1.1 editando el compose de CasaOS:
```bash
sudo nano /var/lib/casaos/apps/pihole/docker-compose.yml
```

Cambiar esta línea:
```bash
FTLCONF_dns_upstreams: 172.18.0.2#53
```

por esta otra:
```bash
FTLCONF_dns_upstreams: 1.1.1.1
```

y luego:
```bash
cd /var/lib/casaos/apps/pihole
sudo docker compose up -d pihole
nslookup google.es 10.8.0.1
```

Cuando Unbound vuelva a estar bien, volver a poner la IP correcta en:

/var/lib/casaos/apps/pihole/docker-compose.yml

/home/alejandro/servidores/docker/dns/.env (variable PIHOLE_DNS_UPSTREAMS)
