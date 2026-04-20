<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New Request - Exchange.Med</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&display=swap" rel="stylesheet">
    <link href="/css/main.css" rel="stylesheet">
</head>
<body>

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
        <div class="container py-4" style="max-width: 900px;">
            <!-- Header -->
            <div class="mb-5 animate-fade">
                <a href="/marketplace" class="text-decoration-none text-muted small">
                    <i class="fa-solid fa-arrow-left me-1"></i> Back to Marketplace
                </a>
                <h2 class="fw-bold mt-3 mb-1">Initialize Allocation Request</h2>
                <p class="text-muted">Broadcast resource demand to the secure medical network</p>
            </div>

            <div class="row g-4">
                <div class="col-lg-8">
                    <div class="card-saas animate-fade">
                        <form action="/requests/new" method="POST">
                            <div class="row g-4">
                                <div class="col-12">
                                    <label class="form-label fw-bold small text-muted">TARGET RESOURCE</label>
                                    <div class="p-4 rounded-4 border border-primary-light bg-primary-light d-flex align-items-center justify-content-between mb-2">
                                        <div>
                                            <div class="h5 fw-bold text-primary mb-1">${targetResource.resourceName}</div>
                                            <div class="small fw-600">${targetResource.hospital.name}</div>
                                        </div>
                                        <input type="hidden" name="resourceId" value="${targetResource.id}">
                                        <span class="badge bg-white text-primary border px-3 py-2 rounded-pill shadow-sm">
                                            <i class="fa-solid fa-tag me-1 small"></i> ${targetResource.type}
                                        </span>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-bold small text-muted">REQUEST PRIORITY</label>
                                    <select name="priority" class="form-control-saas">
                                        <option value="NORMAL">Normal Priority</option>
                                        <option value="HIGH">High Priority</option>
                                        <option value="EMERGENCY">🚨 Life-Saving Emergency</option>
                                    </select>
                                    <div class="form-text text-danger small mt-2 fw-500">
                                        <i class="fa-solid fa-triangle-exclamation me-1"></i> Emergency bypasses buffers.
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-bold small text-muted">ESTIMATED DURATION</label>
                                    <select name="durationHours" class="form-control-saas">
                                        <option value="1">1 Hour</option>
                                        <option value="4">4 Hours</option>
                                        <option value="12">12 Hours</option>
                                        <option value="24">24 Hours</option>
                                        <option value="48">48 Hours</option>
                                    </select>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-bold small text-muted">START WINDOW</label>
                                    <input type="datetime-local" id="startTime" name="startTime" class="form-control-saas" required>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-bold small text-muted">END WINDOW</label>
                                    <input type="datetime-local" id="endTime" name="endTime" class="form-control-saas" required>
                                </div>

                                <div class="col-12 mt-5">
                                    <button type="submit" class="btn-saas w-100 py-3 fs-6">
                                        <i class="fa-solid fa-share-nodes me-2"></i> Submit Allocation Request
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <div class="col-lg-4">
                    <!-- Policy Info -->
                    <div class="card-saas border-0 bg-primary-light animate-fade" style="animation-delay: 0.2s;">
                        <div class="mb-3 d-flex align-items-center gap-2 text-primary h6 fw-bold">
                            <i class="fa-solid fa-scale-balanced"></i> Network Fairness
                        </div>
                        <p class="small text-muted mb-4 opacity-75">
                            Allocation is governed by proximity, priority, and hospital credit score.
                        </p>
                        
                        <div class="mb-3">
                            <div class="d-flex justify-content-between small fw-bold mb-1">
                                <span>Quota Load</span>
                                <span>${currentQuotaLoad}%</span>
                            </div>
                            <div class="progress" style="height: 6px;">
                                <div class="progress-bar bg-primary" style="width: ${currentQuotaLoad}%"></div>
                            </div>
                        </div>
                        
                        <div class="p-3 bg-white rounded-4 border-0 small text-muted mt-4 shadow-sm">
                            <i class="fa-solid fa-circle-info text-primary me-2"></i>
                            Requests are processed in real-time. You'll be notified of approved status.
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Fix datetime-local inputs: set sensible defaults and enforce browser display
        (function() {
            function toLocalISO(date) {
                const pad = n => String(n).padStart(2,'0');
                return date.getFullYear() + '-' + pad(date.getMonth()+1) + '-' + pad(date.getDate()) +
                       'T' + pad(date.getHours()) + ':' + pad(date.getMinutes());
            }
            const now   = new Date();
            const plus4  = new Date(now.getTime() + 4 * 60 * 60 * 1000);
            const startEl = document.getElementById('startTime');
            const endEl   = document.getElementById('endTime');
            if (startEl) { startEl.min = toLocalISO(now); startEl.value = toLocalISO(now); }
            if (endEl)   { endEl.min   = toLocalISO(now); endEl.value   = toLocalISO(plus4); }
            if (startEl) startEl.addEventListener('change', () => {
                if (endEl) endEl.min = startEl.value;
            });
        })();
    </script>
</body>
</html>
