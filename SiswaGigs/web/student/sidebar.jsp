<%-- 
    Document   : sidebar
    Created on : Nov 21, 2026, 2:33:38 PM
    Author     : HP
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String currentUri = request.getRequestURI();
    String currentServlet = request.getServletPath();

    boolean isExploreGigs =
            currentServlet.contains("JobServlet") ||
            currentUri.contains("JobServlet") ||
            currentUri.contains("jobList.jsp") ||
            currentUri.contains("jobDetails.jsp");

    boolean isWorkRecords =
            currentServlet.contains("WorkRecordServlet") ||
            currentUri.contains("WorkRecordServlet") ||
            currentUri.contains("workRecord.jsp");

    boolean isWageCalculation =
            currentServlet.contains("WageCalculationServlet") ||
            currentUri.contains("WageCalculationServlet") ||
            currentUri.contains("wageCalculation.jsp");

    boolean isPayments =
            currentServlet.contains("PaymentServlet") ||
            currentUri.contains("PaymentServlet") ||
            currentUri.contains("payment.jsp");

    boolean isReports =
            currentServlet.contains("ReportServlet") ||
            currentUri.contains("ReportServlet") ||
            currentUri.contains("reportDashboard.jsp");
%>

<div class="sidebar p-4 d-flex flex-column justify-content-between">
    <div>
        <div class="d-flex align-items-center gap-3 mb-4 pb-3 border-bottom border-secondary">
            <div class="bg-primary text-white rounded-3 d-flex align-items-center justify-content-center shadow-sm"
                 style="width: 38px; height: 38px;">
                <i class="bi bi-briefcase-fill fs-5"></i>
            </div>

            <div>
                <h5 class="fw-bold mb-0" style="letter-spacing: -0.5px;">
                    <span class="text-white">Siswa</span><span class="text-info">-Gigs</span>
                </h5>
                <span class="small" style="color: #cbd5e1; font-size: 0.75rem; font-weight: 500;">
                    Student Portal
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

            <!-- Profile -->
            <li class="nav-item">
                <a href="profile.jsp"
                   class="nav-link text-white <%= currentUri.contains("profile.jsp") ? "active bg-primary" : "link-light" %>">
                    <i class="bi bi-person-circle me-2"></i> Profile
                </a>
            </li>

            <!-- Explore Gigs -->
            <li class="nav-item">
                <a href="JobServlet"
                   class="nav-link text-white <%= isExploreGigs ? "active bg-primary" : "link-light" %>">
                    <i class="bi bi-search me-2"></i> Explore Gigs
                </a>
            </li>

            <!-- My Applications -->
            <li class="nav-item">
                <a href="application.jsp"
                   class="nav-link text-white <%= currentUri.contains("application.jsp") ? "active bg-primary" : "link-light" %>">
                    <i class="bi bi-file-earmark-text-fill me-2"></i> My Applications
                </a>
            </li>

            <!-- Work Records -->
            <li class="nav-item">
                <a href="workRecord.jsp"
                   class="nav-link text-white <%= isWorkRecords ? "active bg-primary" : "link-light" %>">
                    <i class="bi bi-clock-history me-2"></i> Work Records
                </a>
            </li>

            <!-- Wage Calculation -->
            <li class="nav-item">
                <a href="WageCalculationServlet"
                   class="nav-link text-white <%= isWageCalculation ? "active bg-primary" : "link-light" %>">
                    <i class="bi bi-calculator-fill me-2"></i> Wage Calculation
                </a>
            </li>

            <!-- Payments -->
            <li class="nav-item">
                <a href="payment.jsp"
                   class="nav-link text-white <%= isPayments ? "active bg-primary" : "link-light" %>">
                    <i class="bi bi-cash-coin me-2"></i> Payments
                </a>
            </li>

            <!-- Reports & Analytics -->
            <li class="nav-item">
                <a href="ReportServlet"
                   class="nav-link text-white <%= isReports ? "active bg-primary" : "link-light" %>">
                    <i class="bi bi-bar-chart-line-fill me-2"></i> Reports &amp; Analytics
                </a>
            </li>

        </ul>
    </div>

    <!-- Logout -->
    <div class="pt-3 border-top border-secondary">
        <a href="../LogoutServlet" class="dropdown-item text-danger fw-semibold">
            <i class="bi bi-box-arrow-right me-2"></i> Log Out
        </a>
    </div>
</div>
