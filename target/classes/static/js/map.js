/**
 * Exchange.Med — Hospital Map Module
 * Leaflet.js + OpenStreetMap (no API key required)
 * Features: Hospital markers, routing, best-hospital suggestion,
 *           real-time simulation, heatmap, ambulance animation, legend.
 */

'use strict';

// ─── State ────────────────────────────────────────────────────────────────────
let map, userMarker, routeLayer, heatLayer;
let hospitals = [];           // loaded from API
let markers   = {};           // hospitalName -> Leaflet marker
let simTimer  = null;         // setInterval handle for live simulation
let ambulances = [];          // ambulance marker objects
let selectedFilter = 'ALL';   // resource type filter
let searchQuery    = '';
let bestHospitalName = null;

const PUNE_CENTER = [18.5204, 73.8567];

// ─── Init ─────────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
    initMap();
    loadHospitals();
    initControls();
    requestUserLocation();
    startLiveSimulation();
    startAmbulanceSimulation();
});

// ─── Map Initialization ───────────────────────────────────────────────────────
function initMap() {
    map = L.map('hospitalMap', {
        center: PUNE_CENTER,
        zoom: 13,
        zoomControl: false
    });

    // Dark blue-toned tile layer (CartoDB Dark)
    L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/">CARTO</a>',
        subdomains: 'abcd',
        maxZoom: 20
    }).addTo(map);

    // Custom zoom controls (bottom-right)
    L.control.zoom({ position: 'bottomright' }).addTo(map);
}

// ─── Load Hospitals from API ───────────────────────────────────────────────────
function loadHospitals() {
    fetch('/api/map/hospitals')
        .then(r => r.json())
        .then(data => {
            hospitals = data;
            renderMarkers(hospitals);
            initHeatmap(hospitals);
            populateSelects();
            updateSideList(hospitals);
            suggestBestHospital();
        })
        .catch(err => console.error('Map API error:', err));
}

// ─── Marker Icons (custom colored SVG circles) ─────────────────────────────────
function getIcon(status, isBest) {
    const color = status === 'AVAILABLE' ? '#10b981'
                : status === 'LIMITED'   ? '#f59e0b'
                :                          '#ef4444';
    const size = isBest ? 42 : 34;
    const glow = isBest ? `filter:drop-shadow(0 0 10px ${color});` : '';

    const svg = `
        <svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}" viewBox="0 0 ${size} ${size}" style="${glow}">
            <circle cx="${size/2}" cy="${size/2}" r="${size/2 - 3}" fill="${color}" opacity="0.9" stroke="white" stroke-width="2"/>
            <text x="${size/2}" y="${size/2 + 5}" text-anchor="middle" font-size="${size/3}" fill="white" font-family="Arial" font-weight="bold">H</text>
        </svg>`;

    return L.divIcon({
        html: svg,
        className: isBest ? 'hospital-marker best-hospital-marker' : 'hospital-marker',
        iconSize:   [size, size],
        iconAnchor: [size/2, size/2],
        popupAnchor: [0, -size/2]
    });
}

// ─── Render / Update All Markers ───────────────────────────────────────────────
function renderMarkers(data) {
    // Clear existing
    Object.values(markers).forEach(m => map.removeLayer(m));
    markers = {};

    const filterType = selectedFilter;
    const search = searchQuery.toLowerCase();

    data.forEach(h => {
        // Search filter
        if (search && !h.name.toLowerCase().includes(search) && !h.location.toLowerCase().includes(search)) return;

        // Resource type filter
        if (filterType !== 'ALL') {
            const r = h.resources;
            const avail =
                filterType === 'ICU_BED'    ? r.icuAvail :
                filterType === 'VENTILATOR' ? r.ventAvail :
                filterType === 'AMBULANCE'  ? r.ambulanceAvail :
                filterType === 'SPECIALIST' ? r.specialistAvail : 1;
            if (avail === 0) return;
        }

        const isBest = (h.name === bestHospitalName);
        const icon   = getIcon(h.status, isBest);
        const marker = L.marker([h.lat, h.lng], { icon, title: h.name }).addTo(map);
        marker.bindPopup(buildPopup(h), { maxWidth: 320 });
        marker.on('popupopen', () => { /* nothing special */ });
        markers[h.name] = marker;
    });
}

