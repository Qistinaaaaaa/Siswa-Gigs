<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.siswagigs.dao.DBConnection" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    String fullName = (String) session.getAttribute("fullName");
    String matricNumber = (String) session.getAttribute("matricNumber");
    if (userId == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    Double calcTotalHours = (Double) request.getAttribute("totalHours");
    Double calcGrossWage = (Double) request.getAttribute("grossWage");
    Double calcBonus = (Double) request.getAttribute("bonus");
    Double calcDeduction = (Double) request.getAttribute("deduction");
    Double calcNetWage = (Double) request.getAttribute("netWage");
    String selectedJobTitle = (String) request.getAttribute("jobTitle");
    Integer selectedAppId = (Integer) request.getAttribute("applicationId");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Wage Calculation | Siswa-Gigs</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        body { background-color: #f8fafc; font-family: 'Segoe UI', system-ui, sans-serif; }
        .sidebar { width: 260px; min-height: 100vh; background-color: #0f172a; }
        .main-content { flex: 1; padding: 2rem; }
        .card { border: none; border-radius: 14px; box-shadow: 0 2px 12px rgba(0,0,0,0.04); }
        .summary-box { background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%); color: #fff; border-radius: 14px; }
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
        .user-name-full {
            white-space: nowrap;
            display: inline-block;
            vertical-align: middle;
        }
    </style>
</head>
<body>
<div class="d-flex">
    <%@ include file="sidebar.jsp" %>

    <div class="main-content">
        <!-- Top-Right Profile Dropdown & Header Row -->
        <div class="d-flex justify-content-between align-items-start mb-4">
            <div>
                <h3 class="fw-bold text-dark mb-1">Wage Calculator</h3>
                <p class="text-muted mb-0">Compute gross and net wages from logged shift records and proceed to payment.</p>
            </div>
            <div class="dropdown">
                <button class="btn user-dropdown-btn dropdown-toggle d-flex align-items-center gap-2"
                        type="button" id="userMenuDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                    <span class="user-avatar-circle bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 28px; height: 28px; font-size: 0.8rem;">
                        <%= (fullName != null && !fullName.isEmpty()) ? fullName.substring(0, 1).toUpperCase() : "S" %>
                    </span>
                    <span class="text-uppercase user-name-full"><%= (fullName != null) ? fullName : "Student" %></span>
                    <i class="bi bi-chevron-down small text-muted ms-1"></i>
                </button>
                <ul class="dropdown-menu dropdown-menu-end shadow border-0 rounded-3 mt-2" aria-labelledby="userMenuDropdown">
                    <li><h6 class="dropdown-header text-muted small"><%= (matricNumber != null) ? matricNumber : "-" %></h6></li>
                    <li><a class="dropdown-item py-2 fw-medium" href="profile.jsp"><i class="bi bi-person-circle me-2 text-primary"></i> My Profile</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item py-2 fw-semibold text-danger" href="../LogoutServlet"><i class="bi bi-box-arrow-right me-2"></i> Log Out</a></li>
                </ul>
            </div>
        </div>

        <div class="row g-4">
            <!-- Left Column: Wage Calculation Form -->
            <div class="col-lg-6">
                <div class="card p-4">
                    <h5 class="fw-bold mb-3"><i class="bi bi-calculator text-primary me-2"></i>Calculate Gig Earnings</h5>
                    <form action="WageCalculationServlet" method="POST">
                        <input type="hidden" name="action" value="calculate">

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Select Gig Application</label>
                            <select name="applicationId" id="applicationSelect" class="form-select" required>
                                <option value="" disabled selected>-- Choose Gig --</option>
                                <%
                                    Connection conn = null;
                                    PreparedStatement ps = null;
                                    ResultSet rs = null;
                                    try {
                                        conn = DBConnection.getConnection();
                                        String sql = "SELECT a.application_id, j.title, j.hourly_rate, " +
                                                     "COALESCE(SUM(w.hours_worked), 0) AS total_hrs " +
                                                     "FROM applications a " +
                                                     "JOIN jobs j ON a.job_id = j.job_id " +
                                                     "LEFT JOIN work_records w ON a.application_id = w.application_id " +
                                                     "WHERE a.user_id = ? AND a.status = 'Approved' " +
                                                     "GROUP BY a.application_id, j.title, j.hourly_rate";
                                        ps = conn.prepareStatement(sql);
                                        ps.setInt(1, userId);
                                        rs = ps.executeQuery();
                                        while (rs.next()) {
                                            int appId = rs.getInt("application_id");
                                            String title = rs.getString("title");
                                            double rate = rs.getDouble("hourly_rate");
                                            double hrs = rs.getDouble("total_hrs");
                                            boolean isSelected = (selectedAppId != null && selectedAppId.intValue() == appId);
                                %>
                                    <option value="<%= appId %>" <%= isSelected ? "selected" : "" %>>
                                        <%= title %> — <%= String.format("%.1f", hrs) %> hrs @ RM <%= String.format("%.2f", rate) %>/hr
                                    </option>
                                <%
                                        }
                                    } catch (Exception e) {
                                        out.println("<option disabled>Error: " + e.getMessage() + "</option>");
                                    } finally {
                                        if (rs != null) { try { rs.close(); } catch (Exception ignored) {} }
                                        if (ps != null) { try { ps.close(); } catch (Exception ignored) {} }
                                        if (conn != null) { try { conn.close(); } catch (Exception ignored) {} }
                                    }
                                %>
                            </select>
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Performance Bonus (RM)</label>
                                <input type="number" step="0.01" min="0" name="bonus" class="form-control"
                                       value="<%= (calcBonus != null) ? String.format("%.2f", calcBonus) : "0.00" %>">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Deductions / Platform Fee (RM)</label>
                                <input type="number" step="0.01" min="0" name="deduction" class="form-control"
                                       value="<%= (calcDeduction != null) ? String.format("%.2f", calcDeduction) : "0.00" %>">
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary w-100 fw-semibold">
                            <i class="bi bi-lightning-charge-fill me-1"></i> Compute Net Wage
                        </button>
                    </form>
                </div>
            </div>

            <!-- Right Column: Wage Breakdown Card -->
            <div class="col-lg-6">
                <div class="summary-box p-4 h-100 d-flex flex-column justify-content-between">
                    <div>
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <span class="text-uppercase small fw-bold text-info">Wage Breakdown Statement</span>
                            <i class="bi bi-receipt fs-4 text-info"></i>
                        </div>

                        <h5 class="fw-bold mb-4">
                            <%= (selectedJobTitle != null) ? selectedJobTitle : "Select a gig to preview earnings" %>
                        </h5>

                        <div class="d-flex justify-content-between py-2 border-bottom border-secondary">
                            <span class="text-light opacity-75">Total Logged Hours</span>
                            <span class="fw-semibold"><%= (calcTotalHours != null) ? String.format("%.1f hrs", calcTotalHours) : "0.0 hrs" %></span>
                        </div>
                        <div class="d-flex justify-content-between py-2 border-bottom border-secondary">
                            <span class="text-light opacity-75">Gross Wage</span>
                            <span class="fw-semibold">RM <%= (calcGrossWage != null) ? String.format("%.2f", calcGrossWage) : "0.00" %></span>
                        </div>
                        <div class="d-flex justify-content-between py-2 border-bottom border-secondary">
                            <span class="text-light opacity-75">Bonus (+)</span>
                            <span class="text-success fw-semibold">+ RM <%= (calcBonus != null) ? String.format("%.2f", calcBonus) : "0.00" %></span>
                        </div>
                        <div class="d-flex justify-content-between py-2 border-bottom border-secondary">
                            <span class="text-light opacity-75">Deductions (-)</span>
                            <span class="text-danger fw-semibold">- RM <%= (calcDeduction != null) ? String.format("%.2f", calcDeduction) : "0.00" %></span>
                        </div>
                        <div class="d-flex justify-content-between align-items-center pt-3 mt-2">
                            <span class="fs-5 fw-bold">Net Payable Wage</span>
                            <span class="fs-3 fw-bold text-info">RM <%= (calcNetWage != null) ? String.format("%.2f", calcNetWage) : "0.00" %></span>
                        </div>
                    </div>

                    <% if (calcNetWage != null && calcNetWage.doubleValue() > 0 && selectedAppId != null) { %>
                    <form action="PaymentServlet" method="POST" class="mt-4">
                        <input type="hidden" name="action" value="createPayment">
                        <input type="hidden" name="applicationId" value="<%= selectedAppId %>">
                        <input type="hidden" name="amount" value="<%= String.format("%.2f", calcNetWage) %>">
                        <button type="submit" class="btn btn-info text-dark fw-bold w-100">
                            <i class="bi bi-cash-coin me-1"></i> Proceed to Payment Record
                        </button>
                    </form>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
