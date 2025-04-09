-- Create extension for UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create schema for citas-medicas application within the Hypertek database
CREATE SCHEMA IF NOT EXISTS citas_medicas;

-- Users table
CREATE TABLE IF NOT EXISTS citas_medicas.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    document_id VARCHAR(20),
    document_type VARCHAR(20),
    preferred_language VARCHAR(10) DEFAULT 'es',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Doctors table
CREATE TABLE IF NOT EXISTS citas_medicas.doctors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone_number VARCHAR(20),
    max_appointments_per_day INTEGER DEFAULT 20,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Schedules table
CREATE TABLE IF NOT EXISTS citas_medicas.schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    doctor_id UUID NOT NULL REFERENCES citas_medicas.doctors(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL, -- 0 for Sunday, 1 for Monday, etc.
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_doctor_schedule UNIQUE (doctor_id, day_of_week, start_time)
);

-- Available slots table
CREATE TABLE IF NOT EXISTS citas_medicas.available_slots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    doctor_id UUID NOT NULL REFERENCES citas_medicas.doctors(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_doctor_slot UNIQUE (doctor_id, date, start_time)
);

-- Appointments table
CREATE TABLE IF NOT EXISTS citas_medicas.appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES citas_medicas.users(id) ON DELETE CASCADE,
    doctor_id UUID NOT NULL REFERENCES citas_medicas.doctors(id) ON DELETE CASCADE,
    slot_id UUID NOT NULL REFERENCES citas_medicas.available_slots(id) ON DELETE CASCADE,
    appointment_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'scheduled', -- scheduled, confirmed, completed, cancelled, rescheduled
    previous_appointment_id UUID REFERENCES citas_medicas.appointments(id), -- for rescheduled appointments
    cancellation_reason TEXT,
    symptoms TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_appointment UNIQUE (doctor_id, appointment_date, start_time)
);

