<%--
    Document   : login
    Created on : Nov 21, 2026, 2:16:03 PM
    Author     : HP
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Login | Siswa-Gigs</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 50%, #2563eb 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        .login-wrapper {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 0;
        }
        .login-card {
            border: none;
            border-radius: 20px;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
        }

        .navbar {
            backdrop-filter: blur(10px);
            background-color: rgba(255, 255, 255, 0.9);
        }
        .dropdown-item.active,
        .dropdown-item.active:hover {
            background-color: #eff6ff;
            color: #1d4ed8;
            font-weight: 600;
        }
    </style>
</head>
<body>

    <!-- Navigation Bar -->
    <nav class="navbar navbar-expand-lg sticky-top border-bottom py-3">
        <div class="container">
            <a class="navbar-brand fw-bold fs-4 text-primary d-flex align-items-center gap-2" href="../index.jsp">
                <i class="bi bi-briefcase-fill"></i>
                <span>Siswa<span class="text-dark">-Gigs</span></span>
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <div class="d-flex align-items-center gap-3 mt-3 mt-lg-0 ms-lg-auto">
                    <div class="dropdown">
                        <button class="btn btn-outline-primary fw-semibold px-3 rounded-pill dropdown-toggle btn-sm" type="button" data-bs-toggle="dropdown">
                            Login
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0">
                            <li>
                                <a class="dropdown-item py-2 active" href="login.jsp" aria-current="page">
                                    <i class="bi bi-mortarboard me-2 text-primary"></i> Student Login
                                    <i class="bi bi-check2 ms-2"></i>
                                </a>
                            </li>
                            <li><a class="dropdown-item py-2" href="../employer/login.jsp"><i class="bi bi-building me-2 text-success"></i> Employer Login</a></li>
                        </ul>
                    </div>
                    <div class="dropdown">
                        <button class="btn btn-primary fw-semibold px-3 rounded-pill shadow-sm dropdown-toggle btn-sm" type="button" data-bs-toggle="dropdown">
                            Register
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0">
                            <li><a class="dropdown-item py-2" href="register.jsp"><i class="bi bi-mortarboard me-2 text-primary"></i> Register as Student</a></li>
                            <li><a class="dropdown-item py-2" href="../employer/register.jsp"><i class="bi bi-building me-2 text-success"></i> Register as Employer</a></li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </nav>

    <div class="login-wrapper">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-5 col-lg-4">
                <div class="card login-card p-4 p-md-5 bg-white">
                    <div class="text-center mb-4">
                        <h4 class="fw-bold text-dark">Student Login</h4>
                        <p class="text-muted small">Access your student portal to explore gigs</p>
                    </div>

                    <!-- Alert / Mesej Ralat Spesifik -->
                    <%
                        String registration = request.getParameter("registration");
                        String error = request.getParameter("error");

                        if ("success".equals(registration)) {
                    %>
                        <div class="alert alert-success text-center small mb-4 py-2" role="alert">
                            <i class="bi bi-check-circle-fill me-1"></i> Registration successful! Please log in.
                        </div>
                    <%
                        }
                        if ("email_not_found".equals(error)) {
                    %>
                        <div class="alert alert-danger text-center small mb-4 py-2" role="alert">
                            <i class="bi bi-exclamation-triangle-fill me-1"></i> Email not found! Please register an account first.
                        </div>
                    <%
                        }
                        if ("wrong_password".equals(error)) {
                    %>
                        <div class="alert alert-warning text-center small mb-4 py-2" role="alert">
                            <i class="bi bi-exclamation-circle-fill me-1"></i> Incorrect password. Please try again.
                        </div>
                    <%
                        }
                    %>

                    <form action="../LoginServlet" method="POST">
                        <div class="mb-3">
                            <label for="email" class="form-label fw-semibold small">Student Email</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-envelope text-muted"></i></span>
                                <input type="email" class="form-control bg-light border-start-0" id="email" name="email" placeholder="student@uitm.edu.my" required>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label for="password" class="form-label fw-semibold small">Password</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-lock text-muted"></i></span>
                                <input type="password" class="form-control bg-light border-start-0" id="password" name="password" placeholder="Enter your password" required>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold rounded-pill shadow-sm mb-3">
                            Log In
                        </button>

                        <div class="text-center text-muted small">
                            Don't have an account? <a href="register.jsp" class="text-primary text-decoration-none fw-semibold">Register</a>
                        </div>

                        <div class="text-center small mt-3">
                            <a href="../index.jsp" class="text-muted text-decoration-none">
                                <i class="bi bi-arrow-left me-1"></i> Back to Homepage
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>