// ─── Popup HTML ────────────────────────────────────────────────────────────────
function buildPopup(h) {
    const r = h.resources;
    const statusColor = h.status === 'AVAILABLE' ? '#10b981' : h.status === 'LIMITED' ? '#f59e0b' : '#ef4444';
    const isBest = (h.name === bestHospitalName);

    return `
    <div class="map-popup">
        ${isBest ? '<div class="best-badge">⭐ Best Match</div>' : ''}
        <div class="popup-title">${h.name}</div>
        <div class="popup-location">📍 ${h.location}</div>
        <div class="popup-status" style="color:${statusColor}">● ${h.status}</div>
        <div class="popup-resources">
            <div class="res-row"><span>🛏 ICU Beds</span><span>${r.icuAvail}/${r.icuTotal} available</span></div>
            <div class="res-row"><span>🌬 Ventilators</span><span>${r.ventAvail}/${r.ventTotal} available</span></div>
            <div class="res-row"><span>🚑 Ambulances</span><span>${r.ambulanceAvail}/${r.ambulanceTotal} available</span></div>
            <div class="res-row"><span>👨‍⚕️ Specialists</span><span>${r.specialistAvail}/${r.specialistTotal} available</span></div>
        </div>
        <div class="popup-actions">
            <button class="popup-btn" onclick="routeTo(${h.lat}, ${h.lng}, '${escapeName(h.name)}')">🗺 Get Route</button>
            ${h.id > 0 ? `<a href="/hospital/${h.id}" class="popup-btn popup-btn-secondary">View Details</a>` : ''}
        </div>
    </div>`;
}