-- Notifications table
CREATE TABLE IF NOT EXISTS citas_medicas.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    appointment_id UUID REFERENCES citas_medicas.appointments(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES citas_medicas.users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL, -- reminder, confirmation, cancellation, rescheduling, etc.
    status VARCHAR(20) NOT NULL DEFAULT 'pending', -- pending, sent, delivered, read, failed
    response TEXT, -- user's response to the notification
    scheduled_at TIMESTAMP WITH TIME ZONE,
    sent_at TIMESTAMP WITH TIME ZONE,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Conversations table for chat history
CREATE TABLE IF NOT EXISTS citas_medicas.conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES citas_medicas.users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    direction VARCHAR(10) NOT NULL, -- inbound, outbound
    message_type VARCHAR(20) DEFAULT 'text', -- text, image, document, audio, etc.
    media_url TEXT, -- URL to media content if any
    intent VARCHAR(50), -- classified intent of the message
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add context tracking for multi-step conversations
CREATE TABLE IF NOT EXISTS citas_medicas.conversation_contexts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES citas_medicas.users(id) ON DELETE CASCADE,
    context_type VARCHAR(50) NOT NULL, -- scheduling, rescheduling, cancellation, query, etc.
    context_data JSONB, -- JSON with context data
    active BOOLEAN DEFAULT TRUE,
    expired_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Configuration table for system settings
CREATE TABLE IF NOT EXISTS citas_medicas.configuration (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(100) NOT NULL UNIQUE,
    value TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Admin users table
CREATE TABLE IF NOT EXISTS citas_medicas.admin_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(100) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    role VARCHAR(20) NOT NULL DEFAULT 'staff', -- admin, staff
    active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Reports table
CREATE TABLE IF NOT EXISTS citas_medicas.reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_type VARCHAR(50) NOT NULL, -- daily, weekly, monthly, custom
    report_name VARCHAR(100) NOT NULL,
    parameters JSONB,
    result_data JSONB,
    generated_by UUID REFERENCES citas_medicas.admin_users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Audit log table
CREATE TABLE IF NOT EXISTS citas_medicas.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    action VARCHAR(50) NOT NULL, -- create, update, delete, login, etc.
    entity_type VARCHAR(50) NOT NULL, -- user, doctor, appointment, etc.
    entity_id UUID,
    user_id UUID, -- could be NULL for system actions
    admin_id UUID, -- could be NULL for user actions
    old_value JSONB,
    new_value JSONB,
    ip_address VARCHAR(45),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Templates for messages
CREATE TABLE IF NOT EXISTS citas_medicas.message_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    template_name VARCHAR(100) NOT NULL UNIQUE,
    template_type VARCHAR(50) NOT NULL, -- reminder, confirmation, cancellation, welcome, etc.
    template_content TEXT NOT NULL,
    variables JSONB, -- Available variables for this template
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert initial configuration values
INSERT INTO citas_medicas.configuration (key, value, description)
VALUES 
    ('notification_reminder_hours', '24', 'Hours before appointment to send reminder notification'),
    ('notification_confirmation_hours', '48', 'Hours before appointment to request confirmation'),
    ('appointment_duration_minutes', '30', 'Default appointment duration in minutes'),
    ('working_days', '1,2,3,4,5', 'Working days (1=Monday, 7=Sunday)'),
    ('working_hours_start', '08:00', 'Start time of working hours'),
    ('working_hours_end', '18:00', 'End time of working hours'),
    ('max_rescheduling_attempts', '3', 'Maximum number of rescheduling attempts allowed'),
    ('slots_advance_days', '60', 'Number of days in advance to generate available slots'),
    ('cancellation_policy_hours', '24', 'Minimum hours before appointment to allow cancellation'),
    ('context_expiry_minutes', '30', 'Number of minutes after which conversation context expires'),
    ('auto_confirm_appointments', 'true', 'Whether to automatically confirm appointments'),
    ('appointment_reminder_message_template', '¡Hola {{patient_name}}! Este es un recordatorio de tu cita médica mañana a las {{appointment_time}} con {{doctor_name}} ({{specialty}}). Por favor llega 15 minutos antes.', 'Template for appointment reminder messages');

-- Insert initial message templates
INSERT INTO citas_medicas.message_templates (template_name, template_type, template_content, variables)
VALUES
    ('welcome_template', 'welcome', 
     '¡Hola! Gracias por contactar nuestro servicio de citas médicas. ¿En qué podemos ayudarte hoy?\n\n- Agendar una cita\n- Consultar tus citas\n- Cancelar o reprogramar una cita\n- Información de médicos y especialidades', 
     '{"variables": []}'
    ),
    ('appointment_confirmation_template', 'confirmation', 
     '¡Tu cita ha sido agendada exitosamente!\n\nFecha: {{appointment_date}}\nHora: {{appointment_time}}\nMédico: {{doctor_name}}\nEspecialidad: {{specialty}}\n\nRecuerda llegar 15 minutos antes de tu cita con tu documento de identidad.\n\nPara cancelar o reprogramar tu cita, responde a este mensaje con la palabra "reprogramar" o "cancelar".', 
     '{"variables": ["appointment_date", "appointment_time", "doctor_name", "specialty"]}'
    ),
    ('appointment_reminder_template', 'reminder', 
     '¡Hola {{patient_name}}! Este es un recordatorio de tu cita médica mañana a las {{appointment_time}} con {{doctor_name}} ({{specialty}}). Por favor llega 15 minutos antes. Responde SI para confirmar tu asistencia o NO si necesitas reprogramar.', 
     '{"variables": ["patient_name", "appointment_time", "doctor_name", "specialty"]}'
    ),
    ('cancellation_template', 'cancellation', 
     'Tu cita para el {{appointment_date}} a las {{appointment_time}} con {{doctor_name}} ha sido cancelada exitosamente. Si deseas agendar una nueva cita, escribe "nueva cita" en cualquier momento.', 
     '{"variables": ["appointment_date", "appointment_time", "doctor_name"]}'
    ),
    ('reschedule_request_template', 'reschedule', 
     'Entendido, vamos a reprogramar tu cita. Estas son las fechas disponibles:\n\n{{available_slots}}\n\nResponde con el número de la opción que prefieras.', 
     '{"variables": ["available_slots"]}'
    ),
    ('reschedule_confirmation_template', 'reschedule_confirm', 
     'Tu cita ha sido reprogramada exitosamente.\n\nNueva fecha: {{new_appointment_date}}\nNueva hora: {{new_appointment_time}}\nMédico: {{doctor_name}}\nEspecialidad: {{specialty}}\n\nRecuerda llegar 15 minutos antes de tu cita con tu documento de identidad.', 
     '{"variables": ["new_appointment_date", "new_appointment_time", "doctor_name", "specialty"]}'
    ),
    ('availability_response_template', 'availability', 
     'Estos son los horarios disponibles para {{specialty}} con {{doctor_name}}:\n\n{{available_slots}}\n\nResponde con el número de la opción que prefieras para agendar tu cita.', 
     '{"variables": ["specialty", "doctor_name", "available_slots"]}'
    );

-- Create indexes for better performance
CREATE INDEX idx_users_phone ON citas_medicas.users(phone_number);
CREATE INDEX idx_doctors_specialty ON citas_medicas.doctors(specialty);
CREATE INDEX idx_doctors_active ON citas_medicas.doctors(active);
CREATE INDEX idx_appointments_date ON citas_medicas.appointments(appointment_date);
CREATE INDEX idx_appointments_status ON citas_medicas.appointments(status);
CREATE INDEX idx_appointments_user_id ON citas_medicas.appointments(user_id);
CREATE INDEX idx_appointments_doctor_id ON citas_medicas.appointments(doctor_id);
CREATE INDEX idx_available_slots_date ON citas_medicas.available_slots(date);
CREATE INDEX idx_available_slots_doctor_id_available ON citas_medicas.available_slots(doctor_id, is_available);
CREATE INDEX idx_notifications_status ON citas_medicas.notifications(status);
CREATE INDEX idx_notifications_type ON citas_medicas.notifications(type);
CREATE INDEX idx_notifications_scheduled_at ON citas_medicas.notifications(scheduled_at);
CREATE INDEX idx_conversations_user_id ON citas_medicas.conversations(user_id);
CREATE INDEX idx_conversations_created_at ON citas_medicas.conversations(created_at);
CREATE INDEX idx_conversation_contexts_user_id ON citas_medicas.conversation_contexts(user_id);
CREATE INDEX idx_conversation_contexts_active ON citas_medicas.conversation_contexts(active);
CREATE INDEX idx_audit_logs_entity_id ON citas_medicas.audit_logs(entity_id);
CREATE INDEX idx_audit_logs_created_at ON citas_medicas.audit_logs(created_at);

-- Create function to update 'updated_at' field
CREATE OR REPLACE FUNCTION citas_medicas.update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers to automatically update 'updated_at' field
CREATE TRIGGER users_update_timestamp BEFORE UPDATE ON citas_medicas.users
FOR EACH ROW EXECUTE FUNCTION citas_medicas.update_modified_column();

CREATE TRIGGER doctors_update_timestamp BEFORE UPDATE ON citas_medicas.doctors
FOR EACH ROW EXECUTE FUNCTION citas_medicas.update_modified_column();

CREATE TRIGGER schedules_update_timestamp BEFORE UPDATE ON citas_medicas.schedules
FOR EACH ROW EXECUTE FUNCTION citas_medicas.update_modified_column();

CREATE TRIGGER available_slots_update_timestamp BEFORE UPDATE ON citas_medicas.available_slots
FOR EACH ROW EXECUTE FUNCTION citas_medicas.update_modified_column();

CREATE TRIGGER appointments_update_timestamp BEFORE UPDATE ON citas_medicas.appointments
FOR EACH ROW EXECUTE FUNCTION citas_medicas.update_modified_column();

CREATE TRIGGER notifications_update_timestamp BEFORE UPDATE ON citas_medicas.notifications
FOR EACH ROW EXECUTE FUNCTION citas_medicas.update_modified_column();

CREATE TRIGGER configuration_update_timestamp BEFORE UPDATE ON citas_medicas.configuration
FOR EACH ROW EXECUTE FUNCTION citas_medicas.update_modified_column();

CREATE TRIGGER admin_users_update_timestamp BEFORE UPDATE ON citas_medicas.admin_users
FOR EACH ROW EXECUTE FUNCTION citas_medicas.update_modified_column();

CREATE TRIGGER conversation_contexts_update_timestamp BEFORE UPDATE ON citas_medicas.conversation_contexts
FOR EACH ROW EXECUTE FUNCTION citas_medicas.update_modified_column();

CREATE TRIGGER message_templates_update_timestamp BEFORE UPDATE ON citas_medicas.message_templates
FOR EACH ROW EXECUTE FUNCTION citas_medicas.update_modified_column();

-- Create view for upcoming appointments with complete information
CREATE OR REPLACE VIEW citas_medicas.view_upcoming_appointments AS
SELECT 
    a.id as appointment_id,
    a.appointment_date,
    a.start_time,
    a.end_time,
    a.status,
    u.id as user_id,
    u.full_name as patient_name,
    u.phone_number as patient_phone,
    d.id as doctor_id,
    d.full_name as doctor_name,
    d.specialty
FROM citas_medicas.appointments a
JOIN citas_medicas.users u ON a.user_id = u.id
JOIN citas_medicas.doctors d ON a.doctor_id = d.id
WHERE a.appointment_date >= CURRENT_DATE
AND a.status IN ('scheduled', 'confirmed')
ORDER BY a.appointment_date, a.start_time;

-- Create view for daily schedule by doctor
CREATE OR REPLACE VIEW citas_medicas.view_daily_doctor_schedule AS
SELECT 
    d.id as doctor_id,
    d.full_name as doctor_name,
    d.specialty,
    a.appointment_date,
    a.start_time,
    a.end_time,
    u.full_name as patient_name,
    u.phone_number as patient_phone,
    a.status
FROM citas_medicas.appointments a
JOIN citas_medicas.doctors d ON a.doctor_id = d.id
JOIN citas_medicas.users u ON a.user_id = u.id
WHERE a.status IN ('scheduled', 'confirmed')
ORDER BY d.full_name, a.appointment_date, a.start_time;

-- Create function to generate available slots for a specific period
CREATE OR REPLACE FUNCTION citas_medicas.generate_available_slots(
    start_date DATE,
    days_ahead INTEGER
)
RETURNS INTEGER AS $$
DECLARE
    doctor_record RECORD;
    schedule_record RECORD;
    slot_date DATE;
    end_date DATE := start_date + (days_ahead || ' days')::INTERVAL;
    slot_start TIME;
    slot_end TIME;
    slot_interval INTERVAL;
    slots_created INTEGER := 0;
BEGIN
    -- Get slot duration from configuration
    SELECT value::INTEGER INTO slot_interval 
    FROM citas_medicas.configuration 
    WHERE key = 'appointment_duration_minutes';
    
    slot_interval := (slot_interval || ' minutes')::INTERVAL;
    
    -- For each active doctor
    FOR doctor_record IN SELECT id FROM citas_medicas.doctors WHERE active = TRUE LOOP
        -- For each day in the specified range
        slot_date := start_date;
        WHILE slot_date < end_date LOOP
            -- Get the day of week (0 = Sunday, 1 = Monday, etc.)
            -- For each schedule that matches this day of week
            FOR schedule_record IN 
                SELECT * FROM citas_medicas.schedules 
                WHERE doctor_id = doctor_record.id 
                AND day_of_week = EXTRACT(DOW FROM slot_date)::INTEGER
            LOOP
                -- Generate slots at the specified interval
                slot_start := schedule_record.start_time;
                WHILE slot_start < schedule_record.end_time LOOP
                    slot_end := slot_start + slot_interval;
                    
                    -- If slot ends within doctor's schedule
                    IF slot_end <= schedule_record.end_time THEN
                        -- Insert slot if it doesn't already exist
                        BEGIN
                            INSERT INTO citas_medicas.available_slots 
                                (doctor_id, date, start_time, end_time, is_available)
                            VALUES 
                                (doctor_record.id, slot_date, slot_start, slot_end, TRUE);
                            
                            slots_created := slots_created + 1;
                        EXCEPTION WHEN unique_violation THEN
                            -- Skip if slot already exists
                        END;
                    END IF;
                    
                    -- Move to next slot
                    slot_start := slot_end;
                END LOOP;
            END LOOP;
            
            -- Move to next day
            slot_date := slot_date + INTERVAL '1 day';
        END LOOP;
    END LOOP;
    
    RETURN slots_created;
END;
$$ LANGUAGE plpgsql;
