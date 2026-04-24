<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error ${status} - Exchange.Med</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg: #0b1220;
            --card: rgba(15, 23, 42, 0.92);
            --text: #e2e8f0;
            --muted: #94a3b8;
            --accent: #14b8a6;
            --danger: #f97316;
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
            background:
                radial-gradient(circle at top left, rgba(20, 184, 166, 0.18), transparent 35%),
                radial-gradient(circle at bottom right, rgba(249, 115, 22, 0.16), transparent 35%),
                var(--bg);
            color: var(--text);
            font-family: 'Outfit', sans-serif;
        }

        .panel {
            width: min(720px, 100%);
            background: var(--card);
            border: 1px solid rgba(148, 163, 184, 0.18);
            border-radius: 28px;
            padding: 2.5rem;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3);
        }

        .eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 0.9rem;
            border-radius: 999px;
            background: rgba(249, 115, 22, 0.12);
            color: #fdba74;
            font-size: 0.85rem;
            font-weight: 700;
            letter-spacing: 0.04em;
            text-transform: uppercase;
        }

        h1 {
            margin: 1.2rem 0 0.7rem;
            font-size: clamp(2rem, 4vw, 3rem);
            line-height: 1.05;
        }

        p {
            margin: 0;
            color: var(--muted);
            font-size: 1rem;
            line-height: 1.7;
        }

        .meta {
            margin-top: 1.4rem;
            padding: 1rem 1.1rem;
            border-radius: 18px;
            background: rgba(15, 23, 42, 0.75);
            border: 1px solid rgba(148, 163, 184, 0.12);
        }

        .actions {
            margin-top: 1.8rem;
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
        }

        .btn {
            text-decoration: none;
            border-radius: 14px;
            padding: 0.9rem 1.2rem;
            font-weight: 700;
            transition: transform 0.2s ease, opacity 0.2s ease;
        }

        .btn:hover { transform: translateY(-1px); }

        .btn-primary {
            background: linear-gradient(135deg, var(--accent), #0f766e);
            color: white;
        }

        .btn-secondary {
            background: rgba(148, 163, 184, 0.12);
            color: var(--text);
            border: 1px solid rgba(148, 163, 184, 0.18);
        }
    </style>
</head>
<body>
    <div class="panel">
        <div class="eyebrow">Exchange.Med Error ${status}</div>
        <h1>${title}</h1>
        <p>${message}</p>

        <div class="meta">
            <div><strong>Status:</strong> ${status}</div>
            <div><strong>Path:</strong> ${empty path ? 'Unknown' : path}</div>
        </div>

        <div class="actions">
            <a class="btn btn-primary" href="/">Return Home</a>
            <a class="btn btn-secondary" href="/dashboard">Open Dashboard</a>
        </div>
    </div>
</body>
</html>
