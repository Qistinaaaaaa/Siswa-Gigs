<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employer Login | Siswa-Gigs</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: #f8fafc;
            color: #0f172a;
        }
        .auth-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(15, 23, 42, 0.05);
        }
    </style>
</head>
<body class="d-flex align-items-center min-vh-100 py-5">

<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-5">
            <div class="text-center mb-4">
                <div class="d-inline-flex align-items-center gap-2 mb-2">
                    <div class="bg-primary text-white rounded-3 d-flex align-items-center justify-content-center" style="width: 40px; height: 40px;">
                        <i class="bi bi-building-fill fs-5"></i>
                    </div>
                    <h4 class="fw-bold mb-0">Siswa<span class="text-primary">-Gigs</span></h4>
                </div>
                <p class="text-muted small">Employer Portal &bull; Sign in to manage your vacancies</p>
            </div>

            <% if (request.getParameter("error") != null) { %>
                <div class="alert alert-danger rounded-3 small">
                    <i class="bi bi-exclamation-circle me-1"></i> Invalid credentials or unauthorized access.
                </div>
            <% } %>
            <% if ("registered".equals(request.getParameter("status"))) { %>
                <div class="alert alert-success rounded-3 small">
                    <i class="bi bi-check-circle me-1"></i> Company registered! Please log in below.
                </div>
            <% } %>

            <div class="auth-card p-4 p-md-5">
                <h5 class="fw-bold mb-1">Welcome Back</h5>
                <p class="text-muted small mb-4">Enter your registered employer email and password</p>

                <form action="../EmployerLoginServlet" method="post">
                    <input type="hidden" name="role" value="Employer">
                    <div class="mb-3">
                        <label class="form-label small fw-semibold">Email Address</label>
                        <input type="email" name="email" class="form-control rounded-3" placeholder="hr@company.com" required>
                    </div>
                    <div class="mb-4">
                        <label class="form-label small fw-semibold">Password</label>
                        <input type="password" name="password" class="form-control rounded-3" placeholder="••••••••" required>
                    </div>
                    <button type="submit" class="btn btn-primary w-100 py-2 rounded-3 fw-semibold">
                        Sign In to Employer Portal
                    </button>
                </form>

                <div class="text-center mt-4 pt-3 border-top">
                    <span class="text-muted small">New hiring partner?</span>
                    <a href="register.jsp" class="small fw-semibold text-decoration-none ms-1">Register Company Account</a>
                </div>
            </div>
        </div>
    </div>
</div>
                <% if ("registered".equals(request.getParameter("status"))) { %>
                <script>
                    alert("Successfully registered! Your employer account has been created. Please sign in.");
                </script>
                <% } %>
</body>
</html>