<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Network Monitor - Exchange.Med</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&display=swap" rel="stylesheet">
    <link href="/css/main.css" rel="stylesheet">
    <style>
        .queue-item {
            position: relative;
            padding-left: 2rem;
            margin-bottom: 2rem;
        }
        .queue-item::before {
            content: '';
            position: absolute;
            left: 0.5rem;
            top: 1rem;
            bottom: -2rem;
            width: 2px;
            background: var(--border);
        }
        .queue-item:last-child::before { display: none; }
        .queue-dot {
            position: absolute;
            left: 0;
            top: 0.5rem;
            width: 1rem;
            height: 1rem;
            background: var(--primary);
            border-radius: 50%;
            border: 3px solid white;
            box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.1);
        }
        .wait-graph-node {
            border: 1.5px dashed var(--border);
            padding: 1rem;
            border-radius: 0.5rem;
            font-size: 0.8rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }
    </style>
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
            <li class="nav-item">
                <a href="/monitor" class="nav-link active">
                    <i class="fa-solid fa-chart-line"></i> Monitor
                </a>
            </li>
        </ul>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <div class="container-fluid">
            <!-- Header -->
            <div class="mb-5">
                <h2 class="fw-bold mb-0">Network Traffic Monitor</h2>
                <p class="text-muted">Live visualization of resource allocation and waiting cycles</p>
            </div>

            <div class="row g-4">
                <!-- Priority Queue Visualization -->
                <div class="col-md-7">
                    <div class="card-saas h-100">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h5 class="fw-bold mb-0">Priority Allocation Queue</h5>
                            <span class="badge bg-primary-light">${fn:length(waitingRequests)} hospitals waiting</span>
                        </div>

                        <div class="queue-container p-3">
                            <c:forEach items="${waitingRequests}" var="req" varStatus="status">
                                <div class="queue-item animate-fade" style="animation-delay: ${status.index * 0.1}s">
                                    <div class="queue-dot"></div>
                                    <div class="p-3 rounded-4 border bg-white shadow-sm">
                                        <div class="d-flex justify-content-between align-items-center mb-2">
                                            <div class="fw-bold">${req.requesterHospital.name}</div>
                                            <span class="badge ${req.priority == 'EMERGENCY' ? 'bg-danger' : req.priority == 'HIGH' ? 'bg-warning' : 'bg-primary'} font-monospace">
                                                ${req.priority}
                                            </span>
                                        </div>
                                        <div class="d-flex gap-2 text-muted small">
                                            <span>Waiting for: <strong>${req.resourceType}</strong></span>
                                            <span>•</span>
                                            <span>Since: ${req.requestedAt}</span>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                            <c:if test="${empty waitingRequests}">
                                <div class="text-center py-5 text-muted">
                                    <i class="fa-solid fa-circle-check fs-1 mb-3 d-block opacity-25"></i>
                                    Network clear. No active waiting requests.
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>

                <!-- Wait-for Graph / Deadlock Monitor -->
                <div class="col-md-5">
                    <div class="card-saas h-100">
                        <h5 class="fw-bold mb-4">Wait-for Graph (Isolation Monitor)</h5>
                        <div class="alert alert-success border-0 rounded-4 small">
                            <i class="fa-solid fa-shield-cat me-2"></i> No circular dependencies detected.
                        </div>

                        <div class="mt-4">
                            <label class="text-muted small text-uppercase fw-bold mb-3 d-block">Active Dependencies</label>
                            <div class="d-flex flex-column gap-3">
                                <c:forEach items="${dependencies}" var="dep">
                                    <div class="wait-graph-node">
                                        <div class="fw-bold">${dep.fromHospital}</div>
                                        <i class="fa-solid fa-arrow-right-long text-muted"></i>
                                        <div class="text-primary">${dep.toHospital}</div>
                                    </div>
                                </c:forEach>
                                <c:if test="${empty dependencies}">
                                    <div class="p-4 rounded-4 border border-dashed text-center text-muted small">
                                        No hospital dependencies active
                                    </div>
                                </c:if>
                            </div>
                        </div>

                        <div class="mt-5 p-4 bg-light rounded-4">
                            <h6 class="fw-bold"><i class="fa-solid fa-bolt me-2 text-warning"></i> Deadlock Prevention</h6>
                            <p class="text-muted small mb-0">Wait-for graph is updated in real-time. Incoming cycles are broken by systematic request rejection (Simulation mode active).</p>
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
    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
    <script src="/js/realtime.js"></script>
</body>
</html>
