SELECT *
FROM devices;
--
--
SELECT *
FROM locations;
--
--
SELECT *
FROM device_types;
--
--
SELECT *
FROM vendors;
--
--
SELECT *
FROM network_interfaces;
--
--
SELECT *
FROM incidents;
SELECT hostname,
    ip_address,
    status,
    last_seen
FROM devices
WHERE status = 'fault';
--
--
SELECT id,
    device_id,
    title
FROM incidents
WHERE status = 'open';
--
--
SELECT *
FROM devices
WHERE status = 'active';
--
--
SELECT id,
    device_id,
    status
FROM network_interfaces
WHERE status = 'down';
--
--
SELECT devices.hostname,
    devices.ip_address,
    locations.name,
    devices.status,
    incidents.title,
    incidents.severity,
    incidents.created_at
FROM devices
    JOIN incidents ON devices.id = incidents.device_id
    JOIN locations ON devices.location_id = locations.id
WHERE incidents.severity = 'critical';
--
--
SELECT d.hostname,
    d.ip_address,
    v.name AS vendor,
    d.status
FROM devices d
    LEFT JOIN vendors v ON d.vendor_id = v.id;
--
--
SELECT d.hostname,
    dt.name AS device_type
FROM devices d
    JOIN device_types dt ON d.device_type_id = dt.id;
--
--
SELECT d.hostname,
    ni.interface_name,
    ni.status
FROM devices d
    JOIN network_interfaces ni ON d.id = ni.device_id;
--
--
SELECT status,
    COUNT(*) AS interface_count
FROM network_interfaces
GROUP BY status;
--
--
SELECT vendor_id,
    COUNT(*) AS device_count
FROM devices
WHERE vendor_id IS NOT NULL
GROUP BY vendor_id;
--
--
SELECT vendor_id,
    COUNT(*) AS device_count
FROM devices
WHERE vendor_id IS NOT NULL
GROUP BY vendor_id
HAVING COUNT(*) > 2;
--
--
SELECT status,
    COUNT(*) AS device_count
FROM devices
GROUP BY status
HAVING COUNT(*) > 3;
--
--
SELECT l.name,
    l.city
FROM locations l
WHERE l.id IN (
        SELECT d.location_id
        FROM devices d
        WHERE d.status = 'fault'
    );
--
--
SELECT d.hostname,
    d.ip_address
FROM devices d
WHERE d.id IN (
        SELECT i.device_id
        FROM incidents i
        WHERE i.severity = 'critical'
    );
--
--
SELECT title,
    severity,
    created_at,
    device_id
FROM incidents
ORDER BY created_at DESC
LIMIT 3;
--
--
SELECT hostname,
    ip_address,
    created_at
FROM devices
ORDER BY created_at DESC
LIMIT 5;