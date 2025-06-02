using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data; // For DataTable if used for dummy data
using System.Globalization; // For number formatting

namespace WebsiteDoChoi.Admin
{
    public class RecentOrderInfo
    {
        public int OrderId { get; set; }
        public string OrderCode { get; set; }
        public string CustomerName { get; set; }
        public decimal TotalAmount { get; set; }
        public string Status { get; set; } // e.g., "completed", "processing", "shipped", "cancelled"
        public string StatusText { get; set; } // e.g., "Hoàn thành", "Đang xử lý"
    }

    public class AdminNotification
    {
        public string IconCss { get; set; } // e.g., "fas fa-shopping-cart text-primary text-sm"
        public string IconBgCss { get; set; } // e.g., "bg-primary bg-opacity-10"
        public string Message { get; set; }
        public string TimeAgo { get; set; }
    }


    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDashboardStats();
                LoadRecentOrders();
                LoadAdminNotifications();
                PopulateSalesYearDropdown();
                LoadSalesChartData(DateTime.Now.Year); // Load for current year initially
                LoadCategoryChartData();
            }
        }

        private void LoadDashboardStats()
        {
            // TODO: Fetch actual data from database
            lblTotalRevenue.Text = 125500000m.ToString("N0", CultureInfo.GetCultureInfo("vi-VN")) + " VNĐ";
            lblRevenueChange.Text = "+12.5% so với tháng trước";

            lblNewOrders.Text = "248";
            lblNewOrdersChange.Text = "+8.2% so với tuần trước";

            lblNewCustomers.Text = "1,847";
            lblNewCustomersChange.Text = "+15.3% so với tháng trước";

            lblBestSellingProductCount.Text = "573";
            lblBestSellingProductName.Text = "Robot biến hình";
        }

        private void PopulateSalesYearDropdown()
        {
            int currentYear = DateTime.Now.Year;
            for (int i = 0; i < 5; i++) // Show current year and 4 previous years
            {
                ddlSalesYear.Items.Add(new ListItem((currentYear - i).ToString(), (currentYear - i).ToString()));
            }
            ddlSalesYear.SelectedValue = currentYear.ToString();
        }


        private void LoadSalesChartData(int year)
        {
            // TODO: Fetch sales data for the selected year from database
            // Dummy data for demonstration
            var labels = new List<string> { "T1", "T2", "T3", "T4", "T5", "T6", "T7", "T8", "T9", "T10", "T11", "T12" };
            var data = new List<decimal>();
            Random rand = new Random();
            for (int i = 0; i < 12; i++)
            {
                data.Add(rand.Next(50, 200)); // Random sales data in millions
            }

            // Register script to render chart
            string script = $"renderSalesChart({SerializeToJson(labels)}, {SerializeToJson(data)});";
            ScriptManager.RegisterStartupScript(this, GetType(), "SalesChartScript", script, true);
        }

        protected void ddlSalesYear_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (int.TryParse(ddlSalesYear.SelectedValue, out int year))
            {
                LoadSalesChartData(year);
            }
        }


        private void LoadCategoryChartData()
        {
            // TODO: Fetch category sales data from database
            // Dummy data
            var labels = new List<string> { "Đồ chơi giáo dục", "Robot & Nhân vật", "Xe điều khiển", "Đồ chơi xây dựng", "Khác" };
            var data = new List<int> { 35, 25, 20, 15, 5 };

            string script = $"renderCategoryChart({SerializeToJson(labels)}, {SerializeToJson(data)});";
            ScriptManager.RegisterStartupScript(this, GetType(), "CategoryChartScript", script, true);
        }

        private void LoadRecentOrders()
        {
            // TODO: Fetch recent orders from database
            var orders = new List<RecentOrderInfo>
            {
                new RecentOrderInfo { OrderId = 1, OrderCode = "#ORD-001", CustomerName = "Nguyễn Văn A", TotalAmount = 1250000m, Status = "completed", StatusText = "Hoàn thành" },
                new RecentOrderInfo { OrderId = 2, OrderCode = "#ORD-002", CustomerName = "Trần Thị B", TotalAmount = 850000m, Status = "processing", StatusText = "Đang xử lý" },
                new RecentOrderInfo { OrderId = 3, OrderCode = "#ORD-003", CustomerName = "Lê Văn C", TotalAmount = 2150000m, Status = "shipped", StatusText = "Đang giao" },
                new RecentOrderInfo { OrderId = 4, OrderCode = "#ORD-004", CustomerName = "Phạm Thị D", TotalAmount = 675000m, Status = "cancelled", StatusText = "Đã hủy" }
            };
            gvRecentOrders.DataSource = orders;
            gvRecentOrders.DataBind();
        }

        protected string GetStatusCssClass(object statusObj)
        {
            string status = statusObj?.ToString().ToLower() ?? "";
            switch (status)
            {
                case "completed": return "px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800";
                case "processing": return "px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800";
                case "shipped": return "px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800";
                case "cancelled": return "px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800";
                default: return "px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800";
            }
        }

        private void LoadAdminNotifications()
        {
            var notifications = new List<AdminNotification>
            {
                new AdminNotification { IconCss = "fas fa-shopping-cart text-primary text-sm", IconBgCss="bg-primary bg-opacity-10", Message = "Đơn hàng mới từ Nguyễn Văn A", TimeAgo = "5 phút trước" },
                new AdminNotification { IconCss = "fas fa-star text-secondary text-sm", IconBgCss="bg-secondary bg-opacity-10", Message = "Đánh giá 5 sao cho Robot biến hình", TimeAgo = "10 phút trước" },
                new AdminNotification { IconCss = "fas fa-exclamation-triangle text-accent text-sm", IconBgCss="bg-accent bg-opacity-10", Message = "Sản phẩm 'Xe đua RC' sắp hết hàng", TimeAgo = "1 giờ trước" }
            };
            rptAdminNotifications.DataSource = notifications;
            rptAdminNotifications.DataBind();
        }


        // Helper to serialize C# objects to JSON for JavaScript
        private string SerializeToJson(object obj)
        {
            var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            return serializer.Serialize(obj);
        }
    }
}