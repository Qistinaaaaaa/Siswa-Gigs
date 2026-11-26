package com.siswagigs.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.time.LocalDate;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class EmployerJobServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("employer/login.jsp?error=unauthorized");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String action = request.getParameter("action");
        String dbURL = "jdbc:mysql://localhost:3307/siswa_gigs?useSSL=false&serverTimezone=UTC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbURL, "root", "");

            if ("create".equalsIgnoreCase(action)) {
                // Dapatkan employer_id daripada user_id yang sedang log masuk
                int employerId = 0;
                ps = conn.prepareStatement("SELECT employer_id FROM employers WHERE user_id = ?");
                ps.setInt(1, userId);
                rs = ps.executeQuery();
                if (rs.next()) {
                    employerId = rs.getInt("employer_id");
                }
                rs.close();
                ps.close();

                String jobTitle = request.getParameter("job_title");
                String description = request.getParameter("description");
                String location = request.getParameter("location");
                double hourlyRate = Double.parseDouble(request.getParameter("hourly_rate"));
                int vacancies = Integer.parseInt(request.getParameter("vacancies"));
                String expiryDateStr = request.getParameter("expiry_date");
                Date postedDate = Date.valueOf(LocalDate.now());
                Date expiryDate = (expiryDateStr != null && !expiryDateStr.isEmpty()) ? Date.valueOf(expiryDateStr) : null;

                // Masukkan rekod kerja ke jadual jobs (status default: 'Available')
                String sqlJob = "INSERT INTO jobs (employer_id, job_title, description, location, hourly_rate, vacancies, job_status, posted_date, expiry_date) " +
                                "VALUES (?, ?, ?, ?, ?, ?, 'Available', ?, ?)";
                ps = conn.prepareStatement(sqlJob, Statement.RETURN_GENERATED_KEYS);
                ps.setInt(1, employerId);
                ps.setString(2, jobTitle);
                ps.setString(3, description);
                ps.setString(4, location);
                ps.setDouble(5, hourlyRate);
                ps.setInt(6, vacancies);
                ps.setDate(7, postedDate);
                ps.setDate(8, expiryDate);
                ps.executeUpdate();

                rs = ps.getGeneratedKeys();
                int generatedJobId = 0;
                if (rs.next()) {
                    generatedJobId = rs.getInt(1);
                }
                rs.close();
                ps.close();

                // Masukkan kemahiran yang ditanda ke jadual junction job_skills
                String[] skillIds = request.getParameterValues("skill_id");
                if (skillIds != null && generatedJobId > 0) {
                    String sqlSkill = "INSERT INTO job_skills (job_id, skill_id) VALUES (?, ?)";
                    ps = conn.prepareStatement(sqlSkill);
                    for (String skId : skillIds) {
                        ps.setInt(1, generatedJobId);
                        ps.setInt(2, Integer.parseInt(skId));
                        ps.addBatch();
                    }
                    ps.executeBatch();
                    ps.close();
                }

                response.sendRedirect("employer/dashboard.jsp?status=job_created");

            } else if ("close".equalsIgnoreCase(action)) {
                int jobId = Integer.parseInt(request.getParameter("job_id"));
                ps = conn.prepareStatement("UPDATE jobs SET job_status = 'Closed' WHERE job_id = ?");
                ps.setInt(1, jobId);
                ps.executeUpdate();
                ps.close();

                response.sendRedirect("employer/dashboard.jsp?status=job_closed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("employer/dashboard.jsp?error=failed");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignore) {}
            try { if (ps != null) ps.close(); } catch (Exception ignore) {}
            try { if (conn != null) conn.close(); } catch (Exception ignore) {}
        }
    }
}