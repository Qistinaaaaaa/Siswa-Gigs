<%-- 
    Document   : profile
    Created on : Nov 21, 2026, 11:05:16 PM
    Author     : HP
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    // Check student session login
    Integer userId = (Integer) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");

    if (userId == null || !"Student".equals(role)) {
        response.sendRedirect("../login.jsp?error=unauthorized");
        return;
    }

    String fullName = "";
    String email = "";
    String phoneNumber = "";
    String matricNumber = "";
    String programme = "";
    String departmentName = "";
    String resumePath = "";

    String dbURL = "jdbc:mysql://localhost:3306/siswa_gigs?useSSL=false&serverTimezone=UTC";
    String dbUser = "root";
    String dbPass = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        // Fetch user and student details (column names match the database)
        String sql = "SELECT u.full_name, u.email, u.phone_number, s.matric_number, s.programme, s.department_name, s.resume_path " +
                     "FROM users u JOIN students s ON u.user_id = s.user_id WHERE u.user_id = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        ResultSet rs = pstmt.executeQuery();

        if (rs.next()) {
            fullName = rs.getString("full_name") != null ? rs.getString("full_name") : "";
            email = rs.getString("email") != null ? rs.getString("email") : "";
            phoneNumber = rs.getString("phone_number") != null ? rs.getString("phone_number") : "";
            matricNumber = rs.getString("matric_number") != null ? rs.getString("matric_number") : "";
            programme = rs.getString("programme") != null ? rs.getString("programme") : "";
            departmentName = rs.getString("department_name") != null ? rs.getString("department_name") : "";
            resumePath = rs.getString("resume_path") != null ? rs.getString("resume_path") : "";
        }
        rs.close();
        pstmt.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit Profile | Siswa-Gigs</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .sidebar { width: 260px; height: 100vh; position: fixed; top: 0; left: 0; background-color: #0f172a; color: #fff; z-index: 100; }
        .main-content { margin-left: 260px; padding: 2.5rem; }
        .form-control { border: 1px solid #cbd5e1; padding: 0.65rem 1rem; border-radius: 0.5rem; background-color: #fff; }
        .form-control:focus { border-color: #0d6efd; box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.15); }
        .form-label { font-weight: 600; font-size: 0.85rem; color: #334155; margin-bottom: 0.35rem; }
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
                <h2 class="fw-bold text-dark mb-0"><i class="bi bi-pencil-square text-primary me-2"></i> Edit Student Profile</h2>
            </div>

            <!-- User Dropdown Header -->
            <div class="dropdown">
                <button class="btn btn-light border btn-sm rounded-pill px-3 py-2 dropdown-toggle fw-semibold d-inline-flex align-items-center gap-2 shadow-sm bg-white" type="button" data-bs-toggle="dropdown">
                    <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 28px; height: 28px; font-size: 0.8rem; min-width: 28px;">
                        <%= !fullName.isEmpty() ? fullName.substring(0, 1).toUpperCase() : "S" %>
                    </div>
                    <span><%= fullName.isEmpty() ? "Student" : fullName %></span>
                </button>
                <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0 py-2">
                    <li><h6 class="dropdown-header text-muted small fw-bold"><%= matricNumber.isEmpty() ? "-" : matricNumber %></h6></li>
                    <li><a class="dropdown-item small active" href="profile.jsp"><i class="bi bi-person me-2"></i>Profile</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-Item small text-danger fw-semibold" href="../LogoutServlet"><i class="bi bi-box-arrow-right me-2"></i>Log Out</a></li>
                </ul>
            </div>
        </div>
        <%
            String status = request.getParameter("status");
            String error = request.getParameter("error");
            if ("success".equals(status)) {
        %>
            <div class="alert alert-success alert-dismissible fade show shadow-sm rounded-4 mb-4" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i> <strong>Success!</strong> Your profile has been successfully updated.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } else if ("password_mismatch".equals(error)) { %>
            <div class="alert alert-danger alert-dismissible fade show shadow-sm rounded-4 mb-4" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> <strong>Error:</strong> New passwords do not match. Please try again.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } else if ("invalid_file_type".equals(error)) { %>
            <div class="alert alert-danger alert-dismissible fade show shadow-sm rounded-4 mb-4" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> <strong>Error:</strong> Resume must be a PDF file.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } else if ("invalid_format".equals(error)) { %>
            <div class="alert alert-danger alert-dismissible fade show shadow-sm rounded-4 mb-4" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> <strong>Error:</strong> Invalid name or email format.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } else if (error != null) { %>
            <div class="alert alert-danger alert-dismissible fade show shadow-sm rounded-4 mb-4" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> <strong>Error:</strong> Failed to update profile (<%= error %>).
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } %>

        <!-- EDIT FORM CARD -->
        <div class="card border-0 shadow-sm rounded-4 p-4 p-md-5 bg-white mb-5">
            <form action="ProfileServlet" method="POST" enctype="multipart/form-data" onsubmit="return validateForm()">
                <div class="row g-3">
                    <!-- Full Name -->
                    <div class="col-12">
                        <label class="form-label">Full Name:</label>
                        <input type="text" name="fullName" id="fullName" class="form-control" value="<%= fullName %>" required>
                        <div id="nameError" class="text-danger small mt-1 fw-semibold" style="display:none;">Full name cannot contain numbers.</div>
                    </div>

                    <!-- Matric Number -->
                    <div class="col-12">
                        <label class="form-label">Matric Number:</label>
                        <input type="text" name="matricNumber" class="form-control" value="<%= matricNumber %>" required>
                    </div>

                    <!-- Email Address -->
                    <div class="col-12">
                        <label class="form-label">Email:</label>
                        <input type="email" name="email" id="email" class="form-control" value="<%= email %>" required>
                    </div>

                    <!-- Department Name -->
                    <div class="col-12">
                        <label class="form-label">Department / Faculty:</label>
                        <input type="text" name="departmentName" class="form-control" value="<%= departmentName %>" placeholder="Enter department...">
                    </div>

                    <!-- Programme -->
                    <div class="col-12">
                        <label class="form-label">Programme:</label>
                        <input type="text" name="programme" class="form-control" value="<%= programme %>" placeholder="Enter programme...">
                    </div>

                    <!-- Phone Number -->
                    <div class="col-12">
                        <label class="form-label">Phone Number:</label>
                        <input type="text" name="phoneNumber" class="form-control" value="<%= phoneNumber %>" placeholder="e.g. 0123456789">
                    </div>

                    <!-- New Password & Confirmation -->
                    <div class="col-md-6">
                        <label class="form-label">New Password (Optional):</label>
                        <input type="password" name="newPassword" id="newPassword" class="form-control" placeholder="Leave blank to keep current password">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Confirm New Password:</label>
                        <input type="password" name="confirmPassword" id="confirmPassword" class="form-control" placeholder="Re-enter new password">
                        <div id="passwordError" class="text-danger small mt-1 fw-semibold" style="display:none;">Passwords do not match!</div>
                    </div>

                    <!-- Resume Upload -->
                    <div class="col-12 pt-2">
                        <label class="form-label">Resume (.pdf):</label>
                        <input type="file" name="resumeFile" id="resumeFile" class="form-control" accept=".pdf">
                        <% if (!resumePath.isEmpty()) { %>
                            <div class="form-text mt-1">
                                Current Resume: <a href="../<%= resumePath %>" target="_blank" class="text-decoration-none fw-bold text-primary"><i class="bi bi-file-earmark-pdf-fill text-danger me-1"></i>View Resume</a>
                            </div>
                        <% } else { %>
                            <div class="form-text mt-1 text-muted">No resume uploaded yet.</div>
                        <% } %>
                    </div>
                </div>

                <!-- Action Buttons -->
                <div class="mt-4 pt-3 border-top d-flex align-items-center justify-content-between">
                    <a href="dashboard.jsp" class="btn btn-light border px-4 rounded-pill fw-semibold text-secondary">
                        <i class="bi bi-arrow-left me-1"></i> Back
                    </a>
                    <button type="submit" class="btn btn-primary px-5 rounded-pill fw-semibold shadow-sm">
                        <i class="bi bi-save me-1"></i> Save
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- JavaScript Validation -->
    <script>
        function validateForm() {
            var fullName = document.getElementById("fullName").value;
            var nameError = document.getElementById("nameError");
            var numberRegex = /\d/;

            if (numberRegex.test(fullName)) {
                nameError.style.display = "block";
                document.getElementById("fullName").focus();
                return false;
            }
            nameError.style.display = "none";

            var newPassword = document.getElementById("newPassword").value;
            var confirmPassword = document.getElementById("confirmPassword").value;
            var passwordError = document.getElementById("passwordError");

            if (newPassword !== "" && newPassword !== confirmPassword) {
                passwordError.style.display = "block";
                document.getElementById("confirmPassword").focus();
                return false;
            }
            passwordError.style.display = "none";

            return true;
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>