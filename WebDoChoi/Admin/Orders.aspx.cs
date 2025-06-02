using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO; // For Excel export (using a library like EPPlus would be better)


namespace WebsiteDoChoi.Admin
{
    public class AdminOrderSummary
    {
        public int OrderId { get; set; }
        public string OrderCode { get; set; }
        public DateTime OrderDate { get; set; }
        public string CustomerName { get; set; }
        public string CustomerPhone { get; set; }
        public string ProductSummary { get; set; } // e.g., "Product A + 2 more"
        public int TotalItems { get; set; }
        public decimal TotalAmount { get; set; }
        public string PaymentMethod { get; set; }
        public string PaymentStatus { get; set; } // e.g., "Đã thanh toán", "Chưa thanh toán"
        public string Status { get; set; } // e.g., "pending", "delivered"
        public string StatusText { get; set; } // e.g., "Chờ xử lý", "Đã giao"
    }

    public class AdminOrderDetail : AdminOrderSummary // Inherit or compose
    {
        public string CustomerEmail { get; set; }
        public string ShippingAddress { get; set; }
        public string OrderNotes { get; set; }
        public List<AdminOrderItemDetail> Items { get; set; }
        public List<AdminOrderStatusHistory> StatusHistory { get; set; }
        public decimal Subtotal { get; set; }
        public decimal ShippingFee { get; set; }
        public decimal DiscountAmount { get; set; }
    }

    public class AdminOrderItemDetail
    {
        public int ProductId { get; set; }
        public string ProductName { get; set; }
        public string SKU { get; set; }
        public string ImageUrl { get; set; }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal TotalPrice => Quantity * UnitPrice;
    }

    public class AdminOrderStatusHistory
    {
        public string StatusName { get; set; }
        public DateTime StatusDate { get; set; }
        public string Notes { get; set; } // Optional notes for status change
        public string CssClass { get; set; } // e.g., "completed", "current" for timeline dot
    }


