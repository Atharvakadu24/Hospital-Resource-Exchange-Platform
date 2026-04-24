<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Global Control - Exchange.Med</title>
    
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
                <a href="/admin/dashboard" class="nav-link active">
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
                <a href="/map" class="nav-link">
                    <i class="fa-solid fa-map-location-dot"></i> Live Map
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
            <!-- Header Top Bar -->
            <div class="d-flex justify-content-between align-items-center mb-5">
                <div>
                    <h2 class="fw-bold mb-0 text-gradient">Network Overview</h2>
                    <p class="text-muted">Welcome back, <span class="fw-600 text-dark">${user.username}</span></p>
                </div>
                <div class="d-flex align-items-center gap-3">
                    <div class="text-end d-none d-md-block">
                        <div class="fw-bold small">${user.username}</div>
                        <div class="text-muted smaller">${isAdmin ? 'Platform Admin' : 'Hospital Admin'}</div>
                    </div>
                    <form action="/logout" method="POST" class="m-0">
                        <button type="submit" class="btn btn-outline-saas btn-sm">
                            <i class="fa-solid fa-arrow-right-from-bracket"></i>
                        </button>
                    </form>
                </div>
            </div>

            <div class="row g-4">
                <!-- Stat Cards -->
                <div class="col-md-3">
                    <div class="card-saas">
                        <div class="stat-card">
                            <div class="stat-icon bg-primary-light">
                                <i class="fa-solid fa-hospital"></i>
                            </div>
                            <div>
                                <div class="text-muted small">Total Hospitals</div>
                                <div class="fs-4 fw-bold">${fn:length(hospitals)}</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card-saas animate-fade" style="animation-delay: 0.1s;">
                        <div class="stat-card">
                            <div class="stat-icon bg-success-light">
                                <i class="fa-solid fa-microchip"></i>
                            </div>
                            <div>
                                <div class="text-muted small">Resources</div>
                                <div class="h4 fw-bold mb-0">${fn:length(resources)}</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card-saas animate-fade" style="animation-delay: 0.2s;">
                        <div class="stat-card">
                            <div class="stat-icon bg-warning-light">
                                <i class="fa-solid fa-check-circle"></i>
                            </div>
                            <div>
                                <div class="text-muted small">Available</div>
                                <div class="h4 fw-bold mb-0">${availableResources}</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card-saas animate-fade" style="animation-delay: 0.3s;">
                        <div class="stat-card">
                            <div class="stat-icon bg-danger-light">
                                <i class="fa-solid fa-pulse"></i>
                            </div>
                            <div>
                                <div class="text-muted small">Uptime</div>
                                <div class="h4 fw-bold mb-0">${activeAllocations}</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Hospital Quotas Table -->
            <div class="card-saas">
                <h5 class="fw-bold mb-4">Hospital Network Status</h5>
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="text-muted small text-uppercase">
                            <tr>
                                <th>Hospital Name</th>
                                <th>Location</th>
                                <th>Resource Quota</th>
                                <th>Current Load</th>
                                <th class="text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${hospitals}" var="h">
                                <tr class="animate-fade">
                                    <td>
                                        <div class="fw-bold">${h.name}</div>
                                        <div class="text-muted small">ID: #${h.id}</div>
                                    </td>
                                    <td><span class="text-muted">${h.location}</span></td>
                                    <td>
                                        <span class="badge bg-light text-primary border">${h.resourceQuota} units</span>
                                    </td>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <div class="progress flex-grow-1" style="height: 6px;">
                                                <div class="progress-bar bg-primary" style="width: ${hospitalLoads[h.id]}%"></div>
                                            </div>
                                            <span class="small fw-bold">${hospitalLoads[h.id]}% / ${h.resourceQuota}</span>
                                        </div>
                                    </td>
                                    <td class="text-end">
                                        <div class="d-flex justify-content-end gap-2">
                                            <a href="/hospital/${h.id}" class="btn btn-sm btn-saas">
                                                Manage <i class="fa-solid fa-chevron-right ms-1 small"></i>
                                            </a>
                                            <form action="/admin/hospitals/delete/${h.id}" method="POST" class="m-0">
                                                <button type="submit" class="btn btn-sm btn-outline-danger">Delete</button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="card-saas mt-4">
                <h5 class="fw-bold mb-4">Add Hospital</h5>
                <form action="/admin/hospitals" method="POST">
                    <div class="row g-3">
                        <div class="col-md-4">
                            <input type="text" name="name" class="form-control" placeholder="Hospital name" required>
                        </div>
                        <div class="col-md-4">
                            <input type="text" name="location" class="form-control" placeholder="Location" required>
                        </div>
                        <div class="col-md-4">
                            <input type="number" name="resourceQuota" class="form-control" placeholder="Quota" min="1" required>
                        </div>
                        <div class="col-md-4">
                            <input type="text" name="contactNumber" class="form-control" placeholder="Contact number" required>
                        </div>
                        <div class="col-md-4">
                            <input type="email" name="contactEmail" class="form-control" placeholder="Contact email" required>
                        </div>
                        <div class="col-md-2">
                            <input type="number" step="0.000001" name="latitude" class="form-control" placeholder="Latitude" required>
                        </div>
                        <div class="col-md-2">
                            <input type="number" step="0.000001" name="longitude" class="form-control" placeholder="Longitude" required>
                        </div>
                        <div class="col-md-3">
                            <input type="text" name="adminUsername" class="form-control" placeholder="Hospital admin username">
                        </div>
                        <div class="col-md-3">
                            <input type="text" name="adminPassword" class="form-control" placeholder="Hospital admin password">
                        </div>
                        <div class="col-md-3">
                            <button type="submit" class="btn btn-saas w-100">Create Hospital</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script id="global-loader-init">
        // Global form submit loader
        document.querySelectorAll('form').forEach(f => {
            f.addEventListener('submit', () => {
                const loader = document.getElementById('global-loader');
                if (loader) loader.classList.add('active');
            });
        });
    </script>
</body>
</html>
