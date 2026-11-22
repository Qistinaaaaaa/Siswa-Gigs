<%-- 
    Document   : jobList
    Created on : Nov 21, 2026, 6:28:44 PM
    Author     : HP
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    // Student session security check
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userId") == null || !"Student".equals(userSession.getAttribute("role"))) {
        response.sendRedirect("../login.jsp?error=unauthorized");
        return;
    }
    
    String fullName = (String) userSession.getAttribute("fullName");
    String matricNumber = (String) userSession.getAttribute("matricNumber");

    List jobList = (List) request.getAttribute("jobList");
    
    if (jobList == null) {
        response.sendRedirect("JobServlet");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Explore Gigs | Siswa-Gigs</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; background-color: #f8fafc; color: #0f172a; }
        .sidebar { min-height: 100vh; background: #0f172a; color: white; position: fixed; top: 0; left: 0; width: 260px; z-index: 1000; }
        .main-content { margin-left: 260px; }
        @media (max-width: 767.98px) {
            .sidebar { position: static; min-height: auto; }
            .main-content { margin-left: 0; }
        }
        .top-navbar { background: #ffffff; border-bottom: 1px solid #e2e8f0; height: 70px; }
        .gig-card { background: #ffffff; border: 1px solid #e2e8f0; border-radius: 16px; transition: all 0.25s ease; }
        .gig-card:hover { transform: translateY(-3px); box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.06); border-color: #cbd5e1; }
    </style>
</head>
<body>

    <div class="container-fluid p-0">
        <div class="row g-0">
            <%@ include file="sidebar.jsp" %>

            <div class="col main-content">
                <div class="top-navbar px-4 px-md-5 d-flex justify-content-between align-items-center">
                    <div>
                        <span class="text-muted small fw-semibold text-uppercase tracking-wider">Student Portal</span>
                        <h5 class="fw-bold text-dark mb-0">Explore Campus Gigs</h5>
                    </div>
                    <div class="dropdown">
                        <button class="btn btn-light border btn-sm rounded-pill px-3 py-2 dropdown-toggle fw-semibold d-inline-flex align-items-center gap-2 shadow-sm" type="button" data-bs-toggle="dropdown">
                            <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 24px; height: 24px; font-size: 0.75rem;">
                                <%= (fullName != null && !fullName.isEmpty()) ? fullName.substring(0, 1).toUpperCase() : "S" %>
                            </div>
                            <span><%= fullName != null ? fullName : "Student" %></span>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0 py-2">
                            <li><h6 class="dropdown-header text-muted small"><%= matricNumber != null ? matricNumber : "-" %></h6></li>
                            <li><a class="dropdown-item small" href="profile.jsp"><i class="bi bi-person me-2"></i>Profile</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item small text-danger fw-semibold" href="../LogoutServlet"><i class="bi bi-box-arrow-right me-2"></i>Log Out</a></li>
                        </ul>
                    </div>
                </div>

                <div class="p-4 p-md-5">
                    <div class="row g-3 mb-4 align-items-center">
                        <div class="col-md-8">
                            <div class="input-group">
                                <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                                <input type="text" id="searchInput" class="form-control border-start-0 ps-0 shadow-none" placeholder="Search gigs by title, sector, company, or skills...">
                            </div>
                        </div>
                        <div class="col-md-4 text-md-end">
                            <span class="text-muted small fw-semibold">Showing available opportunities</span>
                        </div>
                    </div>

                    <div class="row g-4" id="gigsContainer">
                        <%
                            if (jobList == null || jobList.isEmpty()) {
                        %>
                                <div class="col-12 text-center py-5">
                                    <div class="p-5 border rounded-4 bg-white shadow-sm">
                                        <i class="bi bi-folder2-open display-4 text-muted mb-3 d-block"></i>
                                        <h5 class="fw-bold text-dark">No Open Gigs Available</h5>
                                        <p class="text-muted small mb-0">There are currently no active campus job listings in the database.</p>
                                    </div>
                                </div>
                        <%
                            } else {
                                for (Object obj : jobList) {
                                    Map job = (Map) obj;
                        %>
                                    <div class="col-md-6 col-lg-4 gig-item">
                                        <div class="gig-card p-4 h-100 d-flex flex-column justify-content-between">
                                            <div>
                                                <div class="d-flex justify-content-between align-items-start mb-3">
                                                    <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-1 rounded-pill fw-semibold small">
                                                        <i class="bi bi-geo-alt me-1"></i> <%= job.get("location") %>
                                                    </span>
                                                    <span class="text-success fw-bold">RM <%= String.format("%.2f", job.get("hourlyRate")) %> / hr</span>
                                                </div>
                                                <h5 class="fw-bold text-dark mb-2"><%= job.get("jobTitle") %></h5>
                                                <p class="text-muted small mb-3"><%= job.get("description") %></p>
                                                
                                                <!-- Required Skills Badges -->
                                                <div class="mb-3">
                                                    <span class="text-muted small fw-semibold d-block mb-1"><i class="bi bi-tools me-1"></i> Required Skills:</span>
                                                    <div>
                                                        <%
                                                            String skillsStr = (String) job.get("requiredSkills");
                                                            if (skillsStr != null && !skillsStr.isEmpty()) {
                                                                String[] skills = skillsStr.split(", ");
                                                                for (String skill : skills) {
                                                        %>
                                                                    <span class="badge bg-light text-secondary border me-1 mb-1 px-2 py-1"><%= skill %></span>
                                                        <%
                                                                }
                                                            }
                                                        %>
                                                    </div>
                                                </div>
                                            </div>
                                            
                                            <div>
                                                <!-- Company, Sector, and Vacancies -->
                                                <div class="d-flex align-items-center gap-2 text-muted small mb-3 flex-wrap border-top pt-3">
                                                    <span><i class="bi bi-building me-1"></i> <%= job.get("companyName") %></span>
                                                    <span>•</span>
                                                    <span><i class="bi bi-briefcase me-1"></i> <%= job.get("sector") %></span>
                                                    <span>•</span>
                                                    <span><i class="bi bi-people me-1"></i> <%= job.get("vacancies") %> slots</span>
                                                </div>

                                                <div class="d-flex justify-content-end align-items-center">
                                                    <a href="jobDetails.jsp?id=<%= job.get("jobId") %>" class="btn btn-outline-primary btn-sm rounded-pill px-3 fw-semibold w-100">View Details & Apply</a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                        <%
                                }
                            }
                        %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.getElementById('searchInput').addEventListener('keyup', function() {
            let filter = this.value.toLowerCase();
            let cards = document.querySelectorAll('.gig-item');
            
            cards.forEach(card => {
                let text = card.textContent.toLowerCase();
                if (text.includes(filter)) {
                    card.style.display = "";
                } else {
                    card.style.display = "none";
                }
            });
        });
    </script>
</body>
</html>