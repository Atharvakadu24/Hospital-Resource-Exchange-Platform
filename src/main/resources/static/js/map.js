/**
 * Exchange.Med — Google Maps Module
 * Features: Hospital markers, clustering, routing, best-hospital suggestion,
 *           real-time network sync.
 */

'use strict';

// ─── State ────────────────────────────────────────────────────────────────────
let map;
let markerClusterer;
let userMarker;
let directionsService;
let directionsRenderer;
let hospitals = [];           // Loaded from API
let hospitalMarkers = {};     // hospitalName -> Marker
let selectedFilter = 'ALL';
let searchQuery = '';
let bestHospitalName = null;
let pollTimer = null;

const PUNE_CENTER = { lat: 18.5204, lng: 73.8567 };

// ─── Init ─────────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
    initMap();
    initControls();
});

// ─── Map Initialization ───────────────────────────────────────────────────────
function initMap() {
    if (typeof google === 'undefined' || !google.maps) {
        console.error('Exchange.Med: Google Maps API failed to load. Check your API key.');
        const mapContainer = document.getElementById('hospitalMap');
        if (mapContainer) {
            mapContainer.innerHTML = `
                <div style="display:flex; flex-direction:column; align-items:center; justify-content:center; height:100%; color:#94a3b8; text-align:center; padding:2rem;">
                    <i class="fa-solid fa-triangle-exclamation" style="font-size:3rem; color:#f59e0b; margin-bottom:1rem;"></i>
                    <h3 style="color:#f1f5f9;">Map Initialization Failed</h3>
                    <p>Google Maps API could not be reached. Please verify your API key in application.properties and check your internet connection.</p>
                </div>`;
        }
        return;
    }

    map = new google.maps.Map(document.getElementById('hospitalMap'), {
        center: PUNE_CENTER,
        zoom: 13,
        styles: getDarkThemeStyles(),
        mapTypeControl: false,
        streetViewControl: false,
        fullscreenControl: false
    });

    directionsService = new google.maps.DirectionsService();
    directionsRenderer = new google.maps.DirectionsRenderer({
        map: map,
        suppressMarkers: true,
        polylineOptions: {
            strokeColor: '#6366f1',
            strokeWeight: 5,
            strokeOpacity: 0.8
        }
    });

    // Initialize Marker Clusterer
    markerClusterer = new markerClusterer.MarkerClusterer({ map });

    // Load initial data
    syncNetworkData();

    // Start Polling
    pollTimer = setInterval(syncNetworkData, 10000); // Sync every 10 seconds

    requestUserLocation();
}

// ─── Sync Data from Backend ───────────────────────────────────────────────────
function syncNetworkData() {
    const loader = document.getElementById('mapLoading');
    if (loader) loader.classList.add('active');

    fetch('/api/map/hospitals')
        .then(r => r.json())
        .then(data => {
            hospitals = data;
            updateMarkers();
            updateSideList();
            suggestBestHospital();
            if (loader) loader.classList.remove('active');

            // Blink live dot
            const dot = document.getElementById('liveDot');
            if (dot) { dot.classList.add('pulse-fast'); setTimeout(() => dot.classList.remove('pulse-fast'), 600); }
        })
        .catch(err => {
            console.error('Network sync error:', err);
            if (loader) loader.classList.remove('active');
        });
}

// ─── Marker Logic ─────────────────────────────────────────────────────────────
function updateMarkers() {
    // Clear old markers from clusterer
    markerClusterer.clearMarkers();
    Object.values(hospitalMarkers).forEach(m => m.setMap(null));
    hospitalMarkers = {};

    const filterType = selectedFilter;
    const search = searchQuery.toLowerCase();

    const markersToCluster = [];

    hospitals.forEach(h => {
        if (search && !h.name.toLowerCase().includes(search) && !h.location.toLowerCase().includes(search)) return;

        if (filterType !== 'ALL') {
            const avail = h.resources ? (
                filterType === 'ICU_BED'    ? h.resources.icuAvail :
                filterType === 'VENTILATOR' ? h.resources.ventAvail :
                filterType === 'AMBULANCE'  ? h.resources.ambulanceAvail :
                filterType === 'SPECIALIST' ? h.resources.specialistAvail : 1
            ) : 0;
            if (avail === 0) return;
        }

        const isBest = (h.name === bestHospitalName);
        const marker = createHospitalMarker(h, isBest);
        hospitalMarkers[h.name] = marker;
        markersToCluster.push(marker);
    });

    markerClusterer.addMarkers(markersToCluster);
}

