<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, com.siswagigs.dao.DBConnection" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }

    String fullName = (String) session.getAttribute("fullName");
    if (fullName == null) fullName = "User";

    // {record_id, student_name, job_title, work_date, hours_worked, hourly_rate}
    List<String[]> approvedRecords = new ArrayList<String[]>();

    try (Connection conn = DBConnection.getConnection()) {
        String sql = "SELECT wr.record_id, u.full_name, j.job_title, wr.work_date, wr.hours_worked, wr.hourly_rate " +
                     "FROM work_records wr " +
                     "JOIN applications a ON wr.application_id = a.application_id " +
                     "JOIN students s ON a.student_id = s.student_id " +
                     "JOIN users u ON s.user_id = u.user_id " +
                     "JOIN jobs j ON a.job_id = j.job_id " +
                     "LEFT JOIN payments p ON p.record_id = wr.record_id " +
                     "WHERE wr.work_status = 'Approved' AND p.payment_id IS NULL " +
                     "ORDER BY wr.work_date DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                approvedRecords.add(new String[]{
                    rs.getString("record_id"),
                    rs.getString("full_name"),
                    rs.getString("job_title"),
                    rs.getString("work_date"),
                    rs.getString("hours_worked"),
                    rs.getString("hourly_rate")
                });
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Wage Calculation | Siswa-Gigs</title>
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
        .form-label { font-weight: 600; font-size: .85rem; color: #334155; }
    </style>
</head>
<body onload="onRecordChange()">

    <jsp:include page="sidebar.jsp" />

    <div class="main-content">
        <!-- Top bar -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <div class="text-muted small">Work & Payment Module</div>
                <div class="fw-bold fs-5">Wage Calculation</div>
            </div>
            <div class="fw-semibold text-muted"><i class="bi bi-person-circle me-1"></i> <%= fullName %></div>
        </div>

        <div class="hero mb-4">
            <h1 class="fs-3 fw-bold mb-1">Wage & Deduction Calculation</h1>
            <p class="text-light opacity-75 mb-0">Calculate gross wage (Hours × Hourly Rate), deduct processing fee, and generate payment records.</p>
        </div>

        <% if (error != null) { %>
            <div class="alert alert-danger rounded-4 mb-4">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>
                <%= "not_approved".equals(error) ? "Only approved work records can be calculated." :
                    "already_exists".equals(error) ? "A payment record already exists for this shift." :
                    "missing_fields".equals(error) ? "Please fill in all fields." : error %>
            </div>
        <% } %>

        <div class="panel">
            <h2 class="fs-5 fw-bold mb-3">Generate Payable Record</h2>

            <% if (approvedRecords.isEmpty()) { %>
                <div class="text-center py-5 text-muted">
                    <i class="bi bi-check2-circle fs-1 d-block mb-2"></i>
                    <div class="fw-semibold text-dark">No approved shifts awaiting calculation</div>
                    <div class="small mb-3">All approved work records already have payments generated.</div>
                    <a href="payment.jsp" class="btn btn-primary rounded-pill px-4 fw-semibold">View Payments</a>
                </div>
            <% } else { %>
                <form action="PaymentServlet" method="POST">
                    <div class="row g-3">
                        <div class="col-12">
                            <label class="form-label">Select Approved Work Record</label>
                            <select name="recordId" id="recordId" class="form-select" onchange="onRecordChange()" required>
                                <% for (String[] r : approvedRecords) { %>
                                    <option value="<%= r[0] %>" data-hours="<%= r[4] %>" data-rate="<%= r[5] %>">
                                        #<%= r[0] %> — <%= r[1] %> | <%= r[2] %> (<%= r[3] %>)
                                    </option>
                                <% } %>
                            </select>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label">Hours Worked</label>
                            <input type="text" id="hoursWorked" class="form-control bg-light" readonly>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label">Hourly Rate (RM)</label>
                            <input type="text" id="hourlyRate" class="form-control bg-light" readonly>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label">Platform Processing Fee (RM)</label>
                            <input type="number" step="0.01" min="0" name="processingFee" id="processingFee" value="5.00" class="form-control" oninput="recalculate()" required>
                        </div>

                        <div class="col-md-6">
                            <div class="p-3 rounded-4 bg-light border">
                                <div class="small text-muted">Gross Wage (Hours × Hourly Rate)</div>
                                <div class="fs-4 fw-bold" id="grossDisplay">RM 0.00</div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="p-3 rounded-4 border" style="background:#dcfce7; border-color:#86efac !important;">
                                <div class="small text-success fw-semibold">Net Payable (Gross Wage − Fee)</div>
                                <div class="fs-4 fw-bold text-success" id="netDisplay">RM 0.00</div>
                            </div>
                        </div>
                    </div>

                    <div class="mt-4 d-flex gap-2">
                        <button type="submit" class="btn btn-primary rounded-pill px-4 py-2 fw-semibold">
                            <i class="bi bi-calculator me-1"></i> Save Payment Record
                        </button>
                        <a href="payment.jsp" class="btn btn-outline-secondary rounded-pill px-4 py-2">View Payments</a>
                    </div>
                </form>
            <% } %>
        </div>
    </div>

    <script>
        function onRecordChange() {
            var sel = document.getElementById("recordId");
            if (!sel || sel.options.length === 0) return;
            var opt = sel.options[sel.selectedIndex];
            document.getElementById("hoursWorked").value = opt.getAttribute("data-hours");
            document.getElementById("hourlyRate").value = opt.getAttribute("data-rate");
            recalculate();
        }

        function recalculate() {
            var hrs = parseFloat(document.getElementById("hoursWorked").value) || 0;
            var rate = parseFloat(document.getElementById("hourlyRate").value) || 0;
            var fee = parseFloat(document.getElementById("processingFee").value) || 0;

            var gross = hrs * rate;
            var net = Math.max(0, gross - fee);

            document.getElementById("grossDisplay").textContent = "RM " + gross.toFixed(2);
            document.getElementById("netDisplay").textContent = "RM " + net.toFixed(2);
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>