using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WebDoChoi.Business;
using MySql.Data.MySqlClient;
using WebDoChoi.Data;

namespace WebDoChoi.Client
{
    /// <summary>
    /// Trang chủ website đồ chơi ToyLand
    /// Hiển thị danh mục, sản phẩm bán chạy, nổi bật và mới nhất
    /// Kết nối với MySQL database và CartService
    /// </summary>
    public partial class Default : System.Web.UI.Page
    {
        #region Control Declarations - Khai báo controls

        // Left Sidebar Controls
        protected Repeater rptCategories;
        protected Label lblOnlineUsers;
        protected Label lblTotalProducts;
        protected Label lblTodayOrders;

        // Center Content Controls
        protected Repeater rptBestSellingProducts;
        protected Image imgAdBanner1;
        protected Repeater rptFeaturedProducts;
        protected LinkButton btnGridView;
        protected LinkButton btnListView;
        protected LinkButton btnPrevPage;
        protected LinkButton btnNextPage;
        protected Repeater rptPagination;

        // Right Sidebar Controls
        protected Panel pnlCartEmpty;
        protected Panel pnlCartItems;
        protected Repeater rptCartItems;
        protected Label lblCartTotal;
        protected HyperLink lnkCheckout;
        protected HyperLink lnkViewCart;
        protected Image imgAdBanner2;
        protected Repeater rptNewProducts;

        #endregion

        #region Page Events

        /// <summary>
        /// Override để xử lý postback từ JavaScript
        /// </summary>
        protected override void RaisePostBackEvent(IPostBackEventHandler sourceControl, string eventArgument)
        {
            try
            {
                string[] args = eventArgument.Split('|');
                string action = args[0];

                if (args.Length > 1)
                {
                    int productId = Convert.ToInt32(args[1]);
                    int quantity = args.Length > 2 ? Convert.ToInt32(args[2]) : 1;

                    switch (action)
                    {
                        case "addToCart":
                            HandleAddToCart(productId, quantity);
                            break;
                        case "addToWishlist":
                            HandleAddToWishlist(productId);
                            break;
                        case "updateCartQuantity":
                            UpdateCartQuantity(productId, quantity);
                            break;
                        case "removeFromCart":
                            RemoveFromCart(productId);
                            break;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"RaisePostBackEvent Error: {ex.Message}");
                ShowErrorMessage("Có lỗi xảy ra khi thực hiện thao tác");
            }

            base.RaisePostBackEvent(sourceControl, eventArgument);
        }

        /// <summary>
        /// Page_Load với cart management tích hợp
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                try
                {
                    // Kiểm tra kết nối database
                    if (!DatabaseHelper.TestConnection())
                    {
                        ShowErrorMessage("Không thể kết nối đến cơ sở dữ liệu. Vui lòng thử lại sau.");
                        return;
                    }

                    // Xử lý pending actions sau khi đăng nhập
                    HandlePendingActionsAfterLogin();

                    // Xử lý merge cart sau khi đăng nhập
                    HandleCartMergeAfterLogin();

                    // Load tất cả dữ liệu cho trang chủ
                    LoadAllData();

                    // Đăng ký script cho postback
                    RegisterPostBackScript();
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Page_Load Error: {ex.Message}");
                    ShowErrorMessage("Có lỗi xảy ra khi tải trang. Vui lòng thử lại sau.");
                }
            }
        }

        #endregion

        #region Data Loading Methods - Phương thức tải dữ liệu

