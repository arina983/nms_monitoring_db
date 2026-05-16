SELECT *
FROM devices
WHERE status = 'active';


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