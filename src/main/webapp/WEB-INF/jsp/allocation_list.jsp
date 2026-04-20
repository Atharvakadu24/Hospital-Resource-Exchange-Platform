<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Allocations - Exchange.Med</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&display=swap" rel="stylesheet">
    <link href="/css/main.css" rel="stylesheet">
</head>
<body>

    <!-- Sidebar -->
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
                <a href="/marketplace" class="nav-link">
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
                    <h2 class="fw-bold mb-0">Resource Allocations</h2>
                    <p class="text-muted">Active and upcoming resource bookings across the network</p>
                </div>
            </div>

            <!-- Allocations Grid -->
            <div class="row g-4">
                <c:forEach items="${bookings}" var="booking">
                    <div class="col-md-4">
                        <div class="card-saas h-100 animate-fade <c:if test='${!booking.released}'>border-success-light</c:if>">
                            <div class="d-flex justify-content-between align-items-start mb-3">
                                <div class="stat-icon bg-primary-light">
                                    <i class="fa-solid fa-calendar-check"></i>
                                </div>
                                <span class="badge ${booking.released ? 'bg-light text-muted' : 'bg-success-light text-success'} border-0">
                                    ${booking.released ? 'CLOSED' : 'ACTIVE'}
                                </span>
                            </div>
                            
                            <h5 class="fw-bold mb-1">${booking.resource.resourceName}</h5>
                            <p class="text-primary small mb-3">Requester: ${booking.request.requesterHospital.name}</p>

                            <div class="mt-3 text-muted small">
                                <div class="mb-2"><i class="fa-regular fa-clock me-2"></i> Starts: ${booking.request.startTime}</div>
                                <div><i class="fa-solid fa-hourglass-end me-2"></i> Release: ${booking.releaseAt}</div>
                            </div>

                            <div class="mt-4 pt-3 border-top d-flex justify-content-between align-items-center">
                                <span class="text-muted small">${booking.resource.type}</span>
                                <c:if test="${!booking.released}">
                                    <div class="pulse-small"></div>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                <c:if test="${empty bookings}">
                    <div class="col-12">
                        <div class="card-saas text-center py-5 text-muted">No active allocations found in the network.</div>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="/js/realtime.js"></script>
</body>
</html>
