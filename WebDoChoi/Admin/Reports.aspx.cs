using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
// using iTextSharp.text; // For PDF, if you choose iTextSharp
// using iTextSharp.text.pdf;
// using System.IO;

namespace WebsiteDoChoi.Admin
{
    public class ChartData
    {
        public List<string> Labels { get; set; }
        public List<decimal> Data { get; set; } // For single dataset charts
        public List<List<decimal>> MultiData { get; set; } // For multi-dataset charts like revenue+orders
    }

    public class TopProductReportItem
    {
        public string ProductName { get; set; }
        public int UnitsSold { get; set; }
        public decimal TotalRevenue { get; set; }
        public string TrendCssClass { get; set; } // e.g., "text-green-600" or "text-red-600"
        public string TrendIconCss { get; set; } // "fas fa-arrow-up" or "fas fa-arrow-down"
        public string RankCssClass { get; set; } // For styling rank number background
    }

    public class InventoryReportItem
    {
        public string ProductName { get; set; }
        public string SKU { get; set; }
        public int StockQuantity { get; set; }
        public int LowStockThreshold { get; set; } // Used by helper
    }


    public partial class Reports : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Set default date range (e.g., this month)
                txtStartDate.Text = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1).ToString("yyyy-MM-dd");
                txtEndDate.Text = DateTime.Now.ToString("yyyy-MM-dd");

                PopulateTimeframeDropdown();
                LoadAllReportData();
            }
        }

        private void PopulateTimeframeDropdown()
        {
            if (ddlRevenueTimeframe.Items.Count == 0) // Prevent re-populating on postbacks if ViewState is off
            {
                ddlRevenueTimeframe.Items.Add(new ListItem("7 ngày qua", "7days"));
                ddlRevenueTimeframe.Items.Add(new ListItem("30 ngày qua", "30days"));
                ddlRevenueTimeframe.Items.Add(new ListItem("3 tháng qua", "3months"));
                ddlRevenueTimeframe.Items.Add(new ListItem("12 tháng qua", "12months"));
                ddlRevenueTimeframe.SelectedValue = "30days";
            }
        }


        protected void btnUpdateReports_Click(object sender, EventArgs e)
        {
            LoadAllReportData();
            // ShowAdminNotification("Báo cáo đã được cập nhật theo khoảng thời gian đã chọn.", "success");
        }

        protected void ddlRevenueTimeframe_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadRevenueChartData(); // Only reload this specific chart
                                    // To ensure other parts of the page remain, especially if not in an UpdatePanel or if UpdateMode is Conditional
                                    // upnlReports.Update(); // If revenue chart is inside an UpdatePanel
        }


        private void LoadAllReportData()
        {
            DateTime startDate, endDate;
            if (!DateTime.TryParse(txtStartDate.Text, out startDate) || !DateTime.TryParse(txtEndDate.Text, out endDate))
            {
                // Handle invalid date format, perhaps default to a range or show error
                startDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
                endDate = DateTime.Now;
                ShowAdminNotification("Định dạng ngày không hợp lệ. Sử dụng phạm vi mặc định.", "warning");
            }
            if (startDate > endDate)
            {
                ShowAdminNotification("Ngày bắt đầu không thể lớn hơn ngày kết thúc.", "error");
                return; // Stop further processing
            }

            LoadStatsCardsData(startDate, endDate);
            LoadRevenueChartData(startDate, endDate, ddlRevenueTimeframe.SelectedValue);
            LoadRevenueBreakdownData(startDate, endDate);
            LoadOrderStatusChartData(startDate, endDate);
            LoadTopProductsData(startDate, endDate);
            LoadCustomerDemographicsChartData(startDate, endDate); // For main customer chart
            // Geographic Sales - This requires a different kind of data (map data or region names)
            LoadPerformanceMetricsData(startDate, endDate);
            LoadRecentOrdersReport(startDate, endDate);
            LoadInventoryReport();
        }

        private void LoadStatsCardsData(DateTime startDate, DateTime endDate)
        {
            // TODO: Fetch data for stat cards from DB based on date range
            lblTotalRevenue.Text = (156800000m * (decimal)(endDate - startDate).TotalDays / 30).ToString("N0", CultureInfo.GetCultureInfo("vi-VN")) + " VNĐ";
            lblRevenueTrend.Text = "+18.5%"; lblRevenueTrend.CssClass = "metric-trend-admin up";
            lblCompletedOrders.Text = (1247 * (endDate - startDate).TotalDays / 30).ToString("N0");
            lblCompletedOrdersTrend.Text = "+12.3%"; lblCompletedOrdersTrend.CssClass = "metric-trend-admin up";
            lblNewCustomersReport.Text = (387 * (endDate - startDate).TotalDays / 30).ToString("N0");
            lblNewCustomersTrend.Text = "+25.7%"; lblNewCustomersTrend.CssClass = "metric-trend-admin up";
            lblConversionRate.Text = "3.2%";
            lblConversionRateTrend.Text = "-2.1%"; lblConversionRateTrend.CssClass = "metric-trend-admin down";
        }
        private void LoadRevenueChartData() // Overload for DDL change
        {
            DateTime startDate, endDate;
            DateTime.TryParse(txtStartDate.Text, out startDate);
            DateTime.TryParse(txtEndDate.Text, out endDate);
            LoadRevenueChartData(startDate, endDate, ddlRevenueTimeframe.SelectedValue);
        }

        private void LoadRevenueChartData(DateTime startDate, DateTime endDate, string timeframe)
        {
            // TODO: Fetch actual revenue and order count data based on timeframe and date range
            var labels = new List<string>();
            var revenueValues = new List<decimal>();
            var orderValues = new List<int>();
            Random rand = new Random();
            int numPoints = 7; // Default for 7days or if timeframe is not parsed

            if (timeframe == "30days") numPoints = 30;
            else if (timeframe == "3months") numPoints = 12; // Weeks
            else if (timeframe == "12months") numPoints = 12; // Months

            for (int i = 0; i < numPoints; i++)
            {
                if (timeframe == "7days" || timeframe == "30days") labels.Add(startDate.AddDays(i * ((endDate - startDate).TotalDays / numPoints)).ToString("dd/MM"));
                else if (timeframe == "3months") labels.Add($"Tuần {i + 1}");
                else if (timeframe == "12months") labels.Add(startDate.AddMonths(i).ToString("MMM yy"));

                revenueValues.Add(rand.Next(10, 80)); // In Millions
                orderValues.Add(rand.Next(20, 150));
            }

            string script = $"renderAdminRevenueChart({SerializeToJson(labels)}, {SerializeToJson(revenueValues)}, {SerializeToJson(orderValues)});";
            ScriptManager.RegisterStartupScript(this.upnlReports, this.GetType(), "AdminRevenueChartScript", script, true);
        }

        private void LoadRevenueBreakdownData(DateTime startDate, DateTime endDate)
        {
            // TODO: Fetch revenue breakdown from DB
            var breakdown = new List<object> {
                new { SourceName = "Doanh thu từ sản phẩm", Amount = 142300000m, Percentage = 85, ProgressBarCss = "bg-primary" },
                new { SourceName = "Phí vận chuyển", Amount = 12800000m, Percentage = 10, ProgressBarCss = "bg-secondary"  },
                new { SourceName = "Thuế VAT (ước tính)", Amount = 1700000m, Percentage = 5, ProgressBarCss = "bg-accent"  }
            };
            rptRevenueBreakdown.DataSource = breakdown;
            rptRevenueBreakdown.DataBind();
            lblTotalRevenueBreakdown.Text = breakdown.Sum(b => (decimal)((dynamic)b).Amount).ToString("N0", CultureInfo.GetCultureInfo("vi-VN")) + " VNĐ";
        }


        private void LoadOrderStatusChartData(DateTime startDate, DateTime endDate)
        {
            // TODO: Fetch order status counts from DB based on date range
            var labels = new List<string> { "Hoàn thành", "Đang xử lý", "Đang giao", "Chờ xác nhận", "Đã hủy" };
            var data = new List<int> { 650, 150, 120, 50, 30 }; // Example counts
            // Calculate percentages
            double total = data.Sum();
            var percentages = data.Select(d => Math.Round((d / total) * 100, 1)).ToList();

            string script = $"renderAdminOrderStatusChart({SerializeToJson(labels)}, {SerializeToJson(percentages)});"; // Send percentages
            ScriptManager.RegisterStartupScript(this.upnlReports, this.GetType(), "AdminOrderStatusChartScript", script, true);
        }

        private void LoadTopProductsData(DateTime startDate, DateTime endDate)
        {
            // TODO: Fetch top products from DB
            var topProducts = new List<TopProductReportItem> {
                new TopProductReportItem { ProductName="Robot biến hình thông minh", UnitsSold=573, TotalRevenue=25800000m, TrendCssClass="text-green-600", TrendIconCss="fas fa-arrow-up", RankCssClass="bg-primary bg-opacity-10 text-primary"},
                new TopProductReportItem { ProductName="Bộ xếp hình LEGO City", UnitsSold=412, TotalRevenue=18400000m, TrendCssClass="text-green-600", TrendIconCss="fas fa-arrow-up", RankCssClass="bg-secondary bg-opacity-10 text-secondary"},
                new TopProductReportItem { ProductName="Xe điều khiển địa hình", UnitsSold=298, TotalRevenue=15500000m, TrendCssClass="text-green-600", TrendIconCss="fas fa-arrow-up", RankCssClass="bg-accent bg-opacity-10 text-accent"},
                new TopProductReportItem { ProductName="Đồ chơi học toán", UnitsSold=245, TotalRevenue=9800000m, TrendCssClass="text-red-600", TrendIconCss="fas fa-arrow-down", RankCssClass="bg-gray-100 text-gray-600"},
                new TopProductReportItem { ProductName="Búp bê thông minh", UnitsSold=187, TotalRevenue=6500000m, TrendCssClass="text-green-600", TrendIconCss="fas fa-arrow-up", RankCssClass="bg-gray-100 text-gray-600"}
            };
            rptTopProducts.DataSource = topProducts;
            rptTopProducts.DataBind();
        }

        private void LoadCustomerDemographicsChartData(DateTime startDate, DateTime endDate)
        {
            // TODO: Fetch customer demographics data (e.g., age groups)
            var labels = new List<string> { "18-25 tuổi", "26-35 tuổi", "36-45 tuổi", "46+ tuổi", "Không rõ" };
            var data = new List<int> { 30, 35, 20, 10, 5 }; // Percentages
            string script = $"renderAdminCustomerDemographicsChart({SerializeToJson(labels)}, {SerializeToJson(data)});";
            ScriptManager.RegisterStartupScript(this.upnlReports, this.GetType(), "AdminCustomerDemographicsChartScript", script, true);
        }

        // Placeholder for Geographic Sales Data - this is complex and usually involves maps or more detailed region data.
        // For Performance Metrics, data would be calculated from various sources.
        private void LoadPerformanceMetricsData(DateTime startDate, DateTime endDate)
        {
            // Example: These would be calculated values
            // avgOrderValueLabel.Text = "1.25M VNĐ"; avgOrderValueTrendLabel.Text = "+8.2%";
        }

        private void LoadRecentOrdersReport(DateTime startDate, DateTime endDate)
        {
            // TODO: Fetch recent orders
            var orders = GetDummyAdminOrders().Take(5).ToList(); // Use the dummy data from Orders.aspx.cs for now
            gvRecentOrdersReport.DataSource = orders;
            gvRecentOrdersReport.DataBind();
        }
        private void LoadInventoryReport()
        {
            // TODO: Fetch inventory data
            var inventory = new List<InventoryReportItem> {
                new InventoryReportItem {ProductName="Robot biến hình", SKU="RBT001", StockQuantity=25, LowStockThreshold=10},
                new InventoryReportItem {ProductName="Xe đua RC", SKU="RC001", StockQuantity=3, LowStockThreshold=5},
                new InventoryReportItem {ProductName="LEGO City", SKU="LEGO001", StockQuantity=15, LowStockThreshold=5},
                new InventoryReportItem {ProductName="Búp bê thông minh", SKU="DOLL001", StockQuantity=0, LowStockThreshold=3},
                new InventoryReportItem {ProductName="Đồ chơi học toán", SKU="EDU001", StockQuantity=8, LowStockThreshold=10}
            };
            gvInventoryReport.DataSource = inventory;
            gvInventoryReport.DataBind();
        }
        protected string GetInventoryStatusText(int stock, int threshold)
        {
            if (stock <= 0) return "Hết hàng";
            if (stock <= threshold) return "Sắp hết";
            return "Đủ hàng";
        }
        protected string GetInventoryStatusCssClass(int stock, int threshold)
        {
            if (stock <= 0) return "bg-gray-100 text-gray-800";
            if (stock <= threshold) return "bg-yellow-100 text-yellow-800";
            return "bg-green-100 text-green-800";
        }
        protected string GetStatusReportCssClass(object statusObj)
        { // Slightly different from Orders page for direct use
            string status = statusObj?.ToString().ToLower() ?? "";
            switch (status)
            {
                case "completed": case "delivered": return "bg-green-100 text-green-800";
                case "processing": case "confirmed": return "bg-yellow-100 text-yellow-800";
                case "shipped": return "bg-blue-100 text-blue-800";
                case "pending": return "bg-orange-100 text-orange-800"; // Assuming orange for pending
                case "cancelled": case "returned": return "bg-red-100 text-red-800";
                default: return "bg-gray-100 text-gray-800";
            }
        }



        protected void btnExportExcelReports_Click(object sender, EventArgs e)
        {
          
        }

        protected void btnExportPdfReports_Click(object sender, EventArgs e)
        {
            // PDF Export is more complex. Requires libraries like iTextSharp or Rotativa (HTML to PDF).
            // Basic idea:
            // 1. Create an HTML string or UserControl representing the report.
            // 2. Use a library to convert this HTML to PDF.
            // 3. Stream the PDF to the client.
            ShowAdminNotification("Chức năng xuất PDF đang được phát triển.", "warning");
        }

        private void ShowAdminNotification(string message, string type = "info")
        {
            ScriptManager.RegisterStartupScript(this.upnlReports, this.GetType(), Guid.NewGuid().ToString(), $"showNotification('{message.Replace("'", "\\\'")}', '{type}');", true);
        }
        private string SerializeToJson(object obj) => new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(obj);

        #region Dummy Data (Re-use or adapt from other Admin pages)
        private List<AdminOrderSummary> GetDummyAdminOrders() => new Orders().GetPublicDummyOrders();
        // You might need to make GetDummyAdminOrders in Orders.aspx.cs public or internal and accessible
        #endregion
    }

    // Add this to Orders.aspx.cs or a shared utility class
    public partial class Orders
    {
        public List<AdminOrderSummary> GetPublicDummyOrders()
        {
            var orders = new List<AdminOrderSummary>();
            string[] customers = { "Nguyễn Văn A", "Trần Thị B", "Lê Văn C", "Phạm Thị D", "Hoàng Văn E" };
            string[] statuses = { "pending", "confirmed", "processing", "shipped", "delivered", "cancelled", "returned" };
            string[] statusTexts = { "Chờ xử lý", "Đã xác nhận", "Đang xử lý", "Đã gửi hàng", "Đã giao hàng", "Đã hủy", "Đã trả lại" };
            string[] paymentMethods = { "Tiền mặt", "Chuyển khoản", "MoMo", "ZaloPay", "Thẻ tín dụng" };
            string[] paymentStatuses = { "Đã thanh toán", "Chưa thanh toán", "Chờ xác nhận TT" };
            Random rand = new Random();
            for (int i = 1; i <= 10; i++) // Just 10 for this table
            {
                int statusIndex = rand.Next(statuses.Length);
                orders.Add(new AdminOrderSummary
                {
                    OrderId = i,
                    OrderCode = $"#TL{DateTime.Now.Year}{i:D5}",
                    OrderDate = DateTime.Now.AddDays(-rand.Next(1, 10)).AddHours(-rand.Next(0, 23)),
                    CustomerName = customers[rand.Next(customers.Length)],
                    CustomerPhone = $"09{rand.Next(10000000, 99999999)}",
                    ProductSummary = $"Sản phẩm {rand.Next(1, 5)}",
                    TotalItems = rand.Next(1, 3),
                    TotalAmount = rand.Next(200, 2000) * 1000m,
                    PaymentMethod = paymentMethods[rand.Next(paymentMethods.Length)],
                    PaymentStatus = paymentStatuses[rand.Next(paymentStatuses.Length)],
                    Status = statuses[statusIndex],
                    StatusText = statusTexts[statusIndex]
                });
            }
            return orders.OrderByDescending(o => o.OrderDate).ToList();
        }
    }
}