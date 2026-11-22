<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, com.siswagigs.dao.DBConnection" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");
    if (userId == null) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }

    String fullName = (String) session.getAttribute("fullName");
    if (fullName == null) fullName = "User";

    // {payment_id, record_id, student_name, job_title, work_date, hours, rate, gross, fee, net, pay_status, pay_date}
    List<String[]> payments = new ArrayList<String[]>();
    double totalNet = 0;
    double totalPaid = 0;

    try (Connection conn = DBConnection.getConnection()) {
        StringBuilder sql = new StringBuilder(
            "SELECT p.payment_id, p.record_id, u.full_name, j.job_title, wr.work_date, " +
            "wr.hours_worked, wr.hourly_rate, p.gross_wage, p.processing_fee, p.net_payable, " +
            "p.payment_status, p.payment_date " +
            "FROM payments p " +
            "JOIN work_records wr ON p.record_id = wr.record_id " +
            "JOIN applications a ON wr.application_id = a.application_id " +
            "JOIN students s ON a.student_id = s.student_id " +
            "JOIN users u ON s.user_id = u.user_id " +
            "JOIN jobs j ON a.job_id = j.job_id "
        );

        if ("Student".equalsIgnoreCase(role)) {
            sql.append("WHERE s.user_id = ? ");
        }
        sql.append("ORDER BY p.payment_id DESC");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if ("Student".equalsIgnoreCase(role)) {
                ps.setInt(1, userId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    double net = rs.getDouble("net_payable");
                    String pStatus = rs.getString("payment_status");
                    totalNet += net;
                    if ("Paid".equalsIgnoreCase(pStatus)) totalPaid += net;

                    payments.add(new String[]{
                        rs.getString("payment_id"),
                        rs.getString("record_id"),
                        rs.getString("full_name"),
                        rs.getString("job_title"),
                        rs.getString("work_date"),
                        String.format("%.2f", rs.getDouble("hours_worked")),
                        String.format("%.2f", rs.getDouble("hourly_rate")),
                        String.format("%.2f", rs.getDouble("gross_wage")),
                        String.format("%.2f", rs.getDouble("processing_fee")),
                        String.format("%.2f", net),
                        pStatus,
                        rs.getString("payment_date") != null ? rs.getString("payment_date") : "-"
                    });
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    String status = request.getParameter("status");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Payments | Siswa-Gigs</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; font-family: 'Inter', 'Segoe UI', sans-serif; color: #0f172a; }
        .sidebar { width: 260px; height: 100vh; position: fixed; top: 0; left: 0; background-color: #0f172a; color: #fff; z-index: 100; }
        .main-content { margin-left: 260px; padding: 2.5rem; }
        @media (max-width: 991px) { .main-content { margin-left: 0; padding: 1.25rem; } }
        .hero { background: #16213a; color: #fff; border-radius: 1.5rem; padding: 2rem 2.25rem; }
        .panel { background: #fff; border: 1px solid #e2e8f0; border-radius: 1.25rem; padding: 1.75rem; }
    </style>
</head>
<body>

    <jsp:include page="sidebar.jsp" />

    <div class="main-content">
        <!-- Top bar -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <div class="text-muted small">Work & Payment Module</div>
                <div class="fw-bold fs-5">Payment Records</div>
            </div>
            <div class="fw-semibold text-muted"><i class="bi bi-person-circle me-1"></i> <%= fullName %></div>
        </div>

        <!-- Hero -->
        <div class="hero mb-4 d-flex justify-content-between align-items-center flex-wrap gap-3">
            <div>
                <h1 class="fs-3 fw-bold mb-1">Payments & Payouts</h1>
                <p class="text-light opacity-75 mb-0">Total Payable: <strong>RM <%= String.format("%.2f", totalNet) %></strong> &bull; Paid Out: <strong>RM <%= String.format("%.2f", totalPaid) %></strong></p>
            </div>
            <a href="wageCalculation.jsp" class="btn btn-primary rounded-pill px-4 fw-semibold">
                <i class="bi bi-plus-circle me-1"></i> Calculate New Wage
            </a>
        </div>

        <% if ("created".equals(status)) { %>
            <div class="alert alert-success rounded-4 mb-4"><i class="bi bi-check-circle-fill me-2"></i> Payment record generated successfully.</div>
        <% } else if ("paid".equals(status)) { %>
            <div class="alert alert-success rounded-4 mb-4"><i class="bi bi-check-circle-fill me-2"></i> Payment marked as Paid.</div>
        <% } else if ("deleted".equals(status)) { %>
            <div class="alert alert-warning rounded-4 mb-4"><i class="bi bi-trash me-2"></i> Unpaid payment record removed.</div>
        <% } else if (error != null) { %>
            <div class="alert alert-danger rounded-4 mb-4"><i class="bi bi-exclamation-triangle-fill me-2"></i> <%= error %></div>
        <% } %>

        <div class="panel">
            <div class="table-responsive">
                <table class="table align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Pay ID</th>
                            <th>Student</th>
                            <th>Gig & Shift Date</th>
                            <th>Gross</th>
                            <th>Fee</th>
                            <th>Net Payable</th>
                            <th>Status</th>
                            <th>Payment Date</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (payments.isEmpty()) { %>
                        <tr><td colspan="9" class="text-center py-4 text-muted">No payment records found yet.</td></tr>
                    <% } else {
                           for (String[] p : payments) {
                               boolean isPaid = "Paid".equalsIgnoreCase(p[10]);
                    %>
                        <tr>
                            <td class="fw-semibold">#<%= p[0] %></td>
                            <td><%= p[2] %></td>
                            <td>
                                <div class="fw-semibold"><%= p[3] %></div>
                                <div class="small text-muted"><%= p[4] %> (<%= p[5] %> hrs @ RM <%= p[6] %>)</div>
                            </td>
                            <td>RM <%= p[7] %></td>
                            <td class="text-danger">- RM <%= p[8] %></td>
                            <td class="fw-bold text-success">RM <%= p[9] %></td>
                            <td>
                                <span class="badge rounded-pill <%= isPaid ? "bg-success-subtle text-success" : "bg-warning-subtle text-warning-emphasis" %>">
                                    <%= p[10] %>
                                </span>
                            </td>
                            <td><%= p[11] %></td>
                            <td>
                                <% if (!isPaid) { %>
                                    <a href="PaymentServlet?action=pay&paymentId=<%= p[0] %>" class="btn btn-sm btn-success rounded-pill px-3">Mark Paid</a>
                                    <a href="PaymentServlet?action=delete&paymentId=<%= p[0] %>" class="btn btn-sm btn-outline-danger rounded-pill px-3" onclick="return confirm('Delete unpaid record?');">Delete</a>
                                <% } else { %>
                                    <span class="text-muted small"><i class="bi bi-check2-all"></i> Completed</span>
                                <% } %>
                            </td>
                        </tr>
                    <%     }
                       } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
