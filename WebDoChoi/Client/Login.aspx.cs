using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using WebDoChoi.Business;
using WebDoChoi.Security;
namespace WebDoChoi.Client
{
    /// <summary>
    /// Trang đăng nhập và đăng ký người dùng
    /// Kết nối với MySQL database và sử dụng mã hóa SHA-256
    /// </summary>
    public partial class Login : System.Web.UI.Page
    {
        #region Control Declarations - Khai báo controls
        
        // Header controls
        protected HyperLink lnkHome;
        
        // UpdatePanels
        protected UpdatePanel upLogin;
        protected UpdatePanel upRegister;
        
        // Login form controls
        protected Panel pnlLoginError;
        protected Label lblLoginError;
        protected TextBox txtLoginEmail;
        protected RequiredFieldValidator rfvLoginEmail;
        protected TextBox txtLoginPassword;
        protected RequiredFieldValidator rfvLoginPassword;
        protected CheckBox chkRememberMe;
        protected HyperLink lnkForgotPassword;
        protected Button btnLogin;
        protected Button btnGoogleLogin;
        protected Button btnFacebookLogin;
        
        // Register form controls
        protected Panel pnlRegisterError;
        protected Label lblRegisterError;
        protected TextBox txtFirstName;
        protected RequiredFieldValidator rfvFirstName;
        protected TextBox txtLastName;
        protected RequiredFieldValidator rfvLastName;
        protected TextBox txtRegisterEmail;
        protected RequiredFieldValidator rfvRegisterEmail;
        protected RegularExpressionValidator revEmail;
        protected TextBox txtPhone;
        protected RequiredFieldValidator rfvPhone;
        protected TextBox txtRegisterPassword;
        protected RequiredFieldValidator rfvRegisterPassword;
        protected TextBox txtConfirmPassword;
        protected RequiredFieldValidator rfvConfirmPassword;
        protected CompareValidator cvPassword;
        protected CheckBox chkAgreeTerms;
        protected CustomValidator cvAgreeTerms;
        protected CheckBox chkNewsletter;
        protected Button btnRegister;
        protected Button btnGoogleRegister;
        protected Button btnFacebookRegister;

        #endregion

        #region Page Events

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                try
                {
                    // Debug
                    System.Diagnostics.Debug.WriteLine("Login Page Loading...");

                    // Kiểm tra người dùng đã đăng nhập chưa
                    if (User.Identity.IsAuthenticated)
                    {
                        System.Diagnostics.Debug.WriteLine("User already authenticated, redirecting...");
                        RedirectToReturnUrl();
                        return;
                    }

                    // Lưu return URL nếu có
                    string returnUrl = Request.QueryString["ReturnUrl"];
                    if (!string.IsNullOrEmpty(returnUrl))
                    {
                        Session["ReturnUrl"] = returnUrl;
                        System.Diagnostics.Debug.WriteLine($"Return URL saved: {returnUrl}");
                    }

                    // Kiểm tra kết nối database
                    if (!UserService.TestDatabaseConnection())
                    {
                        System.Diagnostics.Debug.WriteLine("Database connection failed");
                        ShowSystemError("Không thể kết nối đến cơ sở dữ liệu. Vui lòng thử lại sau.");
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine("Database connection OK");
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Page_Load Error: {ex.Message}");
                    ShowSystemError("Có lỗi xảy ra khi tải trang. Vui lòng thử lại.");
                }
            }
            else
            {
                System.Diagnostics.Debug.WriteLine("Login Page PostBack");
            }
        }

        #endregion

        #region Button Events - Xử lý sự kiện nút bấm

