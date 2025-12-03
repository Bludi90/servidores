ls
cd etc/w
cd etc
ls
cd ../..
cd etc
cd wireguard/clients/
ls
cat tv-moli
cat tv-molinar.conf
cat client8.conf
sudo wg-show
sudo wg show
cat client8.conf
cat client1.conf
cat client2.conf
cd ..
ls
cat server.key
cat server.pub
cd keys
ls
cat server_private.key 
sudo wg show wg0 public-key
sudo cat /etc/wireguard/keys/server_public.key
clear
sudo wg-list-peers   # o, si algún día falla, sudo wg show
sudo wg-list-peers   # o, si algún día falla, sudo wg show
ping -c3 10.8.0.4
ip a show dev wg0
sysctl net.ipv4.ip_forward
sudo ufw status verbose
sudo ufw allow in on wg0
sudo ufw status verbose
clear
sudo ufw status verbose
sudo wg show
cd /etc/wireguard/keys
ls
cd ../clients
ls
cat client4.conf
cat client2.conf
sudo wg show
wg-list-peers
cat client3.conf
cat client3.conf
cat client2.conf
cat client3.conf
cd ..
ls
cat wg0.conf
clear
ls
cd clients
ls
client3.conf
cat client3.conf
cat client3.png
clear
sudo apt install qrencode   # si no lo tenés
qrencode -t ansiutf8 < /etc/wireguard/clients/client3.conf
cleart
clear
cd ../../..
ls
cd srv
ls
cd storage/
ls
cd ../../home/alejandro
ls
cd servidores
ls
cd scripts
ls
cd wg-add
cat wg-add
cd ../../..
ls
cd ..
cd
ls
cd ..
ls
cd bin
ls
clear
sudo nano /usr/local/bin/wg
# (o el que uses: /usr/local/bin/wg-add-peer o /home/alejandro/servidores/scripts/wg-add-peer)
cd ..
cd usr
ls
cd bin
ls
cd ../local
ls
cd bin
ls
sudo wg-add
clear
cd ../../..
ls
cd home/alejandro/servidores
ls
cd private/
ls
cd ..
cd root
ls
clear
ls
cd ..
ls
cd hosts
ls
cd main1
ls
ls -alt
ls -l
cd ..
clear
ls
cd ..
ls
cd scripts
ls
cat srv-health
cd ..
clear
ls
cd scripts
ls
cd ..
cd docs/comandos/
ls
cat wireguard.md
cd /usr/local/sbin
ls
sudo nano wg-add
sudo nano wg-add-peer
sudo rm wg-add
sudo nano wg-add-peer
sudo nano wg-add-peer
sudo nano wg-add-peer
sudo nano wg-add-peer
cleR
ar
clear
sudo awk -F= '/^\s*PrivateKey/ {gsub(/[[:space:]]/, "", $2); print $2; exit}' /etc/wireguard/wg0.conf
sudo nano wg-add-peer   # o el nombre real
# → buscás el bloque "# PublicKey del servidor"
# → lo borrás y pegás el bloque nuevo
# Guardar: Ctrl+O, Enter, Ctrl+X
grep -n "server_public.key" /ruta/del/script/wg-add-peer
grep -n "server_public.key" wg-add-peer
sudo WG_IF=wg0 /ruta/del/script/wg-add-peer test-wg
sudo WGIF=wg0 wg-add-peer test-wg
cd /etc/wireguard/clients/test-wg.conf
cat /etc/wireguard/clients/test-wg.conf
sudo wg show wg0 public-key
cd ../../../etc/wireguard/
ls
cd clients
ls
for f in client*.conf; do     qrencode -t PNG -o "${f%.conf}.png" < "$f"; done
qrencode -t PNG -o tv-molinar.png < tv-molinar.conf
ls
ls *.png
sudo wg show
sudo nano client8.conf
sudo nano tv-molinar.conf
sudo nano tv-molinar.conf
sudo nano client8.conf
sudo nano tv-molinar.pub
sudo nano tv-molinar.conf
ls
cd ..
ls
sudo nano wg0.conf
cd clients
ls
sudo nano client5.conf
sudo nano client4.conf
sudo mv tv-molinar.conf client10.conf
ls
sudo mv tv-molinar.key client10.key
sudo mv tv-molinar.png client10.png
sudo mv tv-molinar.pub client10.pub
ls
sudo nano client9.conf
cd ..
sudo nano wg0.conf
clear
cd /home/alejandro
ls
cd wg-export/
ls
sudo cp -r /etc/wireguard/clients/* /home/alejandro/wg-export/
ls
rm *.pub
rm *.key
ls
chown alejandro:alejandro /home/alejandro/wg-export
chmod 700 /home/alejandro/wg-export
ls -ld /home/alejandro/wg-export
# Asegúrate de que la carpeta es de alejandro
chown alejandro:alejandro /home/alejandro
chown -R alejandro:alejandro /home/alejandro/wg-export
# Permisos recomendados (solo tú puedes entrar/leérlos)
chmod 750 /home/alejandro
chmod 700 /home/alejandro/wg-export
chmod 600 /home/alejandro/wg-export/*
sudo -u alejandro ls -l /home/alejandro/wg-export
ls
rm *
ls
cd ..
ls
docker exec -it jellyfin ls -la "/media/N_normal/peliculas"
clear
# 1. Copia de seguridad de wg0.conf actual
sudo cp /etc/wireguard/wg0.conf /etc/wireguard/wg0.conf.bak-$(date +%Y%m%d-%H%M%S)
# 2. Eliminar la línea SaveConfig del fichero
sudo sed -i '/^SaveConfig/d' /etc/wireguard/wg0.conf
# 3. Reiniciar la interfaz para asegurarnos de que todo sigue bien
sudo systemctl restart wg-quick@wg0
# 4. Comprobar estado
sudo systemctl status wg-quick@wg0 --no-pager
wg show
sudo systemctl status wg-quick@wg0 --no-pager
wg show
wg show
clear
cd ~/servidores
nano scripts/import-peli.sh
su alejandro
ls "/media/devmon/WD4TB/Vuze downloads" | grep -i "Taxi"
import-peli -s "/media/devmon/WD4TB/Vuze downloads/Taxi Driver (1976)" -d "/srv/storage/media/N_normal/peliculas" -t "Taxi Driver" -y 1976
import-peli -s "/media/devmon/WD4TB/Vuze downloads/Interstellar (2014)" -d "/srv/storage/media/N_normal/peliculas" -t "Interstellar" -y 2014
import-peli -s "/media/devmon/WD4TB/Vuze downloads/Enemy (2013) [1080p]" -d "/srv/storage/media/N_normal/peliculas" -t "Enemy" -y 2013
ls /media/devmon/WD4TB | head
tree
cd /media/devmon
ls
cd WD4TB/
ls
cd Vuze\ downloads/
ls
cd "/media/devmon/WD4TB/Vuze downloads"
ls | head
mkdir -p "/srv/storage/media/N_normal/peliculas/Se7en (1995)"
rsync -avh --info=progress2   "/media/devmon/WD4TB/Vuze downloads/Se7en (1995)"*   "/srv/storage/media/N_normal/peliculas/Se7en (1995)/"
cd 'Se7en (1995)'/
ls
ls -la "/srv/storage/media/N_normal/peliculas/Se7en (1995)"
ls -la "/srv/storage/media/N_normal/peliculas/Se7en (1995)/Se7en (1995)"
mv "/srv/storage/media/N_normal/peliculas/Se7en (1995)/Se7en (1995)/se7en.1995.remastered.720p.bluray.x264.YIFY.mkv"    "/srv/storage/media/N_normal/peliculas/Se7en (1995)/Se7en (1995).mkv"
rm "/srv/storage/media/N_normal/peliculas/Se7en (1995)/Se7en (1995)/AhaShare.com.txt"
rm "/srv/storage/media/N_normal/peliculas/Se7en (1995)/Se7en (1995)/Torrent downloaded from Demonoid.com - Copy.txt"
rmdir "/srv/storage/media/N_normal/peliculas/Se7en (1995)/Se7en (1995)"
sudo chown -R alejandro:alejandro "/srv/storage/media/N_normal/peliculas/Se7en (1995)"
sudo find "/srv/storage/media/N_normal/peliculas/Se7en (1995)" -type d -exec chmod 770 {} \;
sudo find "/srv/storage/media/N_normal/peliculas/Se7en (1995)" -type f -exec chmod 660 {} \;
ls -la "/srv/storage/media/N_normal/peliculas/Se7en (1995)"
cd /srv/storage/media/N_normal/peliculas/Se7en (1995)
cd /srv/storage/media/N_normal/peliculas/
ls
cd 'Se7en (1995)'/
ls
ls -l
ls -alt
clear
cd /mnt
ls
cd import
ls
cd ../..
ls
cd media/devmon/WD4TB/
ls
cd 'Vuze downloads'/
ls
mkdir -p "/srv/storage/media/N_normal/peliculas/The Godfather (1972)"
rsync -avh --info=progress2   "/media/devmon/WD4TB/Vuze downloads/The Godfather (1972) [1080p]"*   "/srv/storage/media/N_normal/peliculas/The Godfather (1972)/"
cd /srv/storage/media/N_normal/peliculas/The Godfather (1972)/
cd /srv/storage/media/N_normal/peliculas/The Godfather (1972)
/srv/storage/media/N_normal/peliculas/'The Godfather (1972)'
cd /srv/storage/media/N_normal/peliculas/'The Godfather (1972)'
ls
cd 'The Godfather (1972) [1080p]'/
ls
mv mv The.Godfather.1972.1080p.BrRip.x264.BOKUTOX.YIFY.mp4 /srv/storage/media/N_normal/peliculas/'The Godfather (1972)'
root@main1:/srv/storage/media/N_normal/peliculas/The Godfather (1972)/The Godfather (1972) [1080p]#
mv The.Godfather.1972.1080p.BrRip.x264.BOKUTOX.YIFY.mp4 /srv/storage/media/N_normal/peliculas/'The Godfather (1972)'
ls
mv The.Godfather.1972.1080p.BrRip.x264.BOKUTOX.YIFY.srt /srv/storage/media/N_normal/peliculas/'The Godfather (1972)'
ls
rm *
ls
cd ..
ls
rm -r 'The Godfather (1972) [1080p]'/
ls
mv The.Godfather.1972.1080p.BrRip.x264.BOKUTOX.YIFY.mp4 'The God Father (1972)'.mp4
mv The.Godfather.1972.1080p.BrRip.x264.BOKUTOX.YIFY.srt 'The God Father (1972)'.srt
ls
sudo chown -R alejandro:alejandro "/srv/storage/media/N_normal/peliculas/The Godfather (1972)"
sudo find "/srv/storage/media/N_normal/peliculas/The Godfather (1972)" -type d -exec chmod 770 {} \;
sudo find "/srv/storage/media/N_normal/peliculas/The Godfather (1972)" -type f -exec chmod 660 {} \;
clear
cd srvidores
su alejandro
cd ../../..
ls
cd media/
ls
cd devmon/WD4TB/'devmon/WD4TB/Vuze downloads'/
cd 'devmon/WD4TB/Vuze downloads'/
ls
ls | grep Si
cd Sicario Day of the Soldado [Brs][Latino][wWw.EliteTorrent.BiZ]
cd 'Sicario Day of the Soldado [Brs][Latino][wWw.EliteTorrent.BiZ]'
pwd
import-peli -s "/media/devmon/WD4TB/Vuze downloads/Sicario Day of the Soldado [Brs][Latino][wWw.EliteTorrent.BiZ]" -d "/srv/storage/media/N_normal/peliculas/" -t "Sicario" -y 2015
import-peli -s "/media/devmon/WD4TB/Vuze downloads/12 Years A Slave (2013) [1080p]" -d "/srv/storage/media/N_normal/peliculas/" -t "12 Años de Esclavitud" -y 2013
import-peli -s "/media/devmon/WD4TB/Vuze downloads/12 Years a Slave (2013) [1080p]" -d "/srv/storage/media/N_normal/peliculas/" -t "12 Años de Esclavitud" -y 2013
import-peli -s "/media/devmon/WD4TB/Vuze downloads/Blade.Runner (1997)" -d "/srv/storage/media/N_normal/peliculas/" -t "Blade Runner" -y 1997
import-peli -s "/media/devmon/WD4TB/Vuze downloads/Blade Runner 2049 2017 1080p WEBRip 6CH AAC x264 - EiE" -d "/srv/storage/media/N_normal/peliculas/" -t "Blade Runner" -y 1997
import-peli -s "/media/devmon/WD4TB/Vuze downloads/Blade Runner 2049 2017 1080p WEBRip 6CH AAC x264 - EiE" -d "/srv/storage/media/N_normal/peliculas/" -t "Blade Runner 2049" -y 2017
import-peli -s "/media/devmon/WD4TB/Vuze downloads/La Leyenda de la Ciudad sin Nombre (1969) DVD9" -d "/srv/storage/media/N_normal/peliculas/" -t "La Leyenda de la Ciudad sin Nombre" -y 1969
cd /srv/storage/media/N_normal/peliculas/La Leyenda de la Ciudad sin Nombre (1969)
cd '/srv/storage/media/N_normal/peliculas/La Leyenda de la Ciudad sin Nombre (1969)'
ls
cd VIDEO_TS/
ls
ls -l
ls -ls
import-peli -s "/media/devmon/WD4TB/Vuze downloads/Nerve (2016) [YTS.AG]" -d "/srv/storage/media/N_normal/peliculas/" -t "Nerve" -y 2016
ls
cd "/srv/storage/media/N_normal/peliculas/La Leyenda de la Ciudad sin Nombre (1969)/VIDEO_TS"
# 1) Crear una lista con los VOB del título principal (probablemente VTS_01_*.VOB)
ls VTS_01_*.VOB
# 2) Generar un archivo de texto para ffmpeg
> files.txt
for f in VTS_01_*.VOB; do   echo "file '$PWD/$f'" >> files.txt; done
# 3) Unirlos en un solo MKV sin recomprimir
ffmpeg -f concat -safe 0 -i files.txt -c copy   "../La Leyenda de la Ciudad sin Nombre (1969).mkv"
ls
apt update
apt install cockpit -y
systemctl enable --now cockpit.socket
systemctl statuts cockpit.socket
systemctl status cockpit.socket
clear
systemctl status cockpit.socket
ufw allow from 192.168.1.0/24 to any port 9090 proto tcp comment "Cockpit - Panel Web" 
ufw allow from 10.8.0.0/24 to any port 9090 proto tcp comment "Cockpit - Panel Web"
ufw status
clear
sudo -i
cd ../../..
ls
cd media/devmon/WD4TB/Vuze\ downloads/
ls
ls \ grep Maze
ls | grep Maze

ls | grep Shu
import-peli -s "Shutter.Island.720p.2010/" -d "/srv/storage/media/N_normal/peliculas/" -t "Shutter Island" -y 2010
clear
sudo -i
mkdir -p /srv/storage/services/dns/pihole/etc-pihole
mkdir -p /srv/storage/services/dns/pihole/etc-dnsmasq.d
mkdir -p /srv/storage/services/dns/unbound
ls -R /srv/storage/services/dns
cd ~/servidores
mkdir -p docker/dns
cd docker/dns
cd ~/servidores/docker/dns
cd ~/servidores/docker/dns
nano docker-compose.yml
docker compose up -d
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
pihole setpassword
sudo pihole setpassword
nano docker-compose.yml
sudo ufw status
docker exec -it pihole pihole -a -p
pihole setpassword
docker exec -it pihole pihole -a -p
docker exec -it pihole pihole setpassword
sudo -i
apt install -y dnsutils
dig @127.0.0.1 google.com
sudo -i
ufw delete allow from 10.8.0.0/24 to any port 10080 proto tcp
ufw delete allow from 192.168.1.0/24 to any port 10080 proto tcp
ufw delete allow from 192.168.1.0/24 to any port 10081 proto tcp
ufw delete allow from 10.8.0.0/24 to any port 6789 proto tcp
ufw status
sudo -i
sudo ufw status
ufw allow from 192.168.1.0/24 to any port 8081 proto tcp comment "Pi-hole Web LAN"
ufw allow from 10.8.0.0/24   to any port 8081 proto tcp comment "Pi-hole Web VPN (wg)"
sudo ufw status
ufw delete allow in on wg0
ufw delete allow in on wg0 proto ipv6
ufw status
cd ../..
ls
cd media/devmon/WD4TB/Vuze\ downloads/
 import-peli -s "Sicario Day of the Soldado [Brs][Latino][wWw.EliteTorrent.BiZ]" -d "/srv/storage/media/N_normal/peliculas/" t- "Sicario: Day of the Soldado" -y 2018
 import-peli -s "/Sicario Day of the Soldado [Brs][Latino][wWw.EliteTorrent.BiZ]" -d "/srv/storage/media/N_normal/peliculas/" t- "Sicario: Day of the Soldado" -y 2018
 import-peli -s "/media/devmon/WD4TB/Vuze Downloads/Sicario Day of the Soldado [Brs][Latino][wWw.EliteTorrent.BiZ]" -d "/srv/storage/media/N_normal/peliculas/" t- "Sicario: Day of the Soldado" -y 2018
srv-health
clear
import-peli   -s "/media/devmon/WD4TB/Vuze Downloads/Sicario Day of the Soldado [Brs][Latino][wWw.EliteTorrent.BiZ]"   -d "/srv/storage/media/N_normal/peliculas"   -t "Sicario: Day of the Soldado"   -y 2018
sudo ufw status
root@main1:/media/devmon/WD4TB/Vuze downloads#
import-peli   -s "/media/devmon/WD4TB/Vuze downloads/Sicario Day of the Soldado [Brs][Latino][wWw.EliteTorrent.BiZ]"   -d "/srv/storage/media/N_normal/peliculas"   -t "Sicario: Day of the Soldado"   -y 2018
import-peli   -s "/media/devmon/WD4TB/Vuze downloads/Harry Potter 1 (Y la piedra filosofal) (HDRip) (Elitetorrent.net).avi"   -d "/srv/storage/media/N_normal/peliculas"   -t "Harry Potter y la Piedra Filosofal" -y 2001 
import-peli   -s "/media/devmon/WD4TB/Vuze downloads/Harry Potter 2 (Y la camara secreta) (HDRip) (Elitetorrent.net).avi"   -d "/srv/storage/media/N_normal/peliculas"   -t "Harry Potter y la Cámara Secreta" -y 2002 
mkdir -p /srv/storage/services/reverse-proxy/caddy/{config,data}
chown -R 1000:1000 /srv/storage/services/reverse-proxy
nano /srv/storage/services/reverse-proxy/caddy/config/Caddyfile
mkdir -p /home/alejandro/servidores/docker/caddy
cd /home/alejandro/servidores/docker/caddy
nano docker-compose.yml
cd /home/alejandro/servidores/docker/caddy
nano docker-compose.yml
cd /home/alejandro/servidores/docker/caddy
docker compose up -d
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | grep caddy || echo "caddy no aparece"
sudo -i
ufw allow from 192.168.1.0/24 to any port 443 proto tcp comment "Caddy HTTPS LAN"
ufw status
cd ../../media/devmon/WD4TB/Vuze\ downloads/
ls
cd ../../media/devmon/WD4TB/Vuze\ downloads/
ls
import-peli   -s /media/devmon/WD4TB/Vuze\ downloads/Star\ Trek\ Beyond\ 2016\ 1080p\ WEB-DL\ x264\ AC3-JYK/" \
  -d "/srv/storage/media/N_normal/peliculas" \
  -t "Star Trek: Beyond" \
  -y 2016

import-peli -s /media/devmon/WD4TB/Vuze\ downloads/Star\ Trek\ Beyond\ 2016\ 1080p\ WEB-DL\ x264\ AC3-JYK/" -d "/srv/storage/media/N_normal/peliculas" -t "Star Trek: Beyond" -y 2016
import-peli -s "/media/devmon/WD4TB/Vuze\ downloads/Star\ Trek\ Beyond\ 2016\ 1080p\ WEB-DL\ x264\ AC3-JYK/" -d "/srv/storage/media/N_normal/peliculas" -t "Star Trek: Beyond" -y 2016
import-peli -s "/media/devmon/WD4TB/Vuze downloads/Star Trek Beyond 2016 1080p WEB-DL x264 AC3-JYK" -d "/srv/storage/media/N_normal/peliculas" -t "Star Trek: Beyond" -y 2016
import-peli -s "/media/devmon/WD4TB/Vuze downloads/Harry Potter 3 (Y el prisionero de Azkaban) (HDRip) (Elitetorrent.net).avi" -d "/srv/storage/media/N_normal/peliculas" -t "Harry Potter y el Prisionero de Azkaban" -y 2004
import-peli -s "/media/devmon/WD4TB/Vuze downloads/Harry Potter 4 (Y el caliz de fuego) (HDRip) (Elitetorrent.net).avi" -d "/srv/storage/media/N_normal/peliculas" -t "Harry Potter y el cáliz de fuego" -y 2005
import-peli -s "/media/devmon/WD4TB/Vuze downloads/Harry Potter 5 (Y la orden del Fenix) (HDRip) (Elitetorrent.net).avi" -d "/srv/storage/media/N_normal/peliculas" -t "Harry Potter y la Orden del Fénix" -y 2007
import-peli -s "/media/devmon/WD4TB/Vuze downloads/Harry Potter 6 (Y el misterio del Principe) (HDRip) (Elitetorrent.net).avi" -d "/srv/storage/media/N_normal/peliculas" -t "Harry Potter y el misterio del príncipe" -y 2009
import-peli -s "/media/devmon/WD4TB/Vuze downloads/Harry Potter 7 (Y las reliquias de la Muerte Parte I) (HDRip) (Elitetorrent.net).avi" -d "/srv/storage/media/N_normal/peliculas" -t "Harry Potter y las Reliquias de la Muerte: Parte 1" -y 2010
import-peli -s "/media/devmon/WD4TB/Vuze downloads/Harry Potter 8 (Y las reliquias de la Muerte Parte II) (HDRip) (Elitetorrent.net).avi" -d "/srv/storage/media/N_normal/peliculas" -t "Harry Potter y las Reliquias de la Muerte: Parte 2" -y 2011
import-peli -s "/media/devmon/WD4TB/Vuze downloads/Jason Bourne (2016) [1080p] [YTS.AG]"/ -d "/srv/storage/media/N_normal/peliculas" -t "Jason Bourne" -y 2016
cd /srv/storage/media/N_normal/peliculas/
ls
cd Blade\ Runner\ 
ls
cd 'Blade Runner 
cd 'Blade Runner (1997)'
ls
rm 'Blade Runner (1997).srt'
ls
cd ..
clear
cd ~/servidores/docker/caddy
nano docker-compose.yml
cd ~/servidores/docker/caddy
cd ../..
ls
pwd
cd ~/servidores/docker/caddy
su alejandro
ufw status numbered
ufw allow in on wg0 to any port 9980 proto tcp comment 'Collabora VPN (wg)'
ufw reload
sudo apt install -y dnsutils  # si no lo tenés
dig @10.8.0.1 nextcloud.srv
dig @10.8.0.1 jellyfin.srv
dig @10.8.0.1 firefly.srv
dig @10.8.0.1 firefly.import
nano /srv/storage/services/reverse-proxy/caddy/config/Caddyfile
docker exec caddy caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile
clear
srv-health short
lan-scan
lan-scan
nano /srv/storage/services/reverse-proxy/caddy/config/Caddyfile
docker exec caddy caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile
docker exec caddy caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile
sudo ufw status
clear
docker restart jellyfin 
ls
cd ../../media/devmon/WD4TB/Vuze\ downloads/
cd Blade
ls
