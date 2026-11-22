package com.siswagigs.controller;

import com.siswagigs.dao.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/student/ReportServlet")
public class ReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp?error=unauthorized");
            return;
        }

        double totalGross = 0;
        double totalFees = 0;
        double totalNet = 0;
        double totalPaid = 0;

        List<String[]> peakHiring = new ArrayList<String[]>();
        List<String[]> demandedSkills = new ArrayList<String[]>();

        try (Connection conn = DBConnection.getConnection()) {
            String wageSql = "SELECT COALESCE(SUM(gross_wage),0) AS g, COALESCE(SUM(processing_fee),0) AS f, " +
                             "COALESCE(SUM(net_payable),0) AS n, " +
                             "COALESCE(SUM(CASE WHEN payment_status='Paid' THEN net_payable ELSE 0 END),0) AS p " +
                             "FROM payments";
            try (PreparedStatement ps = conn.prepareStatement(wageSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalGross = rs.getDouble("g");
                    totalFees = rs.getDouble("f");
                    totalNet = rs.getDouble("n");
                    totalPaid = rs.getDouble("p");
                }
            }

            String hiringSql = "SELECT DATE_FORMAT(posted_date, '%Y-%m') AS m, COUNT(job_id) AS jc, COALESCE(SUM(vacancies),0) AS vc " +
                               "FROM jobs GROUP BY DATE_FORMAT(posted_date, '%Y-%m') ORDER BY m ASC";
            try (PreparedStatement ps = conn.prepareStatement(hiringSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    peakHiring.add(new String[]{
                        rs.getString("m"),
                        rs.getString("jc"),
                        rs.getString("vc")
                    });
                }
            }

            // 3. Most Demanded Skill Sets (Joined through job_skills & skills)
            String skillSql = "SELECT s.skill_name, COUNT(js.job_id) AS dc " +
                              "FROM skills s JOIN job_skills js ON s.skill_id = js.skill_id " +
                              "GROUP BY s.skill_id, s.skill_name ORDER BY dc DESC LIMIT 8";
            try (PreparedStatement ps = conn.prepareStatement(skillSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    demandedSkills.add(new String[]{
                        rs.getString("skill_name"),
                        rs.getString("dc")
                    });
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("totalGross", totalGross);
        request.setAttribute("totalFees", totalFees);
        request.setAttribute("totalNet", totalNet);
        request.setAttribute("totalPaid", totalPaid);
        request.setAttribute("peakHiring", peakHiring);
        request.setAttribute("demandedSkills", demandedSkills);

        request.getRequestDispatcher("reportDashboard.jsp").forward(request, response);
    }
}
