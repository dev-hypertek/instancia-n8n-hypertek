#!/bin/bash
# Script para configurar PostgreSQL en la instancia EC2
# Fecha: 8 de abril de 2025
# Autor: Hypertek

set -e

echo "===== Iniciando configuración de PostgreSQL ====="
echo "$(date)"

# Navegar al directorio del proyecto
cd ~/hypertek/docker

# Verificar que el archivo .env exista
if [ ! -f ".env" ]; then
    echo "ERROR: Archivo .env no encontrado. Copiando archivo de ejemplo..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "Archivo .env creado desde .env.example. Por favor, edita los valores según sea necesario."
        echo "Ejemplo: nano .env"
        exit 1
    else
        echo "ERROR: No se encontró ni .env ni .env.example. Por favor, crea manualmente el archivo .env."
        exit 1
    fi
fi

# Iniciar solo PostgreSQL para verificar la configuración
echo "Iniciando contenedor de PostgreSQL..."
sudo docker-compose up -d postgres

# Esperar a que PostgreSQL esté listo
echo "Esperando a que PostgreSQL esté disponible..."
sleep 10

# Verificar que PostgreSQL está funcionando correctamente
echo "Verificando estado de PostgreSQL..."
sudo docker-compose ps postgres
sudo docker-compose logs postgres | tail -n 20

# Verificar que los scripts de inicialización se ejecutaron correctamente
echo "Verificando tablas creadas en la base de datos..."
POSTGRES_USER=$(grep POSTGRES_USER .env | cut -d '=' -f2 || echo "hypertek_admin")
POSTGRES_DB=$(grep POSTGRES_DB .env | cut -d '=' -f2 || echo "bd_hypertek")

echo "Listando esquemas en la base de datos ${POSTGRES_DB}..."
sudo docker-compose exec postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "\dn;"

echo "Listando tablas en el esquema citas_medicas..."
sudo docker-compose exec postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "\dt citas_medicas.*;"

# Verificar que la función para generar slots está disponible
echo "Verificando función de generación de slots..."
sudo docker-compose exec postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "\df citas_medicas.generate_available_slots;"

echo "===== Configuración de PostgreSQL completada ====="
echo "Siguiente paso: Configurar servicios principales"
echo "Ejecuta: ./setup-services.sh"
