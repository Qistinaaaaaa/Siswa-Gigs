<%-- 
    Document   : workRecord
    Created on : Nov 21, 2026, 11:48:11 PM
    Author     : HP
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");
    if (userId == null || !"Student".equals(role)) {
        response.sendRedirect("../login.jsp?error=unauthorized");
        return;
    }

    String fullName = "";
    List<String[]> hiredJobs = new ArrayList<String[]>();   // {application_id, job_title, company, rate}
    List<String[]> records = new ArrayList<String[]>();     // {date, job, company, in, out, hours, amount, workStatus, payStatus}
    double totalHours = 0;
    double totalApproved = 0;

    String dbURL = "jdbc:mysql://localhost:3306/siswa_gigs?useSSL=false&serverTimezone=UTC";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(dbURL, "root", "");

        PreparedStatement ps = conn.prepareStatement("SELECT full_name FROM users WHERE user_id = ?");
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) fullName = rs.getString("full_name");
        rs.close(); ps.close();

        ps = conn.prepareStatement(
            "SELECT a.application_id, j.job_title, e.company_name, j.hourly_rate " +
            "FROM applications a " +
            "JOIN students s ON a.student_id = s.student_id " +
            "JOIN jobs j ON a.job_id = j.job_id " +
            "JOIN employers e ON j.employer_id = e.employer_id " +
            "WHERE s.user_id = ? AND a.application_status = 'Hired'");
        ps.setInt(1, userId);
        rs = ps.executeQuery();
        while (rs.next()) {
            hiredJobs.add(new String[]{
                rs.getString("application_id"), rs.getString("job_title"),
                rs.getString("company_name"), rs.getString("hourly_rate")});
        }
        rs.close(); ps.close();

        ps = conn.prepareStatement(
            "SELECT wr.work_date, j.job_title, e.company_name, wr.clock_in, wr.clock_out, " +
            "wr.hours_worked, wr.hourly_rate, wr.work_status, p.payment_status " +
            "FROM work_records wr " +
            "JOIN applications a ON wr.application_id = a.application_id " +
            "JOIN students s ON a.student_id = s.student_id " +
            "JOIN jobs j ON a.job_id = j.job_id " +
            "JOIN employers e ON j.employer_id = e.employer_id " +
            "LEFT JOIN payments p ON p.record_id = wr.record_id " +
            "WHERE s.user_id = ? ORDER BY wr.work_date DESC, wr.record_id DESC");
        ps.setInt(1, userId);
        rs = ps.executeQuery();
        while (rs.next()) {
            double hrs = rs.getDouble("hours_worked");
            double rate = rs.getDouble("hourly_rate");
            String wStatus = rs.getString("work_status");
            totalHours += hrs;
            if ("Approved".equals(wStatus)) totalApproved += hrs * rate;

            String cin = rs.getTime("clock_in") != null ? rs.getTime("clock_in").toString().substring(0, 5) : "-";
            String cout = rs.getTime("clock_out") != null ? rs.getTime("clock_out").toString().substring(0, 5) : "-";
            String pay = rs.getString("payment_status") != null ? rs.getString("payment_status") : "";

            records.add(new String[]{
                rs.getString("work_date"), rs.getString("job_title"), rs.getString("company_name"),
                cin, cout, String.format("%.2f", hrs), String.format("%.2f", hrs * rate), wStatus, pay});
        }
        rs.close(); ps.close(); conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }

    String status = request.getParameter("status");
    String error = request.getParameter("error");
    String today = java.time.LocalDate.now().toString();
    String[] months = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Work Records | Siswa-Gigs</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --navy: #16213a;
            --ink: #0f172a;
            --muted: #64748b;
            --line: #e2e8f0;
            --blue: #0d6efd;
        }
        body { background-color: #f8fafc; font-family: 'Inter', 'Segoe UI', sans-serif; color: var(--ink); }
        .sidebar { width: 260px; height: 100vh; position: fixed; top: 0; left: 0; background-color: #0f172a; color: #fff; z-index: 100; }
        .main-content { margin-left: 260px; padding: 2.5rem; }
        @media (max-width: 991px) { .main-content { margin-left: 0; padding: 1.25rem; } }

        /* Banner */
        .hero { background: var(--navy); color: #fff; border-radius: 1.5rem; padding: 2rem 2.25rem; }
        .hero h1 { font-size: 1.75rem; font-weight: 700; margin: 0 0 .35rem; }
        .hero p { color: #b6c2d9; margin: 0; }
        .hero-stats { display: flex; gap: 2rem; flex-wrap: wrap; }
        .hero-stat { padding-left: 1.25rem; border-left: 1px solid rgba(255,255,255,.18); }
        .hero-stat:first-child { border-left: 0; padding-left: 0; }
        .hero-stat .num { font-size: 1.6rem; font-weight: 700; line-height: 1.1; }
        .hero-stat .lbl { font-size: .8rem; color: #b6c2d9; }

        /* Cards */
        .panel { background: #fff; border: 1px solid var(--line); border-radius: 1.25rem; padding: 1.5rem; }
        .panel h2 { font-size: 1.05rem; font-weight: 700; margin: 0; }

        /* Form */
        .form-label { font-weight: 600; font-size: .85rem; color: #334155; margin-bottom: .35rem; }
        .form-control, .form-select { border: 1px solid #cbd5e1; padding: .6rem .9rem; border-radius: .6rem; }
        .form-control:focus, .form-select:focus { border-color: var(--blue); box-shadow: 0 0 0 3px rgba(13,110,253,.15); }
        .estimate { background: #f1f5f9; border-radius: .75rem; padding: .85rem 1rem; display: flex; justify-content: space-between; align-items: center; }
        .estimate .amount { font-weight: 700; font-size: 1.15rem; }
        .sticky-form { position: sticky; top: 1.5rem; }

        /* Record rows */
        .rec { display: flex; align-items: center; gap: 1rem; padding: 1rem 0; border-top: 1px solid var(--line); }
        .rec:first-child { border-top: 0; }
        .date-block { width: 54px; flex: none; text-align: center; background: #eff6ff; color: #1d4ed8; border-radius: .75rem; padding: .4rem 0; }
        .date-block .d { font-size: 1.25rem; font-weight: 700; line-height: 1.1; }
        .date-block .m { font-size: .75rem; font-weight: 600; }
        .rec-main { flex: 1; min-width: 0; }
        .rec-title { font-weight: 600; }
        .rec-sub { font-size: .85rem; color: var(--muted); }
        .rec-money { text-align: right; flex: none; }
        .rec-money .amt { font-weight: 700; }
        .rec-money .hrs { font-size: .85rem; color: var(--muted); }
        .pill { display: inline-block; font-size: .75rem; font-weight: 600; padding: .2rem .6rem; border-radius: 999px; }
        .pill-pending { background: #fef3c7; color: #92400e; }
        .pill-approved, .pill-paid { background: #dcfce7; color: #166534; }
        .pill-none { background: #f1f5f9; color: var(--muted); }
        @media (max-width: 575px) { .rec { flex-wrap: wrap; } .rec-money { width: 100%; text-align: left; } }

        .empty { text-align: center; padding: 2.5rem 1rem; color: var(--muted); }
        .empty i { font-size: 2.25rem; display: block; margin-bottom: .5rem; }
    </style>
</head>
<body>

    <jsp:include page="sidebar.jsp" />

    <div class="main-content">

        <!-- Top bar -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <div class="text-muted small fw-semibold text-uppercase">Workspace</div>
                <div class="fw-bold fs-5 text-dark">Student Portal</div>
            </div>
            <div class="dropdown">
                <button class="btn btn-light border btn-sm rounded-pill px-3 py-2 dropdown-toggle fw-semibold d-inline-flex align-items-center gap-2 shadow-sm bg-white" type="button" data-bs-toggle="dropdown">
                    <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 28px; height: 28px; font-size: 0.8rem; min-width: 28px;">
                        <%= !fullName.isEmpty() ? fullName.substring(0, 1).toUpperCase() : "S" %>
                    </div>
                    <span><%= fullName.isEmpty() ? "Student" : fullName %></span>
                </button>
                <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0 py-2">
                    <li><h6 class="dropdown-header text-muted small"><%= session.getAttribute("matricNumber") != null ? session.getAttribute("matricNumber") : "-" %></h6></li>
                    <li><a class="dropdown-item small" href="profile.jsp"><i class="bi bi-person me-2"></i>Profile</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item small text-danger fw-semibold" href="../LogoutServlet"><i class="bi bi-box-arrow-right me-2"></i>Log Out</a></li>
                </ul>
            </div>
        </div>

        <!-- Alerts -->
        <% if ("success".equals(status)) { %>
            <div class="alert alert-success alert-dismissible fade show rounded-4 mb-4" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i> Work record saved. Your employer will review it next.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } else if (error != null) {
               String msg;
               if ("missing_fields".equals(error)) msg = "Fill in every field before saving.";
               else if ("future_date".equals(error)) msg = "Work date can't be in the future.";
               else if ("invalid_time".equals(error)) msg = "Clock out must be later than clock in.";
               else if ("not_allowed".equals(error)) msg = "You can only log hours for gigs where you are hired.";
               else if ("duplicate".equals(error)) msg = "You already logged this gig on that date.";
               else msg = "Couldn't save the record (" + error + ").";
        %>
            <div class="alert alert-danger alert-dismissible fade show rounded-4 mb-4" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> <%= msg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <!-- Banner -->
        <div class="hero mb-4">
            <div class="row align-items-center g-4">
                <div class="col-lg-5">
                    <h1>Work records</h1>
                    <p>Log your hours after each shift and track what you've earned.</p>
                </div>
                <div class="col-lg-7">
                    <div class="hero-stats justify-content-lg-end">
                        <div class="hero-stat"><div class="num"><%= records.size() %></div><div class="lbl">Records</div></div>
                        <div class="hero-stat"><div class="num"><%= String.format("%.2f", totalHours) %></div><div class="lbl">Hours worked</div></div>
                        <div class="hero-stat"><div class="num">RM <%= String.format("%.2f", totalApproved) %></div><div class="lbl">Approved earnings</div></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">

            <!-- History -->
            <div class="col-lg-8 order-2 order-lg-1">
                <div class="panel">
                    <h2 class="mb-2">History</h2>
                    <% if (records.isEmpty()) { %>
                        <div class="empty">
                            <i class="bi bi-clock-history"></i>
                            <div class="fw-semibold text-dark">No work records yet</div>
                            <div class="small">Once you're hired, log your first shift here.</div>
                        </div>
                    <% } else { %>
                        <% for (String[] r : records) {
                               String day = r[0].substring(8, 10);
                               String mon = months[Integer.parseInt(r[0].substring(5, 7)) - 1];
                               String wCls = "Approved".equals(r[7]) ? "pill-approved" : "pill-pending";
                               String pLabel = r[8].isEmpty() ? "Not paid yet" : r[8];
                               String pCls = "Paid".equals(r[8]) ? "pill-paid" : (r[8].isEmpty() ? "pill-none" : "pill-pending");
                        %>
                        <div class="rec">
                            <div class="date-block"><div class="d"><%= day %></div><div class="m"><%= mon %></div></div>
                            <div class="rec-main">
                                <div class="rec-title"><%= r[1] %></div>
                                <div class="rec-sub"><%= r[2] %> &bull; <%= r[3] %> to <%= r[4] %></div>
                                <div class="mt-1">
                                    <span class="pill <%= wCls %>"><%= r[7] %></span>
                                    <span class="pill <%= pCls %>"><%= pLabel %></span>
                                </div>
                            </div>
                            <div class="rec-money">
                                <div class="amt">RM <%= r[6] %></div>
                                <div class="hrs"><%= r[5] %> hrs</div>
                            </div>
                        </div>
                        <% } %>
                    <% } %>
                </div>
            </div>

            <!-- Log form -->
            <div class="col-lg-4 order-1 order-lg-2">
                <div class="panel sticky-form">
                    <h2 class="mb-3">Log a shift</h2>
                    <% if (hiredJobs.isEmpty()) { %>
                        <div class="empty py-3">
                            <i class="bi bi-briefcase"></i>
                            <div class="fw-semibold text-dark">No hired gigs yet</div>
                            <div class="small mb-3">You can log hours once an employer hires you.</div>
                            <a href="exploreGigs.jsp" class="btn btn-primary rounded-pill px-4 fw-semibold">Explore gigs</a>
                        </div>
                    <% } else { %>
                        <form action="WorkRecordServlet" method="POST" onsubmit="return validateTimes()">
                            <div class="mb-3">
                                <label class="form-label">Gig</label>
                                <select name="applicationId" id="gig" class="form-select" required>
                                    <% for (String[] j : hiredJobs) { %>
                                        <option value="<%= j[0] %>" data-rate="<%= j[3] %>"><%= j[1] %> at <%= j[2] %></option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Date</label>
                                <input type="date" name="workDate" class="form-control" max="<%= today %>" value="<%= today %>" required>
                            </div>
                            <div class="row g-2 mb-3">
                                <div class="col-6">
                                    <label class="form-label">Clock in</label>
                                    <input type="time" name="clockIn" id="clockIn" class="form-control" required>
                                </div>
                                <div class="col-6">
                                    <label class="form-label">Clock out</label>
                                    <input type="time" name="clockOut" id="clockOut" class="form-control" required>
                                </div>
                            </div>
                            <div id="timeError" class="text-danger small mb-2 fw-semibold" style="display:none;">Clock out must be later than clock in.</div>

                            <div class="estimate mb-3">
                                <div>
                                    <div class="small text-muted">Estimated pay</div>
                                    <div class="small text-muted" id="estHours">0.00 hrs</div>
                                </div>
                                <div class="amount" id="estAmount">RM 0.00</div>
                            </div>

                            <button type="submit" class="btn btn-primary w-100 rounded-pill fw-semibold py-2">
                                <i class="bi bi-check2-circle me-1"></i> Save record
                            </button>
                        </form>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <script>
        var gig = document.getElementById("gig");
        var cin = document.getElementById("clockIn");
        var cout = document.getElementById("clockOut");

        function toMinutes(t) {
            var p = t.split(":");
            return parseInt(p[0], 10) * 60 + parseInt(p[1], 10);
        }

        function updateEstimate() {
            if (!gig || !cin.value || !cout.value) return;
            var mins = toMinutes(cout.value) - toMinutes(cin.value);
            var hrs = mins > 0 ? mins / 60 : 0;
            var rate = parseFloat(gig.options[gig.selectedIndex].getAttribute("data-rate")) || 0;
            document.getElementById("estHours").textContent = hrs.toFixed(2) + " hrs";
            document.getElementById("estAmount").textContent = "RM " + (hrs * rate).toFixed(2);
        }

        function validateTimes() {
            var err = document.getElementById("timeError");
            if (cin.value && cout.value && toMinutes(cout.value) <= toMinutes(cin.value)) {
                err.style.display = "block";
                return false;
            }
            err.style.display = "none";
            return true;
        }

        if (gig) {
            gig.addEventListener("change", updateEstimate);
            cin.addEventListener("input", updateEstimate);
            cout.addEventListener("input", updateEstimate);
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>