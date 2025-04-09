#!/bin/bash
# Script para configurar los servicios principales del sistema
# Fecha: 8 de abril de 2025
# Autor: Hypertek

set -e

echo "===== Iniciando configuración de servicios Hypertek ====="
echo "$(date)"

# Navegar al directorio del proyecto
cd ~/hypertek/docker

# Verificar que PostgreSQL esté funcionando
echo "Verificando que PostgreSQL esté funcionando..."
if ! sudo docker-compose ps | grep -q "hypertek-postgres.*Up"; then
    echo "ERROR: PostgreSQL no está funcionando. Por favor, ejecuta primero setup-postgres.sh."
    exit 1
fi

# Crear directorios necesarios para las instancias de Evolution API si no existen
echo "Configurando directorios para Evolution API..."
mkdir -p evolution-api-instances

# Configurar directorio nginx si no existe
echo "Configurando directorios para Nginx..."
mkdir -p nginx/conf.d
mkdir -p nginx/ssl
mkdir -p nginx/www

# Verificar si tenemos certificados SSL
echo "Verificando configuración SSL..."
if [ ! -f "nginx/ssl/cert.pem" ] || [ ! -f "nginx/ssl/key.pem" ]; then
    echo "Generando certificados SSL autofirmados temporales..."
    mkdir -p nginx/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout nginx/ssl/key.pem \
        -out nginx/ssl/cert.pem \
        -subj "/CN=hypertek.com.co/O=Hypertek/C=CO"
fi

# Personalizar configuración de Nginx para el dominio
echo "Configurando Nginx para el dominio..."
DOMAIN_NAME=$(grep DOMAIN_NAME .env | cut -d '=' -f2 || echo "hypertek.com.co")
if [ -f "nginx/conf.d/default.conf.template" ]; then
    sed "s/\${DOMAIN_NAME}/${DOMAIN_NAME}/g" nginx/conf.d/default.conf.template > nginx/conf.d/default.conf
    echo "Archivo default.conf configurado para dominio: ${DOMAIN_NAME}"
else
    echo "ADVERTENCIA: No se encontró template de configuración Nginx. Verificando si existe el archivo final..."
    if [ ! -f "nginx/conf.d/default.conf" ]; then
        echo "ERROR: No se encontró configuración de Nginx. Verifique los archivos de configuración."
    fi
fi

# Iniciar servicios principales (n8n, Evolution API, Redis, ntfy)
echo "Iniciando servicios principales..."
sudo docker-compose up -d n8n evolution-api redis-evolution ntfy

# Esperar a que los servicios estén disponibles
echo "Esperando a que los servicios estén disponibles..."
sleep 20

# Verificar que los servicios están funcionando
echo "Verificando estado de los servicios..."
sudo docker-compose ps

# Iniciar Nginx
echo "Iniciando Nginx..."
sudo docker-compose up -d nginx

echo "===== Configuración de servicios completada ====="
echo "Los servicios deberían estar accesibles en:"
echo "- n8n: https://${DOMAIN_NAME}/n8n/"
echo "- Evolution API: https://${DOMAIN_NAME}/evolution-api/"
echo "- ntfy: https://${DOMAIN_NAME}/ntfy/"

echo "Siguiente paso: Configurar respaldos automáticos"
echo "Ejecuta: ./setup-backups.sh"
