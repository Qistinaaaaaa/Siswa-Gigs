<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userId") == null || !"Employer".equals(userSession.getAttribute("role"))) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }

    int userId = (Integer) userSession.getAttribute("userId");
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
    <title>Post a Job | Siswa-Gigs</title>
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
                    <h5 class="fw-bold text-dark mb-0">Post & Manage Gigs</h5>
                </div>
            </div>

            <div class="p-4 p-md-5">
                <% if ("posted".equals(request.getParameter("status"))) { %>
                    <div class="alert alert-success rounded-3 mb-4"><i class="bi bi-check-circle-fill me-2"></i>New gig posted successfully!</div>
                <% } else if ("closed".equals(request.getParameter("status"))) { %>
                    <div class="alert alert-info rounded-3 mb-4"><i class="bi bi-info-circle-fill me-2"></i>Gig status updated to Closed.</div>
                <% } else if (request.getParameter("error") != null) { %>
                    <div class="alert alert-danger rounded-3 mb-4">Error: <%= request.getParameter("error") %></div>
                <% } %>

                <div class="row g-4">
                    <!-- Post New Job Form -->
                    <div class="col-lg-5">
                        <div class="metric-card p-4">
                            <h6 class="fw-bold mb-3"><i class="bi bi-plus-circle text-primary me-2"></i>Create New Gig Listing</h6>
                            <form action="../EmployerJobServlet" method="post">
                                <input type="hidden" name="action" value="create">
                                <div class="mb-3">
                                    <label class="form-label small fw-semibold">Job Title</label>
                                    <input type="text" name="job_title" class="form-control rounded-3" placeholder="e.g. Part-Time Barista" required>
                                </div>
                                <div class="row g-2 mb-3">
                                    <div class="col-6">
                                        <label class="form-label small fw-semibold">Hourly Rate (RM)</label>
                                        <input type="number" step="0.01" min="1" name="hourly_rate" class="form-control rounded-3" placeholder="10.00" required>
                                    </div>
                                    <div class="col-6">
                                        <label class="form-label small fw-semibold">Vacancies</label>
                                        <input type="number" min="1" name="vacancies" class="form-control rounded-3" value="1" required>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label small fw-semibold">Work Location</label>
                                    <input type="text" name="location" class="form-control rounded-3" placeholder="e.g. Seksyen 7, Shah Alam" required>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label small fw-semibold">Expiry Date</label>
                                    <input type="date" name="expiry_date" class="form-control rounded-3" required>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label small fw-semibold">Required Skills</label>
                                    <div class="border rounded-3 p-2 bg-light" style="max-height: 130px; overflow-y: auto;">
                                        <%
                                            ps = conn.prepareStatement("SELECT skill_id, skill_name FROM skills ORDER BY skill_name ASC");
                                            rs = ps.executeQuery();
                                            while (rs.next()) {
                                        %>
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" name="skill_ids" value="<%= rs.getInt("skill_id") %>" id="sk_<%= rs.getInt("skill_id") %>">
                                                <label class="form-check-label small" for="sk_<%= rs.getInt("skill_id") %>"><%= rs.getString("skill_name") %></label>
                                            </div>
                                        <%
                                            }
                                            rs.close();
                                            ps.close();
                                        %>
                                    </div>
                                </div>
                                <div class="mb-4">
                                    <label class="form-label small fw-semibold">Job Description</label>
                                    <textarea name="description" class="form-control rounded-3" rows="3" placeholder="Describe tasks, shift hours, dress code..." required></textarea>
                                </div>
                                <button type="submit" class="btn btn-primary w-100 rounded-3 fw-semibold py-2">
                                    Publish Gig
                                </button>
                            </form>
                        </div>
                    </div>

                    <!-- Posted Jobs List -->
                    <div class="col-lg-7">
                        <div class="metric-card p-4">
                            <h6 class="fw-bold mb-3"><i class="bi bi-list-task text-primary me-2"></i>Your Posted Gigs</h6>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle small">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Job Title</th>
                                            <th>Rate</th>
                                            <th>Vacancies</th>
                                            <th>Status</th>
                                            <th>Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                            ps = conn.prepareStatement("SELECT * FROM jobs WHERE employer_id = ? ORDER BY job_id DESC");
                                            ps.setInt(1, employerId);
                                            rs = ps.executeQuery();
                                            boolean hasJobs = false;
                                            while (rs.next()) {
                                                hasJobs = true;
                                                String st = rs.getString("job_status");
                                        %>
                                        <tr>
                                            <td>
                                                <div class="fw-bold text-dark"><%= rs.getString("job_title") %></div>
                                                <div class="text-muted" style="font-size: 0.75rem;"><i class="bi bi-geo-alt"></i> <%= rs.getString("location") %></div>
                                            </td>
                                            <td class="fw-semibold">RM <%= String.format("%.2f", rs.getDouble("hourly_rate")) %>/hr</td>
                                            <td><%= rs.getInt("vacancies") %></td>
                                            <td>
                                                <span class="badge <%= "Available".equals(st) ? "bg-success" : "bg-secondary" %>"><%= st %></span>
                                            </td>
                                            <td>
                                                <% if ("Available".equals(st)) { %>
                                                <form action="../EmployerJobServlet" method="post" class="d-inline">
                                                    <input type="hidden" name="action" value="close">
                                                    <input type="hidden" name="job_id" value="<%= rs.getInt("job_id") %>">
                                                    <button type="submit" class="btn btn-outline-danger btn-sm rounded-2">Close</button>
                                                </form>
                                                <% } else { %>
                                                    <span class="text-muted">-</span>
                                                <% } %>
                                            </td>
                                        </tr>
                                        <%
                                            }
                                            if (!hasJobs) {
                                        %>
                                        <tr>
                                            <td colspan="5" class="text-center text-muted py-4">No gigs posted yet. Create your first listing on the left!</td>
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