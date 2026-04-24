-- Minimum seed data reference for Hospital Resource Exchange Platform
-- Use this file as the baseline dataset required for a fresh environment.

INSERT INTO hospitals (name, location, contact_number, contact_email, resource_quota, latitude, longitude) VALUES
('AIIMS Delhi', 'Ansari Nagar, New Delhi', '+91-11-26588500', 'admin@aiims.edu', 50, 28.5672, 77.2100),
('Apollo Chennai', 'Greams Road, Chennai', '+91-44-28293333', 'reachus@apollo.com', 40, 13.0635, 80.2520),
('Max Mumbai', 'Andheri, Mumbai', '+91-22-66487500', 'info@maxhealthcare.com', 35, 19.1197, 72.8468),
('Fortis Bangalore', 'Bannerghatta Road, Bangalore', '+91-80-66214444', 'contact@fortis.com', 30, 12.8954, 77.5992),
('Tata Memorial', 'Parel, Mumbai', '+91-22-24177000', 'tmh@tmc.gov.in', 45, 18.9977, 72.8413);

INSERT INTO resources (resource_name, type, status, hospital_id) VALUES
('ICU Bed-A101', 'ICU_BED', 'AVAILABLE', 1),
('Ventilator-V01', 'VENTILATOR', 'AVAILABLE', 1),
('Ambulance-DL01', 'AMBULANCE', 'AVAILABLE', 1),
('ICU Bed-C201', 'ICU_BED', 'AVAILABLE', 2),
('Ventilator-C11', 'VENTILATOR', 'AVAILABLE', 2),
('ICU Bed-M301', 'ICU_BED', 'AVAILABLE', 3),
('Specialist-Oncologist-1', 'SPECIALIST', 'AVAILABLE', 3),
('Ambulance-B401', 'AMBULANCE', 'AVAILABLE', 4),
('Ventilator-B17', 'VENTILATOR', 'MAINTENANCE', 4),
('ICU Bed-T501', 'ICU_BED', 'AVAILABLE', 5);

-- Demo credentials expected by the application:
-- admin / admin123
-- hosp1 / hosp123
-- hosp2 / hosp123
-- hosp3 / hosp123
-- hosp4 / hosp123
-- hosp5 / hosp123
