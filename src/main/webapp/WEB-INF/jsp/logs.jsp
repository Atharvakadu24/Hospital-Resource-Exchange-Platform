<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Audit Logs - Exchange.Med</title>
    
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
            <li class="nav-item mt-4">
                <div class="px-4 text-uppercase fw-bold text-muted" style="font-size: 0.7rem;">Administration</div>
            </li>
            <li class="nav-item">
                <a href="/admin/dashboard" class="nav-link">
                    <i class="fa-solid fa-shield-halved"></i> Global Control
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
                    <h2 class="fw-bold mb-0">System Audit Logs</h2>
                    <p class="text-muted">Permanent record of all resource transactions and system events</p>
                </div>
            </div>

            <!-- Logs Table Card -->
            <div class="card-saas">
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="text-muted small text-uppercase">
                            <tr>
                                <th>Timestamp</th>
                                <th>Action</th>
                                <th>Hospital</th>
                                <th>Performed By</th>
                                <th>Details</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${logs}" var="log">
                                <tr class="animate-fade">
                                    <td class="text-muted small" style="font-family: monospace;">${log.timestamp}</td>
                                    <td>
                                        <span class="badge ${fn:contains(log.action, 'REJECT') or fn:contains(log.action, 'DEADLOCK') ? 'bg-danger-light text-danger' : fn:contains(log.action, 'ALLOCATED') ? 'bg-success-light text-success' : 'bg-primary-light text-primary'} border-0">
                                            ${log.action}
                                        </span>
                                    </td>
                                    <td>
                                        <div class="fw-600">${log.hospital != null ? log.hospital.name : "SYSTEM"}</div>
                                    </td>
                                    <td>
                                        <span class="text-muted small"><i class="fa-solid fa-user-shield me-1"></i> ${log.performedBy}</span>
                                    </td>
                                    <td>
                                        <div class="text-muted small text-truncate" style="max-width: 400px;" title="${log.details}">
                                            ${log.details}
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty logs}">
                                <tr>
                                    <td colspan="5" class="text-center py-5 text-muted">No audit logs found.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="/js/realtime.js"></script>
</body>
</html>
