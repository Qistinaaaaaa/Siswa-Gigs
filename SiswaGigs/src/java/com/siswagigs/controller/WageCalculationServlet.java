package com.siswagigs.controller;

import com.siswagigs.dao.DBConnection;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URLEncoder;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/student/WageCalculationServlet")
public class WageCalculationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp?error=unauthorized");
            return;
        }

        List<String[]> approvedRecords = new ArrayList<String[]>();
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT wr.record_id, u.full_name, j.job_title, wr.work_date, wr.hours_worked, wr.hourly_rate " +
                         "FROM work_records wr " +
                         "JOIN applications a ON wr.application_id = a.application_id " +
                         "JOIN students s ON a.student_id = s.student_id " +
                         "JOIN users u ON s.user_id = u.user_id " +
                         "JOIN jobs j ON a.job_id = j.job_id " +
                         "LEFT JOIN payments p ON p.record_id = wr.record_id " +
                         "WHERE wr.work_status = 'Approved' AND p.payment_id IS NULL " +
                         "ORDER BY wr.work_date DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    approvedRecords.add(new String[]{
                        rs.getString("record_id"),
                        rs.getString("full_name"),
                        rs.getString("job_title"),
                        rs.getString("work_date"),
                        rs.getString("hours_worked"),
                        rs.getString("hourly_rate")
                    });
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("approvedRecords", approvedRecords);
        request.getRequestDispatcher("wageCalculation.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp?error=unauthorized");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            int recordId = Integer.parseInt(request.getParameter("recordId"));
            BigDecimal processingFee = new BigDecimal(request.getParameter("processingFee")).setScale(2, RoundingMode.HALF_UP);

            String checkSql = "SELECT hours_worked, hourly_rate FROM work_records WHERE record_id = ? AND work_status = 'Approved'";
            BigDecimal hours = null;
            BigDecimal rate = null;

            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, recordId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        hours = rs.getBigDecimal("hours_worked");
                        rate = rs.getBigDecimal("hourly_rate");
                    }
                }
            }

            if (hours == null || rate == null) {
                response.sendRedirect("WageCalculationServlet?error=not_approved");
                return;
            }

            BigDecimal grossWage = hours.multiply(rate).setScale(2, RoundingMode.HALF_UP);
            BigDecimal netPayable = grossWage.subtract(processingFee).max(BigDecimal.ZERO).setScale(2, RoundingMode.HALF_UP);

            String insertSql = "INSERT INTO payments (record_id, gross_wage, processing_fee, net_payable, payment_status, payment_date) " +
                               "VALUES (?, ?, ?, ?, 'Unpaid', NULL)";
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, recordId);
                ps.setBigDecimal(2, grossWage);
                ps.setBigDecimal(3, processingFee);
                ps.setBigDecimal(4, netPayable);
                ps.executeUpdate();
            }

            response.sendRedirect("payment.jsp?status=created");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("WageCalculationServlet?error=" + URLEncoder.encode(String.valueOf(e.getMessage()), "UTF-8"));
        }
    }
}