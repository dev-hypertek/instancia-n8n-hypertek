-- Insertar datos de ejemplo para desarrollo

-- Insertar médicos de muestra
INSERT INTO citas_medicas.doctors (full_name, specialty, email, phone_number, max_appointments_per_day)
VALUES 
    ('Dr. Juan Martínez', 'Cardiología', 'jmartinez@ejemplo.com', '+573101234567', 15),
    ('Dra. Ana López', 'Dermatología', 'alopez@ejemplo.com', '+573109876543', 12),
    ('Dr. Carlos Ramírez', 'Pediatría', 'cramirez@ejemplo.com', '+573105555555', 20),
    ('Dra. María Gómez', 'Oftalmología', 'mgomez@ejemplo.com', '+573107777777', 15),
    ('Dr. Roberto Sánchez', 'Neurología', 'rsanchez@ejemplo.com', '+573102222222', 10),
    ('Dra. Lucía Fernández', 'Ginecología', 'lfernandez@ejemplo.com', '+573103333333', 15),
    ('Dr. Javier Rodríguez', 'Medicina General', 'jrodriguez@ejemplo.com', '+573104444444', 25);

-- Insertar horarios para los médicos
-- Dr. Juan Martínez (Lunes, Miércoles, Viernes)
INSERT INTO citas_medicas.schedules (doctor_id, day_of_week, start_time, end_time)
VALUES 
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Juan Martínez'), 1, '08:00', '12:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Juan Martínez'), 3, '08:00', '12:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Juan Martínez'), 5, '08:00', '12:00');

-- Dra. Ana López (Martes, Jueves)
INSERT INTO citas_medicas.schedules (doctor_id, day_of_week, start_time, end_time)
VALUES 
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dra. Ana López'), 2, '13:00', '18:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dra. Ana López'), 4, '13:00', '18:00');

-- Dr. Carlos Ramírez (Lunes a Viernes por la tarde)
INSERT INTO citas_medicas.schedules (doctor_id, day_of_week, start_time, end_time)
VALUES 
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Carlos Ramírez'), 1, '14:00', '17:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Carlos Ramírez'), 2, '14:00', '17:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Carlos Ramírez'), 3, '14:00', '17:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Carlos Ramírez'), 4, '14:00', '17:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Carlos Ramírez'), 5, '14:00', '17:00');

-- Dra. María Gómez (Lunes, Miércoles, Viernes por la tarde)
INSERT INTO citas_medicas.schedules (doctor_id, day_of_week, start_time, end_time)
VALUES 
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dra. María Gómez'), 1, '14:00', '18:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dra. María Gómez'), 3, '14:00', '18:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dra. María Gómez'), 5, '14:00', '18:00');

-- Dr. Roberto Sánchez (Martes, Jueves, Sábado por la mañana)
INSERT INTO citas_medicas.schedules (doctor_id, day_of_week, start_time, end_time)
VALUES 
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Roberto Sánchez'), 2, '08:00', '12:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Roberto Sánchez'), 4, '08:00', '12:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Roberto Sánchez'), 6, '09:00', '13:00');

-- Dra. Lucía Fernández (Lunes a Jueves)
INSERT INTO citas_medicas.schedules (doctor_id, day_of_week, start_time, end_time)
VALUES 
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dra. Lucía Fernández'), 1, '09:00', '15:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dra. Lucía Fernández'), 2, '09:00', '15:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dra. Lucía Fernández'), 3, '09:00', '15:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dra. Lucía Fernández'), 4, '09:00', '15:00');

