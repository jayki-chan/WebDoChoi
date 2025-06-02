using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace WebDoChoi
{
    public partial class SiteMaster : MasterPage
    {
        #region Control Declarations - Khai báo controls

        // Khai báo các controls có trong Site.Master
        // Nếu không có trong file .master thì comment lại
        // protected TextBox txtSearch;
        // protected TextBox txtEmail;
        // protected Button btnSubscribe;

        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                try
                {
                    // Khởi tạo dữ liệu cho Master Page
                    InitializeMasterPage();
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Page_Load Error: {ex.Message}");
                }
            }
        }

        private void InitializeMasterPage()
        {
            try
            {
                // Set default search placeholder - chỉ khi control tồn tại
                var searchControl = FindControl("txtSearch") as TextBox;
                if (searchControl != null)
                {
                    searchControl.Attributes.Add("placeholder", "Tìm kiếm đồ chơi...");
                }

                // Load cart count from session
                UpdateCartCount();

                // Set current page active navigation với delay để tránh conflict
                SetActiveNavigationDelayed();

                // Add mobile optimization script
                AddMobileOptimizationScript();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"InitializeMasterPage Error: {ex.Message}");
            }
        }

        /// <summary>
        /// Thêm script tối ưu mobile
        /// </summary>
        private void AddMobileOptimizationScript()
        {
            try
            {
                string mobileScript = @"
                // Mobile optimization for Site.Master
                (function() {
                    // Detect mobile
                    const isMobile = window.innerWidth <= 1023;
                    
                    if (isMobile) {
                        // Add mobile class to body
                        document.body.classList.add('mobile-layout');
                        
                        // Optimize mobile navigation
                        const desktopNav = document.querySelector('.desktop-nav');
                        if (desktopNav) {
                            desktopNav.style.display = 'none';
                        }
                        
                        // Ensure mobile nav is visible
                        const mobileNav = document.querySelector('.bottom-nav');
                        if (mobileNav) {
                            mobileNav.style.display = 'block';
                        }
                        
                        // Mobile-specific optimizations
                        document.documentElement.style.fontSize = '14px';
                    }
                    
                    // Handle cart count updates
                    window.updateMasterCartCount = function(count) {
                        const cartCounts = document.querySelectorAll('.cart-count');
                        cartCounts.forEach(el => {
                            if (el) {
                                el.textContent = count || '0';
                                el.style.display = (count && count > 0) ? 'flex' : 'none';
                            }
                        });
                    };
                    
                    console.log('Site.Master mobile optimization loaded');
                })();";

                ScriptManager.RegisterStartupScript(this, this.GetType(), "mobileOptimization", mobileScript, true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"AddMobileOptimizationScript Error: {ex.Message}");
            }
        }

        private void UpdateCartCount()
        {
            try
            {
                // Cập nhật số lượng sản phẩm trong giỏ hàng
                var cartItems = Session["CartItems"] as List<object>;
                int cartCount = cartItems?.Count ?? 0;

                // Sử dụng function global để update cart count
                string script = $@"
                setTimeout(function() {{
                    if (typeof updateMasterCartCount === 'function') {{
                        updateMasterCartCount({cartCount});
                    }} else {{
                        // Fallback method
                        const cartCounts = document.querySelectorAll('.cart-count');
                        cartCounts.forEach(el => {{
                            if (el) {{
                                el.textContent = '{cartCount}';
                                el.style.display = {cartCount} > 0 ? 'flex' : 'none';
                            }}
                        }});
                    }}
                }}, 100);";

                ScriptManager.RegisterStartupScript(this, this.GetType(), "updateCartCount", script, true);
            }
            catch (Exception ex)
            {
                // Log error nhưng không làm crash trang
                System.Diagnostics.Debug.WriteLine($"UpdateCartCount Error: {ex.Message}");
            }
        }

        /// <summary>
        /// Set active navigation với delay để tránh conflict với trang con
        /// </summary>
        private void SetActiveNavigationDelayed()
        {
            try
            {
                // Lấy tên trang hiện tại
                string currentPage = System.IO.Path.GetFileName(Request.Url.AbsolutePath);

                // Set active class cho navigation với delay và kiểm tra tránh conflict
                string script = @"
                setTimeout(function() {
                    try {
                        const currentPage = '" + currentPage + @"';
                        
                        // Kiểm tra xem trang con đã xử lý navigation chưa
                        if (document.body.classList.contains('nav-processed')) {
                            console.log('Navigation already processed by child page');
                            return;
                        }
                        
                        // Desktop navigation
                        const desktopNavItems = document.querySelectorAll('.desktop-nav a, nav.desktop-nav a');
                        desktopNavItems.forEach(item => {
                            const href = item.getAttribute('href');
                            if (href && (href.includes(currentPage) || 
                                (currentPage === 'Default.aspx' && href.includes('Default')))) {
                                item.classList.add('active', 'bg-primary');
                                item.classList.remove('text-gray-600');
                                item.style.backgroundColor = '#FF6B6B';
                                item.style.color = 'white';
                            }
                        });
                        
                        // Mobile bottom navigation
                        const mobileNavItems = document.querySelectorAll('.bottom-nav .nav-item');
                        mobileNavItems.forEach(item => {
                            const href = item.getAttribute('href');
                            if (href && (href.includes(currentPage) || 
                                (currentPage === 'Default.aspx' && href.includes('Default')))) {
                                item.classList.add('active');
                                item.classList.remove('text-gray-600');
                                item.style.color = '#FF6B6B';
                                item.style.transform = 'translateY(-2px)';
                            }
                        });
                        
                        console.log('Master navigation updated for:', currentPage);
                        
                    } catch(e) {
                        console.log('Navigation error in Master:', e);
                    }
                }, 200);"; // Delay 200ms để trang con load trước

                ScriptManager.RegisterStartupScript(this, this.GetType(), "setActiveNav", script, true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"SetActiveNavigationDelayed Error: {ex.Message}");
            }
        }

        protected void btnSubscribe_Click(object sender, EventArgs e)
        {
            try
            {
                // Tìm control txtEmail dynamically
                var emailControl = FindControl("txtEmail") as TextBox;
                if (emailControl == null)
                {
                    ShowMobileCompatibleAlert("Không tìm thấy control email!", "error");
                    return;
                }

                string email = emailControl.Text.Trim();

                if (string.IsNullOrEmpty(email))
                {
                    ShowMobileCompatibleAlert("Vui lòng nhập email!", "warning");
                    return;
                }

                if (!IsValidEmail(email))
                {
                    ShowMobileCompatibleAlert("Email không hợp lệ!", "warning");
                    return;
                }

                // Logic lưu email vào database
                SaveNewsletterSubscription(email);

                // Clear textbox
                emailControl.Text = "";

                // Hiển thị thông báo thành công
                ShowMobileCompatibleAlert("Đăng ký thành công! Cảm ơn bạn đã quan tâm đến ToyLand.", "success");
            }
            catch (Exception ex)
            {
                // Log error và hiển thị thông báo lỗi
                System.Diagnostics.Debug.WriteLine($"btnSubscribe_Click Error: {ex.Message}");
                ShowMobileCompatibleAlert("Có lỗi xảy ra. Vui lòng thử lại sau!", "error");
            }
        }

        /// <summary>
        /// Hiển thị alert tương thích mobile
        /// </summary>
        private void ShowMobileCompatibleAlert(string message, string type = "info")
        {
            string icon = type == "success" ? "✅" :
                         type == "error" ? "❌" :
                         type == "warning" ? "⚠️" : "ℹ️";

            string script = $@"
            if (typeof showNotification === 'function') {{
                showNotification('{message}', '{type}');
            }} else {{
                alert('{icon} {message}');
            }}";

            ScriptManager.RegisterStartupScript(this, this.GetType(), $"alert_{type}", script, true);
        }

        /// <summary>
        /// Xử lý sự kiện tìm kiếm (nếu có control search)
        /// </summary>
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            try
            {
                var searchControl = FindControl("txtSearch") as TextBox;
                if (searchControl != null)
                {
                    string searchTerm = searchControl.Text.Trim();
                    if (!string.IsNullOrEmpty(searchTerm))
                    {
                        // Chuyển hướng đến trang tìm kiếm
                        Response.Redirect($"~/Client/ProductList.aspx?search={Server.UrlEncode(searchTerm)}");
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"btnSearch_Click Error: {ex.Message}");
            }
        }

        #region Helper Methods

        private bool IsValidEmail(string email)
        {
            try
            {
                var addr = new System.Net.Mail.MailAddress(email);
                return addr.Address == email;
            }
            catch
            {
                return false;
            }
        }

        private void SaveNewsletterSubscription(string email)
        {
            try
            {
                // TODO: Logic lưu email vào database MySQL
                // Tạm thời lưu vào Application state
                var subscribers = Application["NewsletterSubscribers"] as List<string> ?? new List<string>();
                if (!subscribers.Contains(email))
                {
                    subscribers.Add(email);
                    Application["NewsletterSubscribers"] = subscribers;
                }

                // Log subscription
                System.Diagnostics.Debug.WriteLine($"Newsletter subscription: {email}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"SaveNewsletterSubscription Error: {ex.Message}");
                throw; // Re-throw để caller xử lý
            }
        }

        #endregion

        #region Public Methods - Phương thức public cho các trang con

        /// <summary>
        /// Method để các trang con có thể gọi để cập nhật cart count
        /// </summary>
        public void RefreshCartCount()
        {
            UpdateCartCount();
        }

        /// <summary>
        /// Method để set page title từ các trang con
        /// </summary>
        public void SetPageTitle(string title)
        {
            if (!string.IsNullOrEmpty(title))
            {
                Page.Title = title + " - ToyLand";
            }
        }

        /// <summary>
        /// Method để thêm meta tags từ các trang con
        /// </summary>
        public void AddMetaTag(string name, string content)
        {
            if (!string.IsNullOrEmpty(name) && !string.IsNullOrEmpty(content))
            {
                HtmlMeta meta = new HtmlMeta();
                meta.Name = name;
                meta.Content = content;
                Page.Header.Controls.Add(meta);
            }
        }

        /// <summary>
        /// Method để thêm custom CSS từ các trang con
        /// </summary>
        public void AddCustomCSS(string cssPath)
        {
            if (!string.IsNullOrEmpty(cssPath))
            {
                HtmlLink link = new HtmlLink();
                link.Href = ResolveUrl(cssPath);
                link.Attributes.Add("rel", "stylesheet");
                link.Attributes.Add("type", "text/css");
                Page.Header.Controls.Add(link);
            }
        }

        /// <summary>
        /// Method để thêm custom JavaScript từ các trang con
        /// </summary>
        public void AddCustomJS(string jsPath)
        {
            if (!string.IsNullOrEmpty(jsPath))
            {
                string script = $"<script src='{ResolveUrl(jsPath)}' type='text/javascript'></script>";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "customJS_" + Guid.NewGuid().ToString(), script, false);
            }
        }

        /// <summary>
        /// Method để hiển thị thông báo từ các trang con - Mobile compatible
        /// </summary>
        public void ShowMessage(string message, string type = "info")
        {
            try
            {
                string script = $@"
                setTimeout(function() {{
                    if (typeof showNotification === 'function') {{
                        showNotification('{message.Replace("'", "\\'")}', '{type}');
                    }} else {{
                        const icon = '{type}' === 'success' ? '✅' : 
                                    '{type}' === 'error' ? '❌' : 
                                    '{type}' === 'warning' ? '⚠️' : 'ℹ️';
                        alert(icon + ' {message.Replace("'", "\\'")}');
                    }}
                }}, 100);";

                ScriptManager.RegisterStartupScript(this, this.GetType(), "showMessage_" + Guid.NewGuid().ToString(), script, true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ShowMessage Error: {ex.Message}");
            }
        }

        /// <summary>
        /// Method để đánh dấu navigation đã được xử lý bởi trang con
        /// </summary>
        public void MarkNavigationProcessed()
        {
            string script = @"
            document.addEventListener('DOMContentLoaded', function() {
                document.body.classList.add('nav-processed');
            });";

            ScriptManager.RegisterStartupScript(this, this.GetType(), "markNavProcessed", script, true);
        }

        /// <summary>
        /// Method để update cart count từ trang con
        /// </summary>
        public void UpdateCartCountFromChild(int count)
        {
            try
            {
                Session["CartItems"] = new List<object>(new object[count]); // Mock data
                UpdateCartCount();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"UpdateCartCountFromChild Error: {ex.Message}");
            }
        }

        #endregion

        #region Page Lifecycle Override

        /// <summary>
        /// Override để xử lý lỗi Master Page
        /// </summary>
        protected override void OnError(EventArgs e)
        {
            Exception ex = Server.GetLastError();

            // Log lỗi
            System.Diagnostics.Debug.WriteLine($"Master Page Error: {ex?.Message}");
            System.Diagnostics.Debug.WriteLine($"StackTrace: {ex?.StackTrace}");

            // Clear error để tránh hiển thị error page mặc định
            Server.ClearError();

            // Hiển thị thông báo lỗi thân thiện
            try
            {
                ShowMobileCompatibleAlert("Có lỗi xảy ra trong hệ thống. Vui lòng thử lại sau.", "error");
            }
            catch
            {
                // Fallback nếu không thể hiển thị thông báo
            }

            base.OnError(e);
        }

        /// <summary>
        /// Override PreRender để đảm bảo mobile compatibility
        /// </summary>
        protected override void OnPreRender(EventArgs e)
        {
            try
            {
                // Thêm script cuối cùng để đảm bảo mobile layout
                string finalScript = @"
                // Final mobile compatibility check
                setTimeout(function() {
                    if (window.innerWidth <= 1023) {
                        // Ensure mobile layout is applied
                        document.body.classList.add('mobile-ready');
                        
                        // Force hide desktop elements
                        const desktopElements = document.querySelectorAll('.desktop-nav, .hidden.lg\\:block');
                        desktopElements.forEach(el => {
                            if (el) el.style.display = 'none';
                        });
                        
                        // Ensure mobile elements are visible
                        const mobileElements = document.querySelectorAll('.bottom-nav, .lg\\:hidden');
                        mobileElements.forEach(el => {
                            if (el && el.style.display === 'none') {
                                el.style.display = 'block';
                            }
                        });
                    }
                }, 300);";

                ScriptManager.RegisterStartupScript(this, this.GetType(), "finalMobileCheck", finalScript, true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"OnPreRender Error: {ex.Message}");
            }

            base.OnPreRender(e);
        }

        #endregion
    }
}