function createHospitalMarker(h, isBest) {
    const color = h.status === 'AVAILABLE' ? '#10b981' : h.status === 'LIMITED' ? '#f59e0b' : '#ef4444';
    
    const marker = new google.maps.Marker({
        position: { lat: h.lat, lng: h.lng },
        label: {
            text: 'H',
            color: 'white',
            fontWeight: 'bold'
        },
        title: h.name,
        icon: {
            path: google.maps.SymbolPath.CIRCLE,
            fillColor: color,
            fillOpacity: 0.9,
            strokeColor: 'white',
            strokeWeight: 2,
            scale: isBest ? 15 : 12
        }
    });

    const infoWindow = new google.maps.InfoWindow({
        content: buildPopupHTML(h)
    });

    marker.addListener('click', () => {
        infoWindow.open(map, marker);
    });

    return marker;
}

// ─── Popup Builder ────────────────────────────────────────────────────────────
function buildPopupHTML(h) {
    const r = h.resources || {};
    const statusColor = h.status === 'AVAILABLE' ? '#10b981' : h.status === 'LIMITED' ? '#f59e0b' : '#ef4444';
    const isBest = (h.name === bestHospitalName);

    return `
    <div class="map-popup">
        ${isBest ? '<div class="best-badge">⭐ Best Match</div>' : ''}
        <div class="popup-title">${h.name}</div>
        <div class="popup-location">📍 ${h.location}</div>
        <div class="popup-status" style="color:${statusColor}">● ${h.status}</div>
        <div class="popup-resources">
            <div class="res-row"><span>🛏 ICU Beds</span><span>${r.icuAvail || 0}/${r.icuTotal || 0}</span></div>
            <div class="res-row"><span>🌬 Ventilators</span><span>${r.ventAvail || 0}/${r.ventTotal || 0}</span></div>
            <div class="res-row"><span>🚑 Ambulances</span><span>${r.ambulanceAvail || 0}/${r.ambulanceTotal || 0}</span></div>
        </div>
        <div class="popup-actions" style="margin-top:10px; display:flex; gap:5px;">
            <button class="popup-btn" onclick="routeTo(${h.lat}, ${h.lng}, '${escapeName(h.name)}')">Route</button>
            <a href="/hospital/${h.id}" class="popup-btn popup-btn-secondary">Details</a>
        </div>
    </div>`;
}

