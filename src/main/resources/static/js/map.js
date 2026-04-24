'use strict';

let map;
let hospitals = [];
let selectedFilter = 'ALL';
let searchQuery = '';
let bestHospitalName = null;
let userLocation = null;
let userMarker = null;
let routeLine = null;
let heatLayerGroup = null;
let markersLayer = null;
let hospitalMarkers = {};
let syncTimer = null;

const PUNE_CENTER = [18.5204, 73.8567];
const DEFAULT_SPEED_KMPH = 42;

document.addEventListener('DOMContentLoaded', () => {
    initMap();
    initControls();
    syncNetworkData();
    syncTimer = window.setInterval(syncNetworkData, 15000);
});

function initMap() {
    map = L.map('hospitalMap', {
        zoomControl: false,
        attributionControl: true
    }).setView(PUNE_CENTER, 12);

    L.control.zoom({ position: 'bottomright' }).addTo(map);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; OpenStreetMap contributors'
    }).addTo(map);

    markersLayer = L.layerGroup().addTo(map);
    heatLayerGroup = L.layerGroup().addTo(map);

    window.setTimeout(() => map.invalidateSize(), 150);
    requestUserLocation();
}

function initControls() {
    document.getElementById('hospitalSearch')?.addEventListener('input', event => {
        searchQuery = event.target.value.trim().toLowerCase();
        renderMapState();
    });

    document.getElementById('resourceFilter')?.addEventListener('change', event => {
        selectedFilter = event.target.value;
        renderMapState();
    });

    document.getElementById('heatmapToggle')?.addEventListener('change', () => {
        renderHeatOverlay();
    });

    document.getElementById('suggestBest')?.addEventListener('click', () => {
        suggestBestHospital(true);
    });

    document.getElementById('distSelect')?.addEventListener('change', event => {
        const value = event.target.value;
        if (!value) return;

        const [lat, lng, hospitalName] = value.split('|');
        routeTo(Number(lat), Number(lng), hospitalName);
    });

    document.getElementById('clearRoute')?.addEventListener('click', clearRoute);
}

function syncNetworkData() {
    toggleLoader(true);

    fetch('/api/map/hospitals')
        .then(response => response.json())
        .then(data => {
            hospitals = Array.isArray(data) ? data : [];
            renderMapState();
            toggleLoader(false);
            pulseLiveDot();
        })
        .catch(error => {
            console.error('Map sync failed:', error);
            toggleLoader(false);
            const list = document.getElementById('hospitalList');
            if (list && !hospitals.length) {
                list.innerHTML = '<div class="panel-empty">Unable to load hospital map data right now.</div>';
            }
        });
}

function renderMapState() {
    renderMarkers();
    renderSideList();
    updateDestinationOptions();
    renderHeatOverlay();
    suggestBestHospital(false);
}

function getFilteredHospitals() {
    return hospitals.filter(hospital => {
        const matchesSearch = !searchQuery
            || hospital.name.toLowerCase().includes(searchQuery)
            || hospital.location.toLowerCase().includes(searchQuery);

        if (!matchesSearch) return false;
        if (selectedFilter === 'ALL') return true;

        const resources = hospital.resources || {};
        const availableCount =
            selectedFilter === 'ICU_BED' ? resources.icuAvail :
            selectedFilter === 'VENTILATOR' ? resources.ventAvail :
            selectedFilter === 'AMBULANCE' ? resources.ambulanceAvail :
            selectedFilter === 'SPECIALIST' ? resources.specialistAvail : 0;

        return availableCount > 0;
    });
}

function renderMarkers() {
    if (!markersLayer) return;

    markersLayer.clearLayers();
    hospitalMarkers = {};

    const filtered = getFilteredHospitals();
    filtered.forEach(hospital => {
        const marker = L.marker([hospital.lat, hospital.lng], {
            icon: createHospitalIcon(hospital, hospital.name === bestHospitalName)
        });

        marker.bindPopup(buildPopupHTML(hospital), {
            className: 'hospital-popup-shell',
            maxWidth: 320
        });

        marker.on('click', () => {
            bestHospitalName = hospital.name;
            renderMarkers();
            marker.openPopup();
        });

        marker.addTo(markersLayer);
        hospitalMarkers[hospital.name] = marker;
    });
}

function createHospitalIcon(hospital, isBest) {
    const color = hospital.status === 'AVAILABLE'
        ? '#10b981'
        : hospital.status === 'LIMITED'
            ? '#f59e0b'
            : '#ef4444';

    const ringClass = isBest ? 'hospital-marker best' : 'hospital-marker';
    const size = isBest ? 24 : 20;

    return L.divIcon({
        className: 'hospital-marker-wrapper',
        html: `<div class="${ringClass}" style="--marker-color:${color}; width:${size}px; height:${size}px;"></div>`,
        iconSize: [size, size],
        iconAnchor: [size / 2, size / 2]
    });
}

