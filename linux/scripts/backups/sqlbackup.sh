#!/bin/bash
USER="root"
PASSWORD="tu_password"
DB="nombre_db"
mysqldump -u$USER -p$PASSWORD $DB > backup_${DB}_$(date +%Y%m%d).sql
