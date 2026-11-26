<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employer Registration | Siswa-Gigs</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: #f8fafc;
            color: #0f172a;
        }
        .auth-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(15, 23, 42, 0.05);
        }
    </style>
</head>
<body class="py-5">

<div class="container">
    <div class="row justify-content-center">
        <div class="col-lg-7">
            <div class="text-center mb-4">
                <h4 class="fw-bold mb-1">Register as an Employer</h4>
                <p class="text-muted small">Create your company profile on Siswa-Gigs to hire student talents</p>
            </div>

            <div class="auth-card p-4 p-md-5">
                <form action="../EmployerRegisterServlet" method="post">
                    <input type="hidden" name="role" value="Employer">

                    <h6 class="fw-bold text-primary text-uppercase small mb-3">1. Person In Charge (Table: users)</h6>
                    <div class="row g-3 mb-4">
                        <div class="col-md-6">
                            <label class="form-label small fw-semibold">Full Name</label>
                            <input type="text" name="full_name" class="form-control rounded-3" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-semibold">Phone Number</label>
                            <input type="text" name="phone_number" class="form-control rounded-3" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-semibold">Work Email</label>
                            <input type="email" name="email" class="form-control rounded-3" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-semibold">Password</label>
                            <input type="password" name="password" class="form-control rounded-3" required>
                        </div>
                    </div>

                    <h6 class="fw-bold text-primary text-uppercase small mb-3 pt-3 border-top">2. Company Profile (Table: employers)</h6>
                    <div class="row g-3 mb-4">
                        <div class="col-md-6">
                            <label class="form-label small fw-semibold">Company Name</label>
                            <input type="text" name="company_name" class="form-control rounded-3" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-semibold">Business Registration No (SSM)</label>
                            <input type="text" name="business_registration_no" class="form-control rounded-3" required>
                        </div>
                        <div class="col-12">
                            <label class="form-label small fw-semibold">Business Sector</label>
                            <select name="business_sector" class="form-select rounded-3" required>
                                <option value="">-- Select Sector --</option>
                                <option value="Food & Beverage">Food & Beverage</option>
                                <option value="Retail & Sales">Retail & Sales</option>
                                <option value="IT & Digital">IT & Digital</option>
                                <option value="Event Management">Event Management</option>
                                <option value="Logistics & Operations">Logistics & Operations</option>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label small fw-semibold">Company Address</label>
                            <textarea name="company_address" class="form-control rounded-3" rows="2" required></textarea>
                        </div>
                        <div class="col-12">
                            <label class="form-label small fw-semibold">Company Description</label>
                            <textarea name="company_description" class="form-control rounded-3" rows="3"></textarea>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary w-100 py-2 rounded-3 fw-semibold">
                        Create Employer Account
                    </button>
                </form>

                <div class="text-center mt-4 pt-3 border-top">
                    <span class="text-muted small">Already registered?</span>
                    <a href="login.jsp" class="small fw-semibold text-decoration-none ms-1">Sign In Here</a>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>