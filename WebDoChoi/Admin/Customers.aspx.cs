using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebsiteDoChoi.Admin
{
    public class AdminCustomerSummary
    {
        public int CustomerId { get; set; }
        public string CustomerName { get; set; }
        public string Email { get; set; }
        public string PhoneNumber { get; set; }
        public string AvatarInitial { get; set; }
        public string AvatarBgClass { get; set; }
        public string SegmentText { get; set; } // VIP, Thường, Mới
        public string SegmentCssClass { get; set; } // badge-vip, badge-regular, badge-new
        public int TotalOrders { get; set; }
        public decimal TotalSpent { get; set; }
        public double AverageRating { get; set; }
        public DateTime JoinedDate { get; set; }
        public string AccountStatus { get; set; } // active, inactive, blocked
        public string AccountStatusText { get; set; }
    }

    public class AdminCustomerDetailModel : AdminCustomerSummary
    {
        public string Gender { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public List<CustomerAddressInfo> Addresses { get; set; }
        public List<AdminOrderSummary> RecentOrders { get; set; } // Re-use from Orders page if suitable
        public List<CustomerActivityLog> ActivityLog { get; set; }
        public decimal OrderCompletionRate { get; set; } // Percentage
        // Data for Purchase History Chart
        public List<string> PurchaseChartLabels { get; set; } // e.g., Months
        public List<int> PurchaseChartOrderData { get; set; }
        public List<decimal> PurchaseChartRevenueData { get; set; } // In K VNĐ
    }
    public class CustomerAddressInfo
    {
        public string AddressType { get; set; } // Nhà, Công ty
        public string FullAddress { get; set; }
        public bool IsDefault { get; set; }
    }
    public class CustomerActivityLog
    {
        public string Activity { get; set; }
        public DateTime Timestamp { get; set; }
        public string IconCss { get; set; }
        public string IconBgCss { get; set; }
    }


    public partial class Customers : System.Web.UI.Page
    {
        private const int CustomersPageSize = 9; // Customers per page for card view

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ViewState["CurrentCustomerPage"] = 1;
                PopulateCustomerFilterDropdowns();
                BindCustomers();
                LoadCustomerStatsCards();
                LoadMainCustomerCharts();
            }
        }

        private void PopulateCustomerFilterDropdowns()
        {
            ddlSegmentFilter.Items.Clear();
            ddlSegmentFilter.Items.Add(new ListItem("Tất cả phân khúc", ""));
            ddlSegmentFilter.Items.Add(new ListItem("VIP", "vip"));
            ddlSegmentFilter.Items.Add(new ListItem("Thường", "regular"));
            ddlSegmentFilter.Items.Add(new ListItem("Mới", "new"));

            ddlCustomerStatusFilter.Items.Clear();
            ddlCustomerStatusFilter.Items.Add(new ListItem("Tất cả trạng thái TK", ""));
            ddlCustomerStatusFilter.Items.Add(new ListItem("Hoạt động", "active"));
            ddlCustomerStatusFilter.Items.Add(new ListItem("Không hoạt động", "inactive"));
            ddlCustomerStatusFilter.Items.Add(new ListItem("Đã chặn", "blocked"));

            // For modal
            ddlCustomerGrowthPeriod.SelectedValue = "12m"; // Default chart period
        }

        private void LoadCustomerStatsCards()
        {
            // TODO: Fetch actual data from DB
            lblTotalCustomers.Text = "1,847";
            lblTotalCustomersChange.Text = "+15.3%";
            lblNewCustomersMonthly.Text = "89";
            lblVipCustomers.Text = "156";
            lblVipCustomersPercentage.Text = "8.5%";
            lblReturnRate.Text = "73.2%";
            lblReturnRateChange.Text = "+5.1%";
        }

        private void LoadMainCustomerCharts()
        {
            LoadCustomerGrowthChartData(ddlCustomerGrowthPeriod.SelectedValue);
            LoadCustomerSegmentChartData();
        }

        private void LoadCustomerGrowthChartData(string period)
        {
            // TODO: Fetch data based on period
            var labels = new List<string>();
            var newData = new List<int>();
            var totalData = new List<int>();
            int months = period == "6m" ? 6 : (period == "12m" ? 12 : 24); // Example for "all"
            Random rand = new Random();

            for (int i = 0; i < months; i++)
            {
                labels.Add(DateTime.Now.AddMonths(-(months - 1 - i)).ToString("MMM yy"));
                newData.Add(rand.Next(20, 100));
                totalData.Add(1000 + i * 50 + rand.Next(0, 50));
            }

            string script = $"renderCustomerGrowthChart({SerializeToJson(labels)}, {SerializeToJson(newData)}, {SerializeToJson(totalData)});";
            ScriptManager.RegisterStartupScript(this, GetType(), "CustomerGrowthChartScript", script, true);
        }

        protected void ddlCustomerGrowthPeriod_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadCustomerGrowthChartData(ddlCustomerGrowthPeriod.SelectedValue);
        }


        private void LoadCustomerSegmentChartData()
        {
            // TODO: Fetch actual segment data
            var labels = new List<string> { "Khách VIP", "Khách thường", "Khách mới", "Không hoạt động" };
            var data = new List<int> { 156, 1247, 285, 159 };
            string script = $"renderCustomerSegmentChart({SerializeToJson(labels)}, {SerializeToJson(data)});";
            ScriptManager.RegisterStartupScript(this, GetType(), "CustomerSegmentChartScript", script, true);
        }


        private void BindCustomers()
        {
            int currentPage = Convert.ToInt32(ViewState["CurrentCustomerPage"]);
            string searchTerm = txtSearchCustomers.Text.Trim().ToLower();
            string segmentFilter = ddlSegmentFilter.SelectedValue;
            string statusFilter = ddlCustomerStatusFilter.SelectedValue;
            DateTime? joinedDateFilter = null;
            if (!string.IsNullOrEmpty(txtJoinedDateFilter.Text) && DateTime.TryParse(txtJoinedDateFilter.Text, out DateTime parsedDate))
            {
                joinedDateFilter = parsedDate;
            }

            // TODO: Replace with actual data fetching
            List<AdminCustomerSummary> allCustomers = GetDummyAdminCustomers();

            // Apply filters
            if (!string.IsNullOrEmpty(searchTerm))
                allCustomers = allCustomers.Where(c => c.CustomerName.ToLower().Contains(searchTerm) || c.Email.ToLower().Contains(searchTerm) || c.PhoneNumber.Contains(searchTerm)).ToList();
            if (!string.IsNullOrEmpty(segmentFilter))
                allCustomers = allCustomers.Where(c => c.SegmentText.ToLower().Replace("khách hàng ", "").Replace("khách ", "") == segmentFilter.ToLower()).ToList();
            if (!string.IsNullOrEmpty(statusFilter))
                allCustomers = allCustomers.Where(c => c.AccountStatus == statusFilter).ToList();
            if (joinedDateFilter.HasValue)
                allCustomers = allCustomers.Where(c => c.JoinedDate.Date == joinedDateFilter.Value.Date).ToList();


            int totalCustomers = allCustomers.Count;
            var pagedCustomers = allCustomers.Skip((currentPage - 1) * CustomersPageSize).Take(CustomersPageSize).ToList();

            rptCustomers.DataSource = pagedCustomers;
            rptCustomers.DataBind();

            SetupCustomerPagination(totalCustomers, currentPage);
            lblCustomerPageInfo.Text = $"Hiển thị {(currentPage - 1) * CustomersPageSize + 1}-{Math.Min(currentPage * CustomersPageSize, totalCustomers)} trong tổng số {totalCustomers} khách hàng";
        }

        #region Pagination for Customers
        private void SetupCustomerPagination(int totalItems, int currentPage)
        {
            int totalPages = (int)Math.Ceiling((double)totalItems / CustomersPageSize);
            lnkCustomerPrevPage.Enabled = currentPage > 1;
            lnkCustomerNextPage.Enabled = currentPage < totalPages;

            if (totalPages <= 1)
            {
                rptCustomerPager.Visible = false;
                lnkCustomerPrevPage.Visible = false;
                lnkCustomerNextPage.Visible = false;
                lblCustomerPageInfo.Visible = totalItems > 0;
                return;
            }
            rptCustomerPager.Visible = true;
            lnkCustomerPrevPage.Visible = true;
            lnkCustomerNextPage.Visible = true;
            lblCustomerPageInfo.Visible = true;


            var pageNumbers = new List<object>();
            int startPage = Math.Max(1, currentPage - 2);
            int endPage = Math.Min(totalPages, currentPage + 2);

            if (startPage > 1) pageNumbers.Add(new { Text = "1", Value = "1", IsCurrent = false });
            if (startPage > 2) pageNumbers.Add(new { Text = "...", Value = (startPage - 1).ToString(), IsCurrent = false });

            for (int i = startPage; i <= endPage; i++)
            {
                pageNumbers.Add(new { Text = i.ToString(), Value = i.ToString(), IsCurrent = (i == currentPage) });
            }
            if (endPage < totalPages - 1) pageNumbers.Add(new { Text = "...", Value = (endPage + 1).ToString(), IsCurrent = false });
            if (endPage < totalPages) pageNumbers.Add(new { Text = totalPages.ToString(), Value = totalPages.ToString(), IsCurrent = false });

            rptCustomerPager.DataSource = pageNumbers;
            rptCustomerPager.DataBind();
        }

        protected void CustomerPage_Changed(object sender, EventArgs e)
        {
            string commandArgument = ((LinkButton)sender).CommandArgument;
            int currentPage = Convert.ToInt32(ViewState["CurrentCustomerPage"]);
            // Recalculate totalPages based on current filters
            var filteredCustomers = GetFilteredCustomersForCount(); // Implement this helper
            int totalPages = (int)Math.Ceiling((double)filteredCustomers.Count / CustomersPageSize);

            if (commandArgument == "Prev") { currentPage = Math.Max(1, currentPage - 1); }
            else if (commandArgument == "Next") { currentPage = Math.Min(totalPages, currentPage + 1); }
            else { currentPage = Convert.ToInt32(commandArgument); }

            ViewState["CurrentCustomerPage"] = currentPage;
            BindCustomers();
        }
        // Helper to get count of filtered customers for pagination logic
        private List<AdminCustomerSummary> GetFilteredCustomersForCount()
        {
            string searchTerm = txtSearchCustomers.Text.Trim().ToLower();
            string segmentFilter = ddlSegmentFilter.SelectedValue;
            string statusFilter = ddlCustomerStatusFilter.SelectedValue;
            DateTime? joinedDateFilter = null;
            if (!string.IsNullOrEmpty(txtJoinedDateFilter.Text) && DateTime.TryParse(txtJoinedDateFilter.Text, out DateTime parsedDate))
            {
                joinedDateFilter = parsedDate;
            }
            List<AdminCustomerSummary> allCustomers = GetDummyAdminCustomers(); // Get all
                                                                                // Apply filters again
            if (!string.IsNullOrEmpty(searchTerm))
                allCustomers = allCustomers.Where(c => c.CustomerName.ToLower().Contains(searchTerm) || c.Email.ToLower().Contains(searchTerm) || c.PhoneNumber.Contains(searchTerm)).ToList();
            if (!string.IsNullOrEmpty(segmentFilter))
                allCustomers = allCustomers.Where(c => c.SegmentText.ToLower().Replace("khách hàng ", "").Replace("khách ", "") == segmentFilter.ToLower()).ToList();
            if (!string.IsNullOrEmpty(statusFilter))
                allCustomers = allCustomers.Where(c => c.AccountStatus == statusFilter).ToList();
            if (joinedDateFilter.HasValue)
                allCustomers = allCustomers.Where(c => c.JoinedDate.Date == joinedDateFilter.Value.Date).ToList();
            return allCustomers;
        }

        #endregion

        protected void btnApplyCustomerFilters_Click(object sender, EventArgs e)
        {
            ViewState["CurrentCustomerPage"] = 1;
            BindCustomers();
        }

        protected void btnResetCustomerFilters_Click(object sender, EventArgs e)
        {
            txtSearchCustomers.Text = "";
            ddlSegmentFilter.ClearSelection();
            ddlCustomerStatusFilter.ClearSelection();
            txtJoinedDateFilter.Text = "";
            ViewState["CurrentCustomerPage"] = 1;
            BindCustomers();
            ShowAdminNotification("Đã reset bộ lọc khách hàng.", "info");
        }

        protected void rptCustomers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int customerId = Convert.ToInt32(e.CommandArgument.ToString().Split(',')[0]); // Assuming "customerId,status" for ToggleBlock

            if (e.CommandName == "ViewDetails")
            {
                LoadCustomerDetailModal(customerId);
            }
            else if (e.CommandName == "ToggleBlock")
            {
                string currentStatus = e.CommandArgument.ToString().Split(',')[1];
                ToggleCustomerBlockStatus(customerId, currentStatus);
            }
        }

        private void ToggleCustomerBlockStatus(int customerId, string currentStatus)
        {
            // TODO: Update customer status in DB
            string newStatus = (currentStatus == "blocked") ? "active" : "blocked";
            // UpdateCustomerStatusInDb(customerId, newStatus);
            ShowAdminNotification($"Đã {(newStatus == "blocked" ? "chặn" : "bỏ chặn")} khách hàng #{customerId}.", "success");
            BindCustomers(); // Refresh list
        }
        protected void btnToggleBlockCustomer_Click(object sender, EventArgs e) // For modal button
        {
            if (ViewState["CurrentModalCustomerId"] != null && int.TryParse(ViewState["CurrentModalCustomerId"].ToString(), out int customerId))
            {
                // TODO: Get current status of this customer from DB or a ViewState property if needed
                AdminCustomerDetailModel customer = GetDummyCustomerDetail(customerId); // Re-fetch or use ViewState
                if (customer != null)
                {
                    ToggleCustomerBlockStatus(customerId, customer.AccountStatus);
                    LoadCustomerDetailModal(customerId); // Refresh modal
                }
            }
        }


        #region Customer Detail Modal
        private void LoadCustomerDetailModal(int customerId)
        {
            // TODO: Fetch full customer details from DB
            AdminCustomerDetailModel customer = GetDummyCustomerDetail(customerId);
            if (customer == null)
            {
                ShowAdminNotification("Không tìm thấy thông tin khách hàng.", "error");
                return;
            }
            ViewState["CurrentModalCustomerId"] = customerId;

            lblModalCustomerName.Text = customer.CustomerName;
            lblModalAvatarInitial.Text = GetInitials(customer.CustomerName);
            // Set avatar background class dynamically if needed in code-behind for modal avatar.
            ((System.Web.UI.HtmlControls.HtmlGenericControl)pnlCustomerDetailModal.FindControl("modalAvatarContainer")).Attributes["class"] = "w-16 h-16 " + customer.AvatarBgClass + " rounded-full flex items-center justify-center text-white font-bold text-2xl";

            lblModalCustomerSegment.Text = customer.SegmentText;
            lblModalCustomerSegment.CssClass = "badge-customer " + customer.SegmentCssClass;
            lblModalEmail.Text = customer.Email;
            lblModalPhone.Text = customer.PhoneNumber;
            lblModalGender.Text = customer.Gender;
            lblModalDob.Text = customer.DateOfBirth.HasValue ? customer.DateOfBirth.Value.ToString("dd/MM/yyyy") : "N/A";
            lblModalJoinedDate.Text = customer.JoinedDate.ToString("dd/MM/yyyy");
            lblModalAccountStatus.Text = customer.AccountStatusText;
            lblModalAccountStatus.CssClass = GetAccountStatusCss(customer.AccountStatus) + " px-2 py-0.5 rounded-full text-xs";

            lblModalTotalOrders.Text = customer.TotalOrders.ToString();
            lblModalTotalSpent.Text = customer.TotalSpent.ToString("N0", CultureInfo.GetCultureInfo("vi-VN")) + "K";
            lblModalAvgRating.Text = customer.AverageRating.ToString("F1");
            lblModalCompletionRate.Text = customer.OrderCompletionRate.ToString("F1");

            rptModalAddresses.DataSource = customer.Addresses;
            rptModalAddresses.DataBind();
            lblModalAddressCount.Text = customer.Addresses?.Count.ToString() ?? "0";

            gvModalRecentOrders.DataSource = customer.RecentOrders;
            gvModalRecentOrders.DataBind();
            lblModalRecentOrderCount.Text = customer.RecentOrders?.Count.ToString() ?? "0";

            rptModalActivityLog.DataSource = customer.ActivityLog;
            rptModalActivityLog.DataBind();

            // Set URLs for modal buttons
            hlModalEmailCustomer.NavigateUrl = "mailto:" + customer.Email;
            hlModalEditCustomer.NavigateUrl = $"~/Admin/CustomerEdit.aspx?id={customerId}"; // Assuming a separate edit page

            // Setup block/unblock button in modal
            btnModalToggleBlockCustomer.Text = $"<i class='fas {(customer.AccountStatus == "blocked" ? "fa-unlock" : "fa-ban")} mr-2'></i>{(customer.AccountStatus == "blocked" ? "Bỏ chặn" : "Chặn KH")}";
            btnModalToggleBlockCustomer.CssClass = $"w-full sm:w-auto px-6 py-2 text-white rounded-lg {(customer.AccountStatus == "blocked" ? "bg-green-500 hover:bg-green-600" : "bg-red-500 hover:bg-red-600")}";
            btnModalToggleBlockCustomer.CommandArgument = $"{customerId},{customer.AccountStatus}";


            pnlCustomerDetailModal.Visible = true;
            // Register script to render purchase history chart for this customer
            string script = $"renderCustomerPurchaseChartModal({SerializeToJson(customer.PurchaseChartLabels)}, {SerializeToJson(customer.PurchaseChartOrderData)}, {SerializeToJson(customer.PurchaseChartRevenueData)});";
            ScriptManager.RegisterStartupScript(this, GetType(), "CustomerPurchaseChartModalScript", script, true);
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "OpenCustomerDetailModal", "document.body.style.overflow = 'hidden'; setupModalClose(); if(typeof initCustomerPurchaseChart === 'function' && !customerPurchaseChartModalInstance) { setTimeout(initCustomerPurchaseChart, 100); }", true);
        }

        protected void btnCloseCustomerModal_Click(object sender, EventArgs e)
        {
            pnlCustomerDetailModal.Visible = false;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CloseCustomerModalScript", "document.body.style.overflow = 'auto';", true);
        }
        #endregion

        protected void btnExportCustomers_Click(object sender, EventArgs e)
        {
      
        }

        protected string GetAvatarBgClass(string name)
        {
            // Simple logic for varied avatar backgrounds
            if (string.IsNullOrEmpty(name)) return "bg-gray-400";
            char firstChar = name.ToUpper()[0];
            if (firstChar >= 'A' && firstChar <= 'E') return "bg-blue-500";
            if (firstChar >= 'F' && firstChar <= 'J') return "bg-green-500";
            if (firstChar >= 'K' && firstChar <= 'O') return "bg-yellow-500";
            if (firstChar >= 'P' && firstChar <= 'T') return "bg-purple-500";
            return "bg-pink-500";
        }
        protected string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "?";
            string[] nameParts = name.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (nameParts.Length > 1) return $"{nameParts[0][0]}{nameParts.Last()[0]}".ToUpper();
            return name[0].ToString().ToUpper();
        }
        protected string GetAccountStatusCss(object statusObj)
        {
            string status = statusObj?.ToString().ToLower() ?? "";
            switch (status)
            {
                case "active": return "badge-active";
                case "inactive": return "badge-inactive";
                case "blocked": return "badge-blocked";
                default: return "bg-gray-200 text-gray-700";
            }
        }


        private void ShowAdminNotification(string message, string type = "info")
        {
            ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString(), $"showNotification('{message.Replace("'", "\\\'")}', '{type}');", true);
        }
        private string SerializeToJson(object obj) => new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(obj);


        #region Dummy Data Generators
        private List<AdminCustomerSummary> GetDummyAdminCustomers()
        {
            var customers = new List<AdminCustomerSummary>();
            string[] firstNames = { "Nguyễn", "Trần", "Lê", "Phạm", "Hoàng", "Vũ", "Đặng", "Bùi", "Đỗ", "Hồ" };
            string[] lastNames = { "Văn An", "Thị Lan", "Minh Tuấn", "Thị Hoa", "Văn Đức", "Thị Mai", "Quốc Bảo", "Thị Thu", "Văn Nam", "Ngọc Linh" };
            string[] segments = { "VIP", "Thường", "Mới" };
            string[] segmentCss = { "badge-vip", "badge-regular", "badge-new" };
            string[] accountStatuses = { "active", "inactive", "blocked" };
            string[] accountStatusTexts = { "Hoạt động", "Không hoạt động", "Đã chặn" };
            Random rand = new Random();

            for (int i = 1; i <= 85; i++)
            {
                string fullName = $"{firstNames[rand.Next(firstNames.Length)]} {lastNames[rand.Next(lastNames.Length)]}";
                int segmentIndex = rand.Next(segments.Length);
                int statusIndex = rand.Next(accountStatuses.Length);
                customers.Add(new AdminCustomerSummary
                {
                    CustomerId = i,
                    CustomerName = fullName,
                    Email = $"{fullName.Replace(" ", ".").ToLower().RemoveDiacritics()}@example.com",
                    PhoneNumber = $"09{rand.Next(10000000, 99999999)}",
                    AvatarInitial = GetInitials(fullName),
                    AvatarBgClass = GetAvatarBgClass(fullName),
                    SegmentText = segments[segmentIndex],
                    SegmentCssClass = segmentCss[segmentIndex],
                    TotalOrders = rand.Next(1, 50),
                    TotalSpent = rand.Next(500, 20000), // In K VNĐ
                    AverageRating = Math.Round(rand.NextDouble() * (5.0 - 3.5) + 3.5, 1),
                    JoinedDate = DateTime.Now.AddDays(-rand.Next(30, 700)),
                    AccountStatus = accountStatuses[statusIndex],
                    AccountStatusText = accountStatusTexts[statusIndex]
                });
            }
            return customers;
        }

        private AdminCustomerDetailModel GetDummyCustomerDetail(int customerId)
        {
            var summary = GetDummyAdminCustomers().FirstOrDefault(c => c.CustomerId == customerId);
            if (summary == null) return null;
            Random rand = new Random();

            var orders = new List<AdminOrderSummary>();
            for (int i = 0; i < summary.TotalOrders; i++)
            {
                orders.Add(new AdminOrderSummary { OrderId = 1000 + i, OrderCode = $"#TL{DateTime.Now.Year - 1}{summary.CustomerId}{i}", OrderDate = summary.JoinedDate.AddDays(rand.Next(1, (DateTime.Now - summary.JoinedDate).Days)), TotalAmount = rand.Next(100, 2000) * 1000m, Status = "delivered", StatusText = "Đã giao" });
            }

            var activities = new List<CustomerActivityLog>();
            activities.Add(new CustomerActivityLog { Activity = "Đăng ký tài khoản", Timestamp = summary.JoinedDate, IconCss = "fas fa-user-plus", IconBgCss = "bg-green-100 text-green-600" });
            if (summary.TotalOrders > 0) activities.Add(new CustomerActivityLog { Activity = $"Đặt đơn hàng {orders.First().OrderCode}", Timestamp = orders.First().OrderDate, IconCss = "fas fa-shopping-cart", IconBgCss = "bg-blue-100 text-blue-600" });
            if (summary.TotalOrders > 2) activities.Add(new CustomerActivityLog { Activity = $"Đánh giá sản phẩm ABC", Timestamp = orders.First().OrderDate.AddDays(5), IconCss = "fas fa-star", IconBgCss = "bg-yellow-100 text-yellow-600" });


            var purchaseLabels = new List<string>();
            var purchaseOrderData = new List<int>();
            var purchaseRevenueData = new List<decimal>();
            for (int i = 5; i >= 0; i--)
            { // Last 6 months
                purchaseLabels.Add(DateTime.Now.AddMonths(-i).ToString("MMM yy"));
                purchaseOrderData.Add(rand.Next(0, (summary.TotalOrders / 3) + 2));
                purchaseRevenueData.Add(rand.Next(0, (int)(summary.TotalSpent / 200) + 50) * 10); // in K VNĐ
            }


            return new AdminCustomerDetailModel
            {
                CustomerId = summary.CustomerId,
                CustomerName = summary.CustomerName,
                Email = summary.Email,
                PhoneNumber = summary.PhoneNumber,
                AvatarInitial = summary.AvatarInitial,
                AvatarBgClass = summary.AvatarBgClass,
                SegmentText = summary.SegmentText,
                SegmentCssClass = summary.SegmentCssClass,
                TotalOrders = summary.TotalOrders,
                TotalSpent = summary.TotalSpent,
                AverageRating = summary.AverageRating,
                JoinedDate = summary.JoinedDate,
                AccountStatus = summary.AccountStatus,
                AccountStatusText = summary.AccountStatusText,
                Gender = (rand.Next(0, 2) == 0) ? "Nam" : "Nữ",
                DateOfBirth = summary.JoinedDate.AddYears(-rand.Next(18, 50)),
                Addresses = new List<CustomerAddressInfo> {
                    new CustomerAddressInfo { AddressType="Nhà", FullAddress=$"Số {rand.Next(1,200)}, {summary.CustomerName.Split(' ').Last()} Str, Ward {rand.Next(1,10)}, Dist {rand.Next(1,5)}, City X", IsDefault=true},
                    new CustomerAddressInfo { AddressType="Công ty", FullAddress=$"Tòa nhà XYZ, {rand.Next(1,50)} Example Ave, TP Demo", IsDefault=false}
                },
                RecentOrders = orders.OrderByDescending(o => o.OrderDate).Take(5).ToList(),
                ActivityLog = activities.OrderByDescending(a => a.Timestamp).Take(5).ToList(),
                OrderCompletionRate = summary.TotalOrders > 0 ? (decimal)rand.Next(70, 100) : 0,
                PurchaseChartLabels = purchaseLabels,
                PurchaseChartOrderData = purchaseOrderData,
                PurchaseChartRevenueData = purchaseRevenueData
            };
        }
        #endregion
    }

    // Helper for diacritics removal
    public static class StringExtensions
    {
        public static string RemoveDiacritics(this string text)
        {
            if (string.IsNullOrWhiteSpace(text))
                return text;

            text = text.Normalize(System.Text.NormalizationForm.FormD);
            var chars = text.Where(c => CharUnicodeInfo.GetUnicodeCategory(c) != UnicodeCategory.NonSpacingMark).ToArray();
            return new string(chars).Normalize(System.Text.NormalizationForm.FormC);
        }
    }
}