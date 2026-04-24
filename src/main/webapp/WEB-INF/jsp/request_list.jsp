<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Requests - Exchange.Med</title>
    
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
                <a href="/marketplace" class="nav-link">
                    <i class="fa-solid fa-store"></i> Marketplace
                </a>
            </li>
            <li class="nav-item">
                <a href="/map" class="nav-link">
                    <i class="fa-solid fa-map-location-dot"></i> Live Map
                </a>
            </li>
            <li class="nav-item active">
                <a href="/requests" class="nav-link active">
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
                    <h2 class="fw-bold mb-0">Exchange Network Requests</h2>
                    <p class="text-muted">Live status of all resource allocation requests</p>
                </div>
            </div>

            <!-- Requests Table Card -->
            <div class="card-saas">
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="text-muted small text-uppercase">
                            <tr>
                                <th>Requester</th>
                                <th>Resource Type</th>
                                <th>Priority</th>
                                <th>Status</th>
                                <th>Requested At</th>
                                <th class="text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${requests}" var="req">
                                <tr class="animate-fade">
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <div class="rounded-circle bg-light p-2" style="width: 32px; height: 32px; display:flex; align-items:center; justify-content:center;">
                                                <i class="fa-solid fa-h small text-primary"></i>
                                            </div>
                                            <span class="fw-600">${req.requesterHospital.name}</span>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="text-muted">${req.resourceType}</span>
                                    </td>
                                    <td>
                                        <span class="badge ${req.priority == 'EMERGENCY' ? 'bg-danger-light text-danger' : req.priority == 'HIGH' ? 'bg-warning-light text-warning' : 'bg-primary-light text-primary'} border-0">
                                            ${req.priority}
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge-saas badge-${req.status == 'APPROVED' ? 'available' : req.status == 'WAITING' ? 'reserved' : 'inuse'}">
                                            ${req.status}
                                        </span>
                                    </td>
                                    <td class="text-muted small">${req.requestedAt}</td>
                                    <td class="text-end">
                                        <div class="d-flex justify-content-end gap-2">
                                            <c:if test="${isAdmin and (req.status == 'PENDING' or req.status == 'WAITING')}">
                                                <form action="/requests/allocate/${req.id}" method="POST" class="m-0">
                                                    <button type="submit" class="btn btn-sm btn-saas">Allocate</button>
                                                </form>
                                            </c:if>
                                            <c:if test="${(isAdmin or currentHospitalId == req.requesterHospital.id) and (req.status == 'PENDING' or req.status == 'WAITING')}">
                                                <form action="/requests/cancel/${req.id}" method="POST" class="m-0">
                                                    <button type="submit" class="btn btn-sm btn-outline-danger">Cancel</button>
                                                </form>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty requests}">
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">No requests found in the network.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
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
    <script src="/js/realtime.js"></script>
</body>
</html>
