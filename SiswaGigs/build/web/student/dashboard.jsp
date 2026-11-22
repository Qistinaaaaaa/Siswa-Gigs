<%--
    Document   : dashboard
    Created on : Nov 21, 2026, 2:35:30 PM
    Author     : HP
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userId") == null || !"Student".equals(userSession.getAttribute("role"))) {
        response.sendRedirect("../login.jsp?error=unauthorized");
        return;
    }

    int userId = (Integer) userSession.getAttribute("userId");

    String fullName = "";
    String matricNumber = "";
    int totalApplications = 0;
    int hiredGigs = 0;
    double earnings = 0;

    String dbURL = "jdbc:mysql://localhost:3306/siswa_gigs?useSSL=false&serverTimezone=UTC";

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, "root", "");

        // Name + matric
        ps = conn.prepareStatement(
                "SELECT u.full_name, s.matric_number FROM users u " +
                "JOIN students s ON u.user_id = s.user_id WHERE u.user_id = ?");
        ps.setInt(1, userId);
        rs = ps.executeQuery();
        if (rs.next()) {
            fullName = rs.getString("full_name");
            matricNumber = rs.getString("matric_number");
        }
        rs.close(); ps.close();

        // Total applications + hired count
        ps = conn.prepareStatement(
                "SELECT COUNT(*) AS total, COALESCE(SUM(a.application_status = 'Hired'), 0) AS hired " +
                "FROM applications a JOIN students s ON a.student_id = s.student_id " +
                "WHERE s.user_id = ?");
        ps.setInt(1, userId);
        rs = ps.executeQuery();
        if (rs.next()) {
            totalApplications = rs.getInt("total");
            hiredGigs = rs.getInt("hired");
        }
        rs.close(); ps.close();

        // Earnings from approved work records
        ps = conn.prepareStatement(
                "SELECT COALESCE(SUM(wr.hours_worked * wr.hourly_rate), 0) AS earnings " +
                "FROM work_records wr " +
                "JOIN applications a ON wr.application_id = a.application_id " +
                "JOIN students s ON a.student_id = s.student_id " +
                "WHERE s.user_id = ? AND wr.work_status = 'Approved'");
        ps.setInt(1, userId);
        rs = ps.executeQuery();
        if (rs.next()) {
            earnings = rs.getDouble("earnings");
        }
        rs.close(); ps.close();

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ignore) { }
        try { if (ps != null) ps.close(); } catch (Exception ignore) { }
        try { if (conn != null) conn.close(); } catch (Exception ignore) { }
    }

    if (fullName == null || fullName.isEmpty()) fullName = "Student";
    if (matricNumber == null) matricNumber = "-";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard | Siswa-Gigs</title>
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
            .sidebar {
                position: static;
                min-height: auto;
            }
            .main-content {
                margin-left: 0;
            }
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
                        <h5 class="fw-bold text-dark mb-0">Student Portal</h5>
                    </div>
                    <div class="dropdown">
                        <button class="btn btn-light border btn-sm rounded-pill px-3 py-2 dropdown-toggle fw-semibold d-inline-flex align-items-center gap-2 shadow-sm" type="button" data-bs-toggle="dropdown">
                            <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 24px; height: 24px; font-size: 0.75rem;">
                                <%= fullName.substring(0, 1).toUpperCase() %>
                            </div>
                            <span><%= fullName %></span>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0 py-2">
                            <li><h6 class="dropdown-header text-muted small"><%= matricNumber %></h6></li>
                            <li><a class="dropdown-item small" href="profile.jsp"><i class="bi bi-person me-2"></i>Profile</a></li>
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
                                    <i class="bi bi-shield-check me-1"></i> Verified Student Account
                                </div>
                                <h2 class="fw-bold mb-2">Welcome back, <%= fullName %>!</h2>
                                <p class="text-light opacity-75 mb-0 small">
                                    Matric No: <span class="text-white fw-semibold"><%= matricNumber %></span> &bull; Manage your active tasks, track earnings, and explore campus gigs efficiently.
                                </p>
                            </div>
                            <div class="col-lg-4 text-end d-none d-lg-block">
                                <i class="bi bi-mortarboard text-white opacity-25" style="font-size: 6rem;"></i>
                            </div>
                        </div>
                    </div>

                    <!-- Metric Cards Grid -->
                    <div class="row g-4">
                        <div class="col-md-4">
                            <div class="metric-card p-4 h-100">
                                <div class="d-flex align-items-center justify-content-between mb-3">
                                    <span class="text-muted small fw-bold text-uppercase">Applications</span>
                                    <div class="bg-primary bg-opacity-10 text-primary p-2 rounded-3">
                                        <i class="bi bi-file-earmark-text fs-5"></i>
                                    </div>
                                </div>
                                <h2 class="fw-bold text-dark mb-1"><%= totalApplications %></h2>
                                <p class="text-muted small mb-0">Active gig submissions</p>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="metric-card p-4 h-100">
                                <div class="d-flex align-items-center justify-content-between mb-3">
                                    <span class="text-muted small fw-bold text-uppercase">Hired Gigs</span>
                                    <div class="bg-success bg-opacity-10 text-success p-2 rounded-3">
                                        <i class="bi bi-check-circle fs-5"></i>
                                    </div>
                                </div>
                                <h2 class="fw-bold text-dark mb-1"><%= hiredGigs %></h2>
                                <p class="text-muted small mb-0">Confirmed assignments</p>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="metric-card p-4 h-100">
                                <div class="d-flex align-items-center justify-content-between mb-3">
                                    <span class="text-muted small fw-bold text-uppercase">Earnings</span>
                                    <div class="bg-warning bg-opacity-10 text-warning p-2 rounded-3">
                                        <i class="bi bi-wallet2 fs-5"></i>
                                    </div>
                                </div>
                                <h2 class="fw-bold text-dark mb-1">RM <%= String.format("%.2f", earnings) %></h2>
                                <p class="text-muted small mb-0">Total accumulated payout</p>
                            </div>
                        </div>
                    </div>

                </div>
            </div>

        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>