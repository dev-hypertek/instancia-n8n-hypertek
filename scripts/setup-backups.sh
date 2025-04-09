#!/bin/bash
# Script para configurar respaldos automáticos
# Fecha: 8 de abril de 2025
# Autor: Hypertek

set -e

echo "===== Iniciando configuración de respaldos automáticos ====="
echo "$(date)"

# Navegar al directorio del proyecto
cd ~/hypertek

# Crear directorios para respaldos si no existen
echo "Configurando directorios para respaldos..."
mkdir -p backups/postgres
mkdir -p backups/n8n
mkdir -p backups/evolution-api
mkdir -p logs

# Crear script de respaldo de PostgreSQL
echo "Creando script de respaldo para PostgreSQL..."
cat > scripts/backup-postgres.sh << 'EOF'
#!/bin/bash

# Variables
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_DIR="/home/ubuntu/hypertek/backups/postgres"
BACKUP_FILE="bd_hypertek-$TIMESTAMP.sql.gz"
CONTAINER_NAME="hypertek-postgres"
DB_NAME="bd_hypertek"
DB_USER="hypertek_admin"
LOG_FILE="/home/ubuntu/hypertek/logs/postgres-backup.log"

# Crear directorio si no existe
mkdir -p $BACKUP_DIR

# Registrar inicio del respaldo
echo "$(date): Iniciando respaldo de PostgreSQL..." >> $LOG_FILE

# Realizar respaldo
docker exec $CONTAINER_NAME pg_dump -U $DB_USER -d $DB_NAME | gzip > $BACKUP_DIR/$BACKUP_FILE

# Verificar éxito
if [ $? -eq 0 ]; then
    echo "$(date): Respaldo exitoso: $BACKUP_FILE (Tamaño: $(du -h $BACKUP_DIR/$BACKUP_FILE | cut -f1))" >> $LOG_FILE
    
    # Limpiar respaldos antiguos (mantener solo últimos 7 días)
    find $BACKUP_DIR -name "bd_hypertek-*.sql.gz" -type f -mtime +7 -delete
    echo "$(date): Respaldos antiguos eliminados" >> $LOG_FILE
else
    echo "$(date): ERROR al crear respaldo" >> $LOG_FILE
fi
EOF

# Crear script de respaldo para n8n
echo "Creando script de respaldo para n8n..."
cat > scripts/backup-n8n.sh << 'EOF'
#!/bin/bash

# Variables
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_DIR="/home/ubuntu/hypertek/backups/n8n"
BACKUP_FILE="n8n-flows-$TIMESTAMP.tar.gz"
SOURCE_DIR="/home/ubuntu/hypertek/docker/n8n-flows"
LOG_FILE="/home/ubuntu/hypertek/logs/n8n-backup.log"

# Crear directorio si no existe
mkdir -p $BACKUP_DIR

# Registrar inicio del respaldo
echo "$(date): Iniciando respaldo de flujos n8n..." >> $LOG_FILE

# Realizar respaldo
tar -czf $BACKUP_DIR/$BACKUP_FILE -C $(dirname $SOURCE_DIR) $(basename $SOURCE_DIR)

# Verificar éxito
if [ $? -eq 0 ]; then
    echo "$(date): Respaldo exitoso: $BACKUP_FILE (Tamaño: $(du -h $BACKUP_DIR/$BACKUP_FILE | cut -f1))" >> $LOG_FILE
    
    # Limpiar respaldos antiguos (mantener solo últimos 7 días)
    find $BACKUP_DIR -name "n8n-flows-*.tar.gz" -type f -mtime +7 -delete
    echo "$(date): Respaldos antiguos eliminados" >> $LOG_FILE
else
    echo "$(date): ERROR al crear respaldo" >> $LOG_FILE
fi
EOF

# Crear script de respaldo para Evolution API
echo "Creando script de respaldo para Evolution API..."
cat > scripts/backup-evolution-api.sh << 'EOF'
#!/bin/bash

# Variables
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_DIR="/home/ubuntu/hypertek/backups/evolution-api"
BACKUP_FILE="evolution-api-instances-$TIMESTAMP.tar.gz"
SOURCE_DIR="/home/ubuntu/hypertek/docker/evolution-api-instances"
LOG_FILE="/home/ubuntu/hypertek/logs/evolution-api-backup.log"

# Crear directorio si no existe
mkdir -p $BACKUP_DIR

# Registrar inicio del respaldo
echo "$(date): Iniciando respaldo de instancias Evolution API..." >> $LOG_FILE

# Realizar respaldo solo si hay archivos para respaldar
if [ "$(ls -A $SOURCE_DIR)" ]; then
    tar -czf $BACKUP_DIR/$BACKUP_FILE -C $(dirname $SOURCE_DIR) $(basename $SOURCE_DIR)

    # Verificar éxito
    if [ $? -eq 0 ]; then
        echo "$(date): Respaldo exitoso: $BACKUP_FILE (Tamaño: $(du -h $BACKUP_DIR/$BACKUP_FILE | cut -f1))" >> $LOG_FILE
        
        # Limpiar respaldos antiguos (mantener solo últimos 7 días)
        find $BACKUP_DIR -name "evolution-api-instances-*.tar.gz" -type f -mtime +7 -delete
        echo "$(date): Respaldos antiguos eliminados" >> $LOG_FILE
    else
        echo "$(date): ERROR al crear respaldo" >> $LOG_FILE
    fi
else
    echo "$(date): No hay instancias de Evolution API para respaldar" >> $LOG_FILE
fi
EOF

# Hacer ejecutables los scripts de respaldo
echo "Configurando permisos de ejecución para scripts de respaldo..."
chmod +x scripts/backup-postgres.sh
chmod +x scripts/backup-n8n.sh
chmod +x scripts/backup-evolution-api.sh

# Programar respaldos automáticos con cron
echo "Configurando cron para respaldos automáticos..."
(crontab -l 2>/dev/null || echo "") | grep -v "backup-postgres.sh\|backup-n8n.sh\|backup-evolution-api.sh" > temp_cron
cat << EOF >> temp_cron
# Respaldo diario de PostgreSQL a las 2 AM
0 2 * * * /home/ubuntu/hypertek/scripts/backup-postgres.sh

# Respaldo diario de n8n a las 3 AM
0 3 * * * /home/ubuntu/hypertek/scripts/backup-n8n.sh

# Respaldo diario de Evolution API a las 4 AM
0 4 * * * /home/ubuntu/hypertek/scripts/backup-evolution-api.sh
EOF
crontab temp_cron
rm temp_cron

echo "Tarea cron configurada:"
crontab -l | grep backup

echo "===== Configuración de respaldos automáticos completada ====="
echo "Los respaldos se ejecutarán diariamente en la madrugada."
echo "- PostgreSQL: 2:00 AM"
echo "- n8n flows: 3:00 AM"
echo "- Evolution API: 4:00 AM"
echo ""
echo "Logs de respaldo se almacenarán en: /home/ubuntu/hypertek/logs/"
echo "Archivos de respaldo se almacenarán en: /home/ubuntu/hypertek/backups/"
