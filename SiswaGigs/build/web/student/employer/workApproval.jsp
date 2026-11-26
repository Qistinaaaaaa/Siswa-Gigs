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
    <title>Work Record Approval | Siswa-Gigs</title>
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
                    <h5 class="fw-bold text-dark mb-0">Work Record Approvals</h5>
                </div>
            </div>

            <div class="p-4 p-md-5">
                <% if ("approved".equals(request.getParameter("msg"))) { %>
                    <div class="alert alert-success rounded-3 mb-4"><i class="bi bi-check-circle-fill me-2"></i>Work record approved and payment record generated!</div>
                <% } else if (request.getParameter("error") != null) { %>
                    <div class="alert alert-danger rounded-3 mb-4">Error: <%= request.getParameter("error") %></div>
                <% } %>

                <!-- Filter Tabs -->
                <div class="d-flex flex-wrap gap-2 mb-4">
                    <a href="workApproval.jsp?status=ALL" class="btn btn-sm rounded-pill px-3 fw-semibold <%= "ALL".equals(filterStatus) ? "btn-primary" : "btn-outline-secondary" %>">All Work Logs</a>
                    <a href="workApproval.jsp?status=Pending" class="btn btn-sm rounded-pill px-3 fw-semibold <%= "Pending".equals(filterStatus) ? "btn-warning text-dark" : "btn-outline-secondary" %>">Pending Verification</a>
                    <a href="workApproval.jsp?status=Approved" class="btn btn-sm rounded-pill px-3 fw-semibold <%= "Approved".equals(filterStatus) ? "btn-success" : "btn-outline-secondary" %>">Approved</a>
                </div>

                <!-- Work Records Table -->
                <div class="metric-card p-4">
                    <h6 class="fw-bold mb-3"><i class="bi bi-clock-history text-primary me-2"></i>Student Timesheets & Shift Logs</h6>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle small">
                            <thead class="table-light">
                                <tr>
                                    <th>Student</th>
                                    <th>Job Title</th>
                                    <th>Work Date & Shift</th>
                                    <th>Hours & Rate</th>
                                    <th>Gross Wage</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    String sql = "SELECT wr.record_id, wr.hours_worked, wr.hourly_rate, wr.work_date, wr.work_status, " +
                                                 "wr.clock_in, wr.clock_out, " +
                                                 "j.job_title, u.full_name, s.matric_number " +
                                                 "FROM work_records wr " +
                                                 "JOIN applications a ON wr.application_id = a.application_id " +
                                                 "JOIN jobs j ON a.job_id = j.job_id " +
                                                 "JOIN students s ON a.student_id = s.student_id " +
                                                 "JOIN users u ON s.user_id = u.user_id " +
                                                 "WHERE j.employer_id = ? ";
                                    if (!"ALL".equals(filterStatus)) {
                                        sql += "AND wr.work_status = ? ";
                                    }
                                    sql += "ORDER BY wr.work_date DESC, wr.record_id DESC";

                                    ps = conn.prepareStatement(sql);
                                    ps.setInt(1, employerId);
                                    if (!"ALL".equals(filterStatus)) {
                                        ps.setString(2, filterStatus);
                                    }
                                    rs = ps.executeQuery();

                                    boolean hasRecords = false;
                                    while (rs.next()) {
                                        hasRecords = true;
                                        double hours = rs.getDouble("hours_worked");
                                        double rate = rs.getDouble("hourly_rate");
                                        double gross = hours * rate;
                                        String st = rs.getString("work_status");
                                        Time clockIn = rs.getTime("clock_in");
                                        Time clockOut = rs.getTime("clock_out");
                                %>
                                <tr>
                                    <td>
                                        <div class="fw-bold text-dark"><%= rs.getString("full_name") %></div>
                                        <div class="text-muted" style="font-size: 0.75rem;"><%= rs.getString("matric_number") %></div>
                                    </td>
                                    <td class="fw-semibold text-dark"><%= rs.getString("job_title") %></td>
                                    <td>
                                        <div class="fw-semibold"><%= rs.getDate("work_date") %></div>
                                        <div class="text-muted" style="font-size: 0.75rem;">
                                            <%= (clockIn != null && clockOut != null) ? (clockIn.toString() + " - " + clockOut.toString()) : "Manual Log" %>
                                        </div>
                                    </td>
                                    <td>
                                        <div><strong><%= String.format("%.2f", hours) %></strong> hrs</div>
                                        <div class="text-muted" style="font-size: 0.75rem;">@ RM <%= String.format("%.2f", rate) %>/hr</div>
                                    </td>
                                    <td class="fw-bold text-primary">RM <%= String.format("%.2f", gross) %></td>
                                    <td>
                                        <span class="badge <%= "Approved".equals(st) ? "bg-success" : "bg-warning text-dark" %>"><%= st %></span>
                                    </td>
                                    <td>
                                        <% if ("Pending".equals(st)) { %>
                                            <form action="../EmployerWorkRecordServlet" method="post" class="d-inline">
                                                <input type="hidden" name="record_id" value="<%= rs.getInt("record_id") %>">
                                                <input type="hidden" name="action" value="approve">
                                                <button type="submit" class="btn btn-success btn-sm rounded-2 px-3 fw-semibold">
                                                    <i class="bi bi-check2-circle me-1"></i>Approve
                                                </button>
                                            </form>
                                        <% } else { %>
                                            <span class="text-success fw-semibold small"><i class="bi bi-patch-check-fill me-1"></i>Verified</span>
                                        <% } %>
                                    </td>
                                </tr>
                                <%
                                    }
                                    if (!hasRecords) {
                                %>
                                <tr>
                                    <td colspan="7" class="text-center text-muted py-4">No work records submitted by hired students yet.</td>
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