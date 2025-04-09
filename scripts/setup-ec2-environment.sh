#!/bin/bash
# Script para configurar el entorno Docker en la instancia EC2
# Fecha: 8 de abril de 2025
# Autor: Hypertek

set -e

echo "===== Iniciando configuración del entorno Docker en EC2 ====="
echo "$(date)"

# Actualizar el sistema
echo "Actualizando el sistema..."
sudo apt-get update && sudo apt-get upgrade -y

# Verificar instalación de Docker y Docker Compose
echo "Verificando instalación de Docker..."
if ! command -v docker &> /dev/null; then
    echo "Docker no está instalado. Instalando..."
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
else
    echo "Docker ya está instalado: $(docker --version)"
fi

echo "Verificando instalación de Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose no está instalado. Instalando..."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
else
    echo "Docker Compose ya está instalado: $(docker-compose --version)"
fi

# Añadir usuario actual al grupo docker
echo "Añadiendo usuario al grupo docker..."
sudo usermod -aG docker $USER
echo "NOTA: Es posible que necesites reiniciar la sesión para aplicar los cambios de grupo."

# Crear estructura de directorios
echo "Creando estructura de directorios..."
mkdir -p ~/hypertek/docker
mkdir -p ~/hypertek/letsencrypt
mkdir -p ~/hypertek/logs
mkdir -p ~/hypertek/backups

# Clonar repositorio o configurar para copia SCP
echo "NOTA: Para continuar, debes clonar el repositorio o copiar los archivos mediante SCP."
echo "Ejemplo de clonación:"
echo "git clone https://github.com/dev-hypertek/instancia-n8n-hypertek ~/hypertek"
echo ""
echo "Ejemplo de copia por SCP:"
echo "scp -r -i ~/.ssh/hypertek-key /ruta/local/Instancia_AWS_Hypertek/docker ubuntu@INSTANCE_IP:~/hypertek/"

echo "===== Configuración básica del entorno completada ====="
echo "Siguiente paso: Implementar la base de datos PostgreSQL"
echo "Ejecuta: ./setup-postgres.sh"
