
-- Локации
INSERT INTO locations (name, city, address) VALUES
('ЦОД Новосибирск', 'Новосибирск', 'ул. Инженерная, 15'),
('Узел связи №1', 'Новосибирск', 'ул. Красный проспект, 87'),
('ЦОД Москва', 'Москва', 'ул. Большая Ордынка, 42'),
('Узел связи Бердск', 'Бердск', 'промзона, корпус 3'),
('Офис СибГУТИ', 'Новосибирск', 'ул. Кирова, 86'),
('Академгородок', 'Новосибирск', 'ул. Лаврентьева, 12'),
('ЦОД Екатеринбург', 'Екатеринбург', 'ул. Малышева, 145'),
('Узел связи Томск', 'Томск', 'ул. Вершинина, 74');

-- Типы устройств
INSERT INTO device_types (name) VALUES
('eNodeB'), ('Router'), ('Switch'), ('Firewall'), 
('Server'), ('Access Point'), ('MME'), ('SGW'), ('PGW');

-- Производители
INSERT INTO vendors (name) VALUES
('Huawei'), ('Ericsson'), ('Nokia'), ('Cisco'), 
('ZTE'), ('Samsung'), ('Juniper'), ('MikroTik');

-- Устройства 
INSERT INTO devices 
    (hostname, ip_address, location_id, device_type_id, vendor_id, 
     network_type, technology, cell_id, pci, signal_strength, status) 
VALUES
('enodeb-nsk-01', '192.168.25.10', 1, 1, 1, 'lte', 'LTE', 'LTE-00001', 101, -68, 'active'),
('enodeb-nsk-02', '192.168.25.11', 1, 1, 2, 'lte', 'LTE', 'LTE-00002', 245, -72, 'active'),
('enodeb-berdsk-01', '192.168.26.1', 4, 1, 3, 'lte', 'LTE', 'LTE-00003', 67, -59, 'active'),
('enodeb-tmsk-01', '192.168.40.10', 8, 1, 1, 'lte', 'LTE', 'LTE-00004', 189, -81, 'active'),
('enodeb-ekb-01', '10.20.30.10', 7, 1, 5, 'lte', 'LTE', 'LTE-00005', 312, -65, 'active'),
('router-nsk-core', '192.168.10.1', 1, 2, 4, 'wired', 'LTE', NULL, NULL, NULL, 'active'),
('switch-nsk-01', '192.168.10.10', 1, 3, 1, 'wired', 'LTE', NULL, NULL, NULL, 'active'),
('ap-nsk-office', '192.168.15.50', 5, 6, 8, 'wired', 'WiFi', NULL, NULL, -45, 'active'),
('fw-nsk-01', '192.168.10.5', 1, 4, 2, 'wired', 'LTE', NULL, NULL, NULL, 'active'),
('mme-nsk-01', '192.168.30.1', 1, 7, 3, 'lte', 'LTE', NULL, NULL, NULL, 'active');

-- Сетевые интерфейсы
INSERT INTO network_interfaces (device_id, interface_name, status)
SELECT id, 'eth0', 'up' FROM devices 
UNION ALL
SELECT id, 'radio0', 'up' FROM devices WHERE device_type_id = 1;

-- Метрики
INSERT INTO metrics (device_id, metric_type, value, collected_at)
SELECT d.id, m.metric_type, m.value, NOW() - (random()*INTERVAL '48 hours')
FROM devices d
CROSS JOIN (
    VALUES 
        ('cpu_usage', 45.6),
        ('memory_percent', 72.3),
        ('traffic_in_mbps', 1240.5),
        ('rsrp', -78.4),
        ('rsrq', -11.2),
        ('sinr', 18.7),
        ('connected_users', 245)
) m(metric_type, value)
LIMIT 50;

-- Инциденты
INSERT INTO incidents (device_id, title, severity, status, created_at) VALUES
(1, 'Низкий уровень сигнала RSRP', 'high', 'open', NOW() - INTERVAL '45 min'),
(2, 'Перегрузка PRB на eNodeB', 'critical', 'open', NOW() - INTERVAL '2 hours'),
(3, 'Падение eNodeB', 'critical', 'resolved', NOW() - INTERVAL '1 day'),
(4, 'Высокая загрузка CPU', 'medium', 'open', NOW() - INTERVAL '3 hours'),
(6, 'Проблема с S1-интерфейсом', 'high', 'open', NOW() - INTERVAL '1 hour');

SELECT 
    'locations' as table_name, COUNT(*) as row_count FROM locations UNION ALL
SELECT 'device_types', COUNT(*) FROM device_types UNION ALL
SELECT 'vendors', COUNT(*) FROM vendors UNION ALL
SELECT 'devices', COUNT(*) FROM devices UNION ALL
SELECT 'network_interfaces', COUNT(*) FROM network_interfaces UNION ALL
SELECT 'metrics', COUNT(*) FROM metrics UNION ALL
SELECT 'incidents', COUNT(*) FROM incidents
ORDER BY row_count DESC;