<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Live Map - Exchange.Med</title>
    <meta name="description" content="Leaflet-powered live hospital network map with resource-aware routing and search.">

    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <link href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" rel="stylesheet">
    <link href="/css/main.css" rel="stylesheet">

    <style>
        * { box-sizing: border-box; }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: 'Outfit', sans-serif;
            background:
                radial-gradient(circle at top left, rgba(15, 118, 110, 0.16), transparent 32%),
                radial-gradient(circle at bottom right, rgba(99, 102, 241, 0.15), transparent 30%),
                #0b1220;
            color: #e2e8f0;
            overflow: hidden;
        }

        .map-page {
            display: grid;
            grid-template-columns: 300px minmax(320px, 360px) 1fr;
            grid-template-rows: auto 1fr;
            min-height: 100vh;
            height: 100vh;
            overflow: hidden;
        }

        .sidebar {
            grid-column: 1;
            grid-row: 1 / span 2;
            position: relative;
            width: auto;
            height: 100vh;
            background: rgba(10, 16, 31, 0.96);
            border-right: 1px solid rgba(148, 163, 184, 0.12);
            box-shadow: none;
            display: flex;
            flex-direction: column;
            z-index: 30;
        }

        .sidebar .brand {
            padding: 1.6rem 1.5rem 1.4rem;
            color: #6366f1;
            border-bottom: 1px solid rgba(148, 163, 184, 0.08);
        }

        .sidebar-nav {
            list-style: none;
            margin: 0;
            padding: 1rem;
            display: flex;
            flex-direction: column;
            gap: 0.45rem;
        }

        .sidebar-nav li {
            margin: 0;
            padding: 0;
        }

        .sidebar-nav li a {
            display: flex;
            align-items: center;
            gap: 0.8rem;
            width: 100%;
            padding: 0.92rem 1rem;
            border-radius: 16px;
            color: #a5b4fc;
            text-decoration: none;
            font-weight: 600;
            transition: background 0.18s ease, color 0.18s ease, transform 0.18s ease;
        }

        .sidebar-nav li a:hover,
        .sidebar-nav li a.active {
            background: rgba(99, 102, 241, 0.18);
            color: #eef2ff;
            transform: translateX(2px);
        }

        .sidebar-nav li a i {
            width: 20px;
            text-align: center;
        }

        .sidebar-bottom {
            margin-top: auto;
            padding: 1rem;
        }

        .sign-out-btn {
            width: 100%;
            border: 1px solid rgba(248, 113, 113, 0.12);
            border-radius: 16px;
            background: rgba(127, 29, 29, 0.18);
            color: #fca5a5;
            padding: 0.95rem 1rem;
            font-family: inherit;
            font-size: 0.95rem;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.65rem;
            cursor: pointer;
        }

        .map-topbar {
            grid-column: 2 / 4;
            display: flex;
            align-items: center;
            gap: 0.9rem;
            flex-wrap: wrap;
            padding: 1rem 1.25rem;
            background: rgba(11, 18, 32, 0.88);
            border-bottom: 1px solid rgba(148, 163, 184, 0.1);
            backdrop-filter: blur(16px);
            position: sticky;
            top: 0;
            z-index: 20;
        }

        .map-topbar h2 {
            margin: 0;
            font-size: 1.05rem;
            font-weight: 700;
            color: #f8fafc;
            display: flex;
            align-items: center;
            gap: 0.6rem;
        }

        .live-indicator {
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            color: #10b981;
            font-size: 0.8rem;
            font-weight: 700;
            letter-spacing: 0.06em;
        }

        #liveDot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: #10b981;
            box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.45);
            animation: livePulse 2s infinite;
        }

        @keyframes livePulse {
            0%, 100% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.45); }
            50% { box-shadow: 0 0 0 10px rgba(16, 185, 129, 0); }
        }

        .pulse-fast { animation: none !important; transform: scale(1.2); }

        .search-box {
            position: relative;
            min-width: 260px;
            flex: 1 1 280px;
            max-width: 420px;
        }

        .search-box i {
            position: absolute;
            left: 0.9rem;
            top: 50%;
            transform: translateY(-50%);
            color: #64748b;
        }

        .search-box input,
        .top-select {
            width: 100%;
            background: rgba(30, 41, 59, 0.9);
            border: 1px solid rgba(148, 163, 184, 0.18);
            border-radius: 16px;
            color: #f8fafc;
            min-height: 48px;
            font-family: inherit;
        }

        .search-box input {
            padding: 0.85rem 1rem 0.85rem 2.8rem;
        }

        .top-select {
            padding: 0.85rem 1rem;
            min-width: 190px;
        }

        .map-topbar .top-select {
            width: auto;
            flex: 0 0 210px;
        }

        .top-btn {
            min-height: 48px;
            border-radius: 16px;
            padding: 0.85rem 1.2rem;
            border: 1px solid transparent;
            background: linear-gradient(135deg, #6366f1, #4f46e5);
            color: white;
            font-family: inherit;
            font-weight: 700;
            cursor: pointer;
            transition: transform 0.18s ease, opacity 0.18s ease;
        }

        .top-btn:hover { transform: translateY(-1px); }

        .top-btn-outline {
            background: rgba(15, 23, 42, 0.45);
            border-color: rgba(148, 163, 184, 0.18);
            color: #e2e8f0;
        }

        .toggle-label {
            display: inline-flex;
            align-items: center;
            gap: 0.55rem;
            color: #cbd5e1;
            font-size: 0.9rem;
            font-weight: 600;
        }

        .toggle-label input {
            width: 18px;
            height: 18px;
        }

        .map-left-panel {
            grid-column: 2 / 3;
            display: flex;
            flex-direction: column;
            min-height: 0;
            height: calc(100vh - 81px);
            background: rgba(15, 23, 42, 0.9);
            border-right: 1px solid rgba(148, 163, 184, 0.1);
            overflow: hidden;
        }

        .panel-section {
            padding: 1rem 1rem 0.9rem;
            border-bottom: 1px solid rgba(148, 163, 184, 0.08);
        }

        .panel-section h4 {
            margin: 0 0 0.8rem;
            color: #94a3b8;
            font-size: 0.76rem;
            font-weight: 800;
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .best-hospital-card,
        .route-result,
        .map-legend {
            background: rgba(15, 23, 42, 0.78);
            border: 1px solid rgba(148, 163, 184, 0.12);
            border-radius: 18px;
        }

        .best-hospital-card {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.9rem;
            padding: 1rem;
        }

        .best-hospital-name {
            font-size: 0.95rem;
            font-weight: 700;
            color: #f8fafc;
        }

        .best-hospital-meta {
            margin-top: 0.2rem;
            color: #94a3b8;
            font-size: 0.78rem;
        }

        .best-hospital-route {
            border: none;
            border-radius: 12px;
            background: linear-gradient(135deg, #0f766e, #14b8a6);
            color: white;
            font-weight: 700;
            font-family: inherit;
            padding: 0.75rem 0.95rem;
            cursor: pointer;
        }

        .best-hospital-empty,
        .panel-empty {
            color: #94a3b8;
            font-size: 0.88rem;
            text-align: center;
            padding: 1.1rem 0.6rem;
        }

        .route-selects {
            display: grid;
            gap: 0.7rem;
        }

        .route-result {
            margin-top: 0.8rem;
            padding: 0.9rem 1rem;
            display: flex;
            gap: 0.65rem;
            flex-wrap: wrap;
            color: #d1fae5;
            font-size: 0.82rem;
        }

        .panel-list {
            flex: 1;
            overflow-y: auto;
            padding: 0.8rem;
            display: grid;
            gap: 0.75rem;
            align-content: start;
        }

        .hospital-list-item {
            width: 100%;
            text-align: left;
            border: 1px solid rgba(148, 163, 184, 0.1);
            background: rgba(15, 23, 42, 0.72);
            border-radius: 18px;
            padding: 1rem;
            color: #e2e8f0;
            cursor: pointer;
            transition: transform 0.18s ease, border-color 0.18s ease, background 0.18s ease;
        }

        .hospital-list-item:hover {
            transform: translateY(-1px);
            border-color: rgba(99, 102, 241, 0.45);
            background: rgba(30, 41, 59, 0.88);
        }

        .hospital-list-item.status-available { box-shadow: inset 3px 0 0 #10b981; }
        .hospital-list-item.status-limited { box-shadow: inset 3px 0 0 #f59e0b; }
        .hospital-list-item.status-critical { box-shadow: inset 3px 0 0 #ef4444; }

        .hospital-list-item__header {
            display: flex;
            justify-content: space-between;
            gap: 0.75rem;
            align-items: center;
        }

        .hospital-list-item__name {
            font-weight: 700;
            font-size: 0.95rem;
        }

        .hospital-list-item__badge {
            padding: 0.25rem 0.55rem;
            border-radius: 999px;
            font-size: 0.67rem;
            font-weight: 800;
            background: rgba(99, 102, 241, 0.18);
            color: #c7d2fe;
            text-transform: uppercase;
            letter-spacing: 0.06em;
        }

        .hospital-list-item__location {
            margin-top: 0.35rem;
            color: #94a3b8;
            font-size: 0.8rem;
        }

        .hospital-list-item__stats {
            margin-top: 0.8rem;
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            color: #cbd5e1;
            font-size: 0.76rem;
        }

        .hospital-list-item__stats span {
            background: rgba(51, 65, 85, 0.72);
            border-radius: 999px;
            padding: 0.3rem 0.55rem;
        }

        .map-container {
            grid-column: 3 / 4;
            position: relative;
            min-width: 0;
            min-height: 0;
            height: calc(100vh - 81px);
            background: rgba(15, 23, 42, 0.75);
        }

        #hospitalMap {
            width: 100%;
            height: 100%;
        }

        .map-legend {
            position: absolute;
            left: 1rem;
            bottom: 1rem;
            z-index: 500;
            padding: 1rem;
            min-width: 180px;
            box-shadow: 0 18px 35px rgba(2, 6, 23, 0.3);
        }

        .map-legend h5 {
            margin: 0 0 0.8rem;
            color: #94a3b8;
            font-size: 0.76rem;
            font-weight: 800;
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .legend-item {
            display: flex;
            align-items: center;
            gap: 0.55rem;
            color: #e2e8f0;
            font-size: 0.82rem;
            margin-bottom: 0.45rem;
        }

        .legend-dot {
            width: 12px;
            height: 12px;
            border-radius: 50%;
            border: 2px solid rgba(255, 255, 255, 0.4);
        }

        .legend-line {
            width: 20px;
            height: 3px;
            border-radius: 999px;
        }

        .loading-overlay {
            position: absolute;
            inset: 0;
            display: none;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            gap: 1rem;
            background: rgba(11, 18, 32, 0.6);
            z-index: 700;
            backdrop-filter: blur(8px);
        }

        .loading-overlay.active { display: flex; }

        .spinner {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            border: 4px solid rgba(148, 163, 184, 0.25);
            border-top-color: #6366f1;
            animation: spin 0.9s linear infinite;
        }

        @keyframes spin { to { transform: rotate(360deg); } }

        .loading-text {
            color: #e2e8f0;
            font-weight: 700;
        }

        .sidebar-toggle { display: none; }

        .hospital-marker-wrapper {
            background: transparent;
            border: none;
        }

        .hospital-marker {
            border-radius: 50%;
            background: var(--marker-color);
            border: 3px solid rgba(255, 255, 255, 0.92);
            box-shadow: 0 0 0 3px rgba(15, 23, 42, 0.25);
        }

        .hospital-marker.best {
            box-shadow: 0 0 0 4px rgba(20, 184, 166, 0.24), 0 0 18px rgba(20, 184, 166, 0.45);
        }

        .hospital-popup-shell .leaflet-popup-content-wrapper,
        .hospital-popup-shell .leaflet-popup-tip {
            background: #f8fafc;
            color: #0f172a;
        }

        .hospital-popup {
            min-width: 240px;
            font-family: 'Outfit', sans-serif;
        }

        .hospital-popup__title {
            font-size: 1rem;
            font-weight: 800;
        }

        .hospital-popup__meta {
            margin-top: 0.2rem;
            color: #64748b;
            font-size: 0.8rem;
        }

        .hospital-popup__status {
            margin-top: 0.5rem;
            font-size: 0.78rem;
            font-weight: 800;
            letter-spacing: 0.06em;
            text-transform: uppercase;
        }

        .hospital-popup__grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 0.5rem;
            margin-top: 0.85rem;
        }

        .hospital-popup__grid div {
            background: #e2e8f0;
            border-radius: 12px;
            padding: 0.65rem 0.7rem;
        }

        .hospital-popup__grid span {
            display: block;
            color: #64748b;
            font-size: 0.72rem;
        }

        .hospital-popup__grid strong {
            display: block;
            margin-top: 0.2rem;
            font-size: 0.86rem;
        }

        .hospital-popup__actions {
            display: flex;
            gap: 0.55rem;
            margin-top: 0.9rem;
        }

        .popup-btn {
            flex: 1;
            border-radius: 12px;
            border: none;
            padding: 0.7rem 0.8rem;
            text-align: center;
            font-family: inherit;
            font-weight: 700;
            text-decoration: none;
            color: white;
            background: linear-gradient(135deg, #6366f1, #4f46e5);
            cursor: pointer;
        }

        .popup-btn--ghost {
            background: #0f172a;
            color: #f8fafc;
        }

        .leaflet-control-attribution {
            background: rgba(15, 23, 42, 0.86) !important;
            color: #cbd5e1 !important;
        }

        .leaflet-control-attribution a { color: #93c5fd !important; }

        @media (max-width: 1200px) {
            .map-page {
                grid-template-columns: 260px 320px 1fr;
            }
        }

        @media (max-width: 1024px) {
            body { overflow: auto; }

            .map-page {
                grid-template-columns: 1fr;
                grid-template-rows: auto auto auto 1fr;
            }

            .sidebar {
                position: fixed;
                left: -280px;
                top: 0;
                width: 280px;
                transition: left 0.22s ease;
                z-index: 900;
            }

            .sidebar.active { left: 0; }

            .sidebar-toggle {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                width: 42px;
                height: 42px;
                border-radius: 12px;
                border: 1px solid rgba(148, 163, 184, 0.16);
                background: rgba(15, 23, 42, 0.8);
                color: #f8fafc;
                cursor: pointer;
            }

            .map-topbar,
            .map-left-panel,
            .map-container {
                grid-column: 1;
            }

            .map-topbar {
                position: relative;
                padding-top: 0.85rem;
            }

            .map-left-panel {
                border-right: none;
                border-bottom: 1px solid rgba(148, 163, 184, 0.1);
                height: auto;
            }

            .panel-list {
                max-height: 320px;
            }

            #hospitalMap {
                height: 62vh;
                min-height: 440px;
            }

            .map-container {
                height: auto;
            }

            .map-legend {
                position: static;
                margin: 1rem;
            }
        }
    </style>
</head>
<body>
<div class="map-page">
    <div class="sidebar">
        <div class="brand">
            <i class="fa-solid fa-hospital-user"></i>
            <span>Exchange.Med</span>
        </div>
        <ul class="sidebar-nav">
            <li><a href="/dashboard"><i class="fa-solid fa-house"></i> <span>Overview</span></a></li>
            <li><a href="/map" class="active"><i class="fa-solid fa-map-location-dot"></i> <span>Live Map</span></a></li>
            <li><a href="/marketplace"><i class="fa-solid fa-store"></i> <span>Marketplace</span></a></li>
            <li><a href="/requests"><i class="fa-solid fa-code-pull-request"></i> <span>Requests</span></a></li>
            <li><a href="/monitor"><i class="fa-solid fa-chart-line"></i> <span>Monitor</span></a></li>
            <c:if test="${isAdmin}">
                <li style="margin-top:1rem">
                    <a href="/admin/dashboard"><i class="fa-solid fa-shield-halved"></i> <span>Admin</span></a>
                </li>
            </c:if>
        </ul>
        <div class="sidebar-bottom">
            <form action="/logout" method="POST">
                <button type="submit" class="sign-out-btn">
                    <i class="fa-solid fa-right-from-bracket"></i> <span>Sign Out</span>
                </button>
            </form>
        </div>
    </div>

    <div class="map-topbar">
        <div class="sidebar-toggle" onclick="document.querySelector('.sidebar').classList.toggle('active')">
            <i class="fa-solid fa-bars"></i>
        </div>
        <h2>
            <i class="fa-solid fa-map-location-dot" style="color:#6366f1"></i>
            Hospital Network Map
        </h2>
        <div class="live-indicator">
            <div id="liveDot"></div>
            LIVE
        </div>
        <div class="search-box">
            <i class="fa-solid fa-magnifying-glass"></i>
            <input type="text" id="hospitalSearch" placeholder="Search hospital or location...">
        </div>
        <select id="resourceFilter" class="top-select">
            <option value="ALL">All Resources</option>
            <option value="ICU_BED">ICU Beds</option>
            <option value="VENTILATOR">Ventilators</option>
            <option value="AMBULANCE">Ambulances</option>
            <option value="SPECIALIST">Specialists</option>
        </select>
        <label class="toggle-label">
            <input type="checkbox" id="heatmapToggle">
            Resource Pressure
        </label>
        <button id="suggestBest" class="top-btn">Suggest Best</button>
        <button id="clearRoute" class="top-btn top-btn-outline">Clear Route</button>
    </div>

    <aside class="map-left-panel">
        <div class="panel-section">
            <h4>Best Hospital Suggestion</h4>
            <div id="bestHospitalPanel">
                <div class="best-hospital-empty">Loading best match...</div>
            </div>
        </div>

        <div class="panel-section">
            <h4>Route Planner</h4>
            <div class="route-selects">
                <select id="srcSelect" class="top-select">
                    <option value="18.5204,73.8567">Pune centre</option>
                </select>
                <select id="distSelect" class="top-select">
                    <option value="">Select destination…</option>
                </select>
            </div>
            <div id="routeInfo"></div>
        </div>

        <div class="panel-section">
            <h4>Hospitals</h4>
        </div>
        <div class="panel-list" id="hospitalList">
            <div class="panel-empty">Loading hospital map data...</div>
        </div>
    </aside>

    <section class="map-container">
        <div id="mapLoading" class="loading-overlay active">
            <div class="spinner"></div>
            <div class="loading-text">Syncing hospital network...</div>
        </div>

        <div id="hospitalMap"></div>

        <div class="map-legend">
            <h5>Legend</h5>
            <div class="legend-item">
                <div class="legend-dot" style="background:#10b981"></div>
                Available
            </div>
            <div class="legend-item">
                <div class="legend-dot" style="background:#f59e0b"></div>
                Limited
            </div>
            <div class="legend-item">
                <div class="legend-dot" style="background:#ef4444"></div>
                Critical
            </div>
            <div class="legend-item">
                <div class="legend-dot" style="background:#6366f1"></div>
                Your location
            </div>
            <div class="legend-item">
                <div class="legend-line" style="background:#6366f1"></div>
                Active route
            </div>
        </div>
    </section>
</div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="/js/map.js"></script>
</body>
</html>
