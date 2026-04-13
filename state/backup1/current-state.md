# backup1 — state snapshot

- Host: `backup1`
- Fecha: `2026-04-13 03:39:01 CEST`
- Arrancado desde: `2026-04-13 03:30:58`
- Uptime: `up 8 minutes`

## Red (IPv4 global)

```text
eno1             UP             192.168.1.122/24 
docker0          DOWN           172.17.0.1/16 
br-7bd6ce37ca3d  UP             172.21.0.1/16 
br-fa1bfe95f7ad  UP             172.18.0.1/16 
br-1dc76445de0d  UP             172.20.0.1/16 
br-443ffb922fc9  UP             172.19.0.1/16 
br-5fc9606e742a  UP             172.22.0.1/16 
```

## Rutas

```text
default via 192.168.1.1 dev eno1 proto dhcp src 192.168.1.122 metric 1002 
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 linkdown 
172.18.0.0/16 dev br-fa1bfe95f7ad proto kernel scope link src 172.18.0.1 
172.19.0.0/16 dev br-443ffb922fc9 proto kernel scope link src 172.19.0.1 
172.20.0.0/16 dev br-1dc76445de0d proto kernel scope link src 172.20.0.1 
172.21.0.0/16 dev br-7bd6ce37ca3d proto kernel scope link src 172.21.0.1 
172.22.0.0/16 dev br-5fc9606e742a proto kernel scope link src 172.22.0.1 
192.168.1.0/24 dev eno1 proto dhcp scope link src 192.168.1.122 metric 1002 
```

## Servicios clave

```text
=== ssh ===
enabled
active

=== wg-quick@wg0 ===
masked
inactive

=== wg-quick@wgr0 ===
masked
inactive

```

## Unidades fallidas

```text
UNIT LOAD ACTIVE SUB DESCRIPTION

0 loaded units listed.
```

## Pooles ZFS

```text
NAME     SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
backup  7.27T  3.09T  4.17T        -         -     0%    42%  1.00x    ONLINE  -
```

## Health ZFS

```text
all pools are healthy
```

## Estado detallado ZFS

```text
  pool: backup
 state: ONLINE
  scan: scrub repaired 0B in 05:12:28 with 0 errors on Sun Apr 12 05:36:29 2026
config:

	NAME                                   STATE     READ WRITE CKSUM
	backup                                 ONLINE       0     0     0
	  mirror-0                             ONLINE       0     0     0
	    ata-WDC_WD80EDAZ-11TA3A0_VGK20KVG  ONLINE       0     0     0
	    ata-WDC_WD80EDAZ-11TA3A0_VGKGHEJG  ONLINE       0     0     0

errors: No known data errors
```

## Datasets ZFS

```text
NAME                                                             USED  AVAIL  REFER  MOUNTPOINT
backup                                                          3.09T  4.05T    96K  /backup
backup/dr-lab                                                    328M  4.05T    96K  none
backup/dr-lab/jellyfin-media-replica-20260410-033003               0B  4.05T  1.90T  /mnt/dr-lab-jellyfin-media-replica-20260410-033003
backup/dr-lab/jellyfin-root-replica-20260410-033003             7.97M  4.05T  1.07T  /mnt/dr-lab-jellyfin-root-replica-20260410-033003
backup/dr-lab/nextcloud-config-replica-20260410-033003           480K  4.05T   643M  /mnt/dr-lab-nextcloud-config-replica-20260410-033003
backup/dr-lab/nextcloud-data-replica-20260410-033003            2.04M  4.05T  33.6G  /mnt/dr-lab-nextcloud-data-replica-20260410-033003
backup/dr-lab/nextcloud-db-replica-20260410-033003              18.9M  4.05T   649M  /mnt/dr-lab-nextcloud-db-replica-20260410-033003
backup/dr-lab/nextcloud-media-replica-20260410-033003           85.0M  4.05T  1.90T  /mnt/dr-lab-nextcloud-media-replica-20260410-033003
backup/dr-lab/nextcloud-root-replica-20260410-033003             213M  4.05T  1.07T  /mnt/dr-lab-nextcloud-root-replica-20260410-033003
backup/replicas                                                 3.09T  4.05T    96K  /backup/replicas
backup/replicas/main1                                           3.09T  4.05T    96K  /backup/replicas/main1
backup/replicas/main1/tank                                      3.09T  4.05T  1.10T  /backup/replicas/main1/tank
backup/replicas/main1/tank/appdata                              24.8G  4.05T   104K  /backup/replicas/main1/tank/appdata
backup/replicas/main1/tank/appdata/casaos                        304K  4.05T   304K  /backup/replicas/main1/tank/appdata/casaos
backup/replicas/main1/tank/appdata/docker                       24.7G  4.05T  24.4G  /backup/replicas/main1/tank/appdata/docker
backup/replicas/main1/tank/media                                1.91T  4.05T  1.91T  /backup/replicas/main1/tank/media
backup/replicas/main1/tank/nextcloud                            46.2G  4.05T   264M  /backup/replicas/main1/tank/nextcloud
backup/replicas/main1/tank/nextcloud/config                      645M  4.05T   643M  /backup/replicas/main1/tank/nextcloud/config
backup/replicas/main1/tank/nextcloud/data                       44.4G  4.05T  33.9G  /backup/replicas/main1/tank/nextcloud/data
backup/replicas/main1/tank/nextcloud/db                          859M  4.05T   671M  /backup/replicas/main1/tank/nextcloud/db
backup/restore-tests                                              96K  4.05T    96K  none
backup/takeover                                                  223M  4.05T    96K  none
backup/takeover/main1                                            223M  4.05T    96K  none
backup/takeover/main1/replica-20260410-033003                    223M  4.05T    96K  none
backup/takeover/main1/replica-20260410-033003/media              184K  4.05T  1.90T  /mnt/takeover/main1/replica-20260410-033003/media
backup/takeover/main1/replica-20260410-033003/nextcloud-config   396K  4.05T   643M  /mnt/takeover/main1/replica-20260410-033003/nextcloud-config
backup/takeover/main1/replica-20260410-033003/nextcloud-data    2.01M  4.05T  33.6G  /mnt/takeover/main1/replica-20260410-033003/nextcloud-data
backup/takeover/main1/replica-20260410-033003/nextcloud-db      7.52M  4.05T   646M  /mnt/takeover/main1/replica-20260410-033003/nextcloud-db
backup/takeover/main1/replica-20260410-033003/root               212M  4.05T  1.07T  /mnt/takeover/main1/replica-20260410-033003/root
```

