<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userId") == null || !"Employer".equals(userSession.getAttribute("role"))) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }

    int userId = (Integer) userSession.getAttribute("userId");
    String filterStatus = request.getParameter("status");
    if (filterStatus == null || filterStatus.isEmpty()) filterStatus = "ALL";

    String dbURL = "jdbc:mysql://localhost:3307/siswa_gigs?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException ex) {
            Class.forName("com.mysql.jdbc.Driver");
        }
        conn = DriverManager.getConnection(dbURL, "root", "");

        int employerId = 0;
        ps = conn.prepareStatement("SELECT employer_id FROM employers WHERE user_id = ?");
        ps.setInt(1, userId);
        rs = ps.executeQuery();
        if (rs.next()) {
            employerId = rs.getInt("employer_id");
        }
        rs.close();
        ps.close();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Application Management | Siswa-Gigs</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; background-color: #f8fafc; color: #0f172a; }
        .sidebar { min-height: 100vh; background: #0f172a; color: white; position: fixed; top: 0; left: 0; width: 260px; z-index: 1000; }
        .main-content { margin-left: 260px; }
        @media (max-width: 767.98px) { .sidebar { position: static; min-height: auto; } .main-content { margin-left: 0; } }
        .top-navbar { background: #ffffff; border-bottom: 1px solid #e2e8f0; height: 70px; }
        .metric-card { background: #ffffff; border: 1px solid #e2e8f0; border-radius: 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.02); }
    </style>
</head>
<body>

<div class="container-fluid p-0">
    <div class="row g-0">

        <jsp:include page="sidebar.jsp" />

        <div class="col main-content">
            <div class="top-navbar px-4 px-md-5 d-flex justify-content-between align-items-center">
                <div>
                    <span class="text-muted small fw-semibold text-uppercase">Employer Portal</span>
                    <h5 class="fw-bold text-dark mb-0">Application Management</h5>
                </div>
            </div>

            <div class="p-4 p-md-5">
                <% if ("updated".equals(request.getParameter("msg"))) { %>
                    <div class="alert alert-success rounded-3 mb-4"><i class="bi bi-check-circle-fill me-2"></i>Application status updated successfully!</div>
                <% } else if (request.getParameter("error") != null) { %>
                    <div class="alert alert-danger rounded-3 mb-4">Error: <%= request.getParameter("error") %></div>
                <% } %>

                <!-- Filter Tabs -->
                <div class="d-flex flex-wrap gap-2 mb-4">
                    <a href="applicationManage.jsp?status=ALL" class="btn btn-sm rounded-pill px-3 fw-semibold <%= "ALL".equals(filterStatus) ? "btn-primary" : "btn-outline-secondary" %>">All Applications</a>
                    <a href="applicationManage.jsp?status=Pending" class="btn btn-sm rounded-pill px-3 fw-semibold <%= "Pending".equals(filterStatus) ? "btn-warning text-dark" : "btn-outline-secondary" %>">Pending</a>
                    <a href="applicationManage.jsp?status=Hired" class="btn btn-sm rounded-pill px-3 fw-semibold <%= "Hired".equals(filterStatus) ? "btn-success" : "btn-outline-secondary" %>">Hired</a>
                    <a href="applicationManage.jsp?status=Rejected" class="btn btn-sm rounded-pill px-3 fw-semibold <%= "Rejected".equals(filterStatus) ? "btn-danger" : "btn-outline-secondary" %>">Rejected</a>
                </div>

                <!-- Applications Table -->
                <div class="metric-card p-4">
                    <h6 class="fw-bold mb-3"><i class="bi bi-people text-primary me-2"></i>Student Applicants</h6>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle small">
                            <thead class="table-light">
                                <tr>
                                    <th>Applicant</th>
                                    <th>Matric & Programme</th>
                                    <th>Job Applied</th>
                                    <th>Applied Date</th>
                                    <th>Status</th>
                                    <th>Decision</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    String sql = "SELECT a.application_id, a.application_date, a.application_status, " +
                                                 "j.job_title, j.hourly_rate, " +
                                                 "u.full_name, u.email, u.phone_number, " +
                                                 "s.matric_number, s.programme, s.study_year " +
                                                 "FROM applications a " +
                                                 "JOIN jobs j ON a.job_id = j.job_id " +
                                                 "JOIN students s ON a.student_id = s.student_id " +
                                                 "JOIN users u ON s.user_id = u.user_id " +
                                                 "WHERE j.employer_id = ? ";
                                    if (!"ALL".equals(filterStatus)) {
                                        sql += "AND a.application_status = ? ";
                                    }
                                    sql += "ORDER BY a.application_date DESC";

                                    ps = conn.prepareStatement(sql);
                                    ps.setInt(1, employerId);
                                    if (!"ALL".equals(filterStatus)) {
                                        ps.setString(2, filterStatus);
                                    }
                                    rs = ps.executeQuery();

                                    boolean hasApps = false;
                                    while (rs.next()) {
                                        hasApps = true;
                                        String st = rs.getString("application_status");
                                        String badgeClass = "bg-warning text-dark";
                                        if ("Hired".equals(st)) badgeClass = "bg-success";
                                        else if ("Rejected".equals(st)) badgeClass = "bg-danger";
                                %>
                                <tr>
                                    <td>
                                        <div class="fw-bold text-dark"><%= rs.getString("full_name") %></div>
                                        <div class="text-muted" style="font-size: 0.75rem;"><%= rs.getString("email") %> &bull; <%= rs.getString("phone_number") != null ? rs.getString("phone_number") : "-" %></div>
                                    </td>
                                    <td>
                                        <div class="fw-semibold"><%= rs.getString("matric_number") %></div>
                                        <div class="text-muted" style="font-size: 0.75rem;"><%= rs.getString("programme") != null ? rs.getString("programme") : "-" %> (Year <%= rs.getInt("study_year") %>)</div>
                                    </td>
                                    <td>
                                        <div class="fw-semibold text-dark"><%= rs.getString("job_title") %></div>
                                        <div class="text-muted" style="font-size: 0.75rem;">RM <%= String.format("%.2f", rs.getDouble("hourly_rate")) %>/hr</div>
                                    </td>
                                    <td><%= rs.getTimestamp("application_date") %></td>
                                    <td><span class="badge <%= badgeClass %>"><%= st %></span></td>
                                    <td>
                                        <% if ("Pending".equals(st)) { %>
                                            <form action="../EmployerApplicationServlet" method="post" class="d-inline">
                                                <input type="hidden" name="application_id" value="<%= rs.getInt("application_id") %>">
                                                <input type="hidden" name="decision" value="Hired">
                                                <button type="submit" class="btn btn-success btn-sm rounded-2 px-2">Hire</button>
                                            </form>
                                            <form action="../EmployerApplicationServlet" method="post" class="d-inline ms-1">
                                                <input type="hidden" name="application_id" value="<%= rs.getInt("application_id") %>">
                                                <input type="hidden" name="decision" value="Rejected">
                                                <button type="submit" class="btn btn-outline-danger btn-sm rounded-2 px-2">Reject</button>
                                            </form>
                                        <% } else { %>
                                            <span class="text-muted fst-italic">Processed</span>
                                        <% } %>
                                    </td>
                                </tr>
                                <%
                                    }
                                    if (!hasApps) {
                                %>
                                <tr>
                                    <td colspan="6" class="text-center text-muted py-4">No student applications found for this filter.</td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
<%
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<div class='alert alert-danger m-4'>Database Error: " + e.getMessage() + "</div>");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ignore) {}
        try { if (ps != null) ps.close(); } catch (Exception ignore) {}
        try { if (conn != null) conn.close(); } catch (Exception ignore) {}
    }
%>