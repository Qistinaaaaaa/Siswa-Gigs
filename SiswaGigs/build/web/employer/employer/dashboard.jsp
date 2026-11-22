<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userId") == null || !"Employer".equals(userSession.getAttribute("role"))) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }

    int userId = (Integer) userSession.getAttribute("userId");

    int employerId = 0;
    String fullName = "";
    String companyName = "";
    String ssmNo = "";
    String sector = "";
    int activeJobs = 0;
    int pendingApps = 0;
    int pendingWorkRecords = 0;

    String dbURL = "jdbc:mysql://localhost:3306/siswa_gigs?useSSL=false&serverTimezone=UTC";
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, "root", "");

        // Employer + User details
        ps = conn.prepareStatement(
                "SELECT u.full_name, e.employer_id, e.company_name, e.business_registration_no, e.business_sector " +
                "FROM users u JOIN employers e ON u.user_id = e.user_id WHERE u.user_id = ?");
        ps.setInt(1, userId);
        rs = ps.executeQuery();
        if (rs.next()) {
            fullName = rs.getString("full_name");
            employerId = rs.getInt("employer_id");
            companyName = rs.getString("company_name");
            ssmNo = rs.getString("business_registration_no");
            sector = rs.getString("business_sector");
        }
        rs.close(); ps.close();

        // Active Jobs count (ENUM: 'Available')
        ps = conn.prepareStatement(
                "SELECT COUNT(*) AS cnt FROM jobs WHERE employer_id = ? AND job_status = 'Available'");
        ps.setInt(1, employerId);
        rs = ps.executeQuery();
        if (rs.next()) activeJobs = rs.getInt("cnt");
        rs.close(); ps.close();

        // Pending Applications count
        ps = conn.prepareStatement(
                "SELECT COUNT(*) AS cnt FROM applications a " +
                "JOIN jobs j ON a.job_id = j.job_id " +
                "WHERE j.employer_id = ? AND a.application_status = 'Pending'");
        ps.setInt(1, employerId);
        rs = ps.executeQuery();
        if (rs.next()) pendingApps = rs.getInt("cnt");
        rs.close(); ps.close();

        // Pending Work Records count
        ps = conn.prepareStatement(
                "SELECT COUNT(*) AS cnt FROM work_records wr " +
                "JOIN applications a ON wr.application_id = a.application_id " +
                "JOIN jobs j ON a.job_id = j.job_id " +
                "WHERE j.employer_id = ? AND wr.work_status = 'Pending'");
        ps.setInt(1, employerId);
        rs = ps.executeQuery();
        if (rs.next()) pendingWorkRecords = rs.getInt("cnt");
        rs.close(); ps.close();

        if (companyName == null || companyName.isEmpty()) companyName = "Employer";
        if (ssmNo == null) ssmNo = "-";
        if (sector == null) sector = "-";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employer Dashboard | Siswa-Gigs</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: #f8fafc;
            color: #0f172a;
        }
        .sidebar {
            min-height: 100vh;
            background: #0f172a;
            color: white;
            position: fixed;
            top: 0;
            left: 0;
            width: 260px;
            z-index: 1000;
        }
        .main-content {
            margin-left: 260px;
        }
        @media (max-width: 767.98px) {
            .sidebar { position: static; min-height: auto; }
            .main-content { margin-left: 0; }
        }
        .top-navbar {
            background: #ffffff;
            border-bottom: 1px solid #e2e8f0;
            height: 70px;
        }
        .welcome-card {
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
            border-radius: 16px;
            color: white;
            position: relative;
            overflow: hidden;
            box-shadow: 0 4px 20px rgba(15, 23, 42, 0.08);
        }
        .metric-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.02);
        }
    </style>
</head>
<body>

<div class="container-fluid p-0">
    <div class="row g-0">

        <!-- Sidebar -->
        <jsp:include page="sidebar.jsp" />

        <!-- Main Content Area -->
        <div class="col main-content">

            <!-- Top Nav Bar -->
            <div class="top-navbar px-4 px-md-5 d-flex justify-content-between align-items-center">
                <div>
                    <span class="text-muted small fw-semibold text-uppercase">Workspace</span>
                    <h5 class="fw-bold text-dark mb-0">Employer Portal</h5>
                </div>
                <div class="dropdown">
                    <button class="btn btn-light border btn-sm rounded-pill px-3 py-2 dropdown-toggle fw-semibold d-inline-flex align-items-center gap-2 shadow-sm" type="button" data-bs-toggle="dropdown">
                        <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 24px; height: 24px; font-size: 0.75rem;">
                            <%= companyName.substring(0, 1).toUpperCase() %>
                        </div>
                        <span><%= companyName %></span>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0 py-2">
                        <li><h6 class="dropdown-header text-muted small">SSM: <%= ssmNo %></h6></li>
                        <li><a class="dropdown-item small" href="jobPost.jsp"><i class="bi bi-plus-circle me-2"></i>Post New Job</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item small text-danger fw-semibold" href="../LogoutServlet"><i class="bi bi-box-arrow-right me-2"></i>Log Out</a></li>
                    </ul>
                </div>
            </div>

            <!-- Page Body Content -->
            <div class="p-4 p-md-5">

                <!-- Welcome Hero Card -->
                <div class="welcome-card p-4 p-md-5 mb-4">
                    <div class="row align-items-center">
                        <div class="col-lg-8">
                            <div class="badge bg-primary bg-opacity-25 text-info px-3 py-2 rounded-pill fw-semibold mb-3 small">
                                <i class="bi bi-patch-check-fill me-1"></i> Verified Hiring Partner
                            </div>
                            <h2 class="fw-bold mb-2">Welcome back, <%= companyName %>!</h2>
                            <p class="text-light opacity-7