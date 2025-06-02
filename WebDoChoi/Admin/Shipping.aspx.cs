using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;

namespace WebsiteDoChoi.Admin
{
    public class ShippingMethodView
    {
        public int MethodId { get; set; }
        public string MethodName { get; set; }
        public string Description { get; set; }
        public string EstimatedTime { get; set; }
        public decimal BaseCost { get; set; }
        public decimal CostPerKg { get; set; }
        public bool IsActive { get; set; }
        public DateTime LastUpdated { get; set; }
        public int OrderCountThisMonth { get; set; }
        public double SuccessRate { get; set; }
        public string IconCss { get; set; } // e.g., "fas fa-shipping-fast"
        public string IconBgCss { get; set; } // e.g., "bg-green-400"
    }

    public class ShippingZoneView
    {
        public int ZoneId { get; set; }
        public string ZoneName { get; set; }
        public string RegionsDescription { get; set; } // e.g., "Quận 1, 3, 5"
        public decimal BaseFee { get; set; }
        public decimal FeePerUnit { get; set; } // e.g., per kg or per item
        public string UnitName { get; set; } // "kg", "sản phẩm"
        public string EstimatedDeliveryTime { get; set; }
        public double SuccessRate { get; set; }
        public bool IsActive { get; set; }
    }

    public class ShippingPartnerView
    {
        public int PartnerId { get; set; }
        public string PartnerName { get; set; }
        public string LogoUrl { get; set; }
        public string IntegrationType { get; set; } // "API tích hợp", "Thủ công"
        public bool IsConnected { get; set; }
        public int OrdersThisMonth { get; set; }
        public double SuccessRate { get; set; }
        public decimal AverageCost { get; set; }
        public double AverageTimeDays { get; set; }
        public double Rating { get; set; } // Out of 5
    }
    public class OrderTrackingDetailView
    {
        public string OrderCode { get; set; }
        public string CustomerName { get; set; }
        public string CustomerPhone { get; set; }
        public string ShippingAddress { get; set; }
        public string ShippingPartner { get; set; }
        public string PartnerTrackingCode { get; set; }
        public string CurrentOverallStatus { get; set; }
    }


