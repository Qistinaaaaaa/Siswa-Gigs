<%-- 
    Document   : application
    Created on : Nov 21, 2026, 10:20:12 PM
    Author     : HP
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%
    // Check student session login
    Integer userId = (Integer) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");
    
    if (userId == null || !"Student".equals(role)) {
        response.sendRedirect("../login.jsp?error=unauthorized");
        return;
    }

    // Retrieve search query and status filter parameters if available
    String searchQuery = request.getParameter("search");
    if (searchQuery == null) searchQuery = "";
    
    String statusFilter = request.getParameter("statusFilter");
    if (statusFilter == null) statusFilter = "All";

    String dbURL = "jdbc:mysql://localhost:3306/siswa_gigs?useSSL=false&serverTimezone=UTC";
    String dbUser = "root";
    String dbPass = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Applications | Siswa-Gigs</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .sidebar { width: 260px; height: 100vh; position: fixed; top: 0; left: 0; background-color: #0f172a; color: #fff; z-index: 100; }
        .main-content { margin-left: 260px; padding: 2rem; }
        .nav-link:hover { background-color: rgba(255, 255, 255, 0.05); }
        .nav-link.active { background-color: #0d6efd !important; color: white !important; }
    </style>
</head>
<body>

    <!-- Include Sidebar -->
    <jsp:include page="sidebar.jsp" />

    <!-- Main Content Area -->
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <span class="text-muted small text-uppercase fw-bold">Student Portal</span>
                <h2 class="fw-bold text-dark mb-0">My Applications</h2>
            </div>
            <!-- Profile Dropdown Header -->
            <div class="dropdown">
                <button class="btn btn-light border btn-sm rounded-pill px-3 py-2 dropdown-toggle fw-semibold d-inline-flex align-items-center gap-2 shadow-sm bg-white" type="button" data-bs-toggle="dropdown">
                    <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 28px; height: 28px; font-size: 0.8rem; min-width: 28px;">
                        <%= session.getAttribute("fullName") != null ? session.getAttribute("fullName").toString().substring(0, 1).toUpperCase() : "S" %>
                    </div>
                    <span><%= session.getAttribute("fullName") != null ? session.getAttribute("fullName") : "Student" %></span>
                </button>
                <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0 py-2">
                    <li><h6 class="dropdown-header text-muted small"><%= session.getAttribute("matricNumber") != null ? session.getAttribute("matricNumber") : "-" %></h6></li>
                    <li><a class="dropdown-item small" href="profile.jsp"><i class="bi bi-person me-2"></i>Profile</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item small text-danger fw-semibold" href="../LogoutServlet"><i class="bi bi-box-arrow-right me-2"></i>Log Out</a></li>
                </ul>
            </div>
        </div>

        <% 
            String statusParam = request.getParameter("status");
            if ("success".equals(statusParam)) { 
        %>
            <div class="alert alert-success alert-dismissible fade show shadow-sm rounded-4 mb-4" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i> <strong>Application Submitted!</strong> Your job application has been successfully recorded and is pending employer review.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } else if ("duplicate".equals(statusParam)) { %>
            <div class="alert alert-warning alert-dismissible fade show shadow-sm rounded-4 mb-4" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> <strong>Notice:</strong> You already have a pending or accepted application for this job.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } %>

        <!-- Main Card & Search Filter Section -->
        <div class="card border-0 shadow-sm rounded-4 p-4 mb-4 bg-white">
            <div class="row g-3 align-items-center justify-content-between mb-4">
                <div class="col-md-6">
                    <h5 class="fw-bold text-dark mb-1">Application History</h5>
                    <p class="text-muted small mb-0">Track the status of your campus gig applications.</p>
                </div>
                <div class="col-md-6">
                    <form method="GET" action="application.jsp" class="row g-2 justify-content-end">
                        <div class="col-auto">
                            <input type="text" name="search" class="form-control form-control-sm rounded-pill px-3" placeholder="Search job or company..." value="<%= searchQuery %>">
                        </div>
                        <div class="col-auto">
                            <select name="statusFilter" class="form-select form-select-sm rounded-pill px-3">
                                <option value="All" <%= "All".equals(statusFilter) ? "selected" : "" %>>All Status</option>
                                <option value="Pending" <%= "Pending".equals(statusFilter) ? "selected" : "" %>>Pending</option>
                                <option value="Accepted" <%= "Accepted".equals(statusFilter) ? "selected" : "" %>>Accepted</option>
                                <option value="Rejected" <%= "Rejected".equals(statusFilter) ? "selected" : "" %>>Rejected</option>
                            </select>
                        </div>
                        <div class="col-auto">
                            <button type="submit" class="btn btn-primary btn-sm rounded-pill px-3"><i class="bi bi-search"></i></button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Application History Table -->
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light text-uppercase fs-7 text-secondary">
                        <tr>
                            <th class="py-3 ps-3">Job Title</th>
                            <th class="py-3">Company / Dept</th>
                            <th class="py-3">Rate</th>
                            <th class="py-3">Applied Date</th>
                            <th class="py-3">Status</th>
                            <th class="py-3 text-end pe-3">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

                            // Build dynamic SQL with search and status filter support
                            StringBuilder sql = new StringBuilder(
                                "SELECT a.application_id, a.application_date, a.application_status, " +
                                "j.job_id, j.job_title, j.location, j.hourly_rate, e.company_name " +
                                "FROM applications a " +
                                "JOIN students s ON a.student_id = s.student_id " +
                                "JOIN jobs j ON a.job_id = j.job_id " +
                                "JOIN employers e ON j.employer_id = e.employer_id " +
                                "WHERE s.user_id = ?"
                            );

                            if (!searchQuery.isEmpty()) {
                                sql.append(" AND (j.job_title LIKE ? OR e.company_name LIKE ?)");
                            }
                            if (!"All".equals(statusFilter)) {
                                sql.append(" AND a.application_status = ?");
                            }
                            sql.append(" ORDER BY a.application_date DESC, a.application_id DESC");

                            PreparedStatement pstmt = conn.prepareStatement(sql.toString());
                            int paramIdx = 1;
                            pstmt.setInt(paramIdx++, userId);

                            if (!searchQuery.isEmpty()) {
                                pstmt.setString(paramIdx++, "%" + searchQuery + "%");
                                pstmt.setString(paramIdx++, "%" + searchQuery + "%");
                            }
                            if (!"All".equals(statusFilter)) {
                                pstmt.setString(paramIdx++, statusFilter);
                            }

                            ResultSet rs = pstmt.executeQuery();
                            boolean hasRecords = false;

                            // Date formatters for Day Month Year (e.g., 21 Nov 2026)
                            SimpleDateFormat inputFormat = new SimpleDateFormat("yyyy-MM-dd");
                            SimpleDateFormat outputFormat = new SimpleDateFormat("dd MMM yyyy");

                            while (rs.next()) {
                                hasRecords = true;
                                String rawDate = rs.getString("application_date");
                                String formattedDate = rawDate;
                                try {
                                    if (rawDate != null && rawDate.length() >= 10) {
                                        Date parsedDate = inputFormat.parse(rawDate.substring(0, 10));
                                        formattedDate = outputFormat.format(parsedDate);
                                    }
                                } catch (Exception ex) {
                                    formattedDate = rawDate;
                                }

                                String status = rs.getString("application_status");
                                String badgeClass = "bg-warning text-dark";
                                if ("Accepted".equalsIgnoreCase(status)) badgeClass = "bg-success text-white";
                                else if ("Rejected".equalsIgnoreCase(status)) badgeClass = "bg-danger text-white";
                    %>
                        <tr>
                            <td class="ps-3">
                                <div class="fw-bold text-dark"><%= rs.getString("job_title") %></div>
                                <div class="text-muted small"><i class="bi bi-geo-alt me-1"></i><%= rs.getString("location") %></div>
                            </td>
                            <td><%= rs.getString("company_name") %></td>
                            <td class="fw-semibold text-success">RM <%= String.format("%.2f", rs.getDouble("hourly_rate")) %>/hr</td>
                            <td><%= formattedDate %></td>
                            <td>
                                <span class="badge <%= badgeClass %> px-3 py-2 rounded-pill fw-medium"><%= status %></span>
                            </td>
                            <td class="text-end pe-3">
                                <a href="jobDetails.jsp?id=<%= rs.getInt("job_id") %>" class="btn btn-outline-primary btn-sm rounded-pill px-3 fw-semibold">
                                    View Gig
                                </a>
                            </td>
                        </tr>
                    <%
                            }
                            if (!hasRecords) {
                    %>
                        <tr>
                            <td colspan="6" class="text-center py-5 text-muted">
                                <i class="bi bi-folder2-open display-6 d-block mb-2 text-secondary"></i>
                                No applications found matching your search or filter.
                            </td>
                        </tr>
                    <%
                            }
                            rs.close();
                            pstmt.close();
                            conn.close();
                        } catch (Exception e) {
                            e.printStackTrace();
                    %>
                        <tr>
                            <td colspan="6" class="text-center text-danger py-4">Error loading application history: <%= e.getMessage() %></td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <div class="mt-4 text-end">
                <a href="JobServlet" class="btn btn-primary rounded-pill px-4 fw-semibold shadow-sm">
                    <i class="bi bi-search me-2"></i> Find More Gigs
                </a>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>