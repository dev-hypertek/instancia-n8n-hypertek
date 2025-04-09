# Sistema Integral Hypertek

## Descripción General

Sistema integral de automatización basado en n8n, Evolution API, PostgreSQL, y potenciado por Claude AI mediante servidores MCP. El sistema está diseñado para gestionar múltiples flujos de trabajo, comenzando con un módulo de gestión de citas médicas a través de WhatsApp.

## Arquitectura

- **Infraestructura**: AWS EC2 
- **Contenedores**: Docker con orquestación Docker Compose
- **Base de datos**: PostgreSQL con respaldos automatizados
- **Automatización**: n8n con flujos definidos como código
- **Comunicación**: Evolution API para WhatsApp
- **IA**: Claude AI con MCP servers seleccionados
- **Monitoreo**: ntfy para alertas

## Componentes Principales

### Base de Datos PostgreSQL
- Nombre de la BD: `bd_hypertek`
- Esquemas separados para diferentes módulos:
  * `citas_medicas`: Tablas y funciones para el sistema de citas médicas
  * Futuros esquemas se añadirán para nuevos módulos

### Servicios en Contenedores
- **n8n**: Plataforma de automatización para flujos de trabajo
- **Evolution API**: API para comunicación vía WhatsApp
- **Redis**: Utilizado por Evolution API para gestión de sesiones
- **Nginx**: Proxy inverso para los servicios
- **ntfy**: Sistema de notificaciones

### Integración con IA
- Módulo Claude AI para procesamiento de lenguaje natural
- Extracción de entidades y clasificación de intenciones

## Instalación y Configuración

### Requisitos Previos
- Docker y Docker Compose
- Servidor AWS EC2 (Ubuntu recomendado)
- Dominio configurado (hypertek.com.co)

### Despliegue en AWS

1. Clona este repositorio en tu máquina local:
   ```bash
   git clone https://github.com/dev-hypertek/instancia-n8n-hypertek
   cd hypertek
   ```

2. Transfiere los archivos a la instancia EC2:
   ```bash
   scp -r -i ~/.ssh/hypertek-key docker scripts ubuntu@IP_INSTANCIA:~/hypertek/
   ```

3. Conéctate a la instancia EC2:
   ```bash
   ssh -i ~/.ssh/hypertek-key ubuntu@IP_INSTANCIA
   ```

4. Ejecuta los scripts de configuración en orden:
   ```bash
   cd ~/hypertek/scripts
   chmod +x *.sh
   ./setup-ec2-environment.sh
   ./setup-postgres.sh
   ./setup-services.sh
   ./setup-backups.sh
   ```

## Estructura del Proyecto

```
/Users/brandowleon/Instancia_AWS_Hypertek/
├── terraform/                  # Configuración de Terraform (opcional)
├── docker/                     # Configuración de Docker
│   ├── docker-compose.yml      # Definición de servicios
│   ├── .env                    # Variables de entorno
│   ├── init-scripts/           # Scripts de inicialización de BD
│   ├── n8n-flows/              # Flujos de trabajo n8n
│   ├── evolution-api-instances/# Instancias de Evolution API
│   ├── nginx/                  # Configuración de Nginx
│   │   ├── Dockerfile
│   │   ├── conf.d/
│   │   ├── ssl/
│   │   └── www/
│   └── ntfy-config/            # Configuración de notificaciones
├── scripts/                    # Scripts de utilidad
│   ├── deploy-aws.sh           # Script principal de despliegue
│   ├── setup-ec2-environment.sh# Configuración del entorno EC2
│   ├── setup-postgres.sh       # Configuración de PostgreSQL
│   ├── setup-services.sh       # Configuración de servicios
│   └── setup-backups.sh        # Configuración de respaldos
├── mcp-servers/                # Configuración de servidores MCP para Claude AI
│   └── claude-setup.sh         # Script de configuración de Claude AI
├── docs/                       # Documentación
└── README.md                   # Este archivo
```

## Módulos Disponibles

### 1. Sistema de Citas Médicas
- **Funcionalidades**:
  * Agendamiento de citas mediante conversación en WhatsApp
  * Confirmación y recordatorio de citas
  * Cancelación y reprogramación
  * Consulta de disponibilidad de médicos

- **Esquema de BD**: `citas_medicas`
- **Flujos n8n**:
  * `appointment_scheduling.json`: Agendamiento de citas
  * `appointment_reminders.json`: Recordatorios automáticos
  * `appointment_cancellation.json`: Cancelación y reprogramación
  * `availability_check.json`: Consulta de disponibilidad

## Acceso a Servicios

Después de completar el despliegue, los servicios estarán disponibles en:

- **Panel de n8n**: `https://hypertek.com.co/n8n/`
  * Usuario: `contacto@hypertek.com.co`
  * Contraseña: Configurada en el archivo `.env`

- **Evolution API**: `https://hypertek.com.co/evolution-api/`
  * API Key: Configurada en el archivo `.env`

- **Panel de Notificaciones**: `https://hypertek.com.co/ntfy/`

## Mantenimiento y Administración

### Respaldos Automáticos
- Los respaldos se realizan automáticamente cada noche:
  * PostgreSQL: 2:00 AM
  * n8n flows: 3:00 AM
  * Evolution API instances: 4:00 AM
- Ubicación de respaldos: `/home/ubuntu/hypertek/backups/`
- Logs de respaldos: `/home/ubuntu/hypertek/logs/`

### Logs y Monitoreo
- Logs de Docker: `sudo docker-compose logs [servicio]`
- Monitoreo de servicios: `sudo docker-compose ps`
- Reinicio de servicios: `sudo docker-compose restart [servicio]`

### Actualización de Servicios
- Para actualizar los flujos de n8n:
  ```bash
  sudo docker-compose restart n8n
  ```
- Para actualizar configuraciones:
  ```bash
  sudo docker-compose down
  sudo docker-compose up -d
  ```

## Seguridad

- Todos los servicios están protegidos por HTTPS
- Autenticación requerida para acceder a n8n y Evolution API
- Contraseñas y claves API almacenadas en el archivo `.env`
- Respaldos automáticos para recuperación en caso de fallo

## Resolución de Problemas

### Problemas comunes y soluciones

1. **Servicios no accesibles**:
   - Verificar estado de contenedores: `sudo docker-compose ps`
   - Revisar logs: `sudo docker-compose logs nginx`
   - Comprobar configuración DNS del dominio

2. **Problemas con WhatsApp**:
   - Verificar la instancia en Evolution API: `sudo docker-compose logs evolution-api`
   - Reiniciar servicio: `sudo docker-compose restart evolution-api`

3. **Flujos n8n no funcionan**:
   - Verificar conexión a base de datos
   - Revisar logs: `sudo docker-compose logs n8n`
   - Comprobar webhooks configurados

## Contacto y Soporte

Para soporte técnico, contactar a:
- Email: contacto@hypertek.com.co
- WhatsApp: +573XXXXXXXXX

---

© 2025 Hypertek. Todos los derechos reservados.
