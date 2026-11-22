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

public class EmployerWorkRecordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("employer/login.jsp?error=unauthorized");
            return;
        }

        int recordId = Integer.parseInt(request.getParameter("record_id"));
        String workStatus = request.getParameter("work_status"); // 'Approved'

        String dbURL = "jdbc:mysql://localhost:3306/siswa_gigs?useSSL=false&serverTimezone=UTC";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbURL, "root", "");

            String sql = "UPDATE work_records SET work_status = ? WHERE record_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, workStatus);
            ps.setInt(2, recordId);
            ps.executeUpdate();

            response.sendRedirect("employer/workApproval.jsp?status=approved");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("employer/workApproval.jsp?error=failed");
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception ignore) {}
            try { if (conn != null) conn.close(); } catch (Exception ignore) {}
        }
    }
}