function escapeName(name) { return name.replace(/'/g, "\\'"); }

// ─── Heatmap Layer ─────────────────────────────────────────────────────────────
function initHeatmap(data) {
    if (typeof L.heatLayer === 'undefined') return; // plugin not loaded yet

    const points = data.map(h => {
        const demand = h.status === 'CRITICAL' ? 1.0 : h.status === 'LIMITED' ? 0.6 : 0.3;
        return [h.lat, h.lng, demand];
    });

    heatLayer = L.heatLayer(points, {
        radius: 60,
        blur: 40,
        maxZoom: 17,
        gradient: { 0.2: '#3b82f6', 0.5: '#f59e0b', 1.0: '#ef4444' }
    });

    // Heatmap is off by default; toggled by control
}

// ─── User Geolocation ──────────────────────────────────────────────────────────
function requestUserLocation() {
    if (!navigator.geolocation) return;
    navigator.geolocation.getCurrentPosition(
        pos => {
            const { latitude: lat, longitude: lng } = pos.coords;
            const userIcon = L.divIcon({
                html: '<div class="user-location-dot"></div>',
                className: '',
                iconSize: [20, 20],
                iconAnchor: [10, 10]
            });
            userMarker = L.marker([lat, lng], { icon: userIcon, title: 'Your Location', zIndexOffset: 1000 }).addTo(map);
            userMarker.bindPopup('<strong>📍 Your Location</strong>').openPopup();

            // Populate source select
            const srcSelect = document.getElementById('srcSelect');
            if (srcSelect) {
                const opt = document.createElement('option');
                opt.value = `${lat},${lng}`;
                opt.text  = '📍 My Current Location';
                opt.selected = true;
                srcSelect.prepend(opt);
            }

            suggestBestHospital(lat, lng);
        },
        () => { /* silently ignore if denied */ }
    );
}

// ─── Routing (Leaflet Routing Machine) ────────────────────────────────────────
function routeTo(destLat, destLng, hospitalName) {
    if (routeLayer) { map.removeLayer(routeLayer); routeLayer = null; }

    const srcSelect = document.getElementById('srcSelect');
    let srcLat = PUNE_CENTER[0], srcLng = PUNE_CENTER[1];

    if (srcSelect && srcSelect.value) {
        const parts = srcSelect.value.split(',');
        if (parts.length === 2) { srcLat = parseFloat(parts[0]); srcLng = parseFloat(parts[1]); }
    }

    // Use OSRM demo endpoint via Leaflet Routing Machine
    routeLayer = L.Routing.control({
        waypoints: [
            L.latLng(srcLat, srcLng),
            L.latLng(destLat, destLng)
        ],
        routeWhileDragging: false,
        addWaypoints: false,
        draggableWaypoints: false,
        fitSelectedRoutes: true,
        show: true,
        lineOptions: {
            styles: [{ color: '#6366f1', weight: 5, opacity: 0.8 }]
        },
        createMarker: () => null
    }).addTo(map);

    routeLayer.on('routesfound', e => {
        const r = e.routes[0].summary;
        const dist = (r.totalDistance / 1000).toFixed(2);
        const mins = Math.round(r.totalTime / 60);
        document.getElementById('routeInfo').innerHTML =
            `<div class="route-result">
                <span>🏥 ${hospitalName}</span>
                <span>📏 ${dist} km</span>
                <span>⏱ ~${mins} min</span>
             </div>`;
    });
}

// ─── Best Hospital Suggestion ──────────────────────────────────────────────────
function suggestBestHospital(userLat, userLng) {
    if (!hospitals.length) return;

    const refLat = userLat || PUNE_CENTER[0];
    const refLng = userLng || PUNE_CENTER[1];
    const filterType = selectedFilter;

    let candidates = hospitals.filter(h => {
        if (h.status === 'CRITICAL') return false;
        if (filterType === 'ALL') return true;
        const r = h.resources;
        const avail =
            filterType === 'ICU_BED'    ? r.icuAvail :
            filterType === 'VENTILATOR' ? r.ventAvail :
            filterType === 'AMBULANCE'  ? r.ambulanceAvail :
            filterType === 'SPECIALIST' ? r.specialistAvail : 1;
        return avail > 0;
    });

    if (!candidates.length) {
        document.getElementById('bestHospitalPanel').innerHTML =
            '<div class="best-hospital-empty">No suitable hospital found for selected filter.</div>';
        return;
    }

    // Score: lower distance + higher availability = better
    candidates = candidates.map(h => {
        const dist = haversine(refLat, refLng, h.lat, h.lng);
        const r = h.resources;
        const totalAvail = r.icuAvail + r.ventAvail + r.ambulanceAvail + r.specialistAvail;
        const score = dist * 0.6 - totalAvail * 0.4;
        return { ...h, dist, score };
    }).sort((a, b) => a.score - b.score);

    const best = candidates[0];
    bestHospitalName = best.name;

    // Update panel
    document.getElementById('bestHospitalPanel').innerHTML = `
        <div class="best-hospital-card">
            <div class="best-hospital-icon">⭐</div>
            <div class="best-hospital-info">
                <div class="best-hospital-name">${best.name}</div>
                <div class="best-hospital-meta">${best.location} · ${best.dist.toFixed(1)} km away</div>
                <div class="best-hospital-status status-${best.status.toLowerCase()}">${best.status}</div>
            </div>
            <button class="best-hospital-route" onclick="routeTo(${best.lat}, ${best.lng}, '${escapeName(best.name)}')">Route →</button>
        </div>`;

    // Re-render markers to apply glow
    renderMarkers(hospitals);

    // Pan to best
    map.flyTo([best.lat, best.lng], 15, { animate: true, duration: 1.2 });
    if (markers[best.name]) markers[best.name].openPopup();
}

function haversine(lat1, lng1, lat2, lng2) {
    const R = 6371;
    const dLat = deg2rad(lat2 - lat1);
    const dLng = deg2rad(lng2 - lng1);
    const a = Math.sin(dLat/2)**2 + Math.cos(deg2rad(lat1))*Math.cos(deg2rad(lat2))*Math.sin(dLng/2)**2;
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}
function deg2rad(d) { return d * Math.PI / 180; }

// ─── Live Resource Simulation ──────────────────────────────────────────────────
function startLiveSimulation() {
    simTimer = setInterval(() => {
        hospitals.forEach(h => {
            const r = h.resources;
            // Simulate small random fluctuations
            r.icuAvail        = fluctuate(r.icuAvail,        0, r.icuTotal);
            r.ventAvail       = fluctuate(r.ventAvail,       0, r.ventTotal);
            r.ambulanceAvail  = fluctuate(r.ambulanceAvail,  0, r.ambulanceTotal);
            r.specialistAvail = fluctuate(r.specialistAvail, 0, r.specialistTotal);

            // Recompute status
            const totalAvail = r.icuAvail + r.ventAvail + r.ambulanceAvail + r.specialistAvail;
            const totalAll   = r.icuTotal + r.ventTotal + r.ambulanceTotal + r.specialistTotal;
            const ratio = totalAll > 0 ? totalAvail / totalAll : 0;
            h.status = ratio >= 0.5 ? 'AVAILABLE' : ratio > 0 ? 'LIMITED' : 'CRITICAL';
        });

        renderMarkers(hospitals);
        updateHeatmap();
        updateSideList(hospitals);
        suggestBestHospital();

        // Flash live indicator
        const dot = document.getElementById('liveDot');
        if (dot) { dot.classList.add('pulse-fast'); setTimeout(() => dot.classList.remove('pulse-fast'), 600); }
    }, 5000); // every 5 seconds
}

function fluctuate(val, min, max) {
    const delta = Math.random() < 0.3 ? (Math.random() < 0.5 ? -1 : 1) : 0;
    return Math.max(min, Math.min(max, val + delta));
}

function updateHeatmap() {
    if (!heatLayer) return;
    const points = hospitals.map(h => {
        const demand = h.status === 'CRITICAL' ? 1.0 : h.status === 'LIMITED' ? 0.6 : 0.3;
        return [h.lat, h.lng, demand];
    });
    heatLayer.setLatLngs(points);
}

// ─── Ambulance Animation ───────────────────────────────────────────────────────
function startAmbulanceSimulation() {
    const ambIcon = L.divIcon({
        html: '<div class="ambulance-icon">🚑</div>',
        className: '',
        iconSize: [28, 28],
        iconAnchor: [14, 14]
    });

    // Spawn 3 ambulances
    [0, 1, 2].forEach(i => {
        const marker = L.marker(randomNearby(PUNE_CENTER, 0.05), { icon: ambIcon, zIndexOffset: 900 }).addTo(map);
        ambulances.push({ marker, target: null, progress: 0, speed: 0.015 + i * 0.005 });
    });

    // Move ambulances
    setInterval(() => {
        ambulances.forEach(amb => {
            if (!amb.target || amb.progress >= 1) {
                // Pick a random hospital as destination
                const h = hospitals[Math.floor(Math.random() * hospitals.length)];
                if (!h) return;
                amb.start    = amb.marker.getLatLng();
                amb.target   = L.latLng(h.lat, h.lng);
                amb.progress = 0;
            }
            amb.progress = Math.min(1, amb.progress + amb.speed);
            const lat = amb.start.lat + (amb.target.lat - amb.start.lat) * amb.progress;
            const lng = amb.start.lng + (amb.target.lng - amb.start.lng) * amb.progress;
            amb.marker.setLatLng([lat, lng]);
        });
    }, 200);
}

function randomNearby(center, spread) {
    return [center[0] + (Math.random() - 0.5) * spread * 2,
            center[1] + (Math.random() - 0.5) * spread * 2];
}

// ─── Side Panel Hospital List ──────────────────────────────────────────────────
function updateSideList(data) {
    const list  = document.getElementById('hospitalList');
    if (!list) return;
    const search = searchQuery.toLowerCase();

    list.innerHTML = data
        .filter(h => !search || h.name.toLowerCase().includes(search) || h.location.toLowerCase().includes(search))
        .map(h => `
            <div class="hosp-list-item status-border-${h.status.toLowerCase()}" onclick="focusHospital('${escapeName(h.name)}')">
                <div class="hosp-list-name">${h.name}${h.name === bestHospitalName ? ' ⭐' : ''}</div>
                <div class="hosp-list-loc">${h.location}</div>
                <div class="hosp-list-resources">
                    <span title="ICU">🛏 ${h.resources.icuAvail}</span>
                    <span title="Vent">🌬 ${h.resources.ventAvail}</span>
                    <span title="Ambulance">🚑 ${h.resources.ambulanceAvail}</span>
                </div>
                <span class="hosp-list-badge badge-${h.status.toLowerCase()}">${h.status}</span>
            </div>`).join('');
}

function focusHospital(name) {
    const m = markers[name];
    if (m) { map.flyTo(m.getLatLng(), 16, { animate: true, duration: 0.8 }); m.openPopup(); }
}

// ─── Populate Source / Destination Selects ─────────────────────────────────────
function populateSelects() {
    const distSelect = document.getElementById('distSelect');
    if (!distSelect) return;
    distSelect.innerHTML = '<option value="">Select Destination Hospital</option>' +
        hospitals.map(h => `<option value="${h.lat},${h.lng},${escapeName(h.name)}">${h.name}</option>`).join('');

    distSelect.addEventListener('change', () => {
        const parts = distSelect.value.split(',');
        if (parts.length < 3) return;
        const lat = parseFloat(parts[0]), lng = parseFloat(parts[1]);
        const name = parts.slice(2).join(',');
        routeTo(lat, lng, name);
    });
}

// ─── Controls ──────────────────────────────────────────────────────────────────
function initControls() {
    // Search
    document.getElementById('hospitalSearch')?.addEventListener('input', e => {
        searchQuery = e.target.value;
        renderMarkers(hospitals);
        updateSideList(hospitals);
    });

    // Resource filter
    document.getElementById('resourceFilter')?.addEventListener('change', e => {
        selectedFilter = e.target.value;
        renderMarkers(hospitals);
        suggestBestHospital();
    });

    // Heatmap toggle
    document.getElementById('heatmapToggle')?.addEventListener('change', e => {
        if (!heatLayer) { alert('Heatmap plugin loading...'); return; }
        if (e.target.checked) heatLayer.addTo(map);
        else map.removeLayer(heatLayer);
    });

    // Clear route
    document.getElementById('clearRoute')?.addEventListener('click', () => {
        if (routeLayer) { map.removeLayer(routeLayer); routeLayer = null; }
        document.getElementById('routeInfo').innerHTML = '';
    });

    // Suggest best hospital button
    document.getElementById('suggestBest')?.addEventListener('click', () => {
        const loc = userMarker?.getLatLng();
        suggestBestHospital(loc?.lat, loc?.lng);
    });
}
