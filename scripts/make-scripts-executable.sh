#!/bin/bash
# Script para hacer ejecutables todos los scripts shell del proyecto
# Fecha: 8 de abril de 2025
# Autor: Hypertek

set -e

echo "Haciendo ejecutables todos los scripts shell..."

# Hacer ejecutables los scripts en /scripts
find "$(dirname "$(dirname "$0")")/scripts" -name "*.sh" -exec chmod +x {} \;

# Hacer ejecutables los scripts en /mcp-servers
find "$(dirname "$(dirname "$0")")/mcp-servers" -name "*.sh" -exec chmod +x {} \;

echo "Todos los scripts shell son ahora ejecutables."