## Bloques / discos

```text
NAME     SIZE TYPE FSTYPE     MOUNTPOINT MODEL                 SERIAL
sda    894,3G disk                       KINGSTON SA400S37960G 50026B7381CED9EC
├─sda1   976M part vfat       /boot/efi                        
├─sda2 861,4G part ext4       /                                
└─sda3  31,9G part swap       [SWAP]                           
sdb      7,3T disk                       WDC WD80EDAZ-11TA3A0  VGK20KVG
├─sdb1   7,3T part zfs_member                                  
└─sdb9     8M part                                             
sdc      7,3T disk                       WDC WD80EDAZ-11TA3A0  VGKGHEJG
├─sdc1   7,3T part zfs_member                                  
└─sdc9     8M part                                             
sdd      3,6T disk                       WDC WD40PURX-64GVNY0  WD-WCC4E5YRCCP5
```

## Filesystem

```text
S.ficheros                                                     Tipo     Tamaño Usados  Disp Uso% Montado en
udev                                                           devtmpfs    16G      0   16G   0% /dev
tmpfs                                                          tmpfs      3,2G   1,9M  3,2G   1% /run
/dev/sda2                                                      ext4       847G    12G  793G   2% /
tmpfs                                                          tmpfs       16G      0   16G   0% /dev/shm
efivarfs                                                       efivarfs   128K    39K   85K  32% /sys/firmware/efi/efivars
tmpfs                                                          tmpfs      5,0M      0  5,0M   0% /run/lock
tmpfs                                                          tmpfs      1,0M      0  1,0M   0% /run/credentials/systemd-journald.service
tmpfs                                                          tmpfs       16G      0   16G   0% /tmp
/dev/sda1                                                      vfat       975M   8,8M  966M   1% /boot/efi
backup/dr-lab/nextcloud-db-replica-20260410-033003             zfs        4,1T   649M  4,1T   1% /mnt/dr-lab-nextcloud-db-replica-20260410-033003
backup/takeover/main1/replica-20260410-033003/nextcloud-db     zfs        4,1T   646M  4,1T   1% /mnt/takeover/main1/replica-20260410-033003/nextcloud-db
backup/dr-lab/nextcloud-media-replica-20260410-033003          zfs        6,0T   1,9T  4,1T  32% /mnt/dr-lab-nextcloud-media-replica-20260410-033003
backup/dr-lab/nextcloud-root-replica-20260410-033003           zfs        5,2T   1,1T  4,1T  21% /mnt/dr-lab-nextcloud-root-replica-20260410-033003
backup/takeover/main1/replica-20260410-033003/root             zfs        5,2T   1,1T  4,1T  21% /mnt/takeover/main1/replica-20260410-033003/root
backup/takeover/main1/replica-20260410-033003/media            zfs        6,0T   1,9T  4,1T  32% /mnt/takeover/main1/replica-20260410-033003/media
backup                                                         zfs        4,1T   128K  4,1T   1% /backup
backup/replicas                                                zfs        4,1T   128K  4,1T   1% /backup/replicas
backup/dr-lab/nextcloud-config-replica-20260410-033003         zfs        4,1T   643M  4,1T   1% /mnt/dr-lab-nextcloud-config-replica-20260410-033003
backup/takeover/main1/replica-20260410-033003/nextcloud-config zfs        4,1T   643M  4,1T   1% /mnt/takeover/main1/replica-20260410-033003/nextcloud-config
backup/dr-lab/nextcloud-data-replica-20260410-033003           zfs        4,1T    34G  4,1T   1% /mnt/dr-lab-nextcloud-data-replica-20260410-033003
backup/takeover/main1/replica-20260410-033003/nextcloud-data   zfs        4,1T    34G  4,1T   1% /mnt/takeover/main1/replica-20260410-033003/nextcloud-data
tmpfs                                                          tmpfs      1,0M      0  1,0M   0% /run/credentials/getty@tty1.service
tmpfs                                                          tmpfs      3,2G   8,0K  3,2G   1% /run/user/1000
```

