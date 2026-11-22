package com.siswagigs.controller;

import com.siswagigs.dao.DBConnection;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URLEncoder;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/student/PaymentServlet")
public class PaymentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp?error=unauthorized");
            return;
        }

        String action = request.getParameter("action");
        String paymentIdStr = request.getParameter("paymentId");

        try (Connection conn = DBConnection.getConnection()) {
            if ("pay".equals(action) && paymentIdStr != null) {
                String sql = "UPDATE payments SET payment_status = 'Paid', payment_date = CURDATE() WHERE payment_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, Integer.parseInt(paymentIdStr));
                    ps.executeUpdate();
                }
                response.sendRedirect("payment.jsp?status=paid");
                return;

            } else if ("delete".equals(action) && paymentIdStr != null) {
                String sql = "DELETE FROM payments WHERE payment_id = ? AND payment_status = 'Unpaid'";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, Integer.parseInt(paymentIdStr));
                    ps.executeUpdate();
                }
                response.sendRedirect("payment.jsp?status=deleted");
                return;
            }
            response.sendRedirect("payment.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("payment.jsp?error=" + URLEncoder.encode(String.valueOf(e.getMessage()), "UTF-8"));
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp?error=unauthorized");
            return;
        }

        String recordIdStr = request.getParameter("recordId");
        String feeStr = request.getParameter("processingFee");

        if (recordIdStr == null || recordIdStr.isEmpty() || feeStr == null || feeStr.isEmpty()) {
            response.sendRedirect("wageCalculation.jsp?error=missing_fields");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            int recordId = Integer.parseInt(recordIdStr);
            BigDecimal processingFee = new BigDecimal(feeStr).setScale(2, RoundingMode.HALF_UP);

            // 
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
                response.sendRedirect("wageCalculation.jsp?error=not_approved");
                return;
            }

            
            String dupSql = "SELECT 1 FROM payments WHERE record_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(dupSql)) {
                ps.setInt(1, recordId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        response.sendRedirect("wageCalculation.jsp?error=already_exists");
                        return;
                    }
                }
            }

           
            BigDecimal grossWage = hours.multiply(rate).setScale(2, RoundingMode.HALF_UP);
            BigDecimal netPayable = grossWage.subtract(processingFee);
            if (netPayable.compareTo(BigDecimal.ZERO) < 0) {
                netPayable = BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
            }

           
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
            response.sendRedirect("wageCalculation.jsp?error=" + URLEncoder.encode(String.valueOf(e.getMessage()), "UTF-8"));
        }
    }
}