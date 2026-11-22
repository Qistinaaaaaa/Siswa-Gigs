<%--
    Document   : register
    Created on : Nov 21, 2026, 1:51:16 PM
    Author     : HP
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Registration | Siswa-Gigs</title>
    <!-- Google Fonts: Plus Jakarta Sans -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 50%, #2563eb 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        .register-wrapper {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 0;
        }
        .register-card {
            border: none;
            border-radius: 20px;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
        }

        /* Navbar (same as index) */
        .navbar {
            backdrop-filter: blur(10px);
            background-color: rgba(255, 255, 255, 0.9);
        }
        /* Current page highlight inside dropdown */
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
                            <li><a class="dropdown-item py-2" href="login.jsp"><i class="bi bi-mortarboard me-2 text-primary"></i> Student Login</a></li>
                            <li><a class="dropdown-item py-2" href="../employer/login.jsp"><i class="bi bi-building me-2 text-success"></i> Employer Login</a></li>
                        </ul>
                    </div>
                    <div class="dropdown">
                        <button class="btn btn-primary fw-semibold px-3 rounded-pill shadow-sm dropdown-toggle btn-sm" type="button" data-bs-toggle="dropdown">
                            Register
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0">
                            <li>
                                <a class="dropdown-item py-2 active" href="register.jsp" aria-current="page">
                                    <i class="bi bi-mortarboard me-2 text-primary"></i> Register as Student
                                    <i class="bi bi-check2 ms-2"></i>
                                </a>
                            </li>
                            <li><a class="dropdown-item py-2" href="../employer/register.jsp"><i class="bi bi-building me-2 text-success"></i> Register as Employer</a></li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </nav>

    <div class="register-wrapper">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-7 col-lg-6">
                <div class="card register-card p-4 p-md-5 bg-white">
                    <div class="text-center mb-4">
                        <h4 class="fw-bold text-dark">Student Registration</h4>
                        <p class="text-muted small">Create your account to start applying for campus gigs</p>
                    </div>

                    <!-- Error Alert for Duplicates or Invalid Format -->
                    <%
                        String error = request.getParameter("error");
                        if ("duplicate".equals(error)) {
                    %>
                        <div class="alert alert-danger text-center small mb-4 py-2" role="alert">
                            <i class="bi bi-exclamation-triangle-fill me-1"></i> Registration failed: Matric number or Email is already registered!
                        </div>
                    <%
                        } else if ("invalid_format".equals(error)) {
                    %>
                        <div class="alert alert-warning text-center small mb-4 py-2" role="alert">
                            <i class="bi bi-exclamation-circle-fill me-1"></i> Invalid input format detected. Please check your fields.
                        </div>
                    <%
                        }
                    %>

                    <!-- Registration Form with JavaScript Validation -->
                    <form action="../RegisterServlet" method="POST" onsubmit="return validateForm()">

                        <!-- Full Name: Letters and spaces only -->
                        <div class="mb-3">
                            <label for="fullName" class="form-label fw-semibold small">Full Name</label>
                            <input type="text" class="form-control bg-light" id="fullName" name="fullName" placeholder="Enter your full name (letters only)" required>
                            <div class="text-danger small mt-1" id="nameError" style="display: none;">Full name must contain letters and spaces only (no numbers or symbols).</div>
                        </div>

                        <div class="row">
                            <!-- Email: Must contain @ -->
                            <div class="col-md-6 mb-3">
                                <label for="email" class="form-label fw-semibold small">Student Email</label>
                                <input type="email" class="form-control bg-light" id="email" name="email" placeholder="student@uitm.edu.my" required>
                            </div>
                            <!-- Phone Number: Numbers only -->
                            <div class="col-md-6 mb-3">
                                <label for="phone" class="form-label fw-semibold small">Phone Number</label>
                                <input type="text" class="form-control bg-light" id="phone" name="phone" placeholder="0123456789 (numbers only)" required>
                                <div class="text-danger small mt-1" id="phoneError" style="display: none;">Phone number must contain digits only.</div>
                            </div>
                        </div>

                        <div class="row">
                            <!-- Matric Number: Numbers only (Unique) -->
                            <div class="col-md-6 mb-3">
                                <label for="matricNumber" class="form-label fw-semibold small">Matric Number</label>
                                <input type="text" class="form-control bg-light" id="matricNumber" name="matricNumber" placeholder="e.g. 2023812345" required>
                                <div class="text-danger small mt-1" id="matricError" style="display: none;">Matric number must contain digits only.</div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="studyYear" class="form-label fw-semibold small">Study Year</label>
                                <input type="number" class="form-control bg-light" id="studyYear" name="studyYear" min="1" max="5" placeholder="1, 2, 3..." required>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label for="programme" class="form-label fw-semibold small">Programme</label>
                            <input type="text" class="form-control bg-light" id="programme" name="programme" placeholder="e.g. Bachelor of Computer Science" required>
                        </div>

                        <div class="mb-3">
                            <label for="departmentName" class="form-label fw-semibold small">Department / Faculty</label>
                            <input type="text" class="form-control bg-light" id="departmentName" name="departmentName" placeholder="e.g. College of Computing, Informatics and Media" required>
                        </div>

                        <div class="mb-4">
                            <label for="password" class="form-label fw-semibold small">Password</label>
                            <input type="password" class="form-control bg-light" id="password" name="password" placeholder="Create a secure password" minlength="6" required>
                            <div class="form-text text-muted" style="font-size: 0.75rem;">Minimum 6 characters. Will be securely hashed.</div>
                        </div>

                        <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold rounded-pill shadow-sm mb-3">
                            Register Account
                        </button>

                        <div class="text-center text-muted small">
                            Already have an account? <a href="login.jsp" class="text-primary text-decoration-none fw-semibold">Log In</a>
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

    <!-- Client-side Validation Script -->
    <script>
        function validateForm() {
            let fullName = document.getElementById("fullName").value;
            let phone = document.getElementById("phone").value;
            let matricNumber = document.getElementById("matricNumber").value;

            let nameError = document.getElementById("nameError");
            let phoneError = document.getElementById("phoneError");
            let matricError = document.getElementById("matricError");

            let isValid = true;

            // 1. Full name: Letters and spaces only (No numbers)
            let nameRegex = /^[A-Za-z\s]+$/;
            if (!nameRegex.test(fullName)) {
                nameError.style.display = "block";
                isValid = false;
            } else {
                nameError.style.display = "none";
            }

            // 2. Phone number: Digits only
            let digitRegex = /^[0-9]+$/;
            if (!digitRegex.test(phone)) {
                phoneError.style.display = "block";
                isValid = false;
            } else {
                phoneError.style.display = "none";
            }

            // 3. Matric number: Digits only
            if (!digitRegex.test(matricNumber)) {
                matricError.style.display = "block";
                isValid = false;
            } else {
                matricError.style.display = "none";
            }

            return isValid;
        }
    </script>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>