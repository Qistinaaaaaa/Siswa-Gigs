<%--
    Document   : index
    Created on : Nov 21, 2026, 1:21:16 PM
    Author     : HP
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*" %>
<%!
    // Escape employer-entered text before printing it into HTML
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
<%
    // {title, company, location, rate, vacancies, posted, description, skills}
    List<String[]> gigs = new ArrayList<String[]>();

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    java.text.SimpleDateFormat dateFmt = new java.text.SimpleDateFormat("dd MMM yyyy", java.util.Locale.ENGLISH);
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/siswa_gigs?useSSL=false&serverTimezone=UTC", "root", "");
        ps = conn.prepareStatement(
            "SELECT j.job_title, j.description, j.location, j.hourly_rate, j.vacancies, j.posted_date, e.company_name, " +
            "(SELECT GROUP_CONCAT(s.skill_name SEPARATOR ', ') FROM job_skills js " +
            " JOIN skills s ON js.skill_id = s.skill_id WHERE js.job_id = j.job_id) AS skills " +
            "FROM jobs j JOIN employers e ON j.employer_id = e.employer_id " +
            "WHERE j.job_status = 'Available' AND (j.expiry_date IS NULL OR j.expiry_date >= CURDATE()) " +
            "ORDER BY j.posted_date DESC, j.job_id DESC LIMIT 6");
        rs = ps.executeQuery();
        while (rs.next()) {
            String desc = rs.getString("description");
            if (desc != null && desc.length() > 100) desc = desc.substring(0, 100) + "...";
            gigs.add(new String[]{
                rs.getString("job_title"), rs.getString("company_name"), rs.getString("location"),
                String.format("%.2f", rs.getDouble("hourly_rate")), rs.getString("vacancies"),
                dateFmt.format(rs.getDate("posted_date")), desc, rs.getString("skills")});
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ignore) { }
        try { if (ps != null) ps.close(); } catch (Exception ignore) { }
        try { if (conn != null) conn.close(); } catch (Exception ignore) { }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Siswa-Gigs | Campus Freelance & Job Portal</title>

    <!-- Google Fonts: Plus Jakarta Sans -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            color: #1e293b;
            background-color: #f8fafc;
            position: relative;
        }
        .navbar {
            backdrop-filter: blur(10px);
            background-color: rgba(255, 255, 255, 0.9);
        }
        .navbar-nav .nav-link {
            position: relative;
            color: #475569;
            transition: color 0.2s ease;
        }
        .navbar-nav .nav-link:hover,
        .navbar-nav .nav-link:focus,
        .navbar-nav .nav-link.active {
            color: #2563eb !important;
            font-weight: 600;
        }
        .navbar-nav .nav-link::after {
            content: '';
            position: absolute;
            width: 0;
            height: 2px;
            bottom: 0;
            left: 50%;
            background-color: #2563eb;
            transition: all 0.3s ease;
            transform: translateX(-50%);
        }
        .navbar-nav .nav-link:hover::after,
        .navbar-nav .nav-link.active::after {
            width: 60%;
        }
        .hero-section {
            background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 50%, #2563eb 100%);
            color: white;
            padding: 110px 0 90px;
        }
        .hero-badge {
            background: rgba(255, 255, 255, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.25);
            backdrop-filter: blur(5px);
            color: #e0e7ff;
            font-weight: 600;
            font-size: 0.85rem;
        }
        .feature-card {
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            transition: all 0.3s ease;
            background: #ffffff;
        }
        .feature-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 24px -8px rgba(37, 99, 235, 0.12);
            border-color: #93c5fd;
        }
        .icon-box {
            width: 54px;
            height: 54px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }
    </style>
