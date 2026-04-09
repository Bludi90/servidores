# backup1 — state snapshot

- Host: `backup1`
- Fecha: `2026-04-09 17:12:58 CEST`
- Arrancado desde: `2026-04-09 17:11:36`
- Uptime: `up 1 minute`

## Red (IPv4 global)

```text
eno1             UP             192.168.1.122/24 
```

## Rutas

```text
default via 192.168.1.1 dev eno1 proto dhcp src 192.168.1.122 metric 1002 
192.168.1.0/24 dev eno1 proto dhcp scope link src 192.168.1.122 metric 1002 
```

## Servicios clave

```text
=== ssh ===
enabled
active

=== wg-quick@wg0 ===
disabled
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
backup  7.27T  2.99T  4.28T        -         -     0%    41%  1.00x    ONLINE  -
```

## Health ZFS

```text
all pools are healthy
```

## Estado detallado ZFS

```text
  pool: backup
 state: ONLINE
  scan: resilvered 396K in 00:00:00 with 0 errors on Wed Apr  8 14:28:14 2026
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
NAME                                          USED  AVAIL  REFER  MOUNTPOINT
backup                                       2.99T  4.15T    96K  /backup
backup/replicas                              2.99T  4.15T    96K  /backup/replicas
backup/replicas/main1                        2.99T  4.15T    96K  /backup/replicas/main1
backup/replicas/main1/tank                   2.99T  4.15T  1.04T  /backup/replicas/main1/tank
backup/replicas/main1/tank/appdata           24.7G  4.15T   104K  /backup/replicas/main1/tank/appdata
backup/replicas/main1/tank/appdata/casaos     304K  4.15T   304K  /backup/replicas/main1/tank/appdata/casaos
backup/replicas/main1/tank/appdata/docker    24.7G  4.15T  24.4G  /backup/replicas/main1/tank/appdata/docker
backup/replicas/main1/tank/media             1.88T  4.15T  1.88T  /backup/replicas/main1/tank/media
backup/replicas/main1/tank/nextcloud         45.8G  4.15T   264M  /backup/replicas/main1/tank/nextcloud
backup/replicas/main1/tank/nextcloud/config   644M  4.15T   643M  /backup/replicas/main1/tank/nextcloud/config
backup/replicas/main1/tank/nextcloud/data    44.2G  4.15T  33.6G  /backup/replicas/main1/tank/nextcloud/data
backup/replicas/main1/tank/nextcloud/db       785M  4.15T   642M  /backup/replicas/main1/tank/nextcloud/db
backup/restore-tests                           96K  4.15T    96K  none
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
S.ficheros      Tipo     Tamaño Usados  Disp Uso% Montado en
udev            devtmpfs    16G      0   16G   0% /dev
tmpfs           tmpfs      3,2G   936K  3,2G   1% /run
/dev/sda2       ext4       847G   2,7G  802G   1% /
tmpfs           tmpfs       16G      0   16G   0% /dev/shm
efivarfs        efivarfs   128K    39K   85K  32% /sys/firmware/efi/efivars
tmpfs           tmpfs      5,0M      0  5,0M   0% /run/lock
tmpfs           tmpfs      1,0M      0  1,0M   0% /run/credentials/systemd-journald.service
tmpfs           tmpfs       16G      0   16G   0% /tmp
/dev/sda1       vfat       975M   8,8M  966M   1% /boot/efi
backup          zfs        4,2T   128K  4,2T   1% /backup
backup/replicas zfs        4,2T   128K  4,2T   1% /backup/replicas
tmpfs           tmpfs      1,0M      0  1,0M   0% /run/credentials/getty@tty1.service
tmpfs           tmpfs      3,2G   8,0K  3,2G   1% /run/user/1000
```

