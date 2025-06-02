using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.IO;

namespace WebsiteDoChoi.Client
{
    public partial class Profile : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadUserProfile();
                LoadDashboardData();
                LoadRecentOrders();
                LoadNotifications();
                LoadOrders();
                LoadWishlist();
                LoadAddresses();
                LoadLoginHistory();
            }
        }

        #region Load Data Methods

        private void LoadUserProfile()
        {
            try
            {
                // Load user information from database or session
                // This is sample data - replace with actual database calls

                lblWelcomeName.Text = "Nam";
                lblUserInitials.Text = "NVN";
                lblMembershipLevel.Text = "Thành viên VIP";

                // Load profile form data
                txtFullName.Text = "Nguyễn Văn Nam";
                txtEmail.Text = "nam.nguyen@email.com";
                txtPhone.Text = "0987 654 321";
                txtBirthDate.Text = "1990-05-15";
                txtAddress.Text = "123 Đường ABC, Phường XYZ, Quận 1, TP.HCM";
                rblGender.SelectedValue = "male";
            }
            catch (Exception ex)
            {
                // Log error
                Response.Write("<script>alert('Lỗi khi tải thông tin người dùng: " + ex.Message + "');</script>");
            }
        }

        private void LoadDashboardData()
        {
            try
            {
                // Load dashboard statistics
                lblTotalOrders.Text = "24";
                lblTotalSpent.Text = "12.5M";
                lblTotalSaved.Text = "850K";
                lblRewardPoints.Text = "1,250";
                lblOrderCount.Text = "5";
                lblWishlistCount.Text = "12";
            }
            catch (Exception ex)
            {
                Response.Write("<script>alert('Lỗi khi tải dữ liệu dashboard: " + ex.Message + "');</script>");
            }
        }

        private void LoadRecentOrders()
        {
            try
            {
                // Sample data - replace with database call
                var recentOrders = new List<dynamic>
                {
                    new {
                        ProductName = "Robot biến hình thông minh",
                        OrderCode = "TL2024001",
                        TotalAmount = 450000,
                        StatusText = "Đã giao",
                        StatusColor = "green",
                        ProductImage = "https://api.placeholder.com/60/60?text=Robot"
                    },
                    new {
                        ProductName = "Bộ xếp hình thành phố",
                        OrderCode = "TL2024002",
                        TotalAmount = 690000,
                        StatusText = "Đang giao",
                        StatusColor = "blue",
                        ProductImage = "https://api.placeholder.com/60/60?text=Lego"
                    }
                };

                rptRecentOrders.DataSource = recentOrders;
                rptRecentOrders.DataBind();
            }
            catch (Exception ex)
            {
                Response.Write("<script>alert('Lỗi khi tải đơn hàng gần đây: " + ex.Message + "');</script>");
            }
        }

        private void LoadNotifications()
        {
            try
            {
                var notifications = new List<dynamic>
                {
                    new {
                        Title = "Khuyến mãi mới!",
                        Message = "Giảm 30% tất cả đồ chơi giáo dục đến hết tháng",
                        ColorClass = "blue"
                    },
                    new {
                        Title = "Đơn hàng đã giao",
                        Message = "Đơn hàng #TL2024001 đã được giao thành công",
                        ColorClass = "green"
                    },
                    new {
                        Title = "Điểm thưởng sắp hết hạn",
                        Message = "500 điểm sẽ hết hạn vào 15/06/2025",
                        ColorClass = "yellow"
                    }
                };

                rptNotifications.DataSource = notifications;
                rptNotifications.DataBind();
            }
            catch (Exception ex)
            {
                Response.Write("<script>alert('Lỗi khi tải thông báo: " + ex.Message + "');</script>");
            }
        }

        private void LoadOrders()
        {
            try
            {
                // Sample order data
                var orders = new List<dynamic>
                {
                    new {
                        Id = 1,
                        OrderCode = "TL2024001",
                        OrderDate = DateTime.Parse("2025-05-15"),
                        Status = "delivered",
                        StatusText = "Đã giao",
                        StatusColor = "green",
                        TotalAmount = 450000,
                        OrderItems = new List<dynamic>
                        {
                            new {
                                ProductName = "Robot biến hình thông minh",
                                Quantity = 1,
                                Price = 450000,
                                ProductImage = "https://api.placeholder.com/60/60?text=Robot"
                            }
                        }
                    },
                    new {
                        Id = 2,
                        OrderCode = "TL2024002",
                        OrderDate = DateTime.Parse("2025-05-20"),
                        Status = "shipping",
                        StatusText = "Đang giao",
                        StatusColor = "blue",
                        TotalAmount = 1210000,
                        OrderItems = new List<dynamic>
                        {
                            new {
                                ProductName = "Bộ xếp hình thành phố 520 chi tiết",
                                Quantity = 1,
                                Price = 690000,
                                ProductImage = "https://api.placeholder.com/60/60?text=Lego"
                            },
                            new {
                                ProductName = "Xe đua điều khiển từ xa",
                                Quantity = 1,
                                Price = 520000,
                                ProductImage = "https://api.placeholder.com/60/60?text=Car"
                            }
                        }
                    }
                };

                rptOrders.DataSource = orders;
                rptOrders.DataBind();

                // Load pagination
                LoadOrdersPagination();
            }
            catch (Exception ex)
            {
                Response.Write("<script>alert('Lỗi khi tải đơn hàng: " + ex.Message + "');</script>");
            }
        }

        private void LoadOrdersPagination()
        {
            var paginationData = new List<dynamic>
            {
                new { PageNumber = 1, IsCurrentPage = true },
                new { PageNumber = 2, IsCurrentPage = false },
                new { PageNumber = 3, IsCurrentPage = false }
            };

            rptOrdersPagination.DataSource = paginationData;
            rptOrdersPagination.DataBind();
        }

        private void LoadWishlist()
        {
            try
            {
                var wishlistItems = new List<dynamic>
                {
                    new {
                        Id = 1,
                        ProductName = "Đồ chơi nhà bếp mini",
                        Price = 230000,
                        OriginalPrice = 0,
                        Rating = 5.0,
                        ReviewCount = 45,
                        InStock = true,
                        ProductImage = "https://api.placeholder.com/300/300?text=Kitchen"
                    },
                    new {
                        Id = 2,
                        ProductName = "Máy bay điều khiển từ xa",
                        Price = 480000,
                        OriginalPrice = 0,
                        Rating = 4.0,
                        ReviewCount = 32,
                        InStock = false,
                        ProductImage = "https://api.placeholder.com/300/300?text=Plane"
                    },
                    new {
                        Id = 3,
                        ProductName = "Búp bê cảm ứng thông minh",
                        Price = 350000,
                        OriginalPrice = 420000,
                        Rating = 3.5,
                        ReviewCount = 28,
                        InStock = true,
                        ProductImage = "https://api.placeholder.com/300/300?text=Doll"
                    }
                };

                rptWishlist.DataSource = wishlistItems;
                rptWishlist.DataBind();
            }
            catch (Exception ex)
            {
                Response.Write("<script>alert('Lỗi khi tải danh sách yêu thích: " + ex.Message + "');</script>");
            }
        }

        private void LoadAddresses()
        {
            try
            {
                var addresses = new List<dynamic>
                {
                    new {
                        Id = 1,
                        RecipientName = "Nguyễn Văn Nam",
                        PhoneNumber = "0987 654 321",
                        FullAddress = "123 Đường ABC, Phường XYZ, Quận 1, TP.HCM",
                        IsDefault = true
                    },
                    new {
                        Id = 2,
                        RecipientName = "Nguyễn Văn Nam (Văn phòng)",
                        PhoneNumber = "0987 654 321",
                        FullAddress = "456 Đường DEF, Phường GHI, Quận 3, TP.HCM",
                        IsDefault = false
                    }
                };

                rptAddresses.DataSource = addresses;
                rptAddresses.DataBind();
            }
            catch (Exception ex)
            {
                Response.Write("<script>alert('Lỗi khi tải địa chỉ: " + ex.Message + "');</script>");
            }
        }

        private void LoadLoginHistory()
        {
            try
            {
                var loginHistory = new List<dynamic>
                {
                    new {
                        DeviceIcon = "desktop",
                        DeviceColor = "green",
                        DeviceInfo = "Chrome trên Windows",
                        LoginTime = "Hôm nay, 14:30",
                        IpAddress = "192.168.1.1"
                    },
                    new {
                        DeviceIcon = "mobile-alt",
                        DeviceColor = "blue",
                        DeviceInfo = "Chrome trên Android",
                        LoginTime = "Hôm qua, 09:15",
                        IpAddress = "192.168.1.25"
                    }
                };

                rptLoginHistory.DataSource = loginHistory;
                rptLoginHistory.DataBind();
            }
            catch (Exception ex)
            {
                Response.Write("<script>alert('Lỗi khi tải lịch sử đăng nhập: " + ex.Message + "');</script>");
            }
        }

        #endregion

        #region Event Handlers

        protected void btnSearch_Click(object sender, EventArgs e)
        {
                Response.Redirect($"/Client/ProductList.aspx?search={HttpUtility.UrlEncode("")}");
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            // Clear session and redirect to login
            Session.Clear();
            Session.Abandon();
            Response.Redirect("/Client/Login.aspx");
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            lnkLogout_Click(sender, e);
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                try
                {
                    // Save profile data to database
                    string fullName = txtFullName.Text.Trim();
                    string email = txtEmail.Text.Trim();
                    string phone = txtPhone.Text.Trim();
                    string birthDate = txtBirthDate.Text;
                    string address = txtAddress.Text.Trim();
                    string gender = rblGender.SelectedValue;

                    // TODO: Update database
                    // UpdateUserProfile(fullName, email, phone, birthDate, address, gender);

                    Response.Write("<script>showSuccessMessage('Cập nhật thông tin thành công!');</script>");
                }
                catch (Exception ex)
                {
                    Response.Write("<script>showErrorMessage('Lỗi khi cập nhật thông tin: " + ex.Message + "');</script>");
                }
            }
        }

        protected void btnCancelProfile_Click(object sender, EventArgs e)
        {
            LoadUserProfile(); // Reload original data
        }

        protected void btnUploadImage_Click(object sender, EventArgs e)
        {
            if (fuProfileImage.HasFile)
            {
                try
                {
                    string fileName = Path.GetFileName(fuProfileImage.FileName);
                    string fileExtension = Path.GetExtension(fileName).ToLower();

                    // Validate file type
                    if (fileExtension == ".jpg" || fileExtension == ".jpeg" || fileExtension == ".png" || fileExtension == ".gif")
                    {
                        // Save file
                        string uploadPath = Server.MapPath("~/Content/images/profiles/");
                        if (!Directory.Exists(uploadPath))
                        {
                            Directory.CreateDirectory(uploadPath);
                        }

                        string newFileName = $"profile_{Session["UserId"]}_{DateTime.Now.Ticks}{fileExtension}";
                        fuProfileImage.SaveAs(uploadPath + newFileName);

                        // TODO: Update database with new image path

                        Response.Write("<script>showSuccessMessage('Tải ảnh thành công!');</script>");
                    }
                    else
                    {
                        Response.Write("<script>showErrorMessage('Vui lòng chọn file ảnh hợp lệ (jpg, jpeg, png, gif)!');</script>");
                    }
                }
                catch (Exception ex)
                {
                    Response.Write("<script>showErrorMessage('Lỗi khi tải ảnh: " + ex.Message + "');</script>");
                }
            }
        }

        protected void ddlOrderStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Filter orders based on selected status
            LoadOrders(); // Reload with filter
        }

        protected void rptOrders_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int orderId = Convert.ToInt32(e.CommandArgument);

            switch (e.CommandName)
            {
                case "ViewDetails":
                    Response.Redirect($"/Client/OrderDetails.aspx?id={orderId}");
                    break;
                case "Reorder":
                    // Add order items to cart
                    Response.Write("<script>showSuccessMessage('Đã thêm sản phẩm vào giỏ hàng!');</script>");
                    break;
                case "Track":
                    Response.Redirect($"/Client/OrderTracking.aspx?id={orderId}");
                    break;
                case "Cancel":
                    // Cancel order logic
                    Response.Write("<script>showSuccessMessage('Đã hủy đơn hàng thành công!');</script>");
                    LoadOrders(); // Reload orders
                    break;
            }
        }

        protected void btnOrdersPrevPage_Click(object sender, EventArgs e)
        {
            // Handle previous page
        }

        protected void btnOrdersNextPage_Click(object sender, EventArgs e)
        {
            // Handle next page
        }

        protected void btnOrdersPage_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            int pageNumber = Convert.ToInt32(btn.CommandArgument);
            // Load specific page
        }

        protected void rptWishlist_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int productId = Convert.ToInt32(e.CommandArgument);

            switch (e.CommandName)
            {
                case "RemoveFromWishlist":
                    // Remove from wishlist
                    Response.Write("<script>showSuccessMessage('Đã xóa sản phẩm khỏi danh sách yêu thích!');</script>");
                    LoadWishlist(); // Reload wishlist
                    break;
                case "AddToCart":
                    // Add to cart
                    Response.Write("<script>showSuccessMessage('Đã thêm sản phẩm vào giỏ hàng!');</script>");
                    break;
            }
        }

        protected void btnAddNewAddress_Click(object sender, EventArgs e)
        {
            Response.Redirect("/Client/AddAddress.aspx");
        }

        protected void rptAddresses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int addressId = Convert.ToInt32(e.CommandArgument);

            switch (e.CommandName)
            {
                case "Edit":
                    Response.Redirect($"/Client/EditAddress.aspx?id={addressId}");
                    break;
                case "SetDefault":
                    // Set as default address
                    Response.Write("<script>showSuccessMessage('Đã đặt làm địa chỉ mặc định!');</script>");
                    LoadAddresses(); // Reload addresses
                    break;
                case "Delete":
                    // Delete address
                    Response.Write("<script>showSuccessMessage('Đã xóa địa chỉ thành công!');</script>");
                    LoadAddresses(); // Reload addresses
                    break;
            }
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                try
                {
                    string currentPassword = txtCurrentPassword.Text;
                    string newPassword = txtNewPassword.Text;
                    string confirmPassword = txtConfirmPassword.Text;

                    // TODO: Verify current password and update new password
                    // if (VerifyCurrentPassword(currentPassword))
                    // {
                    //     UpdatePassword(newPassword);
                    //     Response.Write("<script>showSuccessMessage('Đổi mật khẩu thành công!');</script>");
                    // }
                    // else
                    // {
                    //     Response.Write("<script>showErrorMessage('Mật khẩu hiện tại không đúng!');</script>");
                    // }

                    // Clear password fields
                    txtCurrentPassword.Text = "";
                    txtNewPassword.Text = "";
                    txtConfirmPassword.Text = "";

                    Response.Write("<script>showSuccessMessage('Đổi mật khẩu thành công!');</script>");
                }
                catch (Exception ex)
                {
                    Response.Write("<script>showErrorMessage('Lỗi khi đổi mật khẩu: " + ex.Message + "');</script>");
                }
            }
        }

        protected void chkTwoFactorAuth_CheckedChanged(object sender, EventArgs e)
        {
            if (chkTwoFactorAuth.Checked)
            {
                lblTwoFactorStatus.Text = "Đã kích hoạt";
                Response.Write("<script>showSuccessMessage('Đã kích hoạt xác thực 2 bước!');</script>");
            }
            else
            {
                lblTwoFactorStatus.Text = "Chưa kích hoạt";
                Response.Write("<script>showSuccessMessage('Đã tắt xác thực 2 bước!');</script>");
            }
        }

        protected void btnActivateTwoFactor_Click(object sender, EventArgs e)
        {
            Response.Redirect("/Client/TwoFactorSetup.aspx");
        }

        protected void btnViewAllLoginHistory_Click(object sender, EventArgs e)
        {
            Response.Redirect("/Client/LoginHistory.aspx");
        }

        #endregion

        #region Helper Methods

        protected string GenerateStars(double rating)
        {
            string stars = "";
            int fullStars = (int)rating;
            bool hasHalfStar = (rating - fullStars) >= 0.5;

            for (int i = 0; i < fullStars; i++)
            {
                stars += "<i class=\"fas fa-star\"></i>";
            }

            if (hasHalfStar)
            {
                stars += "<i class=\"fas fa-star-half-alt\"></i>";
                fullStars++;
            }

            for (int i = fullStars; i < 5; i++)
            {
                stars += "<i class=\"far fa-star\"></i>";
            }

            return stars;
        }

        #endregion
    }
}