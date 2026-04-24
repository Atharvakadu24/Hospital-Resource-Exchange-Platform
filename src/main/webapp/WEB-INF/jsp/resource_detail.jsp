<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${resource.resourceName} Detail - Exchange.Med</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #6366f1;
            --background: #0f172a;
            --card-bg: rgba(30, 41, 59, 0.7);
            --text-main: #f8fafc;
            --text-dim: #94a3b8;
            --accent: #22d3ee;
        }

        body {
            margin: 0;
            font-family: 'Outfit', sans-serif;
            background: radial-gradient(circle at top right, #1e1b4b, #0f172a);
            color: var(--text-main);
            min-height: 100vh;
        }

        nav {
            padding: 1rem 5%;
            background: rgba(15, 23, 42, 0.9);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .container {
            max-width: 800px;
            margin: 3rem auto;
            padding: 0 2rem;
        }

        .detail-card {
            background: var(--card-bg);
            backdrop-filter: blur(10px);
            padding: 3rem;
            border-radius: 2rem;
            border: 1px solid rgba(255, 255, 255, 0.05);
        }

        .label { color: var(--text-dim); font-size: 0.8rem; text-transform: uppercase; margin-bottom: 0.25rem; }
        .value { font-size: 1.5rem; font-weight: 600; margin-bottom: 2rem; }

        .status-pill {
            display: inline-block;
            padding: 0.5rem 1rem;
            border-radius: 9999px;
            font-weight: 700;
            font-size: 0.8rem;
            background: rgba(34, 211, 238, 0.2);
            color: var(--accent);
        }
    </style>
</head>
<body>
    <nav>
        <div style="font-weight: 800; color: var(--accent);">RESOURCE<span style="color: white;">DETAIL</span></div>
        <a href="javascript:history.back()" style="color: var(--text-dim); text-decoration: none;">&larr; Back</a>
    </nav>

    <div class="container">
        <div class="detail-card">
            <div class="label">Resource Name</div>
            <div class="value">${resource.resourceName}</div>

            <div class="label">Type</div>
            <div class="value">${resource.type}</div>

            <div class="label">Host Hospital</div>
            <div class="value">${resource.hospital.name}</div>

            <div class="label">Location</div>
            <div class="value">${resource.hospital.location}</div>

            <div class="label">Current Status</div>
            <div class="status-pill">${resource.status}</div>

            <c:if test="${resource.status == 'AVAILABLE'}">
                <div style="margin-top: 3rem;">
                    <a href="/requests/new?resourceId=${resource.id}" style="color: var(--primary); font-weight: 600; text-decoration: none;">Request Allocation &rarr;</a>
                </div>
            </c:if>
        </div>
    </div>
</body>
</html>
