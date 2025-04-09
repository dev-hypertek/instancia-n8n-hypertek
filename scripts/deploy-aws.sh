#!/bin/bash
# Script maestro para desplegar el sistema Hypertek en AWS
# Fecha: 8 de abril de 2025
# Autor: Hypertek

set -e

echo "================================================================="
echo "  DESPLIEGUE DEL SISTEMA INTEGRAL HYPERTEK  "
echo "================================================================="
echo "Este script guiará el proceso completo de despliegue en AWS."
echo "Asegúrate de tener acceso SSH a la instancia EC2 antes de continuar."
echo ""

# Verificar permisos de ejecución en scripts
chmod +x setup-ec2-environment.sh
chmod +x setup-postgres.sh
chmod +x setup-services.sh
chmod +x setup-backups.sh

echo "Scripts preparados con permisos de ejecución."
echo ""
echo "A continuación, debes transferir los archivos necesarios a la instancia EC2."
echo "Opción 1: Usar el comando scp para copiar los archivos desde local:"
echo ""
echo "cd /Users/brandowleon/Instancia_AWS_Hypertek"
echo "scp -r -i ~/.ssh/key_n8n_hypertek docker scripts ubuntu@13.57.246.205:~/hypertek/"
echo ""
echo "Opción 2: Clonar el repositorio directamente en la instancia EC2:"
echo ""
echo "ssh -i ~/.ssh/key_n8n_hypertek ubuntu@13.57.246.205"
echo "mkdir -p ~/hypertek"
echo "cd ~/hypertek"
echo "git clone https://github.com/dev-hypertek/instancia-n8n-hypertek ."
echo ""
echo "Una vez transferidos los archivos, ejecuta los siguientes comandos en la instancia EC2:"
echo ""
echo "cd ~/hypertek/scripts"
echo "./setup-ec2-environment.sh  # Configura el entorno Docker"
echo "./setup-postgres.sh         # Implementa PostgreSQL"
echo "./setup-services.sh         # Configura servicios principales"
echo "./setup-backups.sh          # Configura respaldos automáticos"
echo ""
echo "Después de completar estos pasos, el sistema estará funcionando en:"
echo "n8n: https://hypertek.com.co/n8n/"
echo "Evolution API: https://hypertek.com.co/evolution-api/"
echo "ntfy: https://hypertek.com.co/ntfy/"
echo ""
echo "Para la integración con Claude AI, revisa la documentación en los archivos correspondientes."