    public partial class Orders : System.Web.UI.Page
    {
        private const int OrdersPageSize = 10; // Number of orders per page

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ViewState["CurrentOrderPage"] = 1;
                PopulateFilterDropdowns();
                BindOrders();
                LoadStatsCards();
            }
        }

        private void PopulateFilterDropdowns()
        {
            // Status Filter
            ddlStatusFilter.Items.Clear();
            ddlStatusFilter.Items.Add(new ListItem("Tất cả trạng thái", ""));
            ddlStatusFilter.Items.Add(new ListItem("Chờ xử lý", "pending"));
            ddlStatusFilter.Items.Add(new ListItem("Đã xác nhận", "confirmed"));
            ddlStatusFilter.Items.Add(new ListItem("Đang xử lý", "processing"));
            ddlStatusFilter.Items.Add(new ListItem("Đã gửi hàng", "shipped"));
            ddlStatusFilter.Items.Add(new ListItem("Đã giao hàng", "delivered"));
            ddlStatusFilter.Items.Add(new ListItem("Đã hủy", "cancelled"));
            ddlStatusFilter.Items.Add(new ListItem("Đã trả lại", "returned"));

            // Payment Filter
            ddlPaymentFilter.Items.Clear();
            ddlPaymentFilter.Items.Add(new ListItem("PT Thanh toán", ""));
            ddlPaymentFilter.Items.Add(new ListItem("Tiền mặt (COD)", "cod"));
            ddlPaymentFilter.Items.Add(new ListItem("Chuyển khoản", "bank"));
            ddlPaymentFilter.Items.Add(new ListItem("MoMo", "momo"));
            ddlPaymentFilter.Items.Add(new ListItem("ZaloPay", "zalopay"));
            ddlPaymentFilter.Items.Add(new ListItem("Thẻ tín dụng", "credit"));

            // Status update dropdowns (in repeater and modal)
            var statusOptions = ddlStatusFilter.Items.Cast<ListItem>().Where(li => !string.IsNullOrEmpty(li.Value)).ToList();
            ddlModalUpdateStatus.Items.Clear();
            ddlModalUpdateStatus.Items.Add(new ListItem("-- Cập nhật TT --", ""));
            foreach (var item in statusOptions)
            {
                ddlModalUpdateStatus.Items.Add(new ListItem(item.Text, item.Value));
            }
            // Note: For the DropDownList in the Repeater, you'd populate it during rptOrders_ItemDataBound
        }

        protected void rptOrders_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DropDownList ddlStatus = (DropDownList)e.Item.FindControl("ddlUpdateStatus");
                if (ddlStatus != null)
                {
                    // Populate with statuses, similar to ddlStatusFilter
                    ddlStatus.Items.Clear();
                    ddlStatus.Items.Add(new ListItem("-- Cập nhật --", ""));
                    ddlStatus.Items.Add(new ListItem("Chờ xử lý", "pending"));
                    ddlStatus.Items.Add(new ListItem("Đã xác nhận", "confirmed"));
                    ddlStatus.Items.Add(new ListItem("Đang xử lý", "processing"));
                    ddlStatus.Items.Add(new ListItem("Đã gửi hàng", "shipped"));
                    ddlStatus.Items.Add(new ListItem("Đã giao hàng", "delivered"));
                    ddlStatus.Items.Add(new ListItem("Đã hủy", "cancelled"));
                    // Set selected value based on current order status if needed
                    // AdminOrderSummary order = (AdminOrderSummary)e.Item.DataItem;
                    // ddlStatus.SelectedValue = order.Status; 
                }
            }
        }


        private void LoadStatsCards()
        {
            // TODO: Fetch actual stats from DB
            lblTotalOrders.Text = "1,247";
            lblTotalOrdersChange.Text = "+8.2%";
            lblPendingOrders.Text = "23";
            lblShippedOrders.Text = "45";
            lblTodayRevenue.Text = 12500000m.ToString("N0", CultureInfo.GetCultureInfo("vi-VN")) + " VNĐ";
            lblTodayRevenueChange.Text = "+15.3%";
        }

        private void BindOrders()
        {
            int currentPage = Convert.ToInt32(ViewState["CurrentOrderPage"]);
            string searchTerm = txtSearchOrders.Text.Trim();
            string statusFilter = ddlStatusFilter.SelectedValue;
            string paymentFilter = ddlPaymentFilter.SelectedValue;
            DateTime? dateFilter = null;
            if (!string.IsNullOrEmpty(txtDateFilter.Text))
            {
                if (DateTime.TryParse(txtDateFilter.Text, out DateTime parsedDate))
                {
                    dateFilter = parsedDate;
                }
            }

            // TODO: Fetch orders from DB with filtering & pagination
            List<AdminOrderSummary> allOrders = GetDummyAdminOrders();

            // Apply Filters
            if (!string.IsNullOrEmpty(searchTerm))
                allOrders = allOrders.Where(o => o.OrderCode.ToLower().Contains(searchTerm.ToLower()) || o.CustomerName.ToLower().Contains(searchTerm.ToLower())).ToList();
            if (!string.IsNullOrEmpty(statusFilter))
                allOrders = allOrders.Where(o => o.Status == statusFilter).ToList();
            if (!string.IsNullOrEmpty(paymentFilter))
                allOrders = allOrders.Where(o => o.PaymentMethod.ToLower().Replace(" ", "") == paymentFilter.ToLower()).ToList();
            if (dateFilter.HasValue)
                allOrders = allOrders.Where(o => o.OrderDate.Date == dateFilter.Value.Date).ToList();


            int totalOrders = allOrders.Count;
            var pagedOrders = allOrders.Skip((currentPage - 1) * OrdersPageSize).Take(OrdersPageSize).ToList();

            rptOrders.DataSource = pagedOrders;
            rptOrders.DataBind();

            SetupOrderPagination(totalOrders, currentPage);
            lblOrderPageInfo.Text = $"Hiển thị {(currentPage - 1) * OrdersPageSize + 1}-{Math.Min(currentPage * OrdersPageSize, totalOrders)} trong tổng số {totalOrders} đơn hàng";
        }

        #region Pagination for Orders
        private void SetupOrderPagination(int totalItems, int currentPage)
        {
            int totalPages = (int)Math.Ceiling((double)totalItems / OrdersPageSize);
            lnkOrderPrevPage.Enabled = currentPage > 1;
            lnkOrderNextPage.Enabled = currentPage < totalPages;

            if (totalPages <= 1)
            {
                rptOrderPager.Visible = false;
                lnkOrderPrevPage.Visible = false;
                lnkOrderNextPage.Visible = false;
                lblOrderPageInfo.Visible = totalItems > 0;
                return;
            }
            rptOrderPager.Visible = true;
            lnkOrderPrevPage.Visible = true;
            lnkOrderNextPage.Visible = true;
            lblOrderPageInfo.Visible = true;

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

            rptOrderPager.DataSource = pageNumbers;
            rptOrderPager.DataBind();
        }

        protected void OrderPage_Changed(object sender, EventArgs e)
        {
            string commandArgument = ((LinkButton)sender).CommandArgument;
            int currentPage = Convert.ToInt32(ViewState["CurrentOrderPage"]);
            // Recalculate totalPages based on current filters if necessary, or get from a ViewState
            var filteredOrders = GetDummyAdminOrders(); // Apply filters again before getting count
            // Apply filters to filteredOrders based on ViewState or control values...
            int totalPages = (int)Math.Ceiling((double)filteredOrders.Count / OrdersPageSize);


            if (commandArgument == "Prev") { currentPage = Math.Max(1, currentPage - 1); }
            else if (commandArgument == "Next") { currentPage = Math.Min(totalPages, currentPage + 1); }
            else { currentPage = Convert.ToInt32(commandArgument); }

            ViewState["CurrentOrderPage"] = currentPage;
            BindOrders();
        }
        #endregion

        protected void btnApplyOrderFilters_Click(object sender, EventArgs e)
        {
            ViewState["CurrentOrderPage"] = 1;
            BindOrders();
        }

        protected void btnResetOrderFilters_Click(object sender, EventArgs e)
        {
            txtSearchOrders.Text = "";
            ddlStatusFilter.ClearSelection();
            ddlPaymentFilter.ClearSelection();
            txtDateFilter.Text = "";
            ViewState["CurrentOrderPage"] = 1;
            BindOrders();
            ShowAdminNotification("Đã reset tất cả bộ lọc.", "info");
        }

        protected void rptOrders_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int orderId = Convert.ToInt32(e.CommandArgument);
            if (e.CommandName == "ViewDetails")
            {
                LoadOrderDetailModal(orderId);
            }
            else if (e.CommandName == "PrintOrder")
            {
                // For card print, you might load data and then trigger client-side print for that specific card's data (more complex)
                // Or simply open the modal and use the modal's print function
                LoadOrderDetailModal(orderId); // Load data into modal first
                ScriptManager.RegisterStartupScript(this, GetType(), "PrintOrderModal", "printOrderDetailFromModal();", true);
            }
        }

        protected void ddlUpdateStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            DropDownList ddl = (DropDownList)sender;
            string newStatus = ddl.SelectedValue;
        }


        #region Order Detail Modal
        private void LoadOrderDetailModal(int orderId)
        {
            // TODO: Fetch full order details by ID from database
            AdminOrderDetail orderDetail = GetDummyOrderDetail(orderId);
            if (orderDetail == null)
            {
                ShowAdminNotification("Không tìm thấy chi tiết đơn hàng.", "error");
                return;
            }

            lblModalOrderId.Text = orderDetail.OrderCode;
            // Customer Info
            lblModalCustomerName.Text = orderDetail.CustomerName;
            lblModalCustomerPhone.Text = orderDetail.CustomerPhone;
            lblModalCustomerEmail.Text = orderDetail.CustomerEmail;
            lblModalShippingAddress.Text = orderDetail.ShippingAddress;
            lblModalOrderNotes.Text = string.IsNullOrEmpty(orderDetail.OrderNotes) ? "Không có" : orderDetail.OrderNotes;

            // Order Items
            rptModalOrderItems.DataSource = orderDetail.Items;
            rptModalOrderItems.DataBind();

            // Payment Summary
            lblModalSubtotal.Text = orderDetail.Subtotal.ToString("N0", CultureInfo.GetCultureInfo("vi-VN")) + "đ";
            lblModalShippingFee.Text = orderDetail.ShippingFee.ToString("N0", CultureInfo.GetCultureInfo("vi-VN")) + "đ";
            lblModalDiscount.Text = orderDetail.DiscountAmount > 0 ? $"-{orderDetail.DiscountAmount.ToString("N0", CultureInfo.GetCultureInfo("vi-VN"))}đ" : "0đ";
            lblModalDiscount.CssClass = orderDetail.DiscountAmount > 0 ? "font-medium text-red-500" : "font-medium";
            lblModalTotalAmount.Text = orderDetail.TotalAmount.ToString("N0", CultureInfo.GetCultureInfo("vi-VN")) + "đ";

            lblModalPaymentMethod.Text = orderDetail.PaymentMethod;
            lblModalPaymentStatus.Text = orderDetail.PaymentStatus;
            if (orderDetail.PaymentStatus == "Đã thanh toán")
            {
                lblModalPaymentStatus.CssClass = "bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs";
            }
            else
            {
                lblModalPaymentStatus.CssClass = "bg-orange-100 text-orange-800 px-2 py-1 rounded-full text-xs";
            }


            // Order Status Timeline
            rptOrderStatusTimeline.DataSource = orderDetail.StatusHistory;
            rptOrderStatusTimeline.DataBind();

            // Status Update Dropdown in Modal
            ddlModalUpdateStatus.ClearSelection();
            var currentStatusItem = ddlModalUpdateStatus.Items.FindByValue(orderDetail.Status);
            if (currentStatusItem != null) currentStatusItem.Selected = true;
            ViewState["CurrentModalOrderId"] = orderId;


            pnlOrderDetailModal.Visible = true;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "OpenOrderDetailModal", "document.body.style.overflow = 'hidden'; setupModalClose();", true);
        }

        protected void btnCloseOrderDetailModal_Click(object sender, EventArgs e)
        {
            pnlOrderDetailModal.Visible = false;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CloseOrderDetailModal", "document.body.style.overflow = 'auto';", true);
        }

        protected void btnModalUpdateStatus_Click(object sender, EventArgs e)
        {
            if (ViewState["CurrentModalOrderId"] != null && int.TryParse(ViewState["CurrentModalOrderId"].ToString(), out int orderId))
            {
                string newStatus = ddlModalUpdateStatus.SelectedValue;
                if (!string.IsNullOrEmpty(newStatus))
                {
                    // TODO: Update order status in database for orderId
                    // UpdateOrderStatusInDB(orderId, newStatus);
                    ShowAdminNotification($"Đã cập nhật trạng thái đơn hàng #{orderId} thành '{ddlModalUpdateStatus.SelectedItem.Text}'.", "success");

                    // Refresh data in modal (or just the status parts) and the main list
                    LoadOrderDetailModal(orderId); // Reload modal with updated status
                    BindOrders(); // Refresh the main order list

                    // Keep modal open with updated info
                    pnlOrderDetailModal.Visible = true;
                    ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ReOpenModalScript", "document.body.style.overflow = 'hidden'; setupModalClose();", true);

                }
                else
                {
                    ShowAdminNotification("Vui lòng chọn một trạng thái để cập nhật.", "warning");
                    pnlOrderDetailModal.Visible = true; // Keep modal open
                    ScriptManager.RegisterStartupScript(Page, Page.GetType(), "KeepModalOpenWarning", "document.body.style.overflow = 'hidden'; setupModalClose();", true);
                }
            }
        }

        #endregion

        protected void btnExportExcel_Click(object sender, EventArgs e)
        {
            // TODO: Fetch all orders (or filtered ones) for export
            List<AdminOrderSummary> ordersToExport = GetDummyAdminOrders(); // Get all or filtered

            // Using EPPlus for Excel export (add NuGet package OfficeOpenXml.Core.ExcelPackage)
            // Or use older Microsoft.Office.Interop.Excel (requires Excel installed on server, not recommended for web)
            // Or generate CSV directly

           
        }

        protected string GetStatusCssClass(object statusObj)
        {
            string status = statusObj?.ToString().ToLower() ?? "";
            switch (status)
            {
                case "pending": return "status-badge status-pending";
                case "confirmed": return "status-badge status-confirmed";
                case "processing": return "status-badge status-processing";
                case "shipped": return "status-badge status-shipped";
                case "delivered": return "status-badge status-delivered";
                case "cancelled": return "status-badge status-cancelled";
                case "returned": return "status-badge status-returned";
                default: return "status-badge status-default";
            }
        }

        private void ShowAdminNotification(string message, string type = "info")
        {
            // This could be a placeholder on Admin.Master or a dynamically added control
            // For now, using client-side alert as a simple feedback
            ScriptManager.RegisterStartupScript(this, GetType(), "AdminOrderNotification", $"alert('{message.Replace("'", "\\\'")}');", true);
            // Or use your existing showNotification JS function:
            // ScriptManager.RegisterStartupScript(this, GetType(), "AdminOrderNotification", $"showNotification('{message.Replace("'", "\\\'")}', '{type}');", true);
        }

        #region Dummy Data Generators
        private List<AdminOrderSummary> GetDummyAdminOrders()
        {
            var orders = new List<AdminOrderSummary>();
            string[] customers = { "Nguyễn Văn A", "Trần Thị B", "Lê Văn C", "Phạm Thị D", "Hoàng Văn E" };
            string[] statuses = { "pending", "confirmed", "processing", "shipped", "delivered", "cancelled", "returned" };
            string[] statusTexts = { "Chờ xử lý", "Đã xác nhận", "Đang xử lý", "Đã gửi hàng", "Đã giao hàng", "Đã hủy", "Đã trả lại" };
            string[] paymentMethods = { "Tiền mặt", "Chuyển khoản", "MoMo", "ZaloPay", "Thẻ tín dụng" };
            string[] paymentStatuses = { "Đã thanh toán", "Chưa thanh toán", "Chờ xác nhận TT" };

            Random rand = new Random();
            for (int i = 1; i <= 50; i++)
            {
                int statusIndex = rand.Next(statuses.Length);
                orders.Add(new AdminOrderSummary
                {
                    OrderId = i,
                    OrderCode = $"#TL{DateTime.Now.Year}{i:D5}",
                    OrderDate = DateTime.Now.AddDays(-rand.Next(1, 60)).AddHours(-rand.Next(0, 23)),
                    CustomerName = customers[rand.Next(customers.Length)],
                    CustomerPhone = $"09{rand.Next(10000000, 99999999)}",
                    ProductSummary = $"Sản phẩm {rand.Next(1, 5)} + {rand.Next(0, 3)} SP khác",
                    TotalItems = rand.Next(1, 5),
                    TotalAmount = rand.Next(200, 5000) * 1000m,
                    PaymentMethod = paymentMethods[rand.Next(paymentMethods.Length)],
                    PaymentStatus = paymentStatuses[rand.Next(paymentStatuses.Length)],
                    Status = statuses[statusIndex],
                    StatusText = statusTexts[statusIndex]
                });
            }
            return orders.OrderByDescending(o => o.OrderDate).ToList();
        }

        private AdminOrderDetail GetDummyOrderDetail(int orderId)
        {
            var summary = GetDummyAdminOrders().FirstOrDefault(o => o.OrderId == orderId);
            if (summary == null) return null;

            var items = new List<AdminOrderItemDetail>();
            for (int i = 0; i < summary.TotalItems; i++)
            {
                items.Add(new AdminOrderItemDetail
                {
                    ProductId = 100 + i,
                    ProductName = $"Chi tiết sản phẩm {i + 1} cho ĐH {orderId}",
                    SKU = $"SKU-{orderId}-{i + 1}",
                    ImageUrl = $"https://api.placeholder.com/80/80?text=P{i + 1}",
                    Quantity = rand.Next(1, 3),
                    UnitPrice = rand.Next(50, 800) * 1000m
                });
            }
            // Ensure total amount roughly matches sum of items for demo
            decimal calculatedSubtotal = items.Sum(it => it.TotalPrice);
            decimal shipping = 30000m;
            decimal discount = (calculatedSubtotal + shipping) > summary.TotalAmount ? (calculatedSubtotal + shipping - summary.TotalAmount) : 0;


            var history = new List<AdminOrderStatusHistory> {
                new AdminOrderStatusHistory { StatusName="Đặt hàng thành công", StatusDate=summary.OrderDate, Notes="Khách hàng đặt qua website.", CssClass="completed"},
            };
            if (Array.IndexOf(new[] { "confirmed", "processing", "shipped", "delivered" }, summary.Status) >= 0)
                history.Add(new AdminOrderStatusHistory { StatusName = "Đã xác nhận", StatusDate = summary.OrderDate.AddHours(1), Notes = "Hệ thống tự động xác nhận.", CssClass = "completed" });
            if (Array.IndexOf(new[] { "processing", "shipped", "delivered" }, summary.Status) >= 0)
                history.Add(new AdminOrderStatusHistory { StatusName = "Đang xử lý", StatusDate = summary.OrderDate.AddHours(3), Notes = "Kho đang chuẩn bị hàng.", CssClass = "completed" });
            if (Array.IndexOf(new[] { "shipped", "delivered" }, summary.Status) >= 0)
                history.Add(new AdminOrderStatusHistory { StatusName = "Đã gửi hàng", StatusDate = summary.OrderDate.AddDays(1).AddHours(2), Notes = "Mã vận đơn: GHN123XYZ", CssClass = "completed" });
            if (summary.Status == "delivered")
                history.Add(new AdminOrderStatusHistory { StatusName = "Đã giao hàng", StatusDate = summary.OrderDate.AddDays(3).AddHours(5), Notes = "Khách đã nhận.", CssClass = "current" });
            else if (summary.Status != "pending" && summary.Status != "confirmed" && summary.Status != "processing" && summary.Status != "shipped" && summary.Status != "cancelled" && summary.Status != "returned") // Any other active status
                history.Add(new AdminOrderStatusHistory { StatusName = summary.StatusText, StatusDate = summary.OrderDate.AddDays(rand.Next(1, 2)).AddHours(rand.Next(1, 5)), Notes = "Cập nhật tự động.", CssClass = "current" });
            else if (summary.Status == "cancelled" || summary.Status == "returned")
                history.Add(new AdminOrderStatusHistory { StatusName = summary.StatusText, StatusDate = summary.OrderDate.AddDays(rand.Next(1, 2)).AddHours(rand.Next(1, 5)), Notes = "Lý do: Khách yêu cầu.", CssClass = "current" });


            return new AdminOrderDetail
            {
                OrderId = summary.OrderId,
                OrderCode = summary.OrderCode,
                OrderDate = summary.OrderDate,
                CustomerName = summary.CustomerName,
                CustomerPhone = summary.CustomerPhone,
                CustomerEmail = summary.CustomerName.Replace(" ", ".").ToLower() + "@example.com",
                ShippingAddress = $"Số {rand.Next(1, 200)}, Đường {summary.CustomerName.Split(' ').Last()} {rand.Next(1, 10)}, Phường {rand.Next(1, 10)}, Quận {rand.Next(1, 12)}, TP Demo",
                OrderNotes = (orderId % 3 == 0) ? "Giao hàng ngoài giờ hành chính." : "",
                Items = items,
                Subtotal = calculatedSubtotal,
                ShippingFee = shipping,
                DiscountAmount = discount,
                TotalAmount = summary.TotalAmount,
                PaymentMethod = summary.PaymentMethod,
                PaymentStatus = summary.PaymentStatus,
                Status = summary.Status,
                StatusText = summary.StatusText,
                StatusHistory = history.OrderBy(h => h.StatusDate).ToList()
            };
        }
        Random rand = new Random(); // For dummy data

        #endregion
    }
}