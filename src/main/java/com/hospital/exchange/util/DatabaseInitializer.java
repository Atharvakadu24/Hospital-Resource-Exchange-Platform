package com.hospital.exchange.util;

import java.sql.*;
import java.time.LocalDateTime;

public class DatabaseInitializer {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/";
    private static final String DB_NAME = "hospital_exchange";
    private static final String USER = "root";
    private static final String PASS = "Psgm@2007";
    private static final String CONNECTION_PARAMS = "?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC";

    public static void main(String[] args) {
        try {
            // 1. Connect to MySQL server
            try (Connection conn = DriverManager.getConnection(DB_URL + CONNECTION_PARAMS, USER, PASS);
                 Statement stmt = conn.createStatement()) {
                stmt.executeUpdate("CREATE DATABASE IF NOT EXISTS " + DB_NAME);
                System.out.println("Connected to MySQL server and ensured database exists.");
            }

            // 2. Connect to the specific database
            try (Connection conn = DriverManager.getConnection(DB_URL + DB_NAME + CONNECTION_PARAMS, USER, PASS)) {
                System.out.println("Switched to database: " + DB_NAME);

                // 3. Create Tables
                createTables(conn);
                System.out.println("Tables created successfully.");

                // 4. Insert Sample Data
                insertSampleData(conn);
                System.out.println("Sample data inserted successfully.");
            }

        } catch (SQLException e) {
            System.err.println("Database Initializer Error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static void createTables(Connection conn) throws SQLException {
        try (Statement stmt = conn.createStatement()) {
            // Drop in reverse order of FKs
            stmt.executeUpdate("SET FOREIGN_KEY_CHECKS = 0");
            stmt.executeUpdate("DROP TABLE IF EXISTS audit_logs");
            stmt.executeUpdate("DROP TABLE IF EXISTS bookings");
            stmt.executeUpdate("DROP TABLE IF EXISTS allocations"); // Old name
            stmt.executeUpdate("DROP TABLE IF EXISTS allocation_requests");
            stmt.executeUpdate("DROP TABLE IF EXISTS requests"); // Old name
            stmt.executeUpdate("DROP TABLE IF EXISTS resource_slots");
            stmt.executeUpdate("DROP TABLE IF EXISTS resources");
            stmt.executeUpdate("DROP TABLE IF EXISTS users_roles");
            stmt.executeUpdate("DROP TABLE IF EXISTS roles");
            stmt.executeUpdate("DROP TABLE IF EXISTS users");
            stmt.executeUpdate("DROP TABLE IF EXISTS hospitals");
            stmt.executeUpdate("SET FOREIGN_KEY_CHECKS = 1");

            // Hospitals
            stmt.executeUpdate("CREATE TABLE hospitals (" +
                    "id BIGINT AUTO_INCREMENT PRIMARY KEY," +
                    "name VARCHAR(255) NOT NULL UNIQUE," +
                    "location VARCHAR(255) NOT NULL," +
                    "contact_number VARCHAR(20) NOT NULL," +
                    "contact_email VARCHAR(100) NOT NULL," +
                    "resource_quota INT NOT NULL DEFAULT 10," +
                    "latitude DOUBLE NOT NULL," +
                    "longitude DOUBLE NOT NULL," +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                    "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP," +
                    "INDEX idx_hosp_location (latitude, longitude)" +
                    ")");

            // Users
            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS users (" +
                    "id BIGINT AUTO_INCREMENT PRIMARY KEY," +
                    "username VARCHAR(100) NOT NULL UNIQUE," +
                    "password VARCHAR(255) NOT NULL," +
                    "enabled BOOLEAN NOT NULL DEFAULT TRUE," +
                    "hospital_id BIGINT," +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                    "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP," +
                    "FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE SET NULL" +
                    ")");

            // Roles
            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS roles (" +
                    "id BIGINT AUTO_INCREMENT PRIMARY KEY," +
                    "name VARCHAR(50) NOT NULL UNIQUE" +
                    ")");

            // Users-Roles Mapping (Many-to-Many)
            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS users_roles (" +
                    "user_id BIGINT NOT NULL," +
                    "role_id BIGINT NOT NULL," +
                    "PRIMARY KEY (user_id, role_id)," +
                    "FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE," +
                    "FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE" +
                    ")");

            // Resources
            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS resources (" +
                    "id BIGINT AUTO_INCREMENT PRIMARY KEY," +
                    "resource_name VARCHAR(255) NOT NULL," +
                    "type VARCHAR(50) NOT NULL," +
                    "status VARCHAR(50) NOT NULL DEFAULT 'AVAILABLE'," +
                    "hospital_id BIGINT NOT NULL," +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                    "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP," +
                    "FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE," +
                    "INDEX idx_res_hosp (hospital_id)," +
                    "INDEX idx_res_status (status)" +
                    ")");

            // Resource Slots (for time-based availability)
            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS resource_slots (" +
                    "id BIGINT AUTO_INCREMENT PRIMARY KEY," +
                    "resource_id BIGINT NOT NULL," +
                    "start_time DATETIME NOT NULL," +
                    "end_time DATETIME NOT NULL," +
                    "booking_status VARCHAR(50) DEFAULT 'OPEN'," +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                    "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP," +
                    "FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE CASCADE," +
                    "INDEX idx_slot_res_time (resource_id, start_time, end_time)" +
                    ")");

            // Allocation Requests (Renamed from requests)
            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS allocation_requests (" +
                    "id BIGINT AUTO_INCREMENT PRIMARY KEY," +
                    "requester_hospital_id BIGINT NOT NULL," +
                    "resource_type VARCHAR(50) NOT NULL," +
                    "priority VARCHAR(50) NOT NULL," +
                    "status VARCHAR(50) NOT NULL DEFAULT 'PENDING'," +
                    "requested_at DATETIME NOT NULL," +
                    "start_time DATETIME NOT NULL," +
                    "end_time DATETIME NOT NULL," +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                    "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP," +
                    "FOREIGN KEY (requester_hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE," +
                    "INDEX idx_req_status (status)," +
                    "INDEX idx_req_hosp_priority (requester_hospital_id, priority)" +
                    ")");

            // Bookings (Renamed from allocations)
            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS bookings (" +
                    "id BIGINT AUTO_INCREMENT PRIMARY KEY," +
                    "request_id BIGINT NOT NULL UNIQUE," +
                    "resource_id BIGINT NOT NULL," +
                    "confirmed_at DATETIME NOT NULL," +
                    "release_at DATETIME NOT NULL," +
                    "released BOOLEAN NOT NULL DEFAULT FALSE," +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                    "FOREIGN KEY (request_id) REFERENCES allocation_requests(id) ON DELETE CASCADE," +
                    "FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE CASCADE," +
                    "INDEX idx_booking_resource (resource_id)," +
                    "INDEX idx_booking_release (release_at, released)" +
                    ")");

            // Audit Logs
            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS audit_logs (" +
                    "id BIGINT AUTO_INCREMENT PRIMARY KEY," +
                    "action VARCHAR(255) NOT NULL," +
                    "details TEXT," +
                    "performed_by VARCHAR(100) NOT NULL," +
                    "hospital_id BIGINT," +
                    "timestamp DATETIME NOT NULL," +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                    "FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE," +
                    "INDEX idx_log_hosp_time (hospital_id, timestamp)" +
                    ")");
        }
    }

    private static void insertSampleData(Connection conn) throws SQLException {
        // Clear existing data to avoid PK conflicts during re-init
        try (Statement stmt = conn.createStatement()) {
            stmt.executeUpdate("SET FOREIGN_KEY_CHECKS = 0");
            stmt.executeUpdate("TRUNCATE TABLE users_roles");
            stmt.executeUpdate("TRUNCATE TABLE users");
            stmt.executeUpdate("TRUNCATE TABLE roles");
            stmt.executeUpdate("TRUNCATE TABLE bookings");
            stmt.executeUpdate("TRUNCATE TABLE allocation_requests");
            stmt.executeUpdate("TRUNCATE TABLE resource_slots");
            stmt.executeUpdate("TRUNCATE TABLE resources");
            stmt.executeUpdate("TRUNCATE TABLE hospitals");
            stmt.executeUpdate("SET FOREIGN_KEY_CHECKS = 1");
        }

        // Insert Hospitals
        String hospSql = "INSERT INTO hospitals (name, location, contact_number, contact_email, resource_quota, latitude, longitude) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(hospSql, Statement.RETURN_GENERATED_KEYS)) {
            Object[][] hospitals = {
                {"AIIMS Delhi", "Ansari Nagar, New Delhi", "+91-11-26588500", "admin@aiims.edu", 50, 18.5314, 73.8446},
                {"Apollo Chennai", "Greams Road, Chennai", "+91-44-28293333", "reachus@apollo.com", 40, 18.5204, 73.8567},
                {"Max Super Speciality Mumbai", "Saket, Mumbai", "+91-22-66487500", "info@maxhealthcare.com", 35, 18.5089, 73.8259},
                {"Fortis Bangalore", "Bannerghatta Road, Bangalore", "+91-80-66214444", "contactus.bgroad@fortishealthcare.com", 30, 18.5645, 73.7769},
                {"Tata Memorial Hospital", "Parel, Mumbai", "+91-22-24177000", "tmcc@tmc.gov.in", 45, 18.4947, 73.8567}
            };
            for (Object[] h : hospitals) {
                pstmt.setString(1, (String) h[0]);
                pstmt.setString(2, (String) h[1]);
                pstmt.setString(3, (String) h[2]);
                pstmt.setString(4, (String) h[3]);
                pstmt.setInt(5, (Integer) h[4]);
                pstmt.setDouble(6, (Double) h[5]);
                pstmt.setDouble(7, (Double) h[6]);
                pstmt.executeUpdate();
            }
        }

        // Insert Resources
        String resSql = "INSERT INTO resources (resource_name, type, status, hospital_id) VALUES (?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(resSql)) {
            Object[][] resources = {
                {"ICU Bed-A101", "ICU_BED", "AVAILABLE", 1},
                {"ICU Bed-A102", "ICU_BED", "IN_USE", 1},
                {"Ventilator-V01", "VENTILATOR", "AVAILABLE", 1},
                {"Ambulance-DL01", "AMBULANCE", "AVAILABLE", 2},
                {"ICU Bed-C201", "ICU_BED", "AVAILABLE", 2},
                {"Ventilator-V99", "VENTILATOR", "MAINTENANCE", 3},
                {"ICU Bed-M301", "ICU_BED", "AVAILABLE", 3},
                {"Specialist-Oncologist-1", "SPECIALIST", "AVAILABLE", 5},
                {"ICU Bed-B401", "ICU_BED", "AVAILABLE", 4},
                {"ICU Bed-T501", "ICU_BED", "IN_USE", 5}
            };
            for (Object[] r : resources) {
                pstmt.setString(1, (String) r[0]);
                pstmt.setString(2, (String) r[1]);
                pstmt.setString(3, (String) r[2]);
                // Robust casting for IDs
                Number hospId = (Number) r[3];
                pstmt.setLong(4, hospId.longValue());
                pstmt.executeUpdate();
            }
        }

        // Insert Default Roles
        try (Statement stmt = conn.createStatement()) {
            stmt.executeUpdate("INSERT INTO roles (id, name) VALUES (1, 'ADMIN'), (2, 'HOSPITAL_ADMIN')");
        }

        // Insert Default Admin User (username: admin, password: admin123)
        String userSql = "INSERT INTO users (id, username, password, enabled, hospital_id) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(userSql)) {
            pstmt.setLong(1, 1);
            pstmt.setString(2, "admin");
            // Verified hash for 'admin123'
            pstmt.setString(3, "$2a$10$2.XruWKf0o5QlGlWzuWVzujP4pXIozdvAYBKcyIPm8bbLvR49Ag3K");
            pstmt.setBoolean(4, true);
            pstmt.setNull(5, Types.BIGINT);
            pstmt.executeUpdate();
            
            // Map to Role ADMIN (id 1)
            try (Statement roleStmt = conn.createStatement()) {
                roleStmt.executeUpdate("INSERT INTO users_roles (user_id, role_id) VALUES (1, 1)");
            }
        }

        // Insert Hospital-specific Admins for demo
        for (int i = 1; i <= 5; i++) {
            try (PreparedStatement pstmt = conn.prepareStatement(userSql)) {
                pstmt.setLong(1, 10 + i);
                pstmt.setString(2, "hosp" + i);
                pstmt.setString(3, "$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xd00DMxs.TVuHOnC"); // admin123
                pstmt.setBoolean(4, true);
                pstmt.setLong(5, i);
                pstmt.executeUpdate();

                try (Statement roleStmt = conn.createStatement()) {
                    roleStmt.executeUpdate("INSERT INTO users_roles (user_id, role_id) VALUES (" + (10 + i) + ", 2)");
                }
            }
        }
    }
}