    public partial class Shipping : System.Web.UI.Page
    {
        private const int ItemsPerPage = 6; // For shipping methods/zones/partners lists

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ViewState["CurrentShippingPage"] = 1;
                ViewState["ActiveAdminShippingTab"] = "Methods";
                LoadShippingStatsCards();
                PopulateFilterDropdownsShipping(); // For main page filters
                PopulateModalDropdowns(); // For modals
                UpdateShippingTabsUI();
                BindShippingData();
            }
            if (pnlShippingMethodModal.Visible || pnlRateCalculatorModal.Visible || pnlDeleteConfirmationModal.Visible)
            {
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ReOpenShippingModal", "document.body.style.overflow = 'hidden'; setupModalClose();", true);
            }
        }

        private void PopulateFilterDropdownsShipping()
        {
            // Main page filters for tracking or other lists if any
            // For example, if the "Theo dõi đơn hàng" tab had a filterable list:
            // ddlTrackingStatusFilter.Items.Add(new ListItem("Tất cả", "")); ...
        }

        private void PopulateModalDropdowns()
        {
            // For Rate Calculator Modal
            ddlCalcZone.Items.Clear();
            ddlCalcZone.Items.Add(new ListItem("Chọn khu vực", ""));
            ddlCalcZone.Items.Add(new ListItem("Nội thành TP.HCM", "inner_hcm"));
            ddlCalcZone.Items.Add(new ListItem("Ngoại thành TP.HCM", "outer_hcm"));
            ddlCalcZone.Items.Add(new ListItem("Các tỉnh lân cận", "province_near"));

            ddlCalcMethod.Items.Clear();
            ddlCalcMethod.Items.Add(new ListItem("Chọn PTVC", ""));
            // Populate with active shipping methods
            GetDummyShippingMethods().Where(m => m.IsActive).ToList().ForEach(m => ddlCalcMethod.Items.Add(new ListItem(m.MethodName, m.MethodId.ToString())));
        }


        protected void ShippingTab_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            ViewState["ActiveAdminShippingTab"] = btn.CommandArgument;
            UpdateShippingTabsUI();
            ViewState["CurrentShippingPage"] = 1;
            BindShippingData();
        }

        private void UpdateShippingTabsUI()
        {
            string activeTab = ViewState["ActiveAdminShippingTab"]?.ToString() ?? "Methods";

            tabBtnMethods.CssClass = "tab-button-shipping py-3 px-4 text-sm font-medium whitespace-nowrap" + (activeTab == "Methods" ? " active text-primary border-primary" : " text-gray-500 hover:text-gray-700 hover:border-gray-300 border-transparent");
            tabBtnZones.CssClass = "tab-button-shipping py-3 px-4 text-sm font-medium whitespace-nowrap" + (activeTab == "Zones" ? " active text-primary border-primary" : " text-gray-500 hover:text-gray-700 hover:border-gray-300 border-transparent");
            tabBtnPartners.CssClass = "tab-button-shipping py-3 px-4 text-sm font-medium whitespace-nowrap" + (activeTab == "Partners" ? " active text-primary border-primary" : " text-gray-500 hover:text-gray-700 hover:border-gray-300 border-transparent");
            tabBtnTracking.CssClass = "tab-button-shipping py-3 px-4 text-sm font-medium whitespace-nowrap" + (activeTab == "Tracking" ? " active text-primary border-primary" : " text-gray-500 hover:text-gray-700 hover:border-gray-300 border-transparent");

            pnlMethodsTab.Visible = (activeTab == "Methods");
            pnlZonesTab.Visible = (activeTab == "Zones");
            pnlPartnersTab.Visible = (activeTab == "Partners");
            pnlTrackingTab.Visible = (activeTab == "Tracking");

            if (activeTab == "Zones" && !IsPostBack) LoadZoneChartData(); // Load specific chart when tab becomes active
            if (activeTab == "Partners" && !IsPostBack) LoadPartnerChartData();
        }

        private void LoadShippingStatsCards()
        {
            // TODO: Fetch data from DB
            lblPendingShipments.Text = "47";
            lblInTransit.Text = "123";
            lblDeliveredCount.Text = "1,847";
            lblTotalShippingCostMonth.Text = "12.5M VNĐ";
        }

        private void BindShippingData()
        {
            string activeTab = ViewState["ActiveAdminShippingTab"]?.ToString() ?? "Methods";
            int currentPage = Convert.ToInt32(ViewState["CurrentShippingPage"]);

            // TODO: Add filtering logic based on search/filter controls if they exist for these lists

            if (activeTab == "Methods")
            {
                var methods = GetDummyShippingMethods();
                var pagedMethods = methods.Skip((currentPage - 1) * ItemsPerPage).Take(ItemsPerPage).ToList();
                rptShippingMethods.DataSource = pagedMethods;
                rptShippingMethods.DataBind();
                SetupShippingPagination(methods.Count, currentPage, "Methods");
            }
            else if (activeTab == "Zones")
            {
                var zones = GetDummyShippingZones();
                var pagedZones = zones.Skip((currentPage - 1) * ItemsPerPage).Take(ItemsPerPage).ToList();
                rptShippingZones.DataSource = pagedZones;
                rptShippingZones.DataBind();
                SetupShippingPagination(zones.Count, currentPage, "Zones");
                LoadZoneChartData();
            }
            else if (activeTab == "Partners")
            {
                var partners = GetDummyShippingPartners();
                var pagedPartners = partners.Skip((currentPage - 1) * ItemsPerPage).Take(ItemsPerPage).ToList();
                rptShippingPartners.DataSource = pagedPartners;
                rptShippingPartners.DataBind();
                SetupShippingPagination(partners.Count, currentPage, "Partners");
                LoadPartnerChartData();
            }
            else if (activeTab == "Tracking")
            {
                // Load recent orders for tracking tab (or based on search)
                var trackingOrders = GetDummyTrackingOrders().Take(10).ToList(); // Example limit
                gvTrackingOrders.DataSource = trackingOrders;
                gvTrackingOrders.DataBind();
                pnlRecentOrdersTracking.Visible = trackingOrders.Any();
                // No pagination for this table in this example, but could be added
                FindControl("lnkOrderPrevPage").Visible = false;
                FindControl("rptOrderPager").Visible = false;
                FindControl("lnkOrderNextPage").Visible = false;
            }
        }

        #region Pagination
        private void SetupShippingPagination(int totalItems, int currentPage, string type) // type for distinguishing pagers if needed
        {
            // Using common pagination controls for now, adjust if specific pagers per tab

        }
        protected void ShippingPage_Changed(object sender, EventArgs e) // Renamed from OrderPage_Changed
        {
            // Similar pagination logic as other pages, ensure ViewState["CurrentShippingPage"] is used
            string commandArgument = ((LinkButton)sender).CommandArgument;
            int currentPage = Convert.ToInt32(ViewState["CurrentShippingPage"]);
            // Recalculate totalPages based on current tab and filters
            int totalItems = 0;
            string activeTab = ViewState["ActiveAdminShippingTab"]?.ToString() ?? "Methods";
            if (activeTab == "Methods") totalItems = GetDummyShippingMethods().Count; // Apply filters if any
            else if (activeTab == "Zones") totalItems = GetDummyShippingZones().Count;
            else if (activeTab == "Partners") totalItems = GetDummyShippingPartners().Count;

            int totalPages = (int)Math.Ceiling((double)totalItems / ItemsPerPage);

            if (commandArgument == "Prev") { currentPage = Math.Max(1, currentPage - 1); }
            else if (commandArgument == "Next") { currentPage = Math.Min(totalPages, currentPage + 1); }
            else { currentPage = Convert.ToInt32(commandArgument); }

            ViewState["CurrentShippingPage"] = currentPage;
            BindShippingData();
        }
        #endregion

        #region Shipping Method Modal
        protected void btnOpenAddMethodModal_Click(object sender, EventArgs e)
        {
            hfShippingMethodId.Value = "0";
            lblMethodModalTitle.Text = "Thêm Phương thức Vận chuyển";
            // Clear form
            txtMethodName.Text = ""; txtMethodDescription.Text = ""; txtEstimatedDays.Text = "";
            txtBaseCost.Text = ""; txtCostPerKg.Text = ""; txtMethodIconCss.Text = "fas fa-truck";
            chkMethodIsActive.Checked = true;
            pnlShippingMethodModal.Visible = true;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "OpenMethodModalAdd", "document.body.style.overflow = 'hidden'; setupModalClose();", true);
        }
        protected void btnCloseMethodModal_Click(object sender, EventArgs e)
        {
            pnlShippingMethodModal.Visible = false;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CloseMethodModal", "document.body.style.overflow = 'auto';", true);
        }
        protected void btnSaveShippingMethod_Click(object sender, EventArgs e)
        {
            Page.Validate("MethodValidation");
            if (Page.IsValid)
            {
                int methodId = Convert.ToInt32(hfShippingMethodId.Value);
                // TODO: Save/Update shipping method in DB
                ShowAdminNotification(methodId == 0 ? "Đã thêm phương thức vận chuyển." : "Đã cập nhật phương thức vận chuyển.", "success");
                pnlShippingMethodModal.Visible = false;
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "SaveMethodCloseModal", "document.body.style.overflow = 'auto';", true);
                BindShippingData(); // Refresh list
            }
            else
            {
                pnlShippingMethodModal.Visible = true; // Keep modal open
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "KeepMethodModalOpen", "document.body.style.overflow = 'hidden'; setupModalClose();", true);
            }
        }
        #endregion

        #region Shipping Zone/Partner/Tracking Modals & Actions (Placeholders)
        protected void btnOpenAddZoneModal_Click(object sender, EventArgs e) { ShowAdminNotification("Chức năng thêm khu vực đang được phát triển.", "info"); }
        protected void btnOpenAddPartnerModal_Click(object sender, EventArgs e) { ShowAdminNotification("Chức năng thêm đối tác đang được phát triển.", "info"); }
        protected void ShippingMethod_Command(object source, RepeaterCommandEventArgs e)
        {
            int methodId = Convert.ToInt32(e.CommandArgument.ToString().Split(',')[0]);
            if (e.CommandName == "EditMethod") { /* Load data and show modal */ }
            else if (e.CommandName == "DeleteMethod") { OpenAdminDeleteConfirmation(methodId, "PTVC ID " + methodId, "shipping_method"); }
            else if (e.CommandName == "ToggleStatus") { /* Update status in DB and rebind */ }
        }
        protected void ShippingZone_Command(object source, RepeaterCommandEventArgs e) { /* Similar for Zones */ }
        protected void ShippingPartner_Command(object source, RepeaterCommandEventArgs e) { /* Similar for Partners */ }

        protected void btnTrackOrder_Click(object sender, EventArgs e)
        {
           
        }
        protected void btnFilterTrackingStatus_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            string statusFilter = btn.CommandArgument;
            // TODO: Filter gvTrackingOrders based on statusFilter
            gvTrackingOrders.DataBind();
            pnlRecentOrdersTracking.Visible = true;
        }
        protected void gvTrackingOrders_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Track")
            {
                txtTrackingOrderCode.Text = e.CommandArgument.ToString();
                txtTrackingPhone.Text = ""; // Clear phone if tracking by code
                btnTrackOrder_Click(sender, e); // Trigger search
            }
        }

        #endregion

        #region Chart Data Loaders
        private void LoadZoneChartData()
        {
            var labels = new List<string> { "Nội thành HCM", "Ngoại thành HCM", "Tỉnh lân cận", "Miền Bắc", "Miền Trung" };
            var data = new List<int> { 45, 25, 15, 10, 5 };
            string script = $"if(typeof initAdminZoneChart === 'function') initAdminZoneChart({SerializeToJson(labels)}, {SerializeToJson(data)}); else console.error('initAdminZoneChart not defined');";
            ScriptManager.RegisterStartupScript(this.upnlShippingPage, this.GetType(), "AdminZoneChartScript", script, true);
        }
        private void LoadPartnerChartData()
        {
            var labels = new List<string> { "GHN", "J&T", "ViettelPost", "AhaMove" };
            var datasets = new List<object> {
                new { label="Số đơn", data = new List<int>{1234,987,756,450}, backgroundColor="#FF6B6B" },
                new { label="Tỷ lệ TC (%)", data = new List<double>{98.5, 97.2, 96.8, 99.1}, backgroundColor="#4ECDC4", yAxisID="y1" }
            };
            string script = $"if(typeof initAdminPartnerChart === 'function') initAdminPartnerChart({SerializeToJson(labels)}, {SerializeToJson(datasets)}); else console.error('initAdminPartnerChart not defined');";
            ScriptManager.RegisterStartupScript(this.upnlShippingPage, this.GetType(), "AdminPartnerChartScript", script, true);
        }
        #endregion

        #region Rate Calculator Modal
        protected void btnOpenRateCalculator_Click(object sender, EventArgs e)
        {
            pnlRateCalculatorModal.Visible = true;
            pnlRateResult.Visible = false; // Hide previous result
            txtCalcWeight.Text = ""; // Clear previous input
            ddlCalcZone.ClearSelection(); ddlCalcMethod.ClearSelection();
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "OpenRateCalcModal", "document.body.style.overflow = 'hidden'; setupModalClose();", true);
        }
        protected void btnCloseRateCalculator_Click(object sender, EventArgs e)
        {
            pnlRateCalculatorModal.Visible = false;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CloseRateCalcModal", "document.body.style.overflow = 'auto';", true);
        }
        protected void btnCalculateRate_Click(object sender, EventArgs e)
        {
            // Simplified calculation, replace with your actual logic
            decimal weight = 0; decimal.TryParse(txtCalcWeight.Text, out weight);
            string zone = ddlCalcZone.SelectedValue;
            string method = ddlCalcMethod.SelectedValue;

            if (weight <= 0 || string.IsNullOrEmpty(zone) || string.IsNullOrEmpty(method))
            {
                lblCalculatedRateResult.Text = "Lỗi";
                lblRateBreakdownResult.Text = "Vui lòng nhập đủ thông tin.";
                pnlRateResult.Visible = true;
                pnlRateCalculatorModal.Visible = true; // Keep modal open
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "RateCalcError", "document.body.style.overflow = 'hidden'; setupModalClose();", true);
                return;
            }

            decimal baseCost = 0, costPerKg = 0;
            // This logic should fetch rates based on selected method and zone from your DB/config
            var selectedMethod = GetDummyShippingMethods().FirstOrDefault(m => m.MethodId.ToString() == method);
            if (selectedMethod != null) { baseCost = selectedMethod.BaseCost; costPerKg = selectedMethod.CostPerKg; }
            if (zone.Contains("outer")) baseCost += 10000; else if (zone.Contains("province")) baseCost += 20000;

            decimal totalCost = baseCost + (weight * costPerKg);
            lblCalculatedRateResult.Text = totalCost.ToString("N0", CultureInfo.GetCultureInfo("vi-VN")) + "đ";
            lblRateBreakdownResult.Text = $"Phí CB: {baseCost:N0}đ + KL: {weight * costPerKg:N0}đ";
            pnlRateResult.Visible = true;
            pnlRateCalculatorModal.Visible = true; // Keep modal open
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "RateCalcSuccess", "document.body.style.overflow = 'hidden'; setupModalClose();", true);
        }
        #endregion

        #region Delete Confirmation
        private void OpenAdminDeleteConfirmation(int itemId, string itemName, string itemType)
        {
            hfDeleteItemId.Value = itemId.ToString();
            hfDeleteItemType.Value = itemType;
            litDeleteItemName.Text = Server.HtmlEncode(itemName);
            pnlDeleteConfirmationModal.Visible = true;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "OpenDeleteConfirmModalShipping", "document.body.style.overflow = 'hidden'; setupModalClose();", true);
        }
        protected void btnModalCancelDelete_Click(object sender, EventArgs e)
        {
            pnlDeleteConfirmationModal.Visible = false;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CloseDeleteConfirmModalShipping", "document.body.style.overflow = 'auto';", true);
        }
        protected void btnModalConfirmDelete_Click(object sender, EventArgs e)
        {
            int itemId = Convert.ToInt32(hfDeleteItemId.Value);
            string itemType = hfDeleteItemType.Value;
            // TODO: Delete item from DB based on type and ID
            ShowAdminNotification($"Đã xóa {itemType} ID: {itemId}.", "success");
            pnlDeleteConfirmationModal.Visible = false;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ConfirmDeleteShipping", "document.body.style.overflow = 'auto';", true);
            BindShippingData(); // Refresh current tab
        }
        #endregion


        private void ShowAdminNotification(string message, string type = "info") => ScriptManager.RegisterStartupScript(this.upnlShippingPage, this.GetType(), Guid.NewGuid().ToString(), $"showNotification('{message.Replace("'", "\\\'")}', '{type}');", true);
        private string SerializeToJson(object obj) => new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(obj);

        #region Dummy Data (Replace with actual DB calls)
        private List<ShippingMethodView> GetDummyShippingMethods()
        {
            return new List<ShippingMethodView> {
                new ShippingMethodView { MethodId=1, MethodName="Giao hàng tiêu chuẩn", EstimatedTime="3-5 ngày", BaseCost=30000, CostPerKg=5000, IsActive=true, LastUpdated=DateTime.Now.AddDays(-10), OrderCountThisMonth=234, SuccessRate=98.5, IconCss="fas fa-shipping-fast", IconBgCss="bg-green-500"},
                new ShippingMethodView { MethodId=2, MethodName="Giao hàng nhanh", EstimatedTime="1-2 ngày", BaseCost=50000, CostPerKg=8000, IsActive=true, LastUpdated=DateTime.Now.AddDays(-5), OrderCountThisMonth=156, SuccessRate=99.1, IconCss="fas fa-bolt", IconBgCss="bg-blue-500"},
                new ShippingMethodView { MethodId=3, MethodName="Giao hàng hỏa tốc", EstimatedTime="Trong ngày", BaseCost=100000, CostPerKg=15000, IsActive=true, LastUpdated=DateTime.Now.AddDays(-2), OrderCountThisMonth=89, SuccessRate=97.8, IconCss="fas fa-rocket", IconBgCss="bg-red-500"},
                new ShippingMethodView { MethodId=4, MethodName="Giao hàng máy bay (Tạm dừng)", EstimatedTime="Khu vực xa", BaseCost=200000, CostPerKg=25000, IsActive=false, LastUpdated=DateTime.Now.AddMonths(-1), OrderCountThisMonth=0, SuccessRate=0, IconCss="fas fa-plane", IconBgCss="bg-gray-400"}
            };
        }
        private List<ShippingZoneView> GetDummyShippingZones()
        {
            return new List<ShippingZoneView> {
                new ShippingZoneView { ZoneId=1, ZoneName="Nội thành TP.HCM", RegionsDescription="Quận 1, 3, 5, 10, Phú Nhuận, Bình Thạnh", BaseFee=15000, FeePerUnit=3000, UnitName="kg", EstimatedDeliveryTime="1-2h", SuccessRate=99.0, IsActive=true },
                new ShippingZoneView { ZoneId=2, ZoneName="Ngoại thành TP.HCM", RegionsDescription="Quận 9, 12, Thủ Đức, Bình Tân, Hóc Môn", BaseFee=25000, FeePerUnit=4000, UnitName="kg", EstimatedDeliveryTime="2-4h", SuccessRate=97.5, IsActive=true },
                new ShippingZoneView { ZoneId=3, ZoneName="Các tỉnh lân cận", RegionsDescription="Đồng Nai, Bình Dương, Long An", BaseFee=35000, FeePerUnit=6000, UnitName="kg", EstimatedDeliveryTime="1-2 ngày", SuccessRate=95.0, IsActive=true },
            };
        }
        private List<ShippingPartnerView> GetDummyShippingPartners()
        {
            return new List<ShippingPartnerView> {
                new ShippingPartnerView { PartnerId=1, PartnerName="Giao Hàng Nhanh", LogoUrl="https://api.placeholder.com/60/60/FF6B6B/FFFFFF?text=GHN", IntegrationType="API tích hợp", IsConnected=true, OrdersThisMonth=1234, SuccessRate=98.5, AverageCost=32000, AverageTimeDays=2.1, Rating=4.8 },
                new ShippingPartnerView { PartnerId=2, PartnerName="J&T Express", LogoUrl="https://api.placeholder.com/60/60/4ECDC4/FFFFFF?text=J&T", IntegrationType="API tích hợp", IsConnected=true, OrdersThisMonth=987, SuccessRate=97.2, AverageCost=28000, AverageTimeDays=2.3, Rating=4.6 },
                new ShippingPartnerView { PartnerId=3, PartnerName="Viettel Post", LogoUrl="https://api.placeholder.com/60/60/FFE66D/1A535C?text=VTP", IntegrationType="API tích hợp", IsConnected=true, OrdersThisMonth=756, SuccessRate=96.8, AverageCost=25000, AverageTimeDays=2.5, Rating=4.4 },
                new ShippingPartnerView { PartnerId=4, PartnerName="AhaMove", LogoUrl="https://api.placeholder.com/60/60/1A535C/FFFFFF?text=Aha", IntegrationType="Thủ công", IsConnected=false, OrdersThisMonth=450, SuccessRate=99.1, AverageCost=55000, AverageTimeDays=0.2, Rating=4.9 }
            };
        }

        private List<AdminOrderSummary> GetDummyTrackingOrders()
        { // Could be more specific to tracking
            return new Orders().GetPublicDummyOrders().Select(o => { return o; }).ToList();
        }
       
        #endregion
    }
    public partial class Orders
    { // Make methods public for Reports page to access
        // Re-use GetPublicDummyOrders() if already made public in Orders.aspx.cs
    }
}