function buildPopupHTML(hospital) {
    const resources = hospital.resources || {};
    const statusTone = hospital.status === 'AVAILABLE'
        ? '#10b981'
        : hospital.status === 'LIMITED'
            ? '#f59e0b'
            : '#ef4444';

    return `
        <div class="hospital-popup">
            <div class="hospital-popup__title">${hospital.name}</div>
            <div class="hospital-popup__meta">${hospital.location}</div>
            <div class="hospital-popup__status" style="color:${statusTone};">${hospital.status}</div>
            <div class="hospital-popup__grid">
                <div><span>ICU</span><strong>${resources.icuAvail || 0}/${resources.icuTotal || 0}</strong></div>
                <div><span>Vent</span><strong>${resources.ventAvail || 0}/${resources.ventTotal || 0}</strong></div>
                <div><span>Amb</span><strong>${resources.ambulanceAvail || 0}/${resources.ambulanceTotal || 0}</strong></div>
                <div><span>Spec</span><strong>${resources.specialistAvail || 0}/${resources.specialistTotal || 0}</strong></div>
            </div>
            <div class="hospital-popup__actions">
                <button type="button" class="popup-btn" onclick="routeTo(${hospital.lat}, ${hospital.lng}, '${escapeHtml(hospital.name)}')">Route</button>
                <a class="popup-btn popup-btn--ghost" href="/hospital/${hospital.id}">Details</a>
            </div>
        </div>
    `;
}

function renderSideList() {
    const list = document.getElementById('hospitalList');
    if (!list) return;

    const filtered = getFilteredHospitals();
    if (!filtered.length) {
        list.innerHTML = '<div class="panel-empty">No hospitals match the current filters.</div>';
        return;
    }

    list.innerHTML = filtered.map(hospital => {
        const resources = hospital.resources || {};
        return `
            <button type="button" class="hospital-list-item status-${hospital.status.toLowerCase()}" onclick="focusHospital('${escapeHtml(hospital.name)}')">
                <div class="hospital-list-item__header">
                    <div class="hospital-list-item__name">${hospital.name}</div>
                    <span class="hospital-list-item__badge">${hospital.status}</span>
                </div>
                <div class="hospital-list-item__location">${hospital.location}</div>
                <div class="hospital-list-item__stats">
                    <span>ICU ${resources.icuAvail || 0}</span>
                    <span>Vent ${resources.ventAvail || 0}</span>
                    <span>Amb ${resources.ambulanceAvail || 0}</span>
                    <span>Spec ${resources.specialistAvail || 0}</span>
                </div>
            </button>
        `;
    }).join('');
}

function updateDestinationOptions() {
    const select = document.getElementById('distSelect');
    if (!select) return;

    const previous = select.value;
    const options = getFilteredHospitals()
        .map(hospital => `<option value="${hospital.lat}|${hospital.lng}|${escapeHtml(hospital.name)}">${hospital.name}</option>`)
        .join('');

    select.innerHTML = '<option value="">Select destination…</option>' + options;
    if (previous) {
        select.value = previous;
    }
}

function renderHeatOverlay() {
    if (!heatLayerGroup) return;

    heatLayerGroup.clearLayers();
    const enabled = document.getElementById('heatmapToggle')?.checked;
    if (!enabled) return;

    getFilteredHospitals().forEach(hospital => {
        const resources = hospital.resources || {};
        const pressure = Math.max(1, (resources.totalAll || 1) - (resources.totalAvail || 0));
        const radius = 300 + pressure * 120;
        const color = hospital.status === 'AVAILABLE'
            ? '#10b981'
            : hospital.status === 'LIMITED'
                ? '#f59e0b'
                : '#ef4444';

        L.circle([hospital.lat, hospital.lng], {
            radius,
            color,
            weight: 0,
            fillColor: color,
            fillOpacity: 0.16
        }).addTo(heatLayerGroup);
    });
}

function requestUserLocation() {
    if (!navigator.geolocation) return;

    navigator.geolocation.getCurrentPosition(position => {
        userLocation = [position.coords.latitude, position.coords.longitude];

        if (userMarker) {
            userMarker.setLatLng(userLocation);
        } else {
            userMarker = L.circleMarker(userLocation, {
                radius: 8,
                color: '#ffffff',
                weight: 3,
                fillColor: '#6366f1',
                fillOpacity: 1
            }).addTo(map).bindPopup('Your location');
        }

        const srcSelect = document.getElementById('srcSelect');
        if (srcSelect && !Array.from(srcSelect.options).some(option => option.value.startsWith('user|'))) {
            const option = document.createElement('option');
            option.value = `user|${userLocation[0]}|${userLocation[1]}`;
            option.textContent = 'My current location';
            option.selected = true;
            srcSelect.prepend(option);
        }

        suggestBestHospital(false);
    });
}