</head>
<body class="d-flex flex-column min-vh-100" data-bs-spy="scroll" data-bs-target="#navbarNav" data-bs-offset="100">

    <!-- Navigation Bar -->
    <nav class="navbar navbar-expand-lg sticky-top border-bottom py-3">
        <div class="container">
            <a class="navbar-brand fw-bold fs-4 text-primary d-flex align-items-center gap-2" href="index.jsp">
                <i class="bi bi-briefcase-fill"></i>
                <span>Siswa<span class="text-dark">-Gigs</span></span>
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav mx-auto fw-medium">
                    <li class="nav-item"><a class="nav-link px-3" href="#features">Portal Features</a></li>
                    <li class="nav-item"><a class="nav-link px-3" href="#gigs-section">Available Gigs</a></li>
                </ul>
                <div class="d-flex align-items-center gap-3 mt-3 mt-lg-0">
                    <div class="dropdown">
                        <button class="btn btn-outline-primary fw-semibold px-3 rounded-pill dropdown-toggle btn-sm" type="button" data-bs-toggle="dropdown">
                            Login
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0">
                            <li><a class="dropdown-item py-2" href="student/login.jsp"><i class="bi bi-mortarboard me-2 text-primary"></i> Student Login</a></li>
                            <li><a class="dropdown-item py-2" href="employer/login.jsp"><i class="bi bi-building me-2 text-success"></i> Employer Login</a></li>
                        </ul>
                    </div>
                    <div class="dropdown">
                        <button class="btn btn-primary fw-semibold px-3 rounded-pill shadow-sm dropdown-toggle btn-sm" type="button" data-bs-toggle="dropdown">
                            Register
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0">
                            <li><a class="dropdown-item py-2" href="student/register.jsp"><i class="bi bi-mortarboard me-2 text-primary"></i> Register as Student</a></li>
                            <li><a class="dropdown-item py-2" href="employer/register.jsp"><i class="bi bi-building me-2 text-success"></i> Register as Employer</a></li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero-section text-center text-lg-start">
        <div class="container">
            <div class="row align-items-center g-5">
                <div class="col-lg-8 mx-auto text-center">
                    <span class="badge hero-badge rounded-pill px-3 py-2 mb-3">
                        <i class="bi bi-lightning-charge-fill me-1"></i> Campus Gig Economy & Task Platform
                    </span>
                    <h1 class="display-4 fw-extrabold mb-4 lh-sm">
                        Connecting Students With <span class="text-info">Flexible Opportunities.</span>
                    </h1>
                    <p class="lead text-light opacity-75 mb-5 px-lg-5">
                        A dedicated platform for students to find micro-jobs and for employers to post tasks and manage talent seamlessly.
                    </p>
                    <div class="d-flex flex-column flex-sm-row gap-3 justify-content-center">
                        <a href="student/register.jsp" class="btn btn-light text-primary btn-lg fw-bold px-4 py-3 rounded-pill shadow">
                            Register as Student <i class="bi bi-arrow-right ms-2"></i>
                        </a>
                        <a href="employer/register.jsp" class="btn btn-outline-light btn-lg fw-semibold px-4 py-3 rounded-pill">
                            Register as Employer
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Features Overview -->
    <section id="features" class="py-5 my-4">
        <div class="container">
            <div class="text-center mb-5">
                <h6 class="text-primary fw-bold text-uppercase tracking-wide">Platform Roles</h6>
                <h2 class="fw-bold">Built For Students & Employers</h2>
                <p class="text-muted">Choose your pathway to get started on Siswa-Gigs</p>
            </div>

            <div class="row g-4 justify-content-center">
                <!-- Student Card -->
                <div class="col-md-6 col-lg-5">
                    <div class="card feature-card h-100 p-4">
                        <div class="icon-box bg-primary-subtle text-primary mb-3">
                            <i class="bi bi-mortarboard"></i>
                        </div>
                        <h4 class="fw-bold">For Students</h4>
                        <p class="text-muted small mb-3">Find flexible part-time gigs, build your portfolio, earn side income around your lecture schedule, and track applications easily.</p>
                        <div class="mt-auto d-flex gap-2">
                            <a href="student/register.jsp" class="btn btn-sm btn-primary rounded-pill px-3">Register Student</a>
                            <a href="student/login.jsp" class="btn btn-sm btn-outline-primary rounded-pill px-3">Login</a>
                        </div>
                    </div>
                </div>

                <!-- Employer Card -->
                <div class="col-md-6 col-lg-5">
                    <div class="card feature-card h-100 p-4">
                        <div class="icon-box bg-success-subtle text-success mb-3">
                            <i class="bi bi-building"></i>
                        </div>
                        <h4 class="fw-bold">For Employers / Task Posters</h4>
                        <p class="text-muted small mb-3">Post short-term tasks or campus projects, review student applicants, coordinate project schedules, and manage gig deliverables.</p>
                        <div class="mt-auto d-flex gap-2">
                            <a href="employer/register.jsp" class="btn btn-sm btn-success rounded-pill px-3">Register Employer</a>
                            <a href="employer/login.jsp" class="btn btn-sm btn-outline-success rounded-pill px-3">Login</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Available Gigs Section -->
    <section id="gigs-section" class="py-5 bg-white border-top">
        <div class="container py-3">
            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
                <div>
                    <h6 class="text-primary fw-bold text-uppercase">Explore</h6>
                    <h2 class="fw-bold mb-0">Recent Available Gigs</h2>
                </div>
                <span class="text-muted small">Showing latest posted opportunities</span>
            </div>

            <% if (gigs.isEmpty()) { %>
            <div class="row g-4">
                <div class="col-12">
                    <div class="card border-0 bg-light rounded-4 p-5 text-center">
                        <div class="mb-3">
                            <i class="bi bi-briefcase text-muted fs-1"></i>
                        </div>
                        <h5 class="fw-bold text-secondary">No active gigs available at the moment</h5>
                        <p class="text-muted small mb-0">New campus task opportunities posted by employers will appear here shortly.</p>
                    </div>
                </div>
            </div>
            <% } else { %>
            <div class="row g-4">
                <% for (String[] g : gigs) { %>
                <div class="col-md-6 col-lg-4">
                    <div class="card feature-card h-100 p-4">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <h5 class="fw-bold mb-0"><%= esc(g[0]) %></h5>
                            <span class="badge bg-success-subtle text-success rounded-pill">RM <%= g[3] %>/hr</span>
                        </div>
                        <div class="text-muted small mb-2"><i class="bi bi-building me-1"></i><%= esc(g[1]) %></div>
                        <div class="text-muted small mb-3">
                            <i class="bi bi-geo-alt me-1"></i><%= esc(g[2]) %>
                            &bull; <%= g[4] %> vacancies
                        </div>
                        <p class="small text-secondary mb-3"><%= esc(g[6]) %></p>
                        <% if (g[7] != null && !g[7].isEmpty()) { %>
                        <div class="mb-3">
                            <% for (String sk : g[7].split(", ")) { %>
                                <span class="badge bg-primary-subtle text-primary rounded-pill me-1 mb-1"><%= esc(sk) %></span>
                            <% } %>
                        </div>
                        <% } %>
                        <div class="mt-auto d-flex justify-content-between align-items-center">
                            <span class="text-muted small">Posted <%= g[5] %></span>
                            <a href="student/login.jsp" class="btn btn-sm btn-primary rounded-pill px-3">Login to apply</a>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>
        </div>
    </section>

    <!-- Footer -->
    <footer class="bg-dark text-light py-4 mt-auto">
        <div class="container text-center text-md-start">
            <div class="row align-items-center">
                <div class="col-md-6 mb-2 mb-md-0">
                    <span class="fw-bold text-white">Siswa-Gigs</span>
                    <span class="text-secondary small ms-2">&copy; 2026 All rights reserved.</span>
                </div>
                <div class="col-md-6 text-md-end small text-secondary">
                    <span>Campus Freelance & Task Platform</span>
                </div>
            </div>
        </div>
    </footer>

    <!-- Bootstrap 5 JS Bundle & ScrollSpy Integration -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>