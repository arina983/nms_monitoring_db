-- Локации
CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Типы устройств
CREATE TABLE device_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- Производители
CREATE TABLE vendors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- Устройства 
CREATE TABLE devices (
    id SERIAL PRIMARY KEY,
    hostname VARCHAR(100) NOT NULL UNIQUE,
    ip_address INET NOT NULL UNIQUE,
    location_id INTEGER REFERENCES locations(id) ON DELETE SET NULL,
    device_type_id INTEGER NOT NULL REFERENCES device_types(id),
    vendor_id INTEGER REFERENCES vendors(id),
    network_type VARCHAR(20) DEFAULT 'lte' CHECK (
        network_type IN ('lte', 'lte-a', 'wired', 'hybrid')),
    technology VARCHAR(30) DEFAULT 'LTE',
    cell_id VARCHAR(50),
    pci INTEGER,
    signal_strength INTEGER,
        status VARCHAR(20) DEFAULT 'active' CHECK (
            status IN ('active', 'inactive', 'maintenance', 'fault')
        ),
    last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Сетевые интерфейсы
CREATE TABLE network_interfaces (
    id SERIAL PRIMARY KEY,
    device_id INTEGER NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    interface_name VARCHAR(30) NOT NULL,
    status VARCHAR(10) DEFAULT 'up' CHECK (status IN ('up', 'down')),
    UNIQUE(device_id, interface_name)
);

-- Метрики мониторинга
CREATE TABLE metrics (
    id SERIAL PRIMARY KEY,
    device_id INTEGER NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    metric_type VARCHAR(50) NOT NULL,
    value NUMERIC(10, 2) NOT NULL CHECK (value >= 0),
    collected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Инциденты
CREATE TABLE incidents (
    id SERIAL PRIMARY KEY,
    device_id INTEGER REFERENCES devices(id) ON DELETE SET NULL,
        title VARCHAR(150) NOT NULL,
        severity VARCHAR(20) NOT NULL CHECK (
            severity IN ('critical', 'high', 'medium', 'low')
        ),
        status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'resolved')),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        resolved_at TIMESTAMP
);


CREATE INDEX idx_devices_status ON devices(status);
CREATE INDEX idx_devices_hostname ON devices(hostname);
CREATE INDEX idx_metrics_device ON metrics(device_id, collected_at);
CREATE INDEX idx_incidents_device ON incidents(device_id, status);
CREATE INDEX idx_devices_cell_id ON devices(cell_id);
CREATE INDEX idx_devices_pci ON devices(pci);