function getSelectedOrigin() {
    const srcSelect = document.getElementById('srcSelect');
    const value = srcSelect?.value || '';

    if (value.startsWith('user|')) {
        const [, lat, lng] = value.split('|');
        return [Number(lat), Number(lng)];
    }

    if (value.includes(',')) {
        const [lat, lng] = value.split(',').map(Number);
        return [lat, lng];
    }

    return userLocation || PUNE_CENTER;
}

function routeTo(lat, lng, hospitalName) {
    if (!map) return;

    const origin = getSelectedOrigin();
    const destination = [lat, lng];

    clearRoute();

    routeLine = L.polyline([origin, destination], {
        color: '#6366f1',
        weight: 4,
        opacity: 0.85,
        dashArray: '10 8'
    }).addTo(map);

    map.fitBounds(routeLine.getBounds(), { padding: [50, 50] });

    const distanceKm = haversine(origin[0], origin[1], lat, lng);
    const etaMinutes = Math.max(4, Math.round((distanceKm / DEFAULT_SPEED_KMPH) * 60));
    const routeInfo = document.getElementById('routeInfo');
    if (routeInfo) {
        routeInfo.innerHTML = `
            <div class="route-result">
                <span>${hospitalName}</span>
                <span>${distanceKm.toFixed(1)} km</span>
                <span>${etaMinutes} min est.</span>
            </div>
        `;
    }
}

function clearRoute() {
    if (routeLine) {
        map.removeLayer(routeLine);
        routeLine = null;
    }

    const routeInfo = document.getElementById('routeInfo');
    if (routeInfo) {
        routeInfo.innerHTML = '';
    }

    const destination = document.getElementById('distSelect');
    if (destination) {
        destination.value = '';
    }
}

function suggestBestHospital(zoomToMarker) {
    const panel = document.getElementById('bestHospitalPanel');
    const filtered = getFilteredHospitals();

    if (!filtered.length) {
        if (panel) panel.innerHTML = '<div class="best-hospital-empty">No hospitals available for the current filters.</div>';
        return;
    }

    const origin = userLocation || PUNE_CENTER;
    const candidate = filtered
        .filter(hospital => hospital.status !== 'CRITICAL')
        .map(hospital => {
            const resources = hospital.resources || {};
            const strength = (resources.totalAvail || 0) * 4
                + (resources.icuAvail || 0) * 3
                + (resources.ventAvail || 0) * 3
                + (resources.ambulanceAvail || 0) * 2
                + (resources.specialistAvail || 0);
            const distanceKm = haversine(origin[0], origin[1], hospital.lat, hospital.lng);
            const score = strength - distanceKm;
            return { hospital, distanceKm, score };
        })
        .sort((left, right) => right.score - left.score)[0];

    if (!candidate) {
        if (panel) panel.innerHTML = '<div class="best-hospital-empty">No safe hospital suggestion right now.</div>';
        return;
    }

    bestHospitalName = candidate.hospital.name;
    if (panel) {
        panel.innerHTML = `
            <div class="best-hospital-card">
                <div>
                    <div class="best-hospital-name">${candidate.hospital.name}</div>
                    <div class="best-hospital-meta">${candidate.hospital.location}</div>
                    <div class="best-hospital-meta">${candidate.distanceKm.toFixed(1)} km away</div>
                </div>
                <button type="button" class="best-hospital-route" onclick="routeTo(${candidate.hospital.lat}, ${candidate.hospital.lng}, '${escapeHtml(candidate.hospital.name)}')">Route</button>
            </div>
        `;
    }

    renderMarkers();

    if (zoomToMarker) {
        focusHospital(candidate.hospital.name);
    }
}

function focusHospital(name) {
    const marker = hospitalMarkers[name];
    if (!marker) return;

    map.setView(marker.getLatLng(), 14, { animate: true });
    marker.openPopup();
}

function pulseLiveDot() {
    const dot = document.getElementById('liveDot');
    if (!dot) return;

    dot.classList.add('pulse-fast');
    window.setTimeout(() => dot.classList.remove('pulse-fast'), 600);
}

function toggleLoader(isVisible) {
    const loader = document.getElementById('mapLoading');
    if (!loader) return;
    loader.classList.toggle('active', isVisible);
}

function haversine(lat1, lon1, lat2, lon2) {
    const radians = degrees => degrees * Math.PI / 180;
    const earthRadiusKm = 6371;
    const dLat = radians(lat2 - lat1);
    const dLon = radians(lon2 - lon1);
    const a = Math.sin(dLat / 2) ** 2
        + Math.cos(radians(lat1)) * Math.cos(radians(lat2)) * Math.sin(dLon / 2) ** 2;
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return earthRadiusKm * c;
}

function escapeHtml(value) {
    return String(value).replace(/'/g, '&#39;');
}
