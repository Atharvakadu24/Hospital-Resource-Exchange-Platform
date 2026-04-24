<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${hospital.name} - Exchange.Med</title>
    
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
            <c:if test="${isAdmin}">
                <li class="nav-item mt-4">
                    <div class="px-4 text-uppercase fw-bold text-muted" style="font-size: 0.7rem;">Administration</div>
                </li>
                <li class="nav-item">
                    <a href="/admin/logs" class="nav-link">
                        <i class="fa-solid fa-clock-rotate-left"></i> Audit Logs
                    </a>
                </li>
            </c:if>
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
                    <a href="/dashboard" class="text-muted text-decoration-none small">
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
                            <span class="badge bg-light text-primary border">${fn:length(resources)} items</span>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead class="text-muted small text-uppercase">
                                    <tr>
                                        <th>Resource Name</th>
                                        <th>Type</th>
                                        <th>Status</th>
                                        <th class="text-end">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${resources}" var="res">
                                        <tr class="animate-fade">
                                            <td><div class="fw-bold">${res.resourceName}</div></td>
                                            <td><span class="badge bg-light text-muted border-0">${res.type}</span></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${res.status == 'AVAILABLE'}">
                                                        <span class="badge-saas badge-available">${res.status}</span>
                                                    </c:when>
                                                    <c:when test="${res.status == 'RESERVED'}">
                                                        <span class="badge-saas badge-reserved">${res.status}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge-saas badge-inuse">${res.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-end">
                                                <c:choose>
                                                    <c:when test="${isHospitalAdmin and currentHospitalId != null and currentHospitalId != hospital.id and res.status == 'AVAILABLE'}">
                                                        <a href="/requests/new?resourceId=${res.id}" class="btn btn-sm btn-saas">Request</a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <a href="/resources/${res.id}" class="btn btn-sm btn-outline-light">View</a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty resources}">
                                        <tr>
                                            <td colspan="4" class="text-center py-5 text-muted">No resources are registered for this hospital.</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Summary -->
                <div class="col-lg-4">
                    <div class="card-saas">
                        <h5 class="fw-bold mb-4">Hospital Snapshot</h5>
                        <div class="d-flex justify-content-between small mb-2">
                            <span class="text-muted">Contact Number</span>
                            <span class="fw-bold">${hospital.contactNumber}</span>
                        </div>
                        <div class="d-flex justify-content-between small mb-2">
                            <span class="text-muted">Contact Email</span>
                            <span class="fw-bold">${hospital.contactEmail}</span>
                        </div>
                        <div class="d-flex justify-content-between small mb-2">
                            <span class="text-muted">Available Resources</span>
                            <span class="fw-bold">${summary.totalAvail}/${summary.totalAll}</span>
                        </div>
                        <div class="d-flex justify-content-between small mb-4">
                            <span class="text-muted">Network Status</span>
                            <span class="fw-bold">${summary.status}</span>
                        </div>

                        <div class="mt-4 p-3 bg-light rounded-3 text-muted small">
                            <i class="fa-solid fa-circle-info me-2 text-primary"></i>
                            <c:choose>
                                <c:when test="${isHospitalAdmin and currentHospitalId != hospital.id}">
                                    Open any available resource from this hospital to create a request instantly.
                                </c:when>
                                <c:when test="${isHospitalAdmin and currentHospitalId == hospital.id}">
                                    This is your own hospital profile. Requests are available only for other hospitals' resources.
                                </c:when>
                                <c:otherwise>
                                    Review live inventory, quota, and contact details for this hospital.
                                </c:otherwise>
                            </c:choose>
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