-- Dr. Javier Rodríguez (Lunes a Viernes todo el día)
INSERT INTO citas_medicas.schedules (doctor_id, day_of_week, start_time, end_time)
VALUES 
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Javier Rodríguez'), 1, '08:00', '12:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Javier Rodríguez'), 1, '14:00', '18:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Javier Rodríguez'), 2, '08:00', '12:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Javier Rodríguez'), 2, '14:00', '18:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Javier Rodríguez'), 3, '08:00', '12:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Javier Rodríguez'), 3, '14:00', '18:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Javier Rodríguez'), 4, '08:00', '12:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Javier Rodríguez'), 4, '14:00', '18:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Javier Rodríguez'), 5, '08:00', '12:00'),
    ((SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Javier Rodríguez'), 5, '14:00', '18:00');

-- Generar slots disponibles para los próximos 60 días
SELECT citas_medicas.generate_available_slots(CURRENT_DATE, 60);

-- Insertar usuarios de muestra
INSERT INTO citas_medicas.users (phone_number, full_name, email, document_id, document_type, preferred_language)
VALUES 
    ('+573201234567', 'Pedro Pérez', 'pperez@ejemplo.com', '1234567890', 'CC', 'es'),
    ('+573209876543', 'Laura González', 'lgonzalez@ejemplo.com', '0987654321', 'CC', 'es'),
    ('+573205555555', 'Miguel Torres', 'mtorres@ejemplo.com', '5555555555', 'CE', 'es'),
    ('+573207777777', 'Carolina Díaz', 'cdiaz@ejemplo.com', '7777777777', 'CC', 'es'),
    ('+573202222222', 'Andrés Ramírez', 'aramirez@ejemplo.com', '2222222222', 'CC', 'es'),
    ('+573203333333', 'Valeria López', 'vlopez@ejemplo.com', '3333333333', 'CC', 'es'),
    ('+573204444444', 'Santiago Herrera', 'sherrera@ejemplo.com', '4444444444', 'CC', 'es');

-- Insertar administradores de muestra
INSERT INTO citas_medicas.admin_users (username, password_hash, full_name, email, phone_number, role)
VALUES
    ('admin', '$2a$10$XZdBUx7rLgG8ZShK3jBOQOoMkmnCh3MmY6h2XGjjyvWu7mxQ.fE6i', 'Administrador Principal', 'admin@ejemplo.com', '+573211234567', 'admin'),  -- Password: admin123
    ('recepcion', '$2a$10$DcbZ.oB9PMZ7QqRM7aDJJeSUDwNCpk8SYtLtEN0d4mP8UXHOeIzWi', 'Recepcionista', 'recepcion@ejemplo.com', '+573219876543', 'staff'); -- Password: recepcion123

-- Insertar algunas citas de muestra
-- Para el usuario Pedro Pérez con el Dr. Juan Martínez
DO $$
DECLARE
    user_id UUID;
    doctor_id UUID;
    slot_id UUID;
    appointment_date DATE;
    start_time TIME;
    end_time TIME;
BEGIN
    -- Obtener IDs
    SELECT id INTO user_id FROM citas_medicas.users WHERE full_name = 'Pedro Pérez';
    SELECT id INTO doctor_id FROM citas_medicas.doctors WHERE full_name = 'Dr. Juan Martínez';
    
    -- Obtener un slot disponible
    SELECT id, date, start_time, end_time INTO slot_id, appointment_date, start_time, end_time
    FROM citas_medicas.available_slots
    WHERE doctor_id = doctor_id AND is_available = TRUE
    ORDER BY date, start_time
    LIMIT 1;
    
    -- Marcar el slot como no disponible
    UPDATE citas_medicas.available_slots SET is_available = FALSE WHERE id = slot_id;
    
    -- Crear la cita
    INSERT INTO citas_medicas.appointments (user_id, doctor_id, slot_id, appointment_date, start_time, end_time, status, symptoms, notes)
    VALUES (user_id, doctor_id, slot_id, appointment_date, start_time, end_time, 'scheduled', 'Dolor en el pecho, dificultad para respirar', 'Paciente con antecedentes de hipertensión');
END $$;

-- Para el usuario Laura González con la Dra. Ana López
DO $$
DECLARE
    user_id UUID;
    doctor_id UUID;
    slot_id UUID;
    appointment_date DATE;
    start_time TIME;
    end_time TIME;
BEGIN
    -- Obtener IDs
    SELECT id INTO user_id FROM citas_medicas.users WHERE full_name = 'Laura González';
    SELECT id INTO doctor_id FROM citas_medicas.doctors WHERE full_name = 'Dra. Ana López';
    
    -- Obtener un slot disponible
    SELECT id, date, start_time, end_time INTO slot_id, appointment_date, start_time, end_time
    FROM citas_medicas.available_slots
    WHERE doctor_id = doctor_id AND is_available = TRUE
    ORDER BY date, start_time
    LIMIT 1;
    
    -- Marcar el slot como no disponible
    UPDATE citas_medicas.available_slots SET is_available = FALSE WHERE id = slot_id;
    
    -- Crear la cita
    INSERT INTO citas_medicas.appointments (user_id, doctor_id, slot_id, appointment_date, start_time, end_time, status, symptoms, notes)
    VALUES (user_id, doctor_id, slot_id, appointment_date, start_time, end_time, 'confirmed', 'Erupción cutánea, picazón', 'Posible reacción alérgica');
END $$;

-- Para el usuario Miguel Torres con el Dr. Carlos Ramírez
DO $$
DECLARE
    user_id UUID;
    doctor_id UUID;
    slot_id UUID;
    appointment_date DATE;
    start_time TIME;
    end_time TIME;
BEGIN
    -- Obtener IDs
    SELECT id INTO user_id FROM citas_medicas.users WHERE full_name = 'Miguel Torres';
    SELECT id INTO doctor_id FROM citas_medicas.doctors WHERE full_name = 'Dr. Carlos Ramírez';
    
    -- Obtener un slot disponible
    SELECT id, date, start_time, end_time INTO slot_id, appointment_date, start_time, end_time
    FROM citas_medicas.available_slots
    WHERE doctor_id = doctor_id AND is_available = TRUE AND date = CURRENT_DATE + INTERVAL '2 days'
    ORDER BY date, start_time
    LIMIT 1;
    
    -- Marcar el slot como no disponible
    UPDATE citas_medicas.available_slots SET is_available = FALSE WHERE id = slot_id;
    
    -- Crear la cita
    INSERT INTO citas_medicas.appointments (user_id, doctor_id, slot_id, appointment_date, start_time, end_time, status, symptoms, notes)
    VALUES (user_id, doctor_id, slot_id, appointment_date, start_time, end_time, 'confirmed', 'Fiebre, dolor de garganta', 'Control de rutina');
END $$;

-- Para Carolina Díaz con la Dra. María Gómez
DO $$
DECLARE
    user_id UUID;
    doctor_id UUID;
    slot_id UUID;
    appointment_date DATE;
    start_time TIME;
    end_time TIME;
BEGIN
    -- Obtener IDs
    SELECT id INTO user_id FROM citas_medicas.users WHERE full_name = 'Carolina Díaz';
    SELECT id INTO doctor_id FROM citas_medicas.doctors WHERE full_name = 'Dra. María Gómez';
    
    -- Obtener un slot disponible
    SELECT id, date, start_time, end_time INTO slot_id, appointment_date, start_time, end_time
    FROM citas_medicas.available_slots
    WHERE doctor_id = doctor_id AND is_available = TRUE AND date = CURRENT_DATE + INTERVAL '1 day'
    ORDER BY date, start_time
    LIMIT 1;
    
    -- Marcar el slot como no disponible
    UPDATE citas_medicas.available_slots SET is_available = FALSE WHERE id = slot_id;
    
    -- Crear la cita
    INSERT INTO citas_medicas.appointments (user_id, doctor_id, slot_id, appointment_date, start_time, end_time, status, symptoms, notes)
    VALUES (user_id, doctor_id, slot_id, appointment_date, start_time, end_time, 'scheduled', 'Visión borrosa, dolor de cabeza', 'Primera consulta');
END $$;

-- Insertar notificaciones de muestra
INSERT INTO citas_medicas.notifications (appointment_id, user_id, message, type, status, scheduled_at, sent_at)
SELECT 
    a.id,
    a.user_id,
    'Recordatorio: Tiene una cita programada para mañana a las ' || a.start_time::text || ' con el ' || d.full_name,
    'reminder',
    'sent',
    NOW() - INTERVAL '1 day',
    NOW() - INTERVAL '1 day'
FROM citas_medicas.appointments a
JOIN citas_medicas.doctors d ON a.doctor_id = d.id
WHERE a.status = 'confirmed'
LIMIT 2;

-- Insertar algunas confirmaciones pendientes
INSERT INTO citas_medicas.notifications (appointment_id, user_id, message, type, status, scheduled_at)
SELECT 
    a.id,
    a.user_id,
    '¿Confirma su asistencia a la cita programada para el ' || a.appointment_date::text || ' a las ' || a.start_time::text || ' con el ' || d.full_name || '? Responda SI para confirmar o NO para cancelar.',
    'confirmation_request',
    'pending',
    NOW() + INTERVAL '1 hour'
FROM citas_medicas.appointments a
JOIN citas_medicas.doctors d ON a.doctor_id = d.id
WHERE a.status = 'scheduled'
LIMIT 2;

-- Insertar algunas conversaciones de muestra
INSERT INTO citas_medicas.conversations (user_id, message, direction, intent, created_at)
SELECT 
    id,
    'Hola, necesito agendar una cita con el cardiólogo',
    'inbound',
    'scheduling',
    NOW() - INTERVAL '3 days'
FROM citas_medicas.users
WHERE full_name = 'Pedro Pérez';

INSERT INTO citas_medicas.conversations (user_id, message, direction, created_at)
SELECT 
    id,
    'Por supuesto, ¿para qué fecha y hora le gustaría agendar la cita?',
    'outbound',
    NOW() - INTERVAL '3 days' + INTERVAL '5 minutes'
FROM citas_medicas.users
WHERE full_name = 'Pedro Pérez';

INSERT INTO citas_medicas.conversations (user_id, message, direction, created_at)
SELECT 
    id,
    'Para el próximo lunes en la mañana si es posible',
    'inbound',
    NOW() - INTERVAL '3 days' + INTERVAL '10 minutes'
FROM citas_medicas.users
WHERE full_name = 'Pedro Pérez';

INSERT INTO citas_medicas.conversations (user_id, message, direction, created_at)
SELECT 
    id,
    'Su cita ha sido agendada para el próximo lunes a las 9:00 AM con el Dr. Juan Martínez. Por favor, llegue 15 minutos antes.',
    'outbound',
    NOW() - INTERVAL '3 days' + INTERVAL '15 minutes'
FROM citas_medicas.users
WHERE full_name = 'Pedro Pérez';

-- Insertar algunos contextos de conversación
INSERT INTO citas_medicas.conversation_contexts (user_id, context_type, context_data, active, expired_at)
SELECT 
    id,
    'scheduling',
    '{"specialty": "dermatología", "preferred_date": "next_week", "pending_info": ["specific_time"]}',
    TRUE,
    NOW() + INTERVAL '30 minutes'
FROM citas_medicas.users
WHERE full_name = 'Valeria López';

INSERT INTO citas_medicas.conversation_contexts (user_id, context_type, context_data, active, expired_at)
SELECT 
    id,
    'rescheduling',
    '{"appointment_id": "' || (SELECT id FROM citas_medicas.appointments LIMIT 1) || '", "reason": "trabajo", "pending_action": "select_new_slot"}',
    TRUE,
    NOW() + INTERVAL '30 minutes'
FROM citas_medicas.users
WHERE full_name = 'Miguel Torres';

-- Insertar algunos eventos de auditoría
INSERT INTO citas_medicas.audit_logs (action, entity_type, entity_id, admin_id, old_value, new_value, ip_address)
VALUES 
(
    'create',
    'appointment',
    (SELECT id FROM citas_medicas.appointments LIMIT 1),
    (SELECT id FROM citas_medicas.admin_users WHERE username = 'recepcion'),
    NULL,
    (SELECT json_build_object(
        'user_id', user_id,
        'doctor_id', doctor_id,
        'appointment_date', appointment_date,
        'start_time', start_time,
        'status', status
    ) FROM citas_medicas.appointments LIMIT 1),
    '192.168.1.100'
),
(
    'update',
    'doctor',
    (SELECT id FROM citas_medicas.doctors WHERE full_name = 'Dr. Juan Martínez'),
    (SELECT id FROM citas_medicas.admin_users WHERE username = 'admin'),
    '{"max_appointments_per_day": 10}',
    '{"max_appointments_per_day": 15}',
    '192.168.1.101'
);

-- Insertar algunos reportes
INSERT INTO citas_medicas.reports (report_type, report_name, parameters, result_data, generated_by)
VALUES 
(
    'monthly',
    'Reporte Mensual de Citas - Abril 2025',
    '{"month": 4, "year": 2025}',
    '{
        "total_appointments": 135,
        "completed": 98,
        "cancelled": 12,
        "no_show": 25,
        "by_specialty": {
            "Cardiología": 32,
            "Dermatología": 25,
            "Pediatría": 41,
            "Oftalmología": 18,
            "Neurología": 19
        }
    }',
    (SELECT id FROM citas_medicas.admin_users WHERE username = 'admin')
),
(
    'weekly',
    'Reporte Semanal de Citas - Semana 14, 2025',
    '{"week": 14, "year": 2025}',
    '{
        "total_appointments": 38,
        "completed": 28,
        "cancelled": 5,
        "no_show": 5,
        "by_doctor": {
            "Dr. Juan Martínez": 8,
            "Dra. Ana López": 6,
            "Dr. Carlos Ramírez": 12,
            "Dra. María Gómez": 5,
            "Dr. Roberto Sánchez": 7
        }
    }',
    (SELECT id FROM citas_medicas.admin_users WHERE username = 'admin')
);