function escapeName(name) { return name.replace(/'/g, "\\'"); }

// ─── Routing ──────────────────────────────────────────────────────────────────
function routeTo(destLat, destLng, hospitalName) {
    const srcSelect = document.getElementById('srcSelect');
    let origin = PUNE_CENTER;

    if (srcSelect && srcSelect.value) {
        const parts = srcSelect.value.split(',');
        if (parts.length === 2) origin = { lat: parseFloat(parts[0]), lng: parseFloat(parts[1]) };
    }

    const request = {
        origin: origin,
        destination: { lat: destLat, lng: destLng },
        travelMode: google.maps.TravelMode.DRIVING
    };

    directionsService.route(request, (result, status) => {
        if (status === 'OK') {
            directionsRenderer.setDirections(result);
            const route = result.routes[0].legs[0];
            document.getElementById('routeInfo').innerHTML = `
                <div class="route-result">
                    <span>🏥 ${hospitalName}</span>
                    <span>📏 ${route.distance.text}</span>
                    <span>⏱ ${route.duration.text}</span>
                </div>`;
        }
    });
}

// ─── Best Hospital Logic ──────────────────────────────────────────────────────
function suggestBestHospital(userLat, userLng) {
    if (!hospitals.length) return;

    const ref = (userLat && userLng) ? { lat: userLat, lng: userLng } : PUNE_CENTER;
    const filterType = selectedFilter;

    let candidates = hospitals.filter(h => {
        if (h.status === 'CRITICAL') return false;
        if (filterType === 'ALL') return true;
        const avail = h.resources ? (
            filterType === 'ICU_BED'    ? h.resources.icuAvail :
            filterType === 'VENTILATOR' ? h.resources.ventAvail :
            filterType === 'AMBULANCE'  ? h.resources.ambulanceAvail : 1
        ) : 0;
        return avail > 0;
    });

    if (!candidates.length) {
        document.getElementById('bestHospitalPanel').innerHTML = '<div class="best-hospital-empty">No criteria-met hospitals found.</div>';
        return;
    }

    candidates = candidates.map(h => {
        const dist = google.maps.geometry.spherical.computeDistanceBetween(
            new google.maps.LatLng(ref.lat, ref.lng),
            new google.maps.LatLng(h.lat, h.lng)
        ) / 1000; // to KM
        
        const r = h.resources || {};
        const totalAvail = (r.icuAvail || 0) + (r.ventAvail || 0) + (r.ambulanceAvail || 0);
        const score = dist * 0.7 - totalAvail * 0.3; // Distance takes 70% weight
        return { ...h, dist, score };
    }).sort((a, b) => a.score - b.score);

    const best = candidates[0];
    bestHospitalName = best.name;

    document.getElementById('bestHospitalPanel').innerHTML = `
        <div class="best-hospital-card">
            <div class="best-hospital-info">
                <div class="best-hospital-name">⭐ ${best.name}</div>
                <div class="best-hospital-meta">${best.location} · ${best.dist.toFixed(1)} km</div>
            </div>
            <button class="best-hospital-route" onclick="routeTo(${best.lat}, ${best.lng}, '${escapeName(best.name)}')">Route</button>
        </div>`;

    // Highlight marker
    updateMarkers();
}

// ─── Location & Helpers ───────────────────────────────────────────────────────
function requestUserLocation() {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(pos => {
            const lat = pos.coords.latitude;
            const lng = pos.coords.longitude;
            
            userMarker = new google.maps.Marker({
                position: { lat, lng },
                map: map,
                title: 'Your Location',
                icon: {
                    path: google.maps.SymbolPath.CIRCLE,
                    fillColor: '#6366f1',
                    fillOpacity: 1,
                    strokeColor: 'white',
                    strokeWeight: 3,
                    scale: 8
                }
            });

            // Update srcSelect
            const srcSelect = document.getElementById('srcSelect');
            if (srcSelect) {
                const opt = document.createElement('option');
                opt.value = `${lat},${lng}`;
                opt.text = '📍 My Current Location';
                opt.selected = true;
                srcSelect.prepend(opt);
            }

            suggestBestHospital(lat, lng);
        });
    }
}

function updateSideList() {
    const list = document.getElementById('hospitalList');
    if (!list) return;
    const search = searchQuery.toLowerCase();

    list.innerHTML = hospitals
        .filter(h => !search || h.name.toLowerCase().includes(search))
        .map(h => `
            <div class="hosp-list-item status-border-${h.status.toLowerCase()}" onclick="focusHospital('${escapeName(h.name)}')">
                <div class="hosp-list-name">${h.name}</div>
                <div class="hosp-list-meta">${h.status} · ${h.location}</div>
            </div>`).join('');
}

function focusHospital(name) {
    const m = hospitalMarkers[name];
    if (m) {
        map.panTo(m.getPosition());
        map.setZoom(16);
        google.maps.event.trigger(m, 'click');
    }
}

function initControls() {
    document.getElementById('hospitalSearch')?.addEventListener('input', e => {
        searchQuery = e.target.value;
        updateMarkers();
        updateSideList();
    });

    document.getElementById('resourceFilter')?.addEventListener('change', e => {
        selectedFilter = e.target.value;
        updateMarkers();
        suggestBestHospital();
    });

    document.getElementById('clearRoute')?.addEventListener('click', () => {
        directionsRenderer.setDirections({ routes: [] });
        document.getElementById('routeInfo').innerHTML = '';
    });
}

function getDarkThemeStyles() {
    return [
        { elementType: "geometry", stylers: [{ color: "#242f3e" }] },
        { elementType: "labels.text.stroke", stylers: [{ color: "#242f3e" }] },
        { elementType: "labels.text.fill", stylers: [{ color: "#746855" }] },
        { featureType: "administrative.locality", elementType: "labels.text.fill", stylers: [{ color: "#d59563" }] },
        { featureType: "poi", elementType: "labels.text.fill", stylers: [{ color: "#d59563" }] },
        { featureType: "poi.park", elementType: "geometry", stylers: [{ color: "#263c3f" }] },
        { featureType: "poi.park", elementType: "labels.text.fill", stylers: [{ color: "#6b9a76" }] },
        { featureType: "road", elementType: "geometry", stylers: [{ color: "#38414e" }] },
        { featureType: "road", elementType: "geometry.stroke", stylers: [{ color: "#212a37" }] },
        { featureType: "road", elementType: "labels.text.fill", stylers: [{ color: "#9ca5b3" }] },
        { featureType: "road.highway", elementType: "geometry", stylers: [{ color: "#746855" }] },
        { featureType: "road.highway", elementType: "geometry.stroke", stylers: [{ color: "#1f2835" }] },
        { featureType: "road.highway", elementType: "labels.text.fill", stylers: [{ color: "#f3d19c" }] },
        { featureType: "water", elementType: "geometry", stylers: [{ color: "#17263c" }] },
        { featureType: "water", elementType: "labels.text.fill", stylers: [{ color: "#515c6d" }] },
        { featureType: "water", elementType: "labels.text.stroke", stylers: [{ color: "#17263c" }] }
    ];
}