        /// <summary>
        /// Xử lý sự kiện đăng nhập - SỬA LẠI
        /// </summary>
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            try
            {
                // Clear errors trước khi validate
                pnlLoginError.Visible = false;
                pnlRegisterError.Visible = false;

                if (!Page.IsValid)
                {
                    ShowLoginError("Vui lòng kiểm tra lại thông tin đăng nhập");
                    return;
                }

                string email = txtLoginEmail.Text.Trim();
                string password = txtLoginPassword.Text;
                bool rememberMe = chkRememberMe.Checked;

                // Validation cơ bản
                if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
                {
                    ShowLoginError("Vui lòng nhập email và mật khẩu");
                    return;
                }

                // Lấy thông tin client
                string ipAddress = GetClientIpAddress();
                string userAgent = Request.UserAgent ?? "";

                // Debug logging
                System.Diagnostics.Debug.WriteLine($"Attempting login for: {email}");

                // Xác thực người dùng
                var authResult = UserService.AuthenticateUser(email, password, ipAddress, userAgent);

                System.Diagnostics.Debug.WriteLine($"Login result: {authResult.IsSuccess}, Message: {authResult.Message}");

                if (authResult.IsSuccess && authResult.User != null)
                {
                    // Tạo authentication ticket
                    CreateAuthenticationTicket(authResult.User, rememberMe, authResult.SessionToken);

                    // Lưu thông tin vào session
                    StoreUserSession(authResult.User);

                    // Sử dụng ScriptManager để hiển thị thành công
                    string successMessage = $"Chào mừng {authResult.User.FullName} đến với ToyLand!";
                    string script = $@"
                setTimeout(function() {{
                    try {{
                        handleAuthSuccess('{successMessage.Replace("'", "\\'")}');
                    }} catch(e) {{
                        console.log('Script error:', e);
                        alert('✅ {successMessage.Replace("'", "\\'")}');
                        window.location.href = '{GetReturnUrl()}';
                    }}
                }}, 200);";

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "loginSuccess", script, true);
                }
                else
                {
                    ShowLoginError(authResult.Message ?? "Email hoặc mật khẩu không đúng");
                }
            }
            catch (Exception ex)
            {
                // Log lỗi chi tiết
                System.Diagnostics.Debug.WriteLine($"Login Error: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"StackTrace: {ex.StackTrace}");

                ShowLoginError("Có lỗi xảy ra trong quá trình đăng nhập. Vui lòng thử lại sau.");
            }
        }

        /// <summary>
        /// Xử lý sự kiện đăng ký - SỬA LẠI
        /// </summary>
        protected void btnRegister_Click(object sender, EventArgs e)
        {
            try
            {
                // Clear errors trước khi validate
                pnlRegisterError.Visible = false;
                pnlLoginError.Visible = false;

                // Kiểm tra Page.IsValid
                if (!Page.IsValid)
                {
                    ShowRegisterError("Vui lòng kiểm tra lại thông tin đã nhập");
                    return;
                }

                // Kiểm tra checkbox đồng ý điều khoản
                if (!chkAgreeTerms.Checked)
                {
                    ShowRegisterError("Vui lòng đồng ý với điều khoản dịch vụ");
                    return;
                }

                // Thu thập thông tin đăng ký với validation
                string email = txtRegisterEmail.Text.Trim();
                string firstName = txtFirstName.Text.Trim();
                string lastName = txtLastName.Text.Trim();
                string phone = txtPhone.Text.Trim();
                string password = txtRegisterPassword.Text;
                string confirmPassword = txtConfirmPassword.Text;

                // Validation cơ bản
                if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(firstName) ||
                    string.IsNullOrEmpty(lastName) || string.IsNullOrEmpty(phone) ||
                    string.IsNullOrEmpty(password))
                {
                    ShowRegisterError("Vui lòng điền đầy đủ thông tin bắt buộc");
                    return;
                }

                if (password != confirmPassword)
                {
                    ShowRegisterError("Mật khẩu xác nhận không khớp");
                    return;
                }

                if (password.Length < 6)
                {
                    ShowRegisterError("Mật khẩu phải có ít nhất 6 ký tự");
                    return;
                }

                var registerInfo = new UserService.RegisterInfo
                {
                    Email = email,
                    FullName = $"{firstName} {lastName}",
                    Phone = phone,
                    Password = password,
                    Username = "", // Sẽ được tạo từ email
                    SubscribeNewsletter = chkNewsletter.Checked,
                    Gender = "Other" // Mặc định
                };

                // Lấy thông tin client
                string ipAddress = GetClientIpAddress();
                string userAgent = Request.UserAgent ?? "";

                // Debug logging
                System.Diagnostics.Debug.WriteLine($"Attempting registration for: {email}");

                // Đăng ký người dùng
                var authResult = UserService.RegisterUser(registerInfo, ipAddress, userAgent);

                System.Diagnostics.Debug.WriteLine($"Registration result: {authResult.IsSuccess}, Message: {authResult.Message}");

                if (authResult.IsSuccess && authResult.User != null)
                {
                    // Tự động đăng nhập sau khi đăng ký thành công
                    CreateAuthenticationTicket(authResult.User, false, authResult.SessionToken);
                    StoreUserSession(authResult.User);

                    // Sử dụng ScriptManager để hiển thị thành công
                    string successMessage = $"Chào mừng {authResult.User.FullName} gia nhập ToyLand!";
                    string script = $@"
                setTimeout(function() {{
                    try {{
                        handleAuthSuccess('{successMessage.Replace("'", "\\'")}');
                    }} catch(e) {{
                        console.log('Script error:', e);
                        alert('✅ {successMessage.Replace("'", "\\'")}');
                        window.location.href = '{GetReturnUrl()}';
                    }}
                }}, 200);";

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "registerSuccess", script, true);
                }
                else
                {
                    // Hiển thị lỗi từ UserService
                    string errorMessage = authResult.Message ?? "Đăng ký thất bại. Vui lòng thử lại.";
                    ShowRegisterError(errorMessage);
                }
            }
            catch (Exception ex)
            {
                // Log lỗi chi tiết
                System.Diagnostics.Debug.WriteLine($"Register Error: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"StackTrace: {ex.StackTrace}");

                // Hiển thị lỗi thân thiện cho người dùng
                ShowRegisterError("Có lỗi xảy ra trong quá trình đăng ký. Vui lòng thử lại sau.");
            }
        }


        /// <summary>
        /// Xử lý đăng nhập Google (tính năng tương lai) - SỬA LẠI
        /// </summary>
        protected void btnGoogleLogin_Click(object sender, EventArgs e)
        {
            string script = @"
    setTimeout(function() {
        handleAuthError('Tính năng đăng nhập Google sẽ được cập nhật sớm!');
    }, 100);";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "googleLogin", script, true);
        }

        /// <summary>
        /// Xử lý đăng nhập Facebook (tính năng tương lai) - SỬA LẠI
        /// </summary>
        protected void btnFacebookLogin_Click(object sender, EventArgs e)
        {
            string script = @"
    setTimeout(function() {
        handleAuthError('Tính năng đăng nhập Facebook sẽ được cập nhật sớm!');
    }, 100);";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "facebookLogin", script, true);
        }

        #endregion

        #region Validation Events - Xử lý validation

        /// <summary>
        /// Validate checkbox đồng ý điều khoản
        /// </summary>
        protected void cvAgreeTerms_ServerValidate(object source, ServerValidateEventArgs args)
        {
            args.IsValid = chkAgreeTerms.Checked;
        }

        #endregion

        #region Helper Methods - Phương thức hỗ trợ

        /// <summary>
        /// Tạo authentication ticket và cookie
        /// </summary>
        private void CreateAuthenticationTicket(UserService.User user, bool rememberMe, string sessionToken)
        {
            try
            {
                // Tạo authentication ticket
                FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(
                    1,                                              // version
                    user.Email,                                     // name
                    DateTime.Now,                                   // issue time
                    DateTime.Now.AddMinutes(rememberMe ? 10080 : 30), // expiration (7 days or 30 min)
                    rememberMe,                                     // persistent
                    $"{user.RoleName}|{user.Id}|{sessionToken}",   // user data
                    FormsAuthentication.FormsCookiePath
                );

                // Mã hóa ticket
                string encryptedTicket = FormsAuthentication.Encrypt(ticket);

                // Tạo cookie
                HttpCookie authCookie = new HttpCookie(FormsAuthentication.FormsCookieName, encryptedTicket);
                authCookie.HttpOnly = true; // Bảo mật XSS
                authCookie.Secure = Request.IsSecureConnection; // HTTPS only if available
                
                if (rememberMe)
                {
                    authCookie.Expires = DateTime.Now.AddDays(7);
                }
                
                Response.Cookies.Add(authCookie);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"CreateAuthenticationTicket Error: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Lưu thông tin người dùng vào session
        /// </summary>
        private void StoreUserSession(UserService.User user)
        {
            try
            {
                Session["UserId"] = user.Id;
                Session["UserName"] = user.FullName;
                Session["UserEmail"] = user.Email;
                Session["UserRole"] = user.RoleName;
                Session["Username"] = user.Username;
                Session["AvatarUrl"] = user.AvatarUrl;
                Session["EmailVerified"] = user.EmailVerified;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"StoreUserSession Error: {ex.Message}");
            }
        }

        /// <summary>
        /// Chuyển hướng đến trang được yêu cầu hoặc trang chủ
        /// </summary>
        private void RedirectToReturnUrl()
        {
            string returnUrl = Session["ReturnUrl"] as string;
            
            if (!string.IsNullOrEmpty(returnUrl) && 
                returnUrl.StartsWith("/") && 
                !returnUrl.Contains("Login.aspx"))
            {
                Response.Redirect(returnUrl);
            }
            else
            {
                Response.Redirect("~/Client/Default.aspx");
            }
        }

        /// <summary>
        /// Lấy địa chỉ IP của client
        /// </summary>
        private string GetClientIpAddress()
        {
            string ipAddress = string.Empty;

            // Kiểm tra các header có thể chứa IP thật
            string[] ipHeaders = { 
                "HTTP_X_FORWARDED_FOR", 
                "HTTP_X_REAL_IP", 
                "HTTP_CLIENT_IP", 
                "REMOTE_ADDR" 
            };

            foreach (string header in ipHeaders)
            {
                string value = Request.ServerVariables[header];
                if (!string.IsNullOrEmpty(value) && value != "unknown")
                {
                    // Lấy IP đầu tiên nếu có nhiều IP
                    ipAddress = value.Split(',')[0].Trim();
                    break;
                }
            }

            // Fallback to Request.UserHostAddress
            if (string.IsNullOrEmpty(ipAddress))
            {
                ipAddress = Request.UserHostAddress;
            }

            return ipAddress ?? "127.0.0.1";
        }

        /// <summary>
        /// Hiển thị lỗi đăng nhập
        /// </summary>
        private void ShowLoginError(string message)
        {
            try
            {
                lblLoginError.Text = message;
                pnlLoginError.Visible = true;
                pnlRegisterError.Visible = false;

                // Cập nhật UpdatePanel
                upLogin.Update();

                // Thêm JavaScript để focus vào form login
                string script = $@"
            setTimeout(function() {{
                try {{
                    // Switch to login form nếu đang ở register form
                    const loginTab = document.getElementById('loginTab');
                    const registerTab = document.getElementById('registerTab');
                    if (loginTab && registerTab) {{
                        loginTab.classList.add('active');
                        registerTab.classList.remove('active');
                    }}
                    
                    // Focus vào email input
                    const emailInput = document.getElementById('{txtLoginEmail.ClientID}');
                    if (emailInput) {{
                        emailInput.focus();
                    }}
                }} catch(e) {{
                    console.log('ShowLoginError script error:', e);
                }}
            }}, 100);";

                ScriptManager.RegisterStartupScript(this, this.GetType(), "showLoginError", script, true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ShowLoginError Error: {ex.Message}");
            }
        }

        /// <summary>
        /// Hiển thị lỗi đăng ký
        /// </summary>
        private void ShowRegisterError(string message)
        {
            try
            {
                lblRegisterError.Text = message;
                pnlRegisterError.Visible = true;
                pnlLoginError.Visible = false;

                // Cập nhật UpdatePanel
                upRegister.Update();

                // Thêm JavaScript để switch sang register form và focus
                string script = $@"
            setTimeout(function() {{
                try {{
                    // Switch to register form
                    const loginTab = document.getElementById('loginTab');
                    const registerTab = document.getElementById('registerTab');
                    const welcomeTitle = document.getElementById('welcomeTitle');
                    const welcomeText = document.getElementById('welcomeText');
                    const switchBtn = document.getElementById('switchBtn');
                    
                    if (loginTab && registerTab) {{
                        loginTab.classList.remove('active');
                        registerTab.classList.add('active');
                        
                        if (welcomeTitle) welcomeTitle.textContent = 'Tham gia cùng chúng tôi!';
                        if (welcomeText) welcomeText.textContent = 'Tạo tài khoản để trải nghiệm mua sắm tuyệt vời và nhận những ưu đãi hấp dẫn từ ToyLand.';
                        if (switchBtn) switchBtn.textContent = 'Đăng nhập';
                    }}
                    
                    // Update global form state
                    window.isLoginForm = false;
                    
                    // Focus vào first name input
                    const firstNameInput = document.getElementById('{txtFirstName.ClientID}');
                    if (firstNameInput) {{
                        firstNameInput.focus();
                    }}
                }} catch(e) {{
                    console.log('ShowRegisterError script error:', e);
                }}
            }}, 100);";

                ScriptManager.RegisterStartupScript(this, this.GetType(), "showRegisterError", script, true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ShowRegisterError Error: {ex.Message}");
            }
        }

        /// <summary>
        /// Hiển thị lỗi hệ thống
        /// </summary>
        private void ShowSystemError(string message)
        {
            string script = $"alert('Lỗi hệ thống: {message}');";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "systemError", script, true);
        }

        #endregion

        #region Page Lifecycle Override

        /// <summary>
        /// Override để xử lý lỗi trang
        /// </summary>
        protected override void OnError(EventArgs e)
        {
            try
            {
                Exception ex = Server.GetLastError();

                // Log lỗi chi tiết
                System.Diagnostics.Debug.WriteLine($"Page Error: {ex?.Message}");
                System.Diagnostics.Debug.WriteLine($"StackTrace: {ex?.StackTrace}");

                // Clear error để tránh hiển thị error page mặc định
                Server.ClearError();

                // Hiển thị thông báo lỗi thân thiện
                string script = @"
            setTimeout(function() {
                try {
                    handleAuthError('Có lỗi xảy ra. Vui lòng thử lại sau.');
                } catch(e) {
                    alert('⚠️ Có lỗi xảy ra. Vui lòng thử lại sau.');
                }
            }, 100);";

                ScriptManager.RegisterStartupScript(this, this.GetType(), "pageError", script, true);
            }
            catch (Exception handlerEx)
            {
                System.Diagnostics.Debug.WriteLine($"OnError Handler Error: {handlerEx.Message}");
            }

            base.OnError(e);
        }
        
        /// <summary>
        /// Lấy URL để redirect sau khi đăng nhập thành công
        /// </summary>
        /// <returns>Return URL</returns>
        protected string GetReturnUrl()
        {
            string returnUrl = Session["ReturnUrl"] as string;

            if (!string.IsNullOrEmpty(returnUrl) &&
                returnUrl.StartsWith("/") &&
                !returnUrl.Contains("Login.aspx"))
            {
                return returnUrl;
            }
            else
            {
                return ResolveUrl("~/Client/Default.aspx");
            }
        }

        #endregion
    }
}