#!/bin/bash

# Script para configurar MCP servers para la integración con Claude AI
# Autor: Hypertek
# Fecha: 8 de abril de 2025

# Instalar dependencias
apt-get update -y
apt-get install -y python3-pip git

# Crear directorio para MCP
mkdir -p /opt/hypertek/mcp
cd /opt/hypertek/mcp

# Clonar el repositorio de MCP
git clone https://github.com/anthropics/anthropic-multimodal-cookbook.git
cd anthropic-multimodal-cookbook

# Instalar dependencias de Python
pip3 install -r requirements.txt
pip3 install anthropic flask requests

# Crear directorios para prompts y configuración
mkdir -p /opt/hypertek/mcp/prompts
mkdir -p /opt/hypertek/mcp/config

# Crear archivo de configuración para Claude AI
cat << EOF > /opt/hypertek/mcp/config/claude_config.json
{
  "api_key": "${CLAUDE_API_KEY:-your-api-key}",
  "model": "claude-3-opus-20240229",
  "max_tokens": 4096,
  "temperature": 0.5
}
EOF

# Crear prompt para extracción de información de citas
cat << EOF > /opt/hypertek/mcp/prompts/medical_appointment.md
# Instrucciones para asistente de citas médicas

Eres un asistente de un centro médico, especializado en el agendamiento y gestión de citas médicas.

## Personalidad
- Amable, profesional y conciso
- Orientado a obtener la información necesaria para agendar una cita
- Empático con las preocupaciones de salud de los pacientes

## Información requerida para agendar citas
- Nombre completo del paciente
- Especialidad médica requerida
- Fecha y hora preferida
- Síntomas o condición (opcional)

## Flujo de conversación
1. Saluda al paciente y pregunta en qué puedes ayudarle
2. Si solicita una cita, obtén la información faltante mediante preguntas específicas
3. Confirma la información recopilada
4. Notifica el siguiente paso (verificación de disponibilidad)

## Consideraciones importantes
- No solicites información médica detallada, solo lo necesario para la cita
- Si el paciente menciona una emergencia, indica que debe acudir inmediatamente a urgencias
- Recuerda a los pacientes traer su identificación y llegar 15 minutos antes
- Mantén un tono cálido pero profesional
EOF

# Crear prompt para extracción de entidades
cat << EOF > /opt/hypertek/mcp/prompts/entity_extraction.md
# Instrucciones para extracción de datos de citas médicas

Eres un asistente especializado en extraer información de solicitudes de citas médicas.

## Objetivo
Analizar mensajes de pacientes para extraer información relevante para agendar una cita médica.

## Datos a extraer
1. Nombre del paciente
2. Tipo de especialidad médica requerida
3. Fecha y hora preferida para la cita
4. Síntomas o condiciones relevantes (opcional)

## Reglas
- Extrae solo la información solicitada
- Si algún dato no está presente, devuelve null para ese campo
- No agregues información adicional o suposiciones
- Responde en formato JSON con los campos: nombre, especialidad, fechaHora, sintomas

## Ejemplos
Mensaje: "Hola, me gustaría agendar una cita con el dermatólogo para este viernes a las 3 pm. Mi nombre es Juan Pérez."
Respuesta: {"nombre":"Juan Pérez","especialidad":"dermatología","fechaHora":"viernes 3 pm","sintomas":null}

Mensaje: "Necesito un turno con el cardiólogo porque tengo dolor en el pecho desde ayer"
Respuesta: {"nombre":null,"especialidad":"cardiología","fechaHora":null,"sintomas":"dolor en el pecho desde ayer"}
EOF

# Crear script Python para la integración con Claude
cat << EOF > /opt/hypertek/mcp/claude_processor.py
#!/usr/bin/env python3

import os
import json
import argparse
from anthropic import Anthropic

# Cargar configuración
def load_config():
    config_path = "/opt/hypertek/mcp/config/claude_config.json"
    with open(config_path, 'r') as file:
        return json.load(file)

