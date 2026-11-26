package com.siswagigs.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class EmployerApplicationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("employer/login.jsp?error=unauthorized");
            return;
        }

        int applicationId = Integer.parseInt(request.getParameter("application_id"));
        String newStatus = request.getParameter("application_status"); // 'Hired' atau 'Rejected'

        String dbURL = "jdbc:mysql://localhost:3307/siswa_gigs?useSSL=false&serverTimezone=UTC";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbURL, "root", "");

            String sql = "UPDATE applications SET application_status = ? WHERE application_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, newStatus);
            ps.setInt(2, applicationId);
            ps.executeUpdate();

            response.sendRedirect("employer/applicationManage.jsp?status=updated");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("employer/applicationManage.jsp?error=failed");
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception ignore) {}
            try { if (conn != null) conn.close(); } catch (Exception ignore) {}
        }
    }
}