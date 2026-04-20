<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit ${resource.resourceName} - Exchange.Med</title>
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
            background: #0f172a;
            color: var(--text-main);
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
        }

        .edit-card {
            background: var(--card-bg);
            padding: 3rem;
            border-radius: 2rem;
            width: 100%;
            max-width: 500px;
            border: 1px solid rgba(255, 255, 255, 0.05);
        }

        input, select {
            width: 100%;
            padding: 0.75rem;
            border-radius: 0.75rem;
            background: rgba(15, 23, 42, 0.8);
            border: 1px solid rgba(255, 255, 255, 0.1);
            color: white;
            margin-bottom: 1.5rem;
            box-sizing: border-box;
        }

        .btn {
            width: 100%;
            padding: 1rem;
            border-radius: 1rem;
            font-weight: 700;
            background: var(--primary);
            color: white;
            border: none;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <div class="edit-card">
        <h2>Edit Resource</h2>
        <form:form action="/resources/update/${resource.id}" method="POST" modelAttribute="resource">
            <label>Resource Name</label>
            <form:input path="resourceName" />
            
            <label>Type</label>
            <form:select path="type">
                <form:options items="${resourceTypes}" />
            </form:select>

            <label>Status</label>
            <form:select path="status">
                <form:options items="${resourceStatuses}" />
            </form:select>
            
            <button type="submit" class="btn">Save Changes</button>
        </form:form>
    </div>
</body>
</html>
