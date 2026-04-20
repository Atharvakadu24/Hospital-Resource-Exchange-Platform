<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hospital Map — Exchange.Med</title>
    <meta name="description" content="Live hospital map with real-time resource tracking, routing and best-hospital suggestion for Pune region.">

    <!-- Fonts & Icons -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">

    <!-- Google Maps JS API + Marker Clusterer -->
    <script src="https://maps.googleapis.com/maps/api/js?key=${googleMapsApiKey}&libraries=geometry,places"></script>
    <script src="https://unpkg.com/@googlemaps/markerclusterer/dist/index.min.js"></script>

    <!-- App CSS -->
    <link href="/css/main.css" rel="stylesheet">

    <style>
        /* ── Layout ─────────────────────────────────────────────── */
        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Outfit', sans-serif;
            background: #0f172a;
            color: #f1f5f9;
            display: flex;
            height: 100vh;
            overflow: hidden;
        }

        /* ── App Sidebar (shared) ─────────────────────────────────── */
        .sidebar {
            width: 240px;
            min-width: 240px;
            background: #0f172a;
            border-right: 1px solid rgba(255,255,255,0.07);
            display: flex;
            flex-direction: column;
            z-index: 900;
        }

        .sidebar .brand {
            padding: 1.5rem 1.5rem 1rem;
            font-size: 1.3rem;
            font-weight: 800;
            color: #6366f1;
            display: flex;
            align-items: center;
            gap: 10px;
            border-bottom: 1px solid rgba(255,255,255,0.06);
        }

        .sidebar-nav { list-style: none; padding: 1rem 0; flex: 1; }

        .sidebar-nav li { margin: .25rem .75rem; }

        .sidebar-nav a {
            display: flex;
            align-items: center;
            gap: 10px;
            color: #94a3b8;
            padding: .7rem 1rem;
            border-radius: .5rem;
            text-decoration: none;
            font-weight: 500;
            font-size: .9rem;
            transition: all .2s;
        }

        .sidebar-nav a:hover,
        .sidebar-nav a.active {
            background: rgba(99,102,241,.15);
            color: #818cf8;
        }

        .sidebar-nav a i { width: 18px; }

        .sidebar-bottom {
            padding: 1rem 1rem 1.5rem;
            border-top: 1px solid rgba(255,255,255,0.06);
        }

        .sign-out-btn {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #f87171;
            background: rgba(239,68,68,.08);
            border: none;
            border-radius: .5rem;
            padding: .6rem 1rem;
            font-size: .875rem;
            cursor: pointer;
            width: 100%;
            font-family: inherit;
            transition: background .2s;
        }

        .sign-out-btn:hover { background: rgba(239,68,68,.18); }

        /* ── Map Wrapper ──────────────────────────────────────────── */
        .map-wrapper {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            position: relative;
        }

        /* ── Top Bar ──────────────────────────────────────────────── */
        .map-topbar {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: .875rem 1.5rem;
            background: #111827;
            border-bottom: 1px solid rgba(255,255,255,0.07);
            z-index: 50;
            flex-wrap: wrap;
        }

        .map-topbar h2 {
            font-size: 1.1rem;
            font-weight: 700;
            color: #f1f5f9;
            white-space: nowrap;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .live-indicator {
            display: flex;
            align-items: center;
            gap: 5px;
            font-size: .75rem;
            color: #10b981;
            font-weight: 600;
        }

        #liveDot {
            width: 8px; height: 8px;
            background: #10b981;
            border-radius: 50%;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%,100% { box-shadow: 0 0 0 0 rgba(16,185,129,.6); }
            50% { box-shadow: 0 0 0 6px rgba(16,185,129,0); }
        }

        .pulse-fast { animation: pulse .3s ease-in-out 2 !important; }

        .search-box {
            flex: 1;
            max-width: 260px;
            position: relative;
        }

        .search-box input {
            width: 100%;
            background: #1e293b;
            border: 1px solid rgba(255,255,255,.1);
            border-radius: .625rem;
            color: #f1f5f9;
            padding: .5rem 1rem .5rem 2.25rem;
            font-size: .875rem;
            font-family: inherit;
            outline: none;
            transition: border .2s;
        }

        .search-box input:focus { border-color: #6366f1; }

        .search-box i {
            position: absolute;
            left: .75rem; top: 50%;
            transform: translateY(-50%);
            color: #64748b; font-size: .8rem;
        }

        .top-select {
            background: #1e293b;
            border: 1px solid rgba(255,255,255,.1);
            border-radius: .625rem;
            color: #f1f5f9;
            padding: .5rem .9rem;
            font-size: .875rem;
            font-family: inherit;
            cursor: pointer;
            outline: none;
        }

        .top-btn {
            background: #6366f1;
            color: #fff;
            border: none;
            border-radius: .625rem;
            padding: .5rem 1.1rem;
            font-size: .875rem;
            font-weight: 600;
            cursor: pointer;
            font-family: inherit;
            transition: background .2s;
            white-space: nowrap;
        }

        .top-btn:hover { background: #4f46e5; }

        .top-btn-outline {
            background: transparent;
            border: 1px solid rgba(255,255,255,.2);
            color: #cbd5e1;
        }

        .top-btn-outline:hover { background: rgba(255,255,255,.07); }

        .toggle-label {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: .8rem;
            color: #94a3b8;
            cursor: pointer;
            white-space: nowrap;
        }

        /* ── Main Area ─────────────────────────────────────────────── */
        .map-body {
            flex: 1;
            display: flex;
            overflow: hidden;
        }

        /* ── Left Panel ───────────────────────────────────────────── */
        .map-left-panel {
            width: 300px;
            min-width: 300px;
            background: #111827;
            border-right: 1px solid rgba(255,255,255,.07);
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .panel-section {
            padding: 1rem 1rem .75rem;
            border-bottom: 1px solid rgba(255,255,255,.06);
        }

        .panel-section h4 {
            font-size: .8rem;
            text-transform: uppercase;
            letter-spacing: .07em;
            color: #64748b;
            font-weight: 700;
            margin-bottom: .75rem;
        }

        /* Best Hospital */
        .best-hospital-card {
            display: flex;
            align-items: center;
            gap: .75rem;
            background: rgba(99,102,241,.1);
            border: 1px solid rgba(99,102,241,.3);
            border-radius: .75rem;
            padding: .875rem;
        }

        .best-hospital-icon { font-size: 1.5rem; }

        .best-hospital-name {
            font-weight: 700;
            font-size: .9rem;
            color: #f1f5f9;
        }

        .best-hospital-meta { font-size: .75rem; color: #94a3b8; margin: .2rem 0; }

        .best-hospital-route {
            margin-left: auto;
            background: #6366f1;
            color: #fff;
            border: none;
            border-radius: .5rem;
            padding: .4rem .8rem;
            font-size: .8rem;
            cursor: pointer;
            font-family: inherit;
            font-weight: 600;
            white-space: nowrap;
        }

        .best-hospital-empty { color: #64748b; font-size: .85rem; text-align: center; padding: .5rem 0; }

        /* Route info */
        .route-result {
            display: flex;
            gap: .75rem;
            flex-wrap: wrap;
            background: rgba(16,185,129,.1);
            border: 1px solid rgba(16,185,129,.2);
            border-radius: .625rem;
            padding: .625rem .875rem;
            font-size: .8rem;
            color: #d1fae5;
        }

        .route-selects { display: flex; flex-direction: column; gap: .5rem; }

        .route-selects select {
            background: #1e293b;
            border: 1px solid rgba(255,255,255,.1);
            border-radius: .5rem;
            color: #f1f5f9;
            padding: .5rem .75rem;
            font-size: .8rem;
            font-family: inherit;
            outline: none;
        }

        /* Hospital List */
        .panel-list {
            flex: 1;
            overflow-y: auto;
            padding: .5rem;
        }

        .panel-list::-webkit-scrollbar { width: 4px; }
        .panel-list::-webkit-scrollbar-thumb { background: #334155; border-radius: 2px; }

        .hosp-list-item {
            border-radius: .625rem;
            padding: .75rem;
            margin-bottom: .4rem;
            cursor: pointer;
            border-left: 3px solid transparent;
            transition: background .15s;
        }

        .hosp-list-item:hover { background: rgba(255,255,255,.04); }

        .status-border-available { border-left-color: #10b981; }
        .status-border-limited   { border-left-color: #f59e0b; }
        .status-border-critical  { border-left-color: #ef4444; }

        .hosp-list-name { font-weight: 600; font-size: .875rem; color: #f1f5f9; }
        .hosp-list-loc  { font-size: .75rem; color: #64748b; margin: .15rem 0 .4rem; }

        .hosp-list-resources {
            display: flex;
            gap: .6rem;
            font-size: .75rem;
            color: #94a3b8;
            margin-bottom: .4rem;
        }

        .hosp-list-badge {
            display: inline-block;
            padding: .15rem .5rem;
            border-radius: 9999px;
            font-size: .65rem;
            font-weight: 700;
            text-transform: uppercase;
        }

        .badge-available { background: rgba(16,185,129,.15); color: #10b981; }
        .badge-limited   { background: rgba(245,158,11,.15); color: #f59e0b; }
        .badge-critical  { background: rgba(239,68,68,.15); color: #ef4444; }

        /* ── Map Container ────────────────────────────────────────── */
        .map-container { flex: 1; position: relative; }

        #hospitalMap { width: 100%; height: 100%; }

        /* ── Legend ───────────────────────────────────────────────── */
        .map-legend {
            position: absolute;
            bottom: 2rem;
            left: 1rem;
            background: rgba(17,24,39,.92);
            backdrop-filter: blur(8px);
            border: 1px solid rgba(255,255,255,.1);
            border-radius: .75rem;
            padding: .875rem 1rem;
            z-index: 500;
            min-width: 170px;
        }

        .map-legend h5 {
            font-size: .7rem;
            text-transform: uppercase;
            letter-spacing: .08em;
            color: #64748b;
            margin-bottom: .6rem;
        }

        .legend-item {
            display: flex;
            align-items: center;
            gap: .5rem;
            font-size: .8rem;
            color: #cbd5e1;
            margin-bottom: .35rem;
        }

        .legend-dot {
            width: 12px; height: 12px;
            border-radius: 50%;
            border: 2px solid rgba(255,255,255,.4);
        }

        .legend-line {
            width: 20px; height: 3px;
            border-radius: 2px;
        }

        /* ── Popup Styling ────────────────────────────────────────── */
        .map-popup { min-width: 260px; font-family: 'Outfit', sans-serif; }

        .best-badge {
            background: rgba(99,102,241,.2);
            color: #818cf8;
            font-size: .7rem;
            font-weight: 700;
            text-transform: uppercase;
            padding: .2rem .6rem;
            border-radius: 9999px;
            margin-bottom: .5rem;
            display: inline-block;
        }

        .popup-title {
            font-size: 1rem;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: .25rem;
        }

        .popup-location { font-size: .75rem; color: #64748b; margin-bottom: .25rem; }

        .popup-status { font-size: .8rem; font-weight: 600; margin-bottom: .75rem; }

        .popup-resources { border-top: 1px solid #e2e8f0; padding-top: .625rem; margin-bottom: .75rem; }

        .res-row {
            display: flex;
            justify-content: space-between;
            font-size: .8rem;
            padding: .25rem 0;
            color: #334155;
        }

        .popup-actions { display: flex; gap: .5rem; flex-wrap: wrap; }

        .popup-btn {
            flex: 1;
            background: #6366f1;
            color: #fff;
            border: none;
            border-radius: .5rem;
            padding: .45rem .75rem;
            font-size: .8rem;
            font-weight: 600;
            cursor: pointer;
            font-family: inherit;
            text-decoration: none;
            text-align: center;
            transition: background .2s;
        }

        .popup-btn:hover { background: #4f46e5; }
        .popup-btn-secondary { background: #e2e8f0; color: #334155; }
        .popup-btn-secondary:hover { background: #cbd5e1; }

        /* ── User Dot ─────────────────────────────────────────────── */
        .user-location-dot {
            width: 18px; height: 18px;
            background: #6366f1;
            border: 3px solid #fff;
            border-radius: 50%;
            box-shadow: 0 0 0 4px rgba(99,102,241,.35);
            animation: pulse 2s infinite;
        }

        /* ── Hospital Marker Pulse (Best) ─────────────────────────── */
        .best-hospital-marker { animation: markerPulse 1.8s ease-in-out infinite; }

        @keyframes markerPulse {
            0%,100% { filter: drop-shadow(0 0 6px #10b981); }
            50%      { filter: drop-shadow(0 0 18px #10b981); }
        }

        /* ── Ambulance ───────────────────────────────────────────── */
        .ambulance-icon { font-size: 1.3rem; }

        /* ── Status badge in best panel ───────────────────────────── */
        .status-available { color: #10b981; font-weight: 700; font-size: .75rem; }
        .status-limited   { color: #f59e0b; font-weight: 700; font-size: .75rem; }
        .status-critical  { color: #ef4444; font-weight: 700; font-size: .75rem; }

        /* ── Routing Machine custom overrides ─────────────────────── */
        .leaflet-routing-container {
            background: #111827 !important;
            color: #f1f5f9 !important;
            border: 1px solid rgba(255,255,255,.1) !important;
            border-radius: .75rem !important;
            font-family: 'Outfit', sans-serif !important;
            font-size: .8rem !important;
            max-height: 220px !important;
            overflow-y: auto !important;
        }

        .leaflet-routing-alt h2,
        .leaflet-routing-alt h3 { color: #818cf8 !important; font-size: .85rem !important; }

        .leaflet-routing-alt tr { border-bottom: 1px solid rgba(255,255,255,.05) !important; }

        /* ── Responsive ───────────────────────────────────────────── */
        @media (max-width: 900px) {
            .map-left-panel { display: none; }
            .sidebar { width: 60px; }
            .sidebar .brand span,
            .sidebar-nav a span { display: none; }
            .sidebar-nav a { justify-content: center; }
            .sidebar-nav a i { width: auto; margin: 0; }
        }
    </style>
</head>
<body>

<!-- ═══ App Sidebar ════════════════════════════════════════════ -->
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

<!-- ═══ Map Section ═══════════════════════════════════════════ -->
<div class="map-wrapper">

    <!-- Sidebar Toggle (Mobile) -->
    <div class="sidebar-toggle" onclick="document.querySelector('.sidebar').classList.toggle('active')">
        <i class="fa-solid fa-bars"></i>
    </div>

    <!-- Top Bar -->
    <div class="map-topbar">
        <h2>
            <i class="fa-solid fa-map-location-dot" style="color:#6366f1"></i>
            Hospital Network Map
        </h2>

        <div class="live-indicator">
            <div id="liveDot"></div>
            LIVE
        </div>

        <!-- Search -->
        <div class="search-box">
            <i class="fa-solid fa-magnifying-glass"></i>
            <input type="text" id="hospitalSearch" placeholder="Search hospital or location…">
        </div>

        <!-- Resource Filter -->
        <select id="resourceFilter" class="top-select">
            <option value="ALL">All Resources</option>
            <option value="ICU_BED">🛏 ICU Beds</option>
            <option value="VENTILATOR">🌬 Ventilators</option>
            <option value="AMBULANCE">🚑 Ambulances</option>
            <option value="SPECIALIST">👨‍⚕️ Specialists</option>
        </select>

        <!-- Heatmap toggle -->
        <label class="toggle-label">
            <input type="checkbox" id="heatmapToggle">
            🔥 Heatmap
        </label>

        <!-- Suggest button -->
        <button id="suggestBest" class="top-btn">⭐ Suggest Best</button>

        <!-- Clear route -->
        <button id="clearRoute" class="top-btn top-btn-outline">✕ Clear Route</button>
    </div>

    <!-- Loading Overlay -->
    <div id="mapLoading" class="loading-overlay">
        <div class="spinner"></div>
        <div class="loading-text">Syncing Hospital Network...</div>
    </div>

    <!-- Body -->
    <div class="map-body">

        <!-- Left Panel -->
        <div class="map-left-panel">

            <!-- Best Hospital -->
            <div class="panel-section">
                <h4>Best Hospital Suggestion</h4>
                <div id="bestHospitalPanel">
                    <div class="best-hospital-empty">Detecting best match…</div>
                </div>
            </div>

            <!-- Routing -->
            <div class="panel-section">
                <h4>Get Route</h4>
                <div class="route-selects">
                    <select id="srcSelect" class="top-select" style="font-size:.8rem">
                        <option value="18.5204,73.8567">📍 Pune Centre (default)</option>
                    </select>
                    <select id="distSelect" class="top-select" style="font-size:.8rem">
                        <option value="">Select Destination…</option>
                    </select>
                </div>
                <div id="routeInfo" style="margin-top:.625rem"></div>
            </div>

            <!-- Hospital List -->
            <div class="panel-section" style="flex-shrink:0">
                <h4>Hospitals</h4>
            </div>
            <div class="panel-list" id="hospitalList">
                <div style="color:#64748b;font-size:.85rem;text-align:center;padding:2rem">Loading…</div>
            </div>
        </div>

        <!-- Map -->
        <div class="map-container">
            <div id="hospitalMap"></div>

            <!-- Legend -->
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
                    <div class="legend-dot" style="background:#6366f1; border-color:#fff"></div>
                    Your Location
                </div>
                <div class="legend-item">
                    <span style="font-size:1rem">🚑</span>
                    Ambulance
                </div>
                <div class="legend-item">
                    <div class="legend-line" style="background:#6366f1"></div>
                    Active Route
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ═══ Scripts ═══════════════════════════════════════════════ -->
<!-- Map logic -->
<script src="/js/map.js"></script>

</body>
</html>
