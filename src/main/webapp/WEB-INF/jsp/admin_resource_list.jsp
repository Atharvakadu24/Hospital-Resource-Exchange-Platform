<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Global Resource Inventory - Exchange.Med</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #6366f1;
            --background: #0f172a;
            --card-bg: rgba(30, 41, 59, 0.7);
            --text-main: #f8fafc;
            --text-dim: #94a3b8;
            --accent: #22d3ee;
            --success: #10b981;
            --warning: #f59e0b;
        }

        body {
            margin: 0;
            font-family: 'Outfit', sans-serif;
            background: #0f172a;
            color: var(--text-main);
        }

        nav {
            padding: 1rem 5%;
            background: rgba(15, 23, 42, 0.9);
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .container { padding: 2rem 5%; }

        table {
            width: 100%;
            border-collapse: collapse;
            background: var(--card-bg);
            border-radius: 1rem;
            overflow: hidden;
        }

        th, td {
            text-align: left;
            padding: 1rem 1.5rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
        }

        th { background: rgba(15, 23, 42, 0.5); color: var(--text-dim); text-transform: uppercase; font-size: 0.75rem; letter-spacing: 0.05em; }

        .status-badge {
            padding: 0.25rem 0.5rem;
            border-radius: 0.25rem;
            font-size: 0.7rem;
            font-weight: 700;
        }

        .status-AVAILABLE { background: rgba(16, 185, 129, 0.2); color: var(--success); }
        .status-RESERVED { background: rgba(245, 158, 11, 0.2); color: var(--warning); }

        .btn {
            padding: 0.4rem 0.8rem;
            border-radius: 0.4rem;
            text-decoration: none;
            font-size: 0.8rem;
            font-weight: 600;
            background: var(--primary);
            color: white;
        }
    </style>
</head>
<body>
    <nav>
        <div style="font-weight: 800; font-size: 1.2rem;">SYSTEM<span style="color: var(--accent);">INVENTORY</span></div>
        <div style="display: flex; gap: 2rem;">
            <a href="/admin/dashboard" style="color: var(--text-dim); text-decoration: none;">Dashboard</a>
            <a href="/" style="color: var(--text-dim); text-decoration: none;">Public Home</a>
        </div>
    </nav>

    <div class="container">
        <h2>Global Resource Inventory</h2>
        <table>
            <thead>
                <tr>
                    <th>Resource</th>
                    <th>Type</th>
                    <th>Hospital</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${resources}" var="res">
                    <tr>
                        <td><strong>${res.resourceName}</strong></td>
                        <td>${res.type}</td>
                        <td>${res.hospital.name}</td>
                        <td><span class="status-badge status-${res.status}">${res.status}</span></td>
                        <td>
                            <a href="/resources/${res.id}" class="btn">View</a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</body>
</html>
