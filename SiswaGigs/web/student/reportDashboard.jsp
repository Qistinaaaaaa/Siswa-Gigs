<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }
    if (request.getAttribute("peakHiring") == null) {
        response.sendRedirect("ReportServlet");
        return;
    }

    String fullName = (String) session.getAttribute("fullName");
    if (fullName == null) fullName = "User";

    double totalGross = (Double) request.getAttribute("totalGross");
    double totalFees = (Double) request.getAttribute("totalFees");
    double totalNet = (Double) request.getAttribute("totalNet");
    double totalPaid = (Double) request.getAttribute("totalPaid");
    List<String[]> peakHiring = (List<String[]>) request.getAttribute("peakHiring");
    List<String[]> demandedSkills = (List<String[]>) request.getAttribute("demandedSkills");
%>
    <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Work & Payment Reports | Siswa-Gigs</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { background-color: #f8fafc; font-family: 'Inter', 'Segoe UI', sans-serif; color: #0f172a; }
        .sidebar { width: 260px; height: 100vh; position: fixed; top: 0; left: 0; background-color: #0f172a; color: #fff; z-index: 100; }
        .main-content { margin-left: 260px; padding: 2.5rem; }
        @media (max-width: 991px) { .main-content { margin-left: 0; padding: 1.25rem; } }
        .hero { background: #16213a; color: #fff; border-radius: 1.5rem; padding: 2rem 2.25rem; }
        .panel { background: #fff; border: 1px solid #e2e8f0; border-radius: 1.25rem; padding: 1.5rem; height: 100%; }
        .stat-card { background: #fff; border: 1px solid #e2e8f0; border-radius: 1.25rem; padding: 1.4rem; }
    </style>
</head>
<body>

    <jsp:include page="sidebar.jsp" />

    <div class="main-content">
        
        <!-- Top bar with Profile & Logout Dropdown -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <div class="text-muted small">Work &amp; Payment Module</div>
                <div class="fw-bold fs-5">Analytics &amp; Reports</div>
            </div>

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

        
        <div class="hero mb-4">
            <h1 class="fs-3 fw-bold mb-1">Work & Payment Dashboard Report</h1>
            <p class="text-light opacity-75 mb-0">Overview of total wages earned, peak hiring periods, and most demanded skill sets.</p>
        </div>

        <!-- Summary Cards -->
        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="small text-muted fw-semibold">Total Gross Wages</div>
                    <div class="fs-4 fw-bold text-primary mt-1">RM <%= String.format("%.2f", totalGross) %></div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="small text-muted fw-semibold">Platform Processing Fees</div>
                    <div class="fs-4 fw-bold text-warning mt-1">RM <%= String.format("%.2f", totalFees) %></div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="small text-muted fw-semibold">Total Net Payable</div>
                    <div class="fs-4 fw-bold text-dark mt-1">RM <%= String.format("%.2f", totalNet) %></div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="small text-muted fw-semibold">Total Paid Out</div>
                    <div class="fs-4 fw-bold text-success mt-1">RM <%= String.format("%.2f", totalPaid) %></div>
                </div>
            </div>
        </div>

        <!-- Charts -->
        <div class="row g-4 mb-4">
            <div class="col-lg-6">
                <div class="panel">
                    <h2 class="fs-6 fw-bold mb-3">Peak Hiring Periods (Vacancies by Month)</h2>
                    <canvas id="hiringChart" height="180"></canvas>
                </div>
            </div>
            <div class="col-lg-6">
                <div class="panel">
                    <h2 class="fs-6 fw-bold mb-3">Most Demanded Skill Sets</h2>
                    <canvas id="skillsChart" height="180"></canvas>
                </div>
            </div>
        </div>

        <!-- Breakdown Tables -->
        <div class="row g-4">
            <div class="col-lg-6">
                <div class="panel">
                    <h2 class="fs-6 fw-bold mb-3">Peak Hiring Periods Breakdown</h2>
                    <table class="table table-sm align-middle mb-0">
                        <thead class="table-light">
                            <tr><th>Month</th><th>Jobs Posted</th><th>Total Vacancies</th></tr>
                        </thead>
                        <tbody>
                        <%
                            StringBuilder mLabels = new StringBuilder();
                            StringBuilder mValues = new StringBuilder();
                            if (peakHiring.isEmpty()) {
                        %>
                            <tr><td colspan="3" class="text-center text-muted py-3">No hiring data available.</td></tr>
                        <%  } else {
                                for (int i = 0; i < peakHiring.size(); i++) {
                                    String[] r = peakHiring.get(i);
                                    if (i > 0) { mLabels.append(","); mValues.append(","); }
                                    mLabels.append("'").append(r[0]).append("'");
                                    mValues.append(r[2]);
                        %>
                            <tr>
                                <td><%= r[0] %></td>
                                <td><%= r[1] %></td>
                                <td class="fw-semibold"><%= r[2] %></td>
                            </tr>
                        <%      }
                            } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="col-lg-6">
                <div class="panel">
                    <h2 class="fs-6 fw-bold mb-3">Most Demanded Skills Breakdown</h2>
                    <table class="table table-sm align-middle mb-0">
                        <thead class="table-light">
                            <tr><th>Skill Name</th><th>Job Listings Count</th></tr>
                        </thead>
                        <tbody>
                        <%
                            StringBuilder sLabels = new StringBuilder();
                            StringBuilder sValues = new StringBuilder();
                            if (demandedSkills.isEmpty()) {
                        %>
                            <tr><td colspan="2" class="text-center text-muted py-3">No skill data available.</td></tr>
                        <%  } else {
                                for (int i = 0; i < demandedSkills.size(); i++) {
                                    String[] r = demandedSkills.get(i);
                                    if (i > 0) { sLabels.append(","); sValues.append(","); }
                                    sLabels.append("'").append(r[0]).append("'");
                                    sValues.append(r[1]);
                        %>
                            <tr>
                                <td><%= r[0] %></td>
                                <td class="fw-semibold"><%= r[1] %></td>
                            </tr>
                        <%      }
                            } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script>
        new Chart(document.getElementById('hiringChart'), {
            type: 'bar',
            data: {
                labels: [<%= mLabels.toString() %>],
                datasets: [{
                    label: 'Job Vacancies',
                    data: [<%= mValues.toString() %>],
                    backgroundColor: '#0d6efd',
                    borderRadius: 6
                }]
            }
        });

        new Chart(document.getElementById('skillsChart'), {
            type: 'bar',
            data: {
                labels: [<%= sLabels.toString() %>],
                datasets: [{
                    label: 'Jobs Requiring Skill',
                    data: [<%= sValues.toString() %>],
                    backgroundColor: '#198754',
                    borderRadius: 6
                }]
            }
        });
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