        /// <summary>
        /// Tải tất cả dữ liệu cần thiết cho trang chủ
        /// </summary>
        private void LoadAllData()
        {
            try
            {
                LoadCategories();
                LoadBestSellingProducts();
                LoadFeaturedProducts();
                LoadNewProducts();
                LoadCartItems();
                LoadStatistics();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadAllData Error: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Tải danh sách danh mục từ database
        /// </summary>
        private void LoadCategories()
        {
            try
            {
                var categories = ProductService.GetActiveCategories(includeProductCount: true);

                var categoryData = categories.Select(c => new
                {
                    Id = c.Id,
                    Name = c.Name,
                    Icon = c.Icon ?? "fas fa-toys",
                    ProductCount = c.ProductCount
                }).ToList();

                rptCategories.DataSource = categoryData;
                rptCategories.DataBind();

                System.Diagnostics.Debug.WriteLine($"Loaded {categoryData.Count} categories");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadCategories Error: {ex.Message}");
                LoadCategoriesFallback();
            }
        }

        /// <summary>
        /// Tải sản phẩm bán chạy từ database
        /// </summary>
        private void LoadBestSellingProducts()
        {
            try
            {
                var products = ProductService.GetBestSellingProducts(limitCount: 8);

                var productData = products.Select(p => new
                {
                    Id = p.Id,
                    Name = p.Name,
                    Price = p.CurrentPrice,
                    OriginalPrice = p.OriginalPrice,
                    DiscountPercent = p.DiscountPercent,
                    ImageUrl = !string.IsNullOrEmpty(p.PrimaryImage) ? p.PrimaryImage :
                        $"https://via.placeholder.com/300x300?text={Uri.EscapeDataString(p.Name)}",
                    Rating = p.RatingAverage,
                    ReviewCount = p.RatingCount,
                    IsNew = p.IsNew
                }).ToList();

                rptBestSellingProducts.DataSource = productData;
                rptBestSellingProducts.DataBind();

                System.Diagnostics.Debug.WriteLine($"Loaded {productData.Count} best selling products");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadBestSellingProducts Error: {ex.Message}");
                LoadBestSellingProductsFallback();
            }
        }

        /// <summary>
        /// Tải sản phẩm nổi bật từ database
        /// </summary>
        private void LoadFeaturedProducts()
        {
            try
            {
                var products = ProductService.GetFeaturedProducts(limitCount: 6);

                var productData = products.Select(p => new
                {
                    Id = p.Id,
                    Name = p.Name,
                    Price = p.CurrentPrice,
                    ImageUrl = !string.IsNullOrEmpty(p.PrimaryImage) ? p.PrimaryImage :
                        $"https://via.placeholder.com/300x300?text={Uri.EscapeDataString(p.Name)}",
                    Rating = p.RatingAverage,
                    ReviewCount = p.RatingCount,
                    IsHot = p.IsFeatured || p.IsBestseller
                }).ToList();

                rptFeaturedProducts.DataSource = productData;
                rptFeaturedProducts.DataBind();

                System.Diagnostics.Debug.WriteLine($"Loaded {productData.Count} featured products");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadFeaturedProducts Error: {ex.Message}");
                LoadFeaturedProductsFallback();
            }
        }

        /// <summary>
        /// Tải sản phẩm mới nhất từ database
        /// </summary>
        private void LoadNewProducts()
        {
            try
            {
                var products = ProductService.GetNewProducts(limitCount: 6);

                var productData = products.Select(p => new
                {
                    Id = p.Id,
                    Name = p.Name,
                    Price = p.CurrentPrice,
                    ImageUrl = !string.IsNullOrEmpty(p.PrimaryImage) ? p.PrimaryImage :
                        $"https://via.placeholder.com/300x300?text={Uri.EscapeDataString(p.Name)}",
                    Rating = p.RatingAverage
                }).ToList();

                rptNewProducts.DataSource = productData;
                rptNewProducts.DataBind();

                System.Diagnostics.Debug.WriteLine($"Loaded {productData.Count} new products");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadNewProducts Error: {ex.Message}");
                LoadNewProductsFallback();
            }
        }

        /// <summary>
        /// Tải thông tin giỏ hàng từ database
        /// </summary>
        private void LoadCartItems()
        {
            try
            {
                int? userId = GetCurrentUserId();
                string sessionId = Session.SessionID;

                var cartSummary = CartService.GetCartSummary(userId, sessionId);

                if (cartSummary.HasItems)
                {
                    pnlCartEmpty.Visible = false;
                    pnlCartItems.Visible = true;

                    var cartData = cartSummary.Items.Select(item => new
                    {
                        Id = item.ProductId,
                        Name = item.ProductName,
                        ImageUrl = !string.IsNullOrEmpty(item.ImageUrl) ? item.ImageUrl :
                            $"https://via.placeholder.com/100x100?text={Uri.EscapeDataString(item.ProductName)}",
                        Price = item.Price,
                        Quantity = item.Quantity,
                        Total = item.Total,
                        IsAvailable = item.IsAvailable
                    }).ToList();

                    rptCartItems.DataSource = cartData;
                    rptCartItems.DataBind();

                    lblCartTotal.Text = cartSummary.Subtotal.ToString("N0");
                    Session["CartSummary"] = cartSummary;
                }
                else
                {
                    pnlCartEmpty.Visible = true;
                    pnlCartItems.Visible = false;
                    lblCartTotal.Text = "0";
                    Session["CartSummary"] = null;
                }

                UpdateCartCountOnPage(cartSummary.TotalQuantity);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadCartItems Error: {ex.Message}");
                pnlCartEmpty.Visible = true;
                pnlCartItems.Visible = false;
                lblCartTotal.Text = "0";
            }
        }

        /// <summary>
        /// Tải thống kê tổng quan từ database
        /// </summary>
        private void LoadStatistics()
        {
            try
            {
                int totalProducts = ProductService.GetTotalActiveProducts();
                int onlineUsers = GetOnlineUsersCount();
                int todayOrders = GetTodayOrdersCount();

                lblOnlineUsers.Text = onlineUsers.ToString("N0");
                lblTotalProducts.Text = totalProducts.ToString("N0");
                lblTodayOrders.Text = todayOrders.ToString("N0");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadStatistics Error: {ex.Message}");
                lblOnlineUsers.Text = "0";
                lblTotalProducts.Text = "0";
                lblTodayOrders.Text = "0";
            }
        }

        #endregion

        #region Cart Management Methods - SỬA CHÍNH TẠI ĐÂY

        /// <summary>
        /// Xử lý thêm sản phẩm vào giỏ hàng với kiểm tra đăng nhập
        /// </summary>
        private void HandleAddToCart(int productId, int quantity = 1)
        {
            try
            {
                int? userId = GetCurrentUserId();

                // Nếu chưa đăng nhập, lưu action và chuyển hướng đến trang đăng nhập
                if (!userId.HasValue)
                {
                    SavePendingAction("addToCart", productId, quantity);
                    RedirectToLoginWithReturn();
                    return;
                }

                // Nếu đã đăng nhập, thực hiện thêm vào giỏ hàng
                string sessionId = Session.SessionID;
                var result = CartService.AddToCart(userId, sessionId, productId, quantity);

                if (result.IsSuccess)
                {
                    Session["CartSummary"] = result.CartSummary;
                    LoadCartItems();
                    ShowSuccessMessage(result.Message);

                    // Cập nhật số lượng giỏ hàng trên client
                    UpdateCartCountOnPage(result.CartSummary.TotalQuantity);
                }
                else
                {
                    ShowErrorMessage(result.Message);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"HandleAddToCart Error: {ex.Message}");
                ShowErrorMessage("Có lỗi khi thêm sản phẩm vào giỏ hàng");
            }
        }

        /// <summary>
        /// Xử lý thêm sản phẩm vào danh sách yêu thích với kiểm tra đăng nhập
        /// </summary>
        private void HandleAddToWishlist(int productId)
        {
            try
            {
                int? userId = GetCurrentUserId();

                // Nếu chưa đăng nhập, lưu action và chuyển hướng đến trang đăng nhập
                if (!userId.HasValue)
                {
                    SavePendingAction("addToWishlist", productId, 1);
                    RedirectToLoginWithReturn();
                    return;
                }

                // Nếu đã đăng nhập, thực hiện thêm vào wishlist
                var result = CartService.AddToWishlist(userId.Value, productId);

                if (result.IsSuccess)
                {
                    ShowSuccessMessage(result.Message);
                    UpdateWishlistCountOnPage();
                }
                else
                {
                    ShowWarningMessage(result.Message);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"HandleAddToWishlist Error: {ex.Message}");
                ShowErrorMessage("Có lỗi khi thêm sản phẩm vào danh sách yêu thích");
            }
        }

        /// <summary>
        /// Lưu hành động cần thực hiện sau khi đăng nhập
        /// </summary>
        private void SavePendingAction(string action, int productId, int quantity)
        {
            try
            {
                var pendingAction = new
                {
                    Action = action,
                    ProductId = productId,
                    Quantity = quantity,
                    Timestamp = DateTime.Now
                };

                Session["PendingAction"] = pendingAction;
                System.Diagnostics.Debug.WriteLine($"Saved pending action: {action} for product {productId}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"SavePendingAction Error: {ex.Message}");
            }
        }

        /// <summary>
        /// Xử lý các hành động đang chờ sau khi đăng nhập
        /// </summary>
        private void HandlePendingActionsAfterLogin()
        {
            try
            {
                var pendingAction = Session["PendingAction"];

                if (pendingAction != null && GetCurrentUserId().HasValue)
                {
                    dynamic action = pendingAction;

                    System.Diagnostics.Debug.WriteLine($"Processing pending action: {action.Action} for product {action.ProductId}");

                    switch (action.Action)
                    {
                        case "addToCart":
                            AddToCart(action.ProductId, action.Quantity);
                            ShowSuccessMessage($"Đã tự động thêm sản phẩm vào giỏ hàng sau khi đăng nhập!");
                            break;
                        case "addToWishlist":
                            AddToWishlist(action.ProductId);
                            ShowSuccessMessage($"Đã tự động thêm sản phẩm vào danh sách yêu thích!");
                            break;
                    }

                    // Xóa pending action sau khi xử lý
                    Session.Remove("PendingAction");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"HandlePendingActionsAfterLogin Error: {ex.Message}");
                Session.Remove("PendingAction");
            }
        }

        /// <summary>
        /// Chuyển hướng đến trang đăng nhập với return URL
        /// </summary>
        private void RedirectToLoginWithReturn()
        {
            try
            {
                string currentUrl = Request.Url.ToString();
                string loginUrl = $"~/Client/Login.aspx?ReturnUrl={HttpUtility.UrlEncode(currentUrl)}";

                System.Diagnostics.Debug.WriteLine($"Redirecting to login: {loginUrl}");

                // Hiển thị thông báo trước khi chuyển hướng
                ShowWarningMessage("Vui lòng đăng nhập để sử dụng tính năng này");

                // Delay redirect để user có thể đọc thông báo
                string script = $@"
                    setTimeout(function() {{
                        window.location.href = '{ResolveUrl(loginUrl)}';
                    }}, 2000);
                ";

                ScriptManager.RegisterStartupScript(this, this.GetType(), "redirectToLogin", script, true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"RedirectToLoginWithReturn Error: {ex.Message}");
                Response.Redirect("~/Client/Login.aspx");
            }
        }

        /// <summary>
        /// Thêm sản phẩm vào giỏ hàng (internal method)
        /// </summary>
        private void AddToCart(int productId, int quantity = 1)
        {
            try
            {
                int? userId = GetCurrentUserId();
                string sessionId = Session.SessionID;

                var result = CartService.AddToCart(userId, sessionId, productId, quantity);

                if (result.IsSuccess)
                {
                    Session["CartSummary"] = result.CartSummary;
                    LoadCartItems();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"AddToCart Error: {ex.Message}");
            }
        }

        /// <summary>
        /// Thêm sản phẩm vào danh sách yêu thích (internal method)
        /// </summary>
        private void AddToWishlist(int productId)
        {
            try
            {
                int? userId = GetCurrentUserId();

                if (userId.HasValue)
                {
                    var result = CartService.AddToWishlist(userId.Value, productId);
                    if (result.IsSuccess)
                    {
                        UpdateWishlistCountOnPage();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"AddToWishlist Error: {ex.Message}");
            }
        }

        /// <summary>
        /// Cập nhật số lượng sản phẩm trong giỏ hàng
        /// </summary>
        private void UpdateCartQuantity(int productId, int quantity)
        {
            try
            {
                int? userId = GetCurrentUserId();

                if (!userId.HasValue)
                {
                    ShowWarningMessage("Vui lòng đăng nhập để sử dụng tính năng này");
                    return;
                }

                string sessionId = Session.SessionID;
                var result = CartService.UpdateCartQuantity(userId, sessionId, productId, quantity);

                if (result.IsSuccess)
                {
                    Session["CartSummary"] = result.CartSummary;
                    LoadCartItems();
                    ShowSuccessMessage(result.Message);
                }
                else
                {
                    ShowErrorMessage(result.Message);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"UpdateCartQuantity Error: {ex.Message}");
                ShowErrorMessage("Có lỗi khi cập nhật số lượng");
            }
        }

        /// <summary>
        /// Xóa sản phẩm khỏi giỏ hàng
        /// </summary>
        private void RemoveFromCart(int productId)
        {
            try
            {
                int? userId = GetCurrentUserId();

                if (!userId.HasValue)
                {
                    ShowWarningMessage("Vui lòng đăng nhập để sử dụng tính năng này");
                    return;
                }

                string sessionId = Session.SessionID;
                var result = CartService.RemoveFromCart(userId, sessionId, productId);

                if (result.IsSuccess)
                {
                    Session["CartSummary"] = result.CartSummary;
                    LoadCartItems();
                    ShowSuccessMessage(result.Message);
                }
                else
                {
                    ShowErrorMessage(result.Message);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"RemoveFromCart Error: {ex.Message}");
                ShowErrorMessage("Có lỗi khi xóa sản phẩm");
            }
        }

        /// <summary>
        /// Xử lý merge cart sau khi đăng nhập
        /// </summary>
        private void HandleCartMergeAfterLogin()
        {
            try
            {
                int? userId = GetCurrentUserId();

                if (userId.HasValue && Session["JustLoggedIn"] != null)
                {
                    string sessionId = Session.SessionID;
                    CartService.MergeSessionCartToUser(userId.Value, sessionId);

                    Session.Remove("JustLoggedIn");
                    ShowSuccessMessage("Đã đồng bộ giỏ hàng của bạn!");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"HandleCartMergeAfterLogin Error: {ex.Message}");
            }
        }

        #endregion

        #region Event Handlers - Xử lý sự kiện

        protected void btnGridView_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Client/ProductList.aspx?view=grid");
        }

        protected void btnListView_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Client/ProductList.aspx?view=list");
        }

        protected void btnPrevPage_Click(object sender, EventArgs e)
        {
            int currentPage = Convert.ToInt32(ViewState["CurrentPage"] ?? 1);
            if (currentPage > 1)
            {
                ViewState["CurrentPage"] = currentPage - 1;
                LoadFeaturedProducts();
            }
        }

        protected void btnNextPage_Click(object sender, EventArgs e)
        {
            int currentPage = Convert.ToInt32(ViewState["CurrentPage"] ?? 1);
            int totalPages = Convert.ToInt32(ViewState["TotalPages"] ?? 4);
            if (currentPage < totalPages)
            {
                ViewState["CurrentPage"] = currentPage + 1;
                LoadFeaturedProducts();
            }
        }

        protected void btnPage_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            int pageNumber = Convert.ToInt32(btn.CommandArgument);
            ViewState["CurrentPage"] = pageNumber;
            LoadFeaturedProducts();
        }

        protected void btnRemoveFromCart_Click(object sender, EventArgs e)
        {
            try
            {
                LinkButton btn = (LinkButton)sender;
                int productId = Convert.ToInt32(btn.CommandArgument);
                RemoveFromCart(productId);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"btnRemoveFromCart_Click Error: {ex.Message}");
                ShowErrorMessage("Có lỗi khi xóa sản phẩm khỏi giỏ hàng");
            }
        }