# Cargar prompt
def load_prompt(prompt_name):
    prompt_path = f"/opt/hypertek/mcp/prompts/{prompt_name}.md"
    with open(prompt_path, 'r') as file:
        return file.read()

# Procesar mensaje con Claude AI
def process_with_claude(message, prompt_name):
    config = load_config()
    prompt = load_prompt(prompt_name)
    
    client = Anthropic(api_key=config["api_key"])
    
    response = client.messages.create(
        model=config["model"],
        max_tokens=config["max_tokens"],
        temperature=config["temperature"],
        system=prompt,
        messages=[{"role": "user", "content": message}]
    )
    
    return response.content[0].text

# Función principal
def main():
    parser = argparse.ArgumentParser(description='Claude AI Integration for Hypertek')
    parser.add_argument('--message', required=True, help='User message to process')
    parser.add_argument('--prompt', required=True, help='Prompt template to use')
    
    args = parser.parse_args()
    
    result = process_with_claude(args.message, args.prompt)
    print(json.dumps({"response": result}))

if __name__ == "__main__":
    main()
EOF

# Crear API REST para comunicación con n8n
cat << EOF > /opt/hypertek/mcp/claude_api.py
#!/usr/bin/env python3

from flask import Flask, request, jsonify
import json
import subprocess
import os

app = Flask(__name__)

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "ok", "service": "claude-api"}), 200

@app.route('/process', methods=['POST'])
def process():
    data = request.json
    
    if not data or 'message' not in data or 'prompt_type' not in data:
        return jsonify({"error": "Missing required parameters: message, prompt_type"}), 400
    
    message = data['message']
    prompt_type = data['prompt_type']
    
    # Validar que el tipo de prompt es válido
    valid_prompts = ["medical_appointment", "entity_extraction"]
    if prompt_type not in valid_prompts:
        return jsonify({"error": f"Invalid prompt_type. Must be one of: {', '.join(valid_prompts)}"}), 400
    
    try:
        # Ejecutar el script de procesamiento
        result = subprocess.run(
            ['/opt/hypertek/mcp/claude_processor.py', '--message', message, '--prompt', prompt_type],
            capture_output=True,
            text=True,
            check=True
        )
        
        # Verificar si el resultado es un JSON válido
        try:
            response_data = json.loads(result.stdout)
            return jsonify(response_data)
        except json.JSONDecodeError:
            # Si no es JSON, devolver el resultado como texto
            return jsonify({"response": result.stdout.strip()})
    except subprocess.CalledProcessError as e:
        return jsonify({"error": f"Processing error: {e.stderr}"}), 500
    except Exception as e:
        return jsonify({"error": f"Unexpected error: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# Hacer ejecutables los scripts
chmod +x /opt/hypertek/mcp/claude_processor.py
chmod +x /opt/hypertek/mcp/claude_api.py

# Crear servicio systemd para la API
cat << EOF > /etc/systemd/system/claude-api.service
[Unit]
Description=Claude AI Integration API for Hypertek
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/hypertek/mcp/claude_api.py
WorkingDirectory=/opt/hypertek/mcp
Restart=always
User=ubuntu
Environment=PATH=/usr/bin:/usr/local/bin
Environment=PYTHONPATH=/opt/hypertek/mcp

[Install]
WantedBy=multi-user.target
EOF

# Habilitar e iniciar el servicio
systemctl daemon-reload
systemctl enable claude-api
systemctl start claude-api

echo "=== Configuración de MCP servers para Claude AI completada ==="
echo "API REST disponible en: http://localhost:5000/process"
echo "Para probar la API:"
echo "curl -X POST http://localhost:5000/process -H 'Content-Type: application/json' -d '{\"message\":\"Quiero una cita con el cardiólogo\",\"prompt_type\":\"entity_extraction\"}'"
echo ""
echo "IMPORTANTE: Debes actualizar el archivo de configuración con tu API key de Claude:"
echo "/opt/hypertek/mcp/config/claude_config.json"
