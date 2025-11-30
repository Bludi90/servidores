# import-peli

<!-- RESUMEN -->
Importa una película desde un disco externo a la biblioteca de Jellyfin, creando la carpeta `Título (Año)`, copiando el vídeo y los subtítulos, renombrándolos y ajustando permisos en `/srv/storage/media`.
<!-- /RESUMEN -->

## Descripción

`import-peli` automatiza el proceso de importar películas a la estructura de medios del servidor para que Jellyfin las lea sin problemas.

Pasos que realiza:

1. Crea la carpeta destino `DESTINO_BASE/TÍTULO (AÑO)`.
2. Copia el contenido de la ruta de origen (carpeta o archivo suelto).
3. Busca archivos de vídeo (`.mkv`, `.mp4`, `.avi`, `.mov`, `.m4v`):
   - Si solo hay uno, lo usa directamente.
   - Si hay varios, los lista mostrando su **tamaño** y te permite elegir cuál es el principal.
4. Mueve y renombra el vídeo elegido a `TÍTULO (AÑO).ext` dentro de la carpeta de la película.
5. Busca subtítulos junto al vídeo original (`.srt`, `.ass`, `.ssa`, `.sub`, `.vtt`) y los mueve/renombra a `TÍTULO (AÑO).ext` en la carpeta de la película.
6. Mueve los **vídeos no elegidos** a una carpeta de extras `DESTINO_BASE/peliculas_extras/` para que Jellyfin no los indexe, pero tú los conserves.
7. Limpia directorios vacíos dentro de la carpeta de la película.
8. Ajusta propietario y permisos para integrarse con el resto del sistema:
   - Usuario/grupo: `alejandro:alejandro`
   - Directorios: `770`
   - Ficheros: `660`

Está pensado para importar pelis desde discos externos montados en modo solo lectura (por ejemplo, un HDD NTFS montado en `/mnt/import`).

## Requisitos

- Script instalado en el sistema como `import-peli` (ubicado en `~/servidores/scripts/import-peli.sh` y enlazado desde `/usr/local/bin`).
- Que el usuario que ejecuta el comando tenga **permiso de lectura** sobre la ruta de origen.
  - Recomendado: montar discos NTFS manualmente en `/mnt/import` con `uid=1000,gid=1000` para que `alejandro` pueda leerlos.
- Carpeta de destino existente, por ejemplo:  
  `/srv/storage/media/N_normal/peliculas`.

## Uso

```bash
import-peli -s ORIGEN -d DESTINO_BASE -t "TÍTULO" -y AÑO
```

Parámetros:

- `-s ORIGEN`  
  Ruta de origen en el disco externo. Puede ser una carpeta (con varios archivos dentro) o un archivo de vídeo suelto.

- `-d DESTINO_BASE`  
  Carpeta base de destino donde viven las pelis de Jellyfin  
  (ejemplo: `/srv/storage/media/N_normal/peliculas`).

- `-t "TÍTULO"`  
  Título limpio de la película, sin el año.  
  Se usa para nombrar carpeta y archivo final.

- `-y AÑO`  
  Año de la película (4 dígitos).  
  Se usa para nombrar carpeta y archivo final.

- `-h`  
  Muestra la ayuda y sale.

La carpeta final siempre sigue el esquema:

```text
DESTINO_BASE/TÍTULO (AÑO)/TÍTULO (AÑO).ext
```

## Ejemplos

### 1. Importar *Se7en (1995)* desde una carpeta en el HDD externo

```bash
import-peli   -s "/mnt/import/Vuze downloads/Se7en (1995)"   -d "/srv/storage/media/N_normal/peliculas"   -t "Se7en"   -y 1995
```

### 2. Importar *The Godfather (1972)* desde otra carpeta

```bash
import-peli   -s "/mnt/import/Vuze downloads/The Godfather (1972)"   -d "/srv/storage/media/N_normal/peliculas"   -t "The Godfather"   -y 1972
```

### 3. Importar *Taxi Driver (1976)*

```bash
import-peli   -s "/mnt/import/Vuze downloads/Taxi Driver (1976)"   -d "/srv/storage/media/N_normal/peliculas"   -t "Taxi Driver"   -y 1976
```

Tras la importación, conviene lanzar un escaneo de la biblioteca de películas en Jellyfin para que aparezca la nueva entrada.

## Notas y buenas prácticas

- Siempre que sea posible, monta el disco externo manualmente en `/mnt/import` con:

  ```bash
  sudo mount -t ntfs3 -o ro,uid=1000,gid=1000,umask=0022 /dev/sdX1 /mnt/import
  ```

  Así `alejandro` puede ejecutar `import-peli` sin problemas de permisos.

- Si el origen se monta automáticamente en `/media/devmon/WD4TB/...` y solo root puede leerlo, el comando fallará cuando se ejecute como `alejandro`. En ese caso:
  - o se re-monta en `/mnt/import` con los flags adecuados,
  - o se ejecuta el comando como root, **cuidando** luego los permisos de destino.

- La carpeta `peliculas_extras` se usa para guardar versiones alternativas o extras que no se quieren indexar en Jellyfin, pero que igual interesa conservar.