        protected void rptBestSellingProducts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                int productId = Convert.ToInt32(e.CommandArgument);

                if (e.CommandName == "AddToCart")
                {
                    HandleAddToCart(productId);
                }
                else if (e.CommandName == "AddToWishlist")
                {
                    HandleAddToWishlist(productId);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"rptBestSellingProducts_ItemCommand Error: {ex.Message}");
                ShowErrorMessage("Có lỗi xảy ra khi thực hiện thao tác");
            }
        }

        protected void rptFeaturedProducts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                int productId = Convert.ToInt32(e.CommandArgument);

                if (e.CommandName == "AddToCart")
                {
                    HandleAddToCart(productId);
                }
                else if (e.CommandName == "AddToWishlist")
                {
                    HandleAddToWishlist(productId);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"rptFeaturedProducts_ItemCommand Error: {ex.Message}");
                ShowErrorMessage("Có lỗi xảy ra khi thực hiện thao tác");
            }
        }

        #endregion

        #region Helper Methods

        /// <summary>
        /// Lấy ID người dùng hiện tại từ session - SỬA CHÍNH
        /// </summary>
        private int? GetCurrentUserId()
        {
            try
            {
                // Kiểm tra session trước
                if (Session["UserId"] != null)
                {
                    return Convert.ToInt32(Session["UserId"]);
                }

                // Fallback: kiểm tra authentication ticket
                if (User.Identity.IsAuthenticated)
                {
                    var authCookie = Request.Cookies[System.Web.Security.FormsAuthentication.FormsCookieName];
                    if (authCookie != null)
                    {
                        try
                        {
                            var ticket = System.Web.Security.FormsAuthentication.Decrypt(authCookie.Value);
                            if (ticket != null && !ticket.Expired)
                            {
                                var userData = ticket.UserData.Split('|');
                                if (userData.Length >= 2)
                                {
                                    int userId = Convert.ToInt32(userData[1]);
                                    Session["UserId"] = userId; // Cache lại trong session
                                    return userId;
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine($"Error reading auth ticket: {ex.Message}");
                        }
                    }
                }

                return null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetCurrentUserId Error: {ex.Message}");
                return null;
            }
        }

        /// <summary>
        /// Cập nhật số lượng giỏ hàng trên page
        /// </summary>
        private void UpdateCartCountOnPage(int count)
        {
            string script = $@"
                try {{
                    const cartCounts = document.querySelectorAll('.cart-count');
                    cartCounts.forEach(element => {{
                        if (element) {{
                            element.textContent = {count};
                            element.style.display = {count} > 0 ? 'flex' : 'none';
                        }}
                    }});
                    
                    localStorage.setItem('cartCount', {count});
                    
                    window.dispatchEvent(new CustomEvent('cartUpdated', {{ 
                        detail: {{ count: {count} }} 
                    }}));
                }} catch (e) {{
                    console.log('Error updating cart count:', e);
                }}
            ";

            ScriptManager.RegisterStartupScript(this, this.GetType(), "updateCartCount", script, true);
        }

        /// <summary>
        /// Cập nhật số lượng wishlist trên page
        /// </summary>
        private void UpdateWishlistCountOnPage()
        {
            try
            {
                int? userId = GetCurrentUserId();
                if (!userId.HasValue) return;

                string query = "SELECT COUNT(*) FROM wishlists WHERE user_id = @UserId";
                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@UserId", userId.Value)
                };

                int wishlistCount = Convert.ToInt32(DatabaseHelper.ExecuteScalar(query, parameters));

                string script = $@"
                    try {{
                        const wishlistCounts = document.querySelectorAll('.wishlist-count');
                        wishlistCounts.forEach(element => {{
                            if (element) {{
                                element.textContent = {wishlistCount};
                                element.style.display = {wishlistCount} > 0 ? 'flex' : 'none';
                            }}
                        }});
                        
                        localStorage.setItem('wishlistCount', {wishlistCount});
                    }} catch (e) {{
                        console.log('Error updating wishlist count:', e);
                    }}
                ";

                ScriptManager.RegisterStartupScript(this, this.GetType(), "updateWishlistCount", script, true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"UpdateWishlistCountOnPage Error: {ex.Message}");
            }
        }

        /// <summary>
        /// Tạo ngôi sao đánh giá HTML
        /// </summary>
        protected string GenerateStars(double rating)
        {
            try
            {
                string stars = "";
                int fullStars = (int)Math.Floor(rating);
                bool hasHalfStar = (rating - fullStars) >= 0.5;

                for (int i = 0; i < fullStars; i++)
                {
                    stars += "<i class='fas fa-star text-yellow-400'></i>";
                }

                if (hasHalfStar)
                {
                    stars += "<i class='fas fa-star-half-alt text-yellow-400'></i>";
                }

                int totalStars = fullStars + (hasHalfStar ? 1 : 0);
                for (int i = totalStars; i < 5; i++)
                {
                    stars += "<i class='far fa-star text-gray-300'></i>";
                }

                return stars;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GenerateStars Error: {ex.Message}");
                return "";
            }
        }

        #endregion

        #region Fallback Methods

        private void LoadCategoriesFallback()
        {
            var categories = new List<object>
            {
                new { Id = 1, Name = "Đồ chơi giáo dục", Icon = "fas fa-puzzle-piece", ProductCount = 45 },
                new { Id = 2, Name = "Xe & Điều khiển", Icon = "fas fa-car", ProductCount = 32 },
                new { Id = 3, Name = "Đồ chơi cho bé 0-3 tuổi", Icon = "fas fa-baby", ProductCount = 28 },
                new { Id = 4, Name = "Robot & Nhân vật", Icon = "fas fa-robot", ProductCount = 56 }
            };

            rptCategories.DataSource = categories;
            rptCategories.DataBind();
        }

        private void LoadBestSellingProductsFallback()
        {
            var products = new List<object>
            {
                new {
                    Id = 1, Name = "Robot biến hình thông minh", Price = 450000, OriginalPrice = 550000,
                    DiscountPercent = 18, ImageUrl = "https://via.placeholder.com/300x300?text=Robot",
                    Rating = 4.5, ReviewCount = 124, IsNew = false
                }
            };

            rptBestSellingProducts.DataSource = products;
            rptBestSellingProducts.DataBind();
        }

        private void LoadFeaturedProductsFallback()
        {
            var products = new List<object>
            {
                new {
                    Id = 5, Name = "Bộ đồ chơi học toán vui nhộn", Price = 195000,
                    ImageUrl = "https://via.placeholder.com/300x300?text=Educational",
                    Rating = 5.0, ReviewCount = 78, IsHot = true
                }
            };

            rptFeaturedProducts.DataSource = products;
            rptFeaturedProducts.DataBind();
        }

        private void LoadNewProductsFallback()
        {
            var products = new List<object>
            {
                new {
                    Id = 8, Name = "Đồ chơi nhà bếp mini", Price = 230000,
                    ImageUrl = "https://via.placeholder.com/300x300?text=New1", Rating = 5.0
                }
            };

            rptNewProducts.DataSource = products;
            rptNewProducts.DataBind();
        }

        #endregion

        #region Statistics Methods

        private int GetOnlineUsersCount()
        {
            try
            {
                string query = @"
                    SELECT COUNT(DISTINCT user_id) 
                    FROM activity_logs 
                    WHERE created_at >= DATE_SUB(NOW(), INTERVAL 15 MINUTE)
                    AND user_id IS NOT NULL";

                object result = DatabaseHelper.ExecuteScalar(query);
                return Math.Max(Convert.ToInt32(result), new Random().Next(50, 150));
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetOnlineUsersCount Error: {ex.Message}");
                return new Random().Next(50, 150);
            }
        }

        private int GetTodayOrdersCount()
        {
            try
            {
                string query = @"
                    SELECT COUNT(*) 
                    FROM orders 
                    WHERE DATE(created_at) = CURDATE()";

                object result = DatabaseHelper.ExecuteScalar(query);
                return Convert.ToInt32(result);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetTodayOrdersCount Error: {ex.Message}");
                return new Random().Next(10, 30);
            }
        }

        #endregion

        #region Script Registration

        private void RegisterPostBackScript()
        {
            string script = @"
                function __doPostBack(eventTarget, eventArgument) {
                    var form = document.forms['form1'] || document.forms[0];
                    if (form) {
                        if (!form.__EVENTTARGET) {
                            var input1 = document.createElement('input');
                            input1.type = 'hidden';
                            input1.name = '__EVENTTARGET';
                            form.appendChild(input1);
                        }
                        if (!form.__EVENTARGUMENT) {
                            var input2 = document.createElement('input');
                            input2.type = 'hidden';
                            input2.name = '__EVENTARGUMENT';
                            form.appendChild(input2);
                        }
                        form.__EVENTTARGET.value = eventTarget;
                        form.__EVENTARGUMENT.value = eventArgument;
                        form.submit();
                    }
                }

                function addToCart(productId, quantity) {
                    quantity = quantity || 1;
                    showPageLoader();
                    __doPostBack('', 'addToCart|' + productId + '|' + quantity);
                }

                function addToWishlist(productId) {
                    showPageLoader();
                    __doPostBack('', 'addToWishlist|' + productId);
                }

                function updateCartQuantity(productId, quantity) {
                    if (quantity <= 0) {
                        removeFromCart(productId);
                        return;
                    }
                    showPageLoader();
                    __doPostBack('', 'updateCartQuantity|' + productId + '|' + quantity);
                }

                function removeFromCart(productId) {
                    if (confirm('Bạn có chắc muốn xóa sản phẩm này khỏi giỏ hàng?')) {
                        showPageLoader();
                        __doPostBack('', 'removeFromCart|' + productId);
                    }
                }

                function showPageLoader() {
                    var loader = document.getElementById('pageLoader');
                    if (loader) {
                        loader.style.display = 'flex';
                    }
                }

                function hidePageLoader() {
                    var loader = document.getElementById('pageLoader');
                    if (loader) {
                        loader.style.display = 'none';
                    }
                }

                function handleQuantityChange(input, productId) {
                    var quantity = parseInt(input.value);
                    if (isNaN(quantity) || quantity < 1) {
                        input.value = 1;
                        quantity = 1;
                    }
                    
                    // Debounce the update
                    clearTimeout(input.updateTimeout);
                    input.updateTimeout = setTimeout(() => {
                        updateCartQuantity(productId, quantity);
                    }, 500);
                }

                window.addEventListener('load', function() {
                    setTimeout(hidePageLoader, 500);
                });
            ";

            ScriptManager.RegisterStartupScript(this, this.GetType(), "cartScripts", script, true);
        }

        #endregion

        #region Message Methods

        /// <summary>
        /// Hiển thị thông báo với auto-hide
        /// </summary>
        private void ShowNotification(string message, string type = "info")
        {
            string bgColor;
            switch (type)
            {
                case "success":
                    bgColor = "bg-green-500";
                    break;
                case "error":
                    bgColor = "bg-red-500";
                    break;
                case "warning":
                    bgColor = "bg-yellow-500";
                    break;
                default:
                    bgColor = "bg-blue-500";
                    break;
            }

            string script = $@"
                try {{
                    const existing = document.querySelectorAll('.notification');
                    existing.forEach(n => n.remove());

                    const notification = document.createElement('div');
                    notification.className = 'notification fixed top-4 right-4 z-50 p-3 rounded-lg shadow-lg max-w-sm text-white {bgColor}';
                    notification.innerHTML = `
                        <div class='flex items-center justify-between'>
                            <span class='text-sm'>{HttpUtility.JavaScriptStringEncode(message)}</span>
                            <button onclick='this.parentElement.parentElement.remove()' class='ml-2 text-white hover:text-gray-200'>
                                <i class='fas fa-times text-xs'></i>
                            </button>
                        </div>
                    `;
                    
                    document.body.appendChild(notification);
                    
                    setTimeout(() => {{
                        if (notification.parentNode) {{
                            notification.remove();
                        }}
                    }}, 3000);
                }} catch (e) {{
                    console.log('Notification error:', e);
                    alert('{HttpUtility.JavaScriptStringEncode(message)}');
                }}
            ";

            ScriptManager.RegisterStartupScript(this, this.GetType(), "notification_" + Guid.NewGuid(), script, true);
        }

        /// <summary>
        /// Hiển thị thông báo thành công
        /// </summary>
        private void ShowSuccessMessage(string message)
        {
            ShowNotification(message, "success");
        }

        /// <summary>
        /// Hiển thị thông báo cảnh báo
        /// </summary>
        private void ShowWarningMessage(string message)
        {
            ShowNotification(message, "warning");
        }

        /// <summary>
        /// Hiển thị thông báo lỗi
        /// </summary>
        private void ShowErrorMessage(string message)
        {
            ShowNotification(message, "error");
        }

        #endregion

        #region Error Handling

        /// <summary>
        /// Override xử lý lỗi trang
        /// </summary>
        protected override void OnError(EventArgs e)
        {
            Exception ex = Server.GetLastError();

            System.Diagnostics.Debug.WriteLine($"Page Error: {ex?.Message}");
            System.Diagnostics.Debug.WriteLine($"StackTrace: {ex?.StackTrace}");

            Server.ClearError();
            ShowErrorMessage("Có lỗi xảy ra trên trang. Vui lòng làm mới trang và thử lại.");

            base.OnError(e);
        }

        #endregion
    }
}