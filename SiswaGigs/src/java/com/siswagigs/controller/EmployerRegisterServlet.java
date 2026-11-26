package com.siswagigs.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class EmployerRegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String role = "Employer";
        String fullName = request.getParameter("full_name");
        String email = request.getParameter("email");
        String phoneNumber = request.getParameter("phone_number");
        String password = request.getParameter("password");

        String companyName = request.getParameter("company_name");
        String ssmNo = request.getParameter("business_registration_no");
        String sector = request.getParameter("business_sector");
        String address = request.getParameter("company_address");
        String description = request.getParameter("company_description");

        String dbURL = "jdbc:mysql://localhost:3307/siswa_gigs?useSSL=false&serverTimezone=UTC";
        Connection conn = null;
        PreparedStatement psUser = null;
        PreparedStatement psEmployer = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbURL, "root", "");

            // Guna kolum password_hash mengikut database kawan anda
            String sqlUser = "INSERT INTO users (full_name, email, password_hash, role, phone_number) VALUES (?, ?, ?, ?, ?)";
            psUser = conn.prepareStatement(sqlUser, Statement.RETURN_GENERATED_KEYS);
            psUser.setString(1, fullName);
            psUser.setString(2, email);
            psUser.setString(3, password);
            psUser.setString(4, role);
            psUser.setString(5, phoneNumber);
            psUser.executeUpdate();

            rs = psUser.getGeneratedKeys();
            int generatedUserId = 0;
            if (rs.next()) {
                generatedUserId = rs.getInt(1);
            }

            String sqlEmployer = "INSERT INTO employers (user_id, company_name, business_registration_no, business_sector, company_address, company_description) VALUES (?, ?, ?, ?, ?, ?)";
            psEmployer = conn.prepareStatement(sqlEmployer);
            psEmployer.setInt(1, generatedUserId);
            psEmployer.setString(2, companyName);
            psEmployer.setString(3, ssmNo);
            psEmployer.setString(4, sector);
            psEmployer.setString(5, address);
            psEmployer.setString(6, description);
            psEmployer.executeUpdate();

            response.sendRedirect("employer/login.jsp?status=registered");

        } catch (Exception e) {
            e.printStackTrace();
            String errorMsg = java.net.URLEncoder.encode(e.getMessage(), "UTF-8");
            response.sendRedirect("employer/register.jsp?error=" + errorMsg);
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignore) {}
            try { if (psUser != null) psUser.close(); } catch (Exception ignore) {}
            try { if (psEmployer != null) psEmployer.close(); } catch (Exception ignore) {}
            try { if (conn != null) conn.close(); } catch (Exception ignore) {}
        }
    }
}