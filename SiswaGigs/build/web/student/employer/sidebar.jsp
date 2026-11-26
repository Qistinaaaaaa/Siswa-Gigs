<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String currentUri = request.getRequestURI();
    String currentServlet = request.getServletPath();

    boolean isJobPost =
            currentServlet.contains("EmployerJobServlet") ||
            currentUri.contains("jobPost.jsp");
%>

<div class="sidebar p-4 d-flex flex-column justify-content-between">
    <div>
        <div class="d-flex align-items-center gap-3 mb-4 pb-3 border-bottom border-secondary">
            <div class="bg-primary text-white rounded-3 d-flex align-items-center justify-content-center shadow-sm"
                 style="width: 38px; height: 38px;">
                <i class="bi bi-building-fill fs-5"></i>
            </div>

            <div>
                <h5 class="fw-bold mb-0" style="letter-spacing: -0.5px;">
                    <span class="text-white">Siswa</span><span class="text-info">-Gigs</span>
                </h5>
                <span class="small" style="color: #cbd5e1; font-size: 0.75rem; font-weight: 500;">
                    Employer Portal
                </span>
            </div>
        </div>

        <div class="text-uppercase fw-bold px-2 mb-2"
             style="font-size: 0.7rem; letter-spacing: 1px; color: #94a3b8;">
            Main Menu
        </div>

        <!-- Main Navigation Menu -->
        <ul class="nav nav-pills flex-column gap-2">

            <!-- Dashboard -->
            <li class="nav-item">
                <a href="dashboard.jsp"
                   class="nav-link text-white <%= currentUri.contains("dashboard.jsp") ? "active bg-primary" : "link-light" %>">
                    <i class="bi bi-grid-1x2-fill me-2"></i> Dashboard
                </a>
            </li>

            <!-- Post a Job -->
            <li class="nav-item">
                <a href="jobPost.jsp"
                   class="nav-link text-white <%= isJobPost ? "active bg-primary" : "link-light" %>">
                    <i class="bi bi-plus-circle-fill me-2"></i> Post a Job
                </a>
            </li>

            <!-- Manage Applications -->
            <li class="nav-item">
                <a href="applicationManage.jsp"
                   class="nav-link text-white <%= currentUri.contains("applicationManage.jsp") ? "active bg-primary" : "link-light" %>">
                    <i class="bi bi-people-fill me-2"></i> Applications
                </a>
            </li>

            <!-- Work Record Approval -->
            <li class="nav-item">
                <a href="workApproval.jsp"
                   class="nav-link text-white <%= currentUri.contains("workApproval.jsp") ? "active bg-primary" : "link-light" %>">
                    <i class="bi bi-check2-square me-2"></i> Work Approvals
                </a>
            </li>

        </ul>
    </div>

    <!-- Logout (Points to shared LogoutServlet) -->
    <div class="pt-3 border-top border-secondary">
        <a href="../LogoutServlet" class="dropdown-item text-danger fw-semibold">
            <i class="bi bi-box-arrow-right me-2"></i> Log Out
        </a>
    </div>
</div>