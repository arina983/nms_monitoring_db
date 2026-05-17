-- Список всех активных устройств
SELECT hostname, ip_address, status, last_seen
FROM devices
WHERE status = 'active'
ORDER BY hostname;

-- Устройства, находящиеся в неисправном состоянии
SELECT hostname, ip_address, status, last_seen
FROM devices
WHERE status = 'fault'
ORDER BY last_seen DESC;

-- Открытые инциденты 
SELECT title, severity, status, created_at
FROM incidents
WHERE status = 'open'
ORDER BY severity DESC, created_at DESC;

-- Интерфейсы, которые сейчас не работают
SELECT d.hostname,
    ni.interface_name,
    ni.status
FROM network_interfaces ni
    JOIN devices d ON ni.device_id = d.id
WHERE ni.status = 'down';

-- Устройства с критическими инцидентами
SELECT d.hostname,
    d.ip_address,
    l.name AS location_name,
    i.title,
    i.severity,
    i.created_at
FROM devices d
    JOIN incidents i ON d.id = i.device_id
    JOIN locations l ON d.location_id = l.id
WHERE i.severity = 'critical'
ORDER BY i.created_at DESC;

-- Устройства с информацией о производителе 
SELECT d.hostname,
    d.ip_address,
    COALESCE(v.name, 'Не указан') AS vendor,
    d.status
FROM devices d
    LEFT JOIN vendors v ON d.vendor_id = v.id
ORDER BY d.hostname;

-- Типы устройств в системе
SELECT dt.name AS device_type,
    COUNT(d.id) AS device_count
FROM device_types dt
    LEFT JOIN devices d ON dt.id = d.device_type_id
GROUP BY dt.name
ORDER BY device_count DESC;

-- Статистика интерфейсов по статусам
SELECT status,
    COUNT(*) AS count
FROM network_interfaces
GROUP BY status;

-- Количество устройств по производителям
SELECT v.name AS vendor,
    COUNT(d.id) AS device_count
FROM vendors v
    LEFT JOIN devices d ON v.id = d.vendor_id
GROUP BY v.name
ORDER BY device_count DESC;

-- Производители с большим количеством устройств 
SELECT v.name AS vendor,
    COUNT(d.id) AS device_count
FROM vendors v
    JOIN devices d ON v.id = d.vendor_id
GROUP BY v.name
HAVING COUNT(d.id) >= 2
ORDER BY device_count DESC;

-- Статистика устройств по статусам 
SELECT status,
    COUNT(*) AS device_count
FROM devices
GROUP BY status
HAVING COUNT(*) > 1
ORDER BY device_count DESC;

-- Локации с неисправными устройствами 
SELECT name AS location_name, city
FROM locations
WHERE id IN (
        SELECT location_id
        FROM devices
        WHERE status = 'fault'
    );

-- Средняя загрузка CPU по устройствам
SELECT d.hostname,
    AVG(m.value) AS avg_cpu,
    COUNT(m.id) AS metric_count
FROM devices d
    JOIN metrics m ON d.id = m.device_id
WHERE m.metric_type = 'cpu_usage'
GROUP BY d.hostname
ORDER BY avg_cpu DESC;

-- Топ устройств по количеству метрик
SELECT d.hostname,
    COUNT(m.id) AS metrics_count
FROM devices d
    JOIN metrics m ON d.id = m.device_id
GROUP BY d.hostname
ORDER BY metrics_count DESC
LIMIT 5;

-- Последние 10 собранных метрик
SELECT d.hostname,
    m.metric_type,
    m.value,
    m.collected_at
FROM metrics m
    JOIN devices d ON m.device_id = d.id
ORDER BY m.collected_at DESC
LIMIT 10;

-- Количество инцидентов по критичности
SELECT severity,
    COUNT(*) AS incident_count
FROM incidents
GROUP BY severity
ORDER BY incident_count DESC;

-- устройства с количеством собранных метрик
WITH device_metrics AS (
    SELECT device_id,
        COUNT(*) AS metrics_count
    FROM metrics
    GROUP BY device_id
)
SELECT d.hostname,
    d.ip_address,
    COALESCE(dm.metrics_count, 0) AS metrics_count
FROM devices d
    LEFT JOIN device_metrics dm ON d.id = dm.device_id
ORDER BY metrics_count DESC;

-- Общее количество устройств по локациям
SELECT l.name AS location,
    COUNT(d.id) AS device_count
FROM locations l
    LEFT JOIN devices d ON l.id = d.location_id
GROUP BY l.name
ORDER BY device_count DESC;

-- Динамика инцидентов по дням 
SELECT DATE(created_at) AS incident_date,
    COUNT(*) AS incidents_per_day,
    COUNT(
        CASE
            WHEN severity = 'critical' THEN 1
        END
    ) AS critical_count
FROM incidents
GROUP BY DATE(created_at)
ORDER BY incident_date DESC;

-- Устройства с наибольшим количеством интерфейсов
SELECT d.hostname,
    COUNT(ni.id) AS interfaces_count
FROM devices d
    JOIN network_interfaces ni ON d.id = ni.device_id
GROUP BY d.hostname
ORDER BY interfaces_count DESC
LIMIT 5;