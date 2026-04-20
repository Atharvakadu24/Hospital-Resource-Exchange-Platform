<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Active Monitor - Exchange.Med</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&display=swap" rel="stylesheet">
    <link href="/css/main.css" rel="stylesheet">
    <style>
        .pulse {
            width: 8px; height: 8px;
            border-radius: 50%;
            background: #10b981;
            box-shadow: 0 0 0 rgba(16, 185, 129, 0.4);
            animation: pulse-ring 1.5s infinite;
        }
        @keyframes pulse-ring {
            0% { transform: scale(0.9); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7); }
            70% { transform: scale(1); box-shadow: 0 0 0 10px rgba(16, 185, 129, 0); }
            100% { transform: scale(0.9); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
        }
    </style>
</head>
<body>

    <!-- Sidebar Toggle (Mobile) -->
    <div class="sidebar-toggle" onclick="document.querySelector('.sidebar').classList.toggle('active')">
        <i class="fa-solid fa-bars"></i>
    </div>

    <!-- Sidebar -->
    <div class="sidebar">
        <div class="brand">
            <i class="fa-solid fa-hospital-user"></i>
            <span>Exchange.Med</span>
        </div>
        <ul class="sidebar-nav">
            <li class="nav-item">
                <a href="/admin/dashboard" class="nav-link">
                    <i class="fa-solid fa-shield-halved"></i> Global Control
                </a>
            </li>
            <li class="nav-item">
                <a href="/admin/logs" class="nav-link">
                    <i class="fa-solid fa-clock-rotate-left"></i> Audit Logs
                </a>
            </li>
            <li class="nav-item mt-4">
                <div class="px-4 text-uppercase fw-bold text-muted" style="font-size: 0.7rem;">Quick Links</div>
            </li>
            <li class="nav-item">
                <a href="/marketplace" class="nav-link">
                    <i class="fa-solid fa-store"></i> Marketplace
                </a>
            </li>
            <li class="nav-item">
                <a href="/monitor" class="nav-link active">
                    <i class="fa-solid fa-chart-line"></i> Monitor
                </a>
            </li>
        </ul>
        
        <div class="position-absolute bottom-0 w-100 p-3">
            <form action="/logout" method="POST">
                <button type="submit" class="btn btn-outline-danger w-100 border-0 text-start">
                    <i class="fa-solid fa-right-from-bracket me-2"></i> Sign Out
                </button>
            </form>
        </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <div class="container-fluid">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-5">
                <div>
                    <h2 class="fw-bold mb-0 d-flex align-items-center gap-2">
                        Network Traffic Monitor <div class="pulse"></div>
                    </h2>
                    <p class="text-muted">Real-time active resource allocations</p>
                </div>
            </div>

            <div class="row g-4 monitor-grid">
                <c:forEach items="${bookings}" var="booking">
                    <c:if test="${!booking.released}">
                        <div class="col-md-4 col-xl-3 animate-fade">
                            <div class="card-saas h-100 d-flex flex-column gap-2">
                                <div class="text-muted small fw-bold">RESOURCE ID: #${booking.resource.id}</div>
                                <div class="h5 fw-bold mb-0">${booking.resource.resourceName}</div>
                                <div class="text-primary small fw-bold">
                                    <i class="fa-solid fa-hospital-user me-1"></i> Held by: ${booking.request.requesterHospital.name}
                                </div>
                                <div class="mt-3 pt-3 border-top small text-muted d-flex align-items-center gap-2">
                                    <i class="fa-solid fa-hourglass-start opacity-50"></i> Active Transfer
                                </div>
                            </div>
                        </div>
                    </c:if>
                </c:forEach>
                <c:if test="${empty bookings}">
                    <div class="col-12 text-center py-5 text-muted">
                        <i class="fa-solid fa-signal-perfect fs-1 mb-3 opacity-25"></i>
                        <p>No active allocations at this moment.</p>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
