# 🐧 Scripts Bash - Linux Mastery

Colección de +20 scripts de administración, automatización y monitoreo de sistemas Linux creados durante las primeras dos semanas del roadmap DevOps.

## 📋 Índice de Scripts

### 🔄 Backup & Restauración
- **`backup.sh`** - Sistema de backup automatizado de directorios críticos
- **`gitbackup.sh`** - Backup automático de repositorios Git
- **`sqlbackup.sh`** - Backup de bases de datos SQL con compresión
- **`sqlimport.sh`** - Importación y restauración de backups SQL

### 🗂️ Gestión de Archivos
- **`cleantemp.sh`** - Limpieza automática de archivos temporales
- **`pngcompressor.sh`** - Compresión batch de imágenes PNG
- **`rmduplicatelines.sh`** - Eliminación de líneas duplicadas en archivos
- **`videotoaudio.sh`** - Conversión de video a audio
- **`videocomp4.sh`** - Compresión de videos a MP4

### 🔐 Seguridad & Contraseñas
- **`cpuram.sh`** - Limpieza segura de RAM
- **`loginverification.sh`** - Verificación y auditoría de logins
- **`passgenerator.sh`** - Generador de contraseñas seguras
- **`openportsscan.sh`** - Ver los puertos abiertos

### 📝 Utilidades Diversas
- **`cmatrix_screensaver.sh`** - Salvapantallas Matrix-style
- **`diario.sh`** - Diario personal en terminal
- **`hello.sh`** - Script de bienvenida personalizado
- **`multichmod.sh`** - Cambio de permisos en múltiples archivos
- **`update.sh`** - Script de actualización del sistema
- **`creaproject.sh`** - Creación automatizada de proyectos con estructura
- **`eldengamememory.sh`** - Script de gestión de memoria para aplicaciones
- **`tablospace.sh`** - Monitoreo de espacio en tablespaces
- **`timecalc.sh`** - Calculadora de tiempo y conversiones
- **`creaproject.sh`** - Creación automatizada de proyectos con estructura
- **`eldengamememory.sh`** - Script de gestión de memoria para aplicaciones

### 📂 Directorio
- **`sysadmin/`** - Scripts adicionales de administración del sistema

## 🚀 Uso General

### Dar permisos de ejecución:
```bash
chmod +x nombre_script.sh
```

### Ejecutar:
```bash
./nombre_script.sh
```

### Para scripts que requieren privilegios:
```bash
sudo ./nombre_script.sh
```

## 📝 Ejemplos de Uso

### Backup automático
```bash
# Backup completo del sistema
./backup.sh

# Backup de repositorios Git
./gitbackup.sh /ruta/a/repos

# Backup de base de datos
./sqlbackup.sh nombre_db
```

### Monitoreo
```bash
# Ver información del sistema
./sysinfo.sh

# Escanear puertos abiertos
./openportscan.sh

# Calcular tiempos
./timecalc.sh
```

### Gestión de archivos
```bash
# Limpiar temporales
./cleantemp.sh

# Comprimir PNGs
./pngcompressor.sh /ruta/imagenes/

# Convertir video a audio
./videotoaudio.sh video.mp4
```

### Seguridad
```bash
# Generar contraseña segura
./passgenerator.sh 16  # 16 caracteres

# Limpiar RAM
sudo ./cpuram.sh
```

## 🛠️ Características Técnicas

- **Error handling**: Manejo de errores con validaciones
- **Logging**: Registro de operaciones en logs
- **User-friendly**: Mensajes claros y coloreados
- **Modular**: Código reutilizable y bien estructurado
- **Documentación**: Comentarios internos en cada script

## 📚 Conceptos Aprendidos

Durante la creación de estos scripts se practicó:

- Variables y arrays en Bash
- Control de flujo (if/else, case, loops)
- Funciones y modularización
- Manejo de argumentos y parámetros
- Expresiones regulares (regex)
- Redirección de entrada/salida
- Pipes y command chaining
- Error handling y exit codes
- Permisos y gestión de usuarios
- Procesos y servicios (systemd)
- Parsing de logs
- Automatización con cron

## 🎯 Hitos Alcanzados

- ✅ +20 scripts funcionales
- ✅ Código modular y reutilizable
- ✅ Error handling implementado
- ✅ Documentación inline
- ✅ Testing en diferentes distros (Ubuntu, Rocky, Debian, Fedora, CachyOS)

## 📖 Recursos Utilizados

- "The Linux Command Line" - William Shotts
- Bash Scripting Tutorial - Ryan's Tutorials
- Man pages de comandos críticos
- ShellCheck para validación de sintaxis

## 📄 Licencia

Scripts creados con propósitos educativos durante el roadmap DevOps <2025.

---

**Autor**: [Unk.ele]  
**Roadmap**: CI-CD-brain  
**Semanas**: 1-2 (Linux Mastery + Bash Scripting)  
**Fecha**: Diciembre 2024  
