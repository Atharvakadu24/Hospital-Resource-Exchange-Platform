-- Create Database
CREATE DATABASE IF NOT EXISTS hospital_exchange;
USE hospital_exchange;

-- Hospitals Table
CREATE TABLE IF NOT EXISTS hospitals (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    location VARCHAR(255) NOT NULL,
    contact_number VARCHAR(20) NOT NULL,
    contact_email VARCHAR(100) NOT NULL,
    resource_quota INT NOT NULL DEFAULT 10,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    hospital_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE SET NULL
);

-- Resources Table
CREATE TABLE IF NOT EXISTS resources (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    resource_name VARCHAR(255) NOT NULL,
    type ENUM('ICU_BED', 'VENTILATOR', 'AMBULANCE', 'SPECIALIST') NOT NULL,
    status ENUM('AVAILABLE', 'RESERVED', 'IN_USE', 'MAINTENANCE') NOT NULL DEFAULT 'AVAILABLE',
    hospital_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE,
    INDEX idx_res_hosp (hospital_id),
    INDEX idx_res_status (status)
);

-- Resource Slots Table
CREATE TABLE IF NOT EXISTS resource_slots (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    resource_id BIGINT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    booking_status ENUM('OPEN', 'BOOKED', 'BLOCKED') DEFAULT 'OPEN',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE CASCADE,
    INDEX idx_slot_res (resource_id)
);

-- Requests Table
CREATE TABLE IF NOT EXISTS requests (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    requester_hospital_id BIGINT NOT NULL,
    resource_type ENUM('ICU_BED', 'VENTILATOR', 'AMBULANCE', 'SPECIALIST') NOT NULL,
    priority ENUM('EMERGENCY', 'HIGH', 'NORMAL') NOT NULL,
    status ENUM('PENDING', 'APPROVED', 'REJECTED', 'COMPLETED') NOT NULL DEFAULT 'PENDING',
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (requester_hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE,
    INDEX idx_req_hosp (requester_hospital_id),
    INDEX idx_req_status (status)
);

-- Allocations Table
CREATE TABLE IF NOT EXISTS allocations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    request_id BIGINT NOT NULL,
    resource_id BIGINT NOT NULL,
    hospital_id BIGINT NOT NULL,
    allocated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (request_id) REFERENCES requests(id) ON DELETE CASCADE,
    FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE CASCADE,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE
);

-- Audit Logs Table
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    action VARCHAR(255) NOT NULL,
    details TEXT,
    performed_by VARCHAR(100) NOT NULL,
    hospital_id BIGINT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE
);

-- INSERT SAMPLE DATA --
INSERT IGNORE INTO hospitals (name, location, contact_number, contact_email, resource_quota) VALUES 
('AIIMS Delhi', 'Ansari Nagar, New Delhi', '+91-11-26588500', 'admin@aiims.edu', 50),
('Apollo Chennai', 'Greams Road, Chennai', '+91-44-28293333', 'reachus@apollo.com', 40),
('Max Super Speciality Mumbai', 'Saket, Mumbai', '+91-22-66487500', 'info@maxhealthcare.com', 35),
('Fortis Bangalore', 'Bannerghatta Road, Bangalore', '+91-80-66214444', 'contactus.bgroad@fortishealthcare.com', 30),
('Tata Memorial Hospital', 'Parel, Mumbai', '+91-22-24177000', 'tmcc@tmc.gov.in', 45);

INSERT INTO resources (resource_name, type, status, hospital_id) VALUES 
('ICU Bed-A101', 'ICU_BED', 'AVAILABLE', 1),
('ICU Bed-A102', 'ICU_BED', 'IN_USE', 1),
('Ventilator-V01', 'VENTILATOR', 'AVAILABLE', 1),
('Ambulance-DL01', 'AMBULANCE', 'AVAILABLE', 2),
('ICU Bed-C201', 'ICU_BED', 'AVAILABLE', 2),
('Ventilator-V99', 'VENTILATOR', 'MAINTENANCE', 3),
('ICU Bed-M301', 'ICU_BED', 'AVAILABLE', 3),
('Specialist-Oncologist-1', 'SPECIALIST', 'AVAILABLE', 5),
('ICU Bed-B401', 'ICU_BED', 'AVAILABLE', 4),
('ICU Bed-T501', 'ICU_BED', 'IN_USE', 5);

INSERT INTO requests (requester_hospital_id, resource_type, priority, status, start_time, end_time) VALUES 
(4, 'VENTILATOR', 'EMERGENCY', 'PENDING', NOW(), DATE_ADD(NOW(), INTERVAL 2 HOUR)),
(2, 'ICU_BED', 'HIGH', 'APPROVED', NOW(), DATE_ADD(NOW(), INTERVAL 2 HOUR));
