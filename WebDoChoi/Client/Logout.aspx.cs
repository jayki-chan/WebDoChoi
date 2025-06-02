using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Security;
using WebDoChoi.Business;
using WebDoChoi.Security;

namespace WebDoChoi.Client
{
    /// <summary>
    /// Trang đăng xuất - Xóa session và cookie đăng nhập
    /// </summary>
    public partial class Logout : System.Web.UI.Page
    {
        #region Control Declarations - Khai báo controls

        protected Panel pnlLogoutSuccess;
        protected Panel pnlLogoutError;
        protected Panel pnlLoggingOut;
        protected Label lblErrorMessage;
        protected Button btnTryAgain;
        protected HyperLink lnkBackToHome;
        protected HyperLink lnkLoginAgain;

        #endregion

        #region Page Events

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                try
                {
                    // Thực hiện đăng xuất
                    PerformLogout();
                }
                catch (Exception ex)
                {
                    // Log lỗi và hiển thị thông báo
                    System.Diagnostics.Debug.WriteLine($"Logout Error: {ex.Message}");
                    ShowLogoutError("Có lỗi xảy ra trong quá trình đăng xuất. Vui lòng thử lại.");
                }
            }
        }

        #endregion

        #region Logout Methods - Phương thức đăng xuất

        /// <summary>
        /// Thực hiện đăng xuất người dùng
        /// </summary>
        private void PerformLogout()
        {
            try
            {
                // Lấy thông tin người dùng hiện tại trước khi đăng xuất
                int? currentUserId = GetCurrentUserId();
                string ipAddress = GetClientIpAddress();
                string userAgent = Request.UserAgent ?? "";

                // 1. Xóa Authentication Cookie
                ClearAuthenticationCookie();

                // 2. Xóa tất cả Sessions
                ClearAllSessions();

                // 3. Xóa tất cả Cookies của ứng dụng
                ClearApplicationCookies();

                // 4. Ghi log hoạt động đăng xuất
                if (currentUserId.HasValue)
                {
                    UserService.LogoutUser(currentUserId.Value, ipAddress, userAgent);
                    SecurityHelper.LogSecurityAction("LOGOUT_SUCCESS", currentUserId.Value, ipAddress, userAgent);
                }

                // 5. Đăng xuất khỏi Forms Authentication
                FormsAuthentication.SignOut();

                // 6. Hiển thị thông báo thành công
                ShowLogoutSuccess();

                // 7. Tự động chuyển hướng sau 3 giây (JavaScript sẽ xử lý)
                string redirectScript = @"
                    <script type='text/javascript'>
                        setTimeout(function() {
                            window.location.href = '" + ResolveUrl("~/Client/Default.aspx") + @"';
                        }, 3000);
                    </script>";

                ClientScript.RegisterStartupScript(this.GetType(), "autoRedirect", redirectScript, false);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"PerformLogout Error: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Xóa Authentication Cookie
        /// </summary>
        private void ClearAuthenticationCookie()
        {
            try
            {
                // Xóa cookie authentication chính
                HttpCookie authCookie = new HttpCookie(FormsAuthentication.FormsCookieName, "");
                authCookie.Expires = DateTime.Now.AddDays(-1);
                authCookie.Path = FormsAuthentication.FormsCookiePath;
                Response.Cookies.Add(authCookie);

                // Xóa cookie ASP.NET_SessionId
                HttpCookie sessionCookie = new HttpCookie("ASP.NET_SessionId", "");
                sessionCookie.Expires = DateTime.Now.AddDays(-1);
                Response.Cookies.Add(sessionCookie);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ClearAuthenticationCookie Error: {ex.Message}");
            }
        }

        /// <summary>
        /// Xóa tất cả Sessions
        /// </summary>
        private void ClearAllSessions()
        {
            try
            {
                // Xóa từng session cụ thể
                Session.Remove("UserId");
                Session.Remove("UserName");
                Session.Remove("UserEmail");
                Session.Remove("UserRole");
                Session.Remove("Username");
                Session.Remove("AvatarUrl");
                Session.Remove("EmailVerified");
                Session.Remove("ReturnUrl");
                Session.Remove("CartItems");
                Session.Remove("WishlistItems");

                // Abandon toàn bộ session
                Session.Abandon();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ClearAllSessions Error: {ex.Message}");
            }
        }

        /// <summary>
        /// Xóa tất cả Cookies của ứng dụng
        /// </summary>
        private void ClearApplicationCookies()
        {
            try
            {
                // Danh sách các cookie cần xóa
                string[] cookiesToClear = {
                    ".ASPXAUTH",
                    "ASP.NET_SessionId",
                    "ToyLand_UserPref",
                    "ToyLand_Cart",
                    "ToyLand_Wishlist",
                    "ToyLand_RecentView"
                };

                foreach (string cookieName in cookiesToClear)
                {
                    if (Request.Cookies[cookieName] != null)
                    {
                        HttpCookie cookie = new HttpCookie(cookieName, "");
                        cookie.Expires = DateTime.Now.AddDays(-1);
                        cookie.Path = "/";
                        Response.Cookies.Add(cookie);
                    }
                }

                // Xóa tất cả cookies trong request
                foreach (string cookieName in Request.Cookies.AllKeys)
                {
                    HttpCookie cookie = new HttpCookie(cookieName, "");
                    cookie.Expires = DateTime.Now.AddDays(-1);
                    cookie.Path = "/";
                    Response.Cookies.Add(cookie);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ClearApplicationCookies Error: {ex.Message}");
            }
        }

        #endregion

        #region Helper Methods - Phương thức hỗ trợ

        /// <summary>
        /// Lấy ID người dùng hiện tại
        /// </summary>
        /// <returns>User ID hoặc null</returns>
        private int? GetCurrentUserId()
        {
            try
            {
                if (Session["UserId"] != null)
                {
                    return Convert.ToInt32(Session["UserId"]);
                }

                // Thử lấy từ Forms Authentication ticket
                if (User.Identity.IsAuthenticated)
                {
                    var authCookie = Request.Cookies[FormsAuthentication.FormsCookieName];
                    if (authCookie != null)
                    {
                        var ticket = FormsAuthentication.Decrypt(authCookie.Value);
                        if (ticket != null && !string.IsNullOrEmpty(ticket.UserData))
                        {
                            string[] userData = ticket.UserData.Split('|');
                            if (userData.Length >= 2 && int.TryParse(userData[1], out int userId))
                            {
                                return userId;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetCurrentUserId Error: {ex.Message}");
            }

            return null;
        }

        /// <summary>
        /// Lấy địa chỉ IP của client
        /// </summary>
        /// <returns>IP address</returns>
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
                    ipAddress = value.Split(',')[0].Trim();
                    break;
                }
            }

            if (string.IsNullOrEmpty(ipAddress))
            {
                ipAddress = Request.UserHostAddress;
            }

            return ipAddress ?? "127.0.0.1";
        }

        /// <summary>
        /// Hiển thị thông báo đăng xuất thành công
        /// </summary>
        private void ShowLogoutSuccess()
        {
            pnlLoggingOut.Visible = false;
            pnlLogoutError.Visible = false;
            pnlLogoutSuccess.Visible = true;
        }

        /// <summary>
        /// Hiển thị thông báo lỗi đăng xuất
        /// </summary>
        /// <param name="errorMessage">Thông điệp lỗi</param>
        private void ShowLogoutError(string errorMessage)
        {
            pnlLoggingOut.Visible = false;
            pnlLogoutSuccess.Visible = false;
            pnlLogoutError.Visible = true;
            lblErrorMessage.Text = errorMessage;
        }

        #endregion

        #region Event Handlers - Xử lý sự kiện

        /// <summary>
        /// Xử lý sự kiện thử lại đăng xuất
        /// </summary>
        protected void btnTryAgain_Click(object sender, EventArgs e)
        {
            try
            {
                // Hiển thị trạng thái đang xử lý
                pnlLoggingOut.Visible = true;
                pnlLogoutError.Visible = false;
                pnlLogoutSuccess.Visible = false;

                // Thực hiện đăng xuất lại
                PerformLogout();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"btnTryAgain_Click Error: {ex.Message}");
                ShowLogoutError("Vẫn không thể đăng xuất. Vui lòng đóng trình duyệt và mở lại.");
            }
        }

        #endregion

        #region Page Override Methods

        /// <summary>
        /// Override để xử lý lỗi trang
        /// </summary>
        protected override void OnError(EventArgs e)
        {
            Exception ex = Server.GetLastError();

            // Log lỗi chi tiết
            System.Diagnostics.Debug.WriteLine($"Logout Page Error: {ex?.Message}");
            System.Diagnostics.Debug.WriteLine($"StackTrace: {ex?.StackTrace}");

            // Clear error để tránh hiển thị error page mặc định
            Server.ClearError();

            // Hiển thị thông báo lỗi thân thiện
            ShowLogoutError("Có lỗi xảy ra trong quá trình đăng xuất. Vui lòng đóng trình duyệt và mở lại.");

            base.OnError(e);
        }

        #endregion
    }
}