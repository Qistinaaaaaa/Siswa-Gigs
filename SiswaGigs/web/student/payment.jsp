<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.siswagigs.dao.DBConnection" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    if (userId == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    double totalPaid = 0.0;
    double totalPending = 0.0;
    int totalCount = 0;

    Connection conn = null;
    PreparedStatement psSummary = null;
    ResultSet rsSummary = null;
    try {
        conn = DBConnection.getConnection();
        String sqlSummary = "SELECT p.status, COALESCE(SUM(p.amount), 0) AS total_amt, COUNT(*) AS cnt " +
                            "FROM payments p " +
                            "JOIN applications a ON p.application_id = a.application_id " +
                            "WHERE a.user_id = ? " +
                            "GROUP BY p.status";
        psSummary = conn.prepareStatement(sqlSummary);
        psSummary.setInt(1, userId);
        rsSummary = psSummary.executeQuery();
        while (rsSummary.next()) {
            String st = rsSummary.getString("status");
            double amt = rsSummary.getDouble("total_amt");
            int cnt = rsSummary.getInt("cnt");
            totalCount += cnt;
            if ("Paid".equalsIgnoreCase(st)) {
                totalPaid += amt;
            } else {
                totalPending += amt;
            }
        }
    } catch (Exception e) {
        // Handled cleanly in table below
    } finally {
        if (rsSummary != null) { try { rsSummary.close(); } catch (Exception ignored) {} }
        if (psSummary != null) { try { psSummary.close(); } catch (Exception ignored) {} }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payments &amp; Payouts | Siswa-Gigs</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        body { background-color: #f8fafc; font-family: 'Segoe UI', system-ui, sans-serif; }
        .sidebar { width: 260px; min-height: 100vh; background-color: #0f172a; }
        .main-content { flex: 1; padding: 2rem; }
        .card { border: none; border-radius: 14px; box-shadow: 0 2px 12px rgba(0,0,0,0.04); }
        .header-banner {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            color: #ffffff;
            border-radius: 16px;
            padding: 1.75rem 2rem;
        }
        .user-dropdown-btn {
            background-color: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            padding: 0.5rem 1.1rem;
            font-weight: 600;
            font-size: 0.875rem;
            color: #1e293b;
            box-shadow: 0 2px 8px rgba(15, 23, 42, 0.06);
        }
        .user-dropdown-btn::after { display: none; }
        .user-avatar-circle {
            width: 30px; height: 30px; border-radius: 50%;
            background-color: #e2e8f0; color: #0f172a;
            display: inline-flex; align-items: center; justify-content: center;
        }
        .user-name-truncate {
            max-width: 170px; white-space: nowrap; overflow: hidden;
            text-overflow: ellipsis; display: inline-block; vertical-align: middle;
        }
    </style>
</head>
<body>
<div class="d-flex">
    <%@ include file="sidebar.jsp" %>

    <div class="main-content">
        <!-- Top-Right User Profile & Logout Dropdown -->
        <div class="d-flex justify-content-end align-items-center mb-3">
            <div class="dropdown">
                <button class="btn user-dropdown-btn dropdown-toggle d-flex align-items-center gap-2"
                        type="button" id="userMenuDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                    <span class="user-avatar-circle"><i class="bi bi-person-fill"></i></span>
                    <span class="text-uppercase user-name-truncate"><%= (userName != null) ? userName : "STUDENT" %></span>
                    <i class="bi bi-chevron-down small text-muted ms-1"></i>
                </button>
                <ul class="dropdown-menu dropdown-menu-end shadow border-0 rounded-3 mt-2" aria-labelledby="userMenuDropdown">
                    <li><a class="dropdown-item py-2 fw-medium" href="profile.jsp"><i class="bi bi-person-circle me-2 text-primary"></i> My Profile</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item py-2 fw-semibold text-danger" href="../LogoutServlet"><i class="bi bi-box-arrow-right me-2"></i> Log Out</a></li>
                </ul>
            </div>
        </div>

        
        <div class="header-banner shadow-sm mb-4">
            <div class="d-flex flex-wrap justify-content-between align-items-center gap-3">
                <div>
                    <h3 class="fw-bold mb-1">Payments &amp; Payouts</h3>
                    <p class="text-light opacity-75 mb-0">Manage gig wage payouts, payment methods, and transaction receipts.</p>
                </div>
                <a href="WageCalculationServlet" class="btn btn-primary fw-semibold px-3 py-2 rounded-3">
                    <i class="bi bi-calculator me-1"></i> Calculate New Wage
                </a>
            </div>
        </div>

      
        <% String msg = request.getParameter("msg");
           if ("created".equals(msg)) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i> Payment record generated and queued for payout!
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } else if ("paid".equals(msg)) { %>
            <div class="alert alert-info alert-dismissible fade show" role="alert">
                <i class="bi bi-patch-check-fill me-2"></i> Payment status updated to <strong>Paid</strong>!
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

       
        <div class="row g-3 mb-4">
            <div class="col-md-4">
                <div class="card p-4 border-start border-success border-4">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <div class="text-uppercase small text-muted fw-bold">Total Paid Out</div>
                            <h3 class="fw-bold text-success mb-0 mt-1">RM <%= String.format("%.2f", totalPaid) %></h3>
                        </div>
                        <i class="bi bi-wallet2 fs-1 text-success opacity-75"></i>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card p-4 border-start border-warning border-4">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <div class="text-uppercase small text-muted fw-bold">Pending Payout</div>
                            <h3 class="fw-bold text-dark mb-0 mt-1">RM <%= String.format("%.2f", totalPending) %></h3>
                        </div>
                        <i class="bi bi-hourglass-split fs-1 text-warning"></i>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card p-4 border-start border-primary border-4">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <div class="text-uppercase small text-muted fw-bold">Total Transactions</div>
                            <h3 class="fw-bold text-dark mb-0 mt-1"><%= totalCount %></h3>
                        </div>
                        <i class="bi bi-receipt-cutoff fs-1 text-primary"></i>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <!-- Left Column: Quick Payment Request Form -->
            <div class="col-lg-4">
                <div class="card p-4">
                    <h5 class="fw-bold mb-3"><i class="bi bi-bank text-primary me-2"></i>Submit Payout Claim</h5>
                    <form action="PaymentServlet" method="POST">
                        <input type="hidden" name="action" value="createPayment">

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Approved Gig</label>
                            <select name="applicationId" class="form-select" required>
                                <option value="" disabled selected>-- Select Gig --</option>
                                <%
                                    PreparedStatement psApps = null;
                                    ResultSet rsApps = null;
                                    try {
                                        if (conn == null || conn.isClosed()) {
                                            conn = DBConnection.getConnection();
                                        }
                                        String sqlApps = "SELECT a.application_id, j.title " +
                                                         "FROM applications a " +
                                                         "JOIN jobs j ON a.job_id = j.job_id " +
                                                         "WHERE a.user_id = ? AND a.status = 'Approved'";
                                        psApps = conn.prepareStatement(sqlApps);
                                        psApps.setInt(1, userId);
                                        rsApps = psApps.executeQuery();
                                        while (rsApps.next()) {
                                %>
                                    <option value="<%= rsApps.getInt("application_id") %>">
                                        <%= rsApps.getString("title") %>
                                    </option>
                                <%
                                        }
                                    } catch (Exception e) {
                                        out.println("<option disabled>Error: " + e.getMessage() + "</option>");
                                    } finally {
                                        if (rsApps != null) { try { rsApps.close(); } catch (Exception ignored) {} }
                                        if (psApps != null) { try { psApps.close(); } catch (Exception ignored) {} }
                                    }
                                %>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Amount (RM)</label>
                            <input type="number" step="0.01" min="1.00" name="amount" class="form-control" placeholder="e.g. 120.00" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Payment Method</label>
                            <select name="paymentMethod" class="form-select" required>
                                <option value="Online Banking (FPX)">Online Banking (FPX)</option>
                                <option value="DuitNow Transfer">DuitNow Transfer</option>
                                <option value="Cash">Cash</option>
                            </select>
                        </div>

                        <button type="submit" class="btn btn-primary w-100 fw-semibold">
                            <i class="bi bi-send-check me-1"></i> Request Payment
                        </button>
                    </form>
                </div>
            </div>

           
            <div class="col-lg-8">
                <div class="card p-4">
                    <h5 class="fw-bold mb-3"><i class="bi bi-clock-history text-primary me-2"></i>Payment Transaction History</h5>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Payment ID</th>
                                    <th>Gig Title</th>
                                    <th>Method</th>
                                    <th>Amount</th>
                                    <th>Date</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    PreparedStatement psPay = null;
                                    ResultSet rsPay = null;
                                    boolean hasPayments = false;
                                    try {
                                        if (conn == null || conn.isClosed()) {
                                            conn = DBConnection.getConnection();
                                        }
                                        String sqlPay = "SELECT p.payment_id, p.amount, p.payment_method, p.payment_date, p.status, j.title " +
                                                        "FROM payments p " +
                                                        "JOIN applications a ON p.application_id = a.application_id " +
                                                        "JOIN jobs j ON a.job_id = j.job_id " +
                                                        "WHERE a.user_id = ? " +
                                                        "ORDER BY p.payment_id DESC";
                                        psPay = conn.prepareStatement(sqlPay);
                                        psPay.setInt(1, userId);
                                        rsPay = psPay.executeQuery();
                                        while (rsPay.next()) {
                                            hasPayments = true;
                                            int payId = rsPay.getInt("payment_id");
                                            String status = rsPay.getString("status");
                                            String method = rsPay.getString("payment_method");
                                            boolean isPaid = "Paid".equalsIgnoreCase(status);
                                %>
                                <tr>
                                    <td class="fw-semibold text-muted">#PAY-<%= String.format("%04d", payId) %></td>
                                    <td class="fw-semibold"><%= rsPay.getString("title") %></td>
                                    <td><%= (method != null) ? method : "Online Banking" %></td>
                                    <td class="fw-bold text-dark">RM <%= String.format("%.2f", rsPay.getDouble("amount")) %></td>
                                    <td><%= (rsPay.getDate("payment_date") != null) ? rsPay.getDate("payment_date") : "-" %></td>
                                    <td>
                                        <span class="badge <%= isPaid ? "bg-success" : "bg-warning text-dark" %>">
                                            <%= status %>
                                        </span>
                                    </td>
                                    <td>
                                        <% if (!isPaid) { %>
                                            <form action="PaymentServlet" method="POST" class="d-inline">
                                                <input type="hidden" name="action" value="markPaid">
                                                <input type="hidden" name="paymentId" value="<%= payId %>">
                                                <button type="submit" class="btn btn-sm btn-success">
                                                    <i class="bi bi-check2-circle"></i> Mark Paid
                                                </button>
                                            </form>
                                        <% } else { %>
                                            <span class="text-success small fw-semibold"><i class="bi bi-check-all"></i> Completed</span>
                                        <% } %>
                                    </td>
                                </tr>
                                <%
                                        }
                                    } catch (Exception e) {
                                        out.println("<tr><td colspan='7' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
                                    } finally {
                                        if (rsPay != null) { try { rsPay.close(); } catch (Exception ignored) {} }
                                        if (psPay != null) { try { psPay.close(); } catch (Exception ignored) {} }
                                        if (conn != null) { try { conn.close(); } catch (Exception ignored) {} }
                                    }
                                    if (!hasPayments) {
                                %>
                                <tr>
                                    <td colspan="7" class="text-center text-muted py-4">No payment records found yet.</td>
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
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
