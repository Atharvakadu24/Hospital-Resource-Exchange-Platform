<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Marketplace - Exchange.Med</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&display=swap" rel="stylesheet">
    <link href="/css/main.css" rel="stylesheet">
</head>
<body>

    <!-- Sidebar Toggle (Mobile) -->
    <div class="sidebar-toggle" onclick="document.querySelector('.sidebar').classList.toggle('active')">
        <i class="fa-solid fa-bars"></i>
    </div>

    <!-- Sidebar (Same as Dashboard) -->
    <div class="sidebar">
        <div class="brand">
            <i class="fa-solid fa-hospital-user"></i>
            <span>Exchange.Med</span>
        </div>
        <ul class="sidebar-nav">
            <li class="nav-item">
                <a href="/dashboard" class="nav-link">
                    <i class="fa-solid fa-house"></i> Overview
                </a>
            </li>
            <li class="nav-item">
                <a href="/marketplace" class="nav-link active">
                    <i class="fa-solid fa-store"></i> Marketplace
                </a>
            </li>
            <li class="nav-item">
                <a href="/map" class="nav-link">
                    <i class="fa-solid fa-map-location-dot"></i> Live Map
                </a>
            </li>
            <li class="nav-item">
                <a href="/requests" class="nav-link">
                    <i class="fa-solid fa-code-pull-request"></i> Requests
                </a>
            </li>
            <li class="nav-item">
                <a href="/monitor" class="nav-link">
                    <i class="fa-solid fa-chart-line"></i> Monitor
                </a>
            </li>
        </ul>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <div class="container-fluid">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="fw-bold mb-0">Resource Marketplace</h2>
                    <p class="text-muted">Real-time availability across the network</p>
                </div>
                <div class="input-group w-25">
                    <span class="input-group-text bg-white border-end-0"><i class="fa-solid fa-magnifying-glass text-muted"></i></span>
                    <input type="text" class="form-control border-start-0" placeholder="Search resources...">
                </div>
            </div>

            <!-- Marketplace Grid -->
            <div class="row g-4">
                <c:forEach items="${allResources}" var="res">
                    <div class="col-md-4" id="resource-container-${res.id}">
                        <div class="card-saas h-100 animate-fade" id="resource-card-${res.id}">
                            <div class="d-flex justify-content-between align-items-start mb-3">
                                <div class="stat-icon ${res.id % 2 == 0 ? 'bg-primary-light' : 'bg-success-light'}">
                                    <i class="fa-solid ${res.type == 'ICU_BED' ? 'fa-bed-pulse' : res.type == 'VENTILATOR' ? 'fa-mask-ventilator' : 'fa-truck-medical'}"></i>
                                </div>
                                <span class="badge-saas badge-${res.status == 'AVAILABLE' ? 'available' : res.status == 'RESERVED' ? 'reserved' : 'inuse'}" id="resource-badge-${res.id}">
                                    ${res.status}
                                </span>
                            </div>
                            
                            <h5 class="fw-bold mb-1">${res.resourceName}</h5>
                            <p class="text-muted small mb-3">Host: ${res.hospital.name}</p>

                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <div class="text-muted small">
                                    <i class="fa-solid fa-location-dot me-1"></i> ${res.hospital.location}
                                </div>
                                <c:choose>
                                    <c:when test="${isHospitalAdmin and currentHospitalId != null and currentHospitalId != res.hospital.id and res.status == 'AVAILABLE'}">
                                        <a href="/requests/new?resourceId=${res.id}" class="btn btn-sm btn-saas">
                                            Request
                                        </a>
                                    </c:when>
                                    <c:when test="${isHospitalAdmin and currentHospitalId == res.hospital.id}">
                                        <button class="btn btn-sm btn-link text-muted p-0 text-decoration-none" disabled>
                                            Your Resource
                                        </button>
                                    </c:when>
                                    <c:when test="${isAdmin}">
                                        <a href="/resources/${res.id}" class="btn btn-sm btn-outline-light">
                                            View
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <button class="btn btn-sm btn-link text-muted p-0 text-decoration-none" disabled>
                                            Unavailable
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>

    <!-- Global Loader -->
    <div id="global-loader" class="loading-overlay">
        <div class="spinner"></div>
        <div class="loading-text">Processing Request...</div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
    <script src="/js/realtime.js"></script>
</body>
</html>
