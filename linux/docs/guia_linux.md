# 🐧 Guía Completa de Comandos Esenciales de Linux

## 1. Introducción a la terminal

La terminal permite administrar y controlar un sistema Linux con
potencia y precisión. El shell más común es **bash**, que interpreta tus
comandos.

------------------------------------------------------------------------

## 2. Navegación por el sistema de archivos

### Comandos básicos

``` bash
pwd
ls
ls -l
ls -a
cd carpeta
cd ..
cd
cd -
```

### Rutas absolutas vs relativas

-   **Absoluta:** `/usr/bin`
-   **Relativa:** `../Documentos`

------------------------------------------------------------------------

## 3. Manipulación de archivos y directorios

### Crear

``` bash
mkdir carpeta
mkdir -p ruta/larga/ejemplo
```

### Copiar

``` bash
cp archivo destino
cp archivo1 archivo2 carpeta/
cp -r carpeta destino
cp -u origen destino
```

### Mover o renombrar

``` bash
mv archivo nuevo_nombre
mv archivo carpeta/
mv carpeta destino/
```

### Borrar

``` bash
rm archivo
rm -i archivo
rm -r carpeta
rm -rf carpeta
```

------------------------------------------------------------------------

## 4. Visualización y análisis de archivos

### Ver contenido

``` bash
less archivo
```

### Identificar tipo

``` bash
file archivo
```

------------------------------------------------------------------------

## 5. Comodines (globs)

  Patrón     Significado
  ---------- ----------------------------------
  `*`        Cualquier cantidad de caracteres
  `?`        Un solo carácter
  `[abc]`    a, b o c
  `[a-z]`    Letras minúsculas
  `[!0-9]`   Lo que NO sea número

Ejemplos:

``` bash
ls *.txt
cp imagen??.png destino/
rm BACKUP.[0-9][0-9][0-9]
```

------------------------------------------------------------------------

## 6. Enlaces en Linux

### Enlace duro

``` bash
ln archivo enlace
```

### Enlace simbólico

``` bash
ln -s archivo enlace
```

------------------------------------------------------------------------

## 7. Permisos en Linux

Formato típico:

    -rwxr-xr--

Cambiar permisos:

``` bash
chmod 755 archivo
chmod u+x script.sh
chmod g-w archivo
chmod o-r carpeta
```

Cambiar propietario o grupo:

``` bash
sudo chown usuario archivo
sudo chgrp grupo archivo
```

------------------------------------------------------------------------

## 8. Procesos y monitorización

``` bash
ps
ps aux
top
htop
```

Matar procesos:

``` bash
kill PID
kill -9 PID
```

------------------------------------------------------------------------

## 9. Información del sistema

``` bash
df -h
du -h carpeta/
free -h
uname -a
hostname
```

------------------------------------------------------------------------

## 10. Gestión de paquetes

### Debian/Ubuntu

``` bash
sudo apt update
sudo apt upgrade
sudo apt install paquete
sudo apt remove paquete
```

### Fedora

``` bash
sudo dnf install paquete
sudo dnf remove paquete
sudo dnf update
```

### Arch Linux

``` bash
sudo pacman -S paquete
sudo pacman -R paquete
sudo pacman -Syu
```

------------------------------------------------------------------------

## 11. Red y conectividad

``` bash
ip a
ip r
ping google.com
wget archivo.zip
curl https://example.com
```

------------------------------------------------------------------------

## 12. Editores de texto

### nano

``` bash
nano archivo
```

### vim

``` bash
vim archivo
```

------------------------------------------------------------------------

## 13. Compresión y empaquetado

``` bash
zip archivo.zip archivo.txt
unzip archivo.zip

tar -cvf archivo.tar carpeta/
tar -xvf archivo.tar
tar -czvf archivo.tar.gz carpeta/
tar -xzvf archivo.tar.gz
```

------------------------------------------------------------------------

## 14. Variables de entorno

``` bash
echo $HOME
echo $PATH
export NOMBRE=valor
```

------------------------------------------------------------------------

## 15. Scripts en bash

Crear script:

``` bash
nano script.sh
```

Contenido:

``` bash
#!/bin/bash
echo "Hola mundo"
```

Hacer ejecutable:

``` bash
chmod +x script.sh
./script.sh
```

------------------------------------------------------------------------

## 16. Estructura de directorios de Linux

  Directorio   Contenido
  ------------ ------------------
  `/`          Raíz
  `/home`      Usuarios
  `/etc`       Configuración
  `/var`       Datos cambiantes
  `/usr/bin`   Ejecutables
  `/opt`       Software externo
  `/tmp`       Temporales
  `/root`      Home de root

------------------------------------------------------------------------

## 17. Atajos útiles

  Atajo      Acción
  ---------- ------------------
  ↑          Historial
  Ctrl + C   Cancelar comando
  Ctrl + D   Cerrar sesión
  Ctrl + Z   Pausar
  Ctrl + L   Limpiar pantalla
  Tab        Autocompletar

------------------------------------------------------------------------

## 18. Consejos prácticos

✔ Verifica con `ls` antes de usar `rm`\
✔ Usa autocompletado\
✔ Usa `man comando` para ayuda\
✔ Trabaja con rutas absolutas cuando haya riesgo

------------------------------------------------------------------------

## 19. Cheatsheet rápido

    pwd ls cd cp mv rm mkdir rmdir  
    file less cat echo touch ln chmod chown  
    ps top kill df du free  
    ip ping wget curl tar unzip zip  
    nano vim bash
