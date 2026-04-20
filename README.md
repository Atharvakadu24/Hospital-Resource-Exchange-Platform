# 🏥 Exchange.Med — Hospital Resource Exchange Platform

**Exchange.Med** is a high-availability, real-time resource management and allocation platform designed for hospital networks. It enables seamless sharing of critical medical assets like ICU beds, ventilators, and ambulances using advanced priority-based allocation and deadlock prevention algorithms.

---

## 🚀 Key Features

*   **📍 Live Network Map**: Interactive Pune-centered map built with Leaflet.js and OpenStreetMap. Features real-time resource tracking, demand heatmaps, and ambulance animations.
*   **⚖️ Smart Priority Allocation**: A central engine that handles incoming resource requests based on medical priority (Emergency, High, Normal) and hospital proximity.
*   **🛡️ Deadlock & Cycle Prevention**: Integrated "Wait-for" graph monitor that identifies and breaks circular dependency chains in resource sharing.
*   **📊 Network Monitor**: Real-time visualization of the global allocation queue and inter-hospital dependencies.
*   **🏢 Hospital Admin Suite**: Dedicated dashboard for hospital administrators to manage their own inventory and track outgoing requests.
*   **🔒 Security Hardened**: Spring Security implementation with Role-Based Access Control (RBAC) and hospital-level data isolation.

---

## 🛠️ Technology Stack

*   **Backend**: Java 24, Spring Boot 4.x, Spring Security 6.
*   **Database**: MySQL 8.0 (Relational schema with spatial support).
*   **Frontend**: JSP, Vanilla JS, Bootstrap 5.3, FontAwesome 6.
*   **Messaging**: WebSocket (STOMP/SockJS) for real-time network updates.
*   **Map Engine**: Leaflet.js, Leaflet Routing Machine, Leaflet Heat.

---

## 🛠️ Setup & Installation

### Prerequisites
*   Java 24+
*   Maven 3.8+
*   MySQL 8.0+

### Database Initialization
The project includes a utility to automatically provision the database schema and seed data.

```bash
# Initialize DB with spatial hospital data and demo users
mvn exec:java -Dexec.mainClass="com.hospital.exchange.util.DatabaseInitializer"
```

### Running the Application
```bash
# Start the Spring Boot application
mvn spring-boot:run
```
The application will be available at `http://localhost:8081`.

---

## 🔐 Credentials (Demo)

| Role | Username | Password |
| :--- | :--- | :--- |
| **System Admin** | `admin` | `admin123` |
| **Hospital Admin (H1)** | `hosp1` | `hosp123` |
| **Hospital Admin (H2)** | `hosp2` | `hosp123` |

---

## 📐 Architecture Overview

1.  **Safety First**: Allocation requests are strictly checked against a hospital's resource quota.
2.  **Proximity Driven**: If multiple hospitals offer a resource, the engine selects the one geographically closest to the requester using the Haversine formula.
3.  **Cyclal Detection**: Before queuing a request, the `DeadlockDetectionService` scans for circular waits. If adding a wait would create a cycle (Deadlock), the request is automatically rejected to ensure network throughput.
4.  **Real-time Push**: Any allocation or status change is instantly broadcasted to all connected clients via WebSockets.

---

## 📜 License
This project is prepared for advanced academic and research-level hospital logistics management.
