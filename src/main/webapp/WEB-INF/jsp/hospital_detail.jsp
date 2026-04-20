<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${hospital.name} - System Admin</title>
    
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
                <a href="/admin/dashboard" class="nav-link">
                    <i class="fa-solid fa-shield-halved"></i> Global Control
                </a>
            </li>
            <li class="nav-item mt-4">
                <div class="px-4 text-uppercase fw-bold text-muted" style="font-size: 0.7rem;">Navigation</div>
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
                <a href="/admin/logs" class="nav-link">
                    <i class="fa-solid fa-clock-rotate-left"></i> Audit Logs
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
            <div class="mb-5">
                <div class="d-flex align-items-center gap-3 mb-2">
                    <a href="/admin/dashboard" class="text-muted text-decoration-none small">
                        <i class="fa-solid fa-arrow-left me-1"></i> Back to Network
                    </a>
                </div>
                <h2 class="fw-bold mb-0">${hospital.name}</h2>
                <div class="text-muted">
                    <i class="fa-solid fa-location-dot me-1"></i> ${hospital.location} 
                    <span class="mx-2">|</span> 
                    <i class="fa-solid fa-box me-1"></i> Quota: ${hospital.resourceQuota} units
                </div>
            </div>

            <c:if test="${param.requested}">
                <div class="alert alert-success card-saas border-success mb-4 animate-fade">
                    <i class="fa-solid fa-circle-check me-2"></i>
                    Request submitted successfully. The system is simulating allocation...
                </div>
            </c:if>

            <div class="row g-4">
                <!-- Managed Resources -->
                <div class="col-lg-8">
                    <div class="card-saas h-100">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h5 class="fw-bold mb-0">Managed Resources</h5>
                            <span class="badge bg-light text-primary border">${resources.size()} items</span>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead class="text-muted small text-uppercase">
                                    <tr>
                                        <th>Resource Name</th>
                                        <th>Type</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${resources}" var="res">
                                        <tr class="animate-fade">
                                            <td><div class="fw-bold">${res.resourceName}</div></td>
                                            <td><span class="badge bg-light text-muted border-0">${res.type}</span></td>
                                            <td>
                                                <span class="badge-saas badge-${res.status.toLowerCase().replace('_', '')}">
                                                    ${res.status}
                                                </span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Request Form -->
                <div class="col-lg-4">
                    <div class="card-saas">
                        <h5 class="fw-bold mb-4">Request Resource</h5>
                        <form action="/resources/request" method="POST">
                            <input type="hidden" name="hospitalId" value="${hospital.id}">
                            
                            <div class="mb-3">
                                <label class="form-label text-muted small fw-bold">Resource Type</label>
                                <select name="type" class="form-control-saas">
                                    <option value="ICU_BED">ICU Bed</option>
                                    <option value="VENTILATOR">Ventilator</option>
                                    <option value="AMBULANCE">Ambulance</option>
                                    <option value="SPECIALIST">Specialist</option>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label text-muted small fw-bold">Priority Level</label>
                                <select name="priority" class="form-control-saas">
                                    <option value="NORMAL">Normal</option>
                                    <option value="HIGH">High</option>
                                    <option value="EMERGENCY">Emergency (Critical)</option>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label text-muted small fw-bold">Start Time</label>
                                <input type="datetime-local" name="startTime" class="form-control-saas" required>
                            </div>

                            <div class="mb-4">
                                <label class="form-label text-muted small fw-bold">End Time</label>
                                <input type="datetime-local" name="endTime" class="form-control-saas" required>
                            </div>

                            <button type="submit" class="btn-saas w-100">
                                <i class="fa-solid fa-paper-plane me-2"></i> Submit Request
                            </button>
                        </form>
                        <div class="mt-4 p-3 bg-light rounded-3 text-muted small">
                            <i class="fa-solid fa-circle-info me-2 text-primary"></i>
                            Allocations are processed using deadlock-prevention algorithms.
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
