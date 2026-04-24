<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hospital Admin - ${hospital.name}</title>
    
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
        </ul>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <div class="container-fluid">
            <!-- Header Top Bar -->
            <div class="d-flex justify-content-between align-items-center mb-5">
                <div>
                    <h2 class="fw-bold mb-0 text-gradient">Hospital Console</h2>
                    <p class="text-muted">Managing <span class="fw-600 text-dark">${hospital.name}</span></p>
                </div>
                <div class="d-flex align-items-center gap-3">
                        <div class="text-end d-none d-md-block">
                            <div class="fw-bold small">${user.username}</div>
                            <div class="text-muted smaller">Resource Manager</div>
                    </div>
                    <form action="/logout" method="POST" class="m-0">
                        <button type="submit" class="btn btn-outline-saas btn-sm">
                            <i class="fa-solid fa-arrow-right-from-bracket"></i>
                        </button>
                    </form>
                </div>
            </div>

            <div class="row g-4">
                <!-- Inventory Column -->
                <div class="col-md-8">
                    <div class="card-saas h-100">
                        <h5 class="fw-bold mb-4">Resource Inventory</h5>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead class="text-muted small text-uppercase">
                                    <tr>
                                        <th>Resource Name</th>
                                        <th>Type</th>
                                        <th>Status</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${resources}" var="res">
                                        <tr class="animate-fade">
                                            <td><span class="fw-600">${res.resourceName}</span></td>
                                            <td><span class="text-muted">${res.type}</span></td>
                                            <td>
                                                <span class="badge-saas badge-${res.status == 'AVAILABLE' ? 'available' : res.status == 'RESERVED' ? 'reserved' : 'inuse'}">
                                                    ${res.status}
                                                </span>
                                            </td>
                                            <td>
                                                <form action="/hospital-admin/resource/delete/${res.id}" method="POST" class="m-0" 
                                                      onsubmit="return confirm('Are you sure you want to delete this resource? This action cannot be undone.');">
                                                    <button type="submit" class="btn btn-sm btn-outline-danger border-0" 
                                                            <c:if test="${res.status != 'AVAILABLE'}">disabled title="Cannot delete in-use resource"</c:if>>
                                                        <i class="fa-solid fa-trash-can"></i>
                                                    </button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Add Resource Column -->
                <div class="col-md-4">
                    <div class="card-saas">
                        <h5 class="fw-bold mb-4">Add New Resource</h5>
                        <form action="/hospital-admin/resource/add" method="POST">
                            <div class="mb-3">
                                <label class="form-label text-muted small">Resource Name</label>
                                <input type="text" name="resourceName" class="form-control" placeholder="e.g. ICU-Ventilator-04" required>
                            </div>
                            
                            <div class="mb-4">
                                <label class="form-label text-muted small">Type</label>
                                <select name="type" class="form-select">
                                    <option value="ICU_BED">ICU Bed</option>
                                    <option value="VENTILATOR">Ventilator</option>
                                    <option value="AMBULANCE">Ambulance</option>
                                    <option value="SPECIALIST">Specialist</option>
                                </select>
                            </div>
                            
                            <button type="submit" class="btn btn-saas w-100">
                                <i class="fa-solid fa-plus me-2"></i> Register Resource
                            </button>
                        </form>
                    </div>

                    <!-- Hospital Info Card -->
                    <div class="card-saas mt-4 bg-primary-light">
                        <h6 class="fw-bold mb-3"><i class="fa-solid fa-info-circle me-2"></i> Quota Status</h6>
                        <div class="d-flex justify-content-between mb-2 small">
                            <span class="text-muted">Max Limit</span>
                            <span class="fw-bold">${hospital.resourceQuota}</span>
                        </div>
                        <div class="progress" style="height: 6px;">
                            <div class="progress-bar bg-primary" style="width: ${currentQuotaLoad}%;"></div>
                        </div>
                        <div class="small text-muted mt-2">${currentQuotaLoad}% of quota currently engaged</div>
                    </div>

                    <div class="card-saas mt-4">
                        <h6 class="fw-bold mb-3"><i class="fa-solid fa-wave-square me-2 text-primary"></i> Request Activity</h6>
                        <div class="d-flex justify-content-between small">
                            <span class="text-muted">Open requests</span>
                            <span class="fw-bold">${pendingRequests}</span>
                        </div>
                    </div>
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
