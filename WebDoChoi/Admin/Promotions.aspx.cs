using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.ComponentModel;

namespace WebsiteDoChoi.Admin
{
    public class AdminPromotionSummaryView
    {
        public int PromotionId { get; set; }
        public string Type { get; set; } // "coupon", "product_promo"
        public string Name { get; set; }
        public string Description { get; set; }
        public string Code { get; set; } // For coupons
        public string DiscountDisplayValue { get; set; } // e.g., "10%", "50.000đ", "Free Ship"
        public string DiscountType { get; set; } // percentage, fixed_amount, free_shipping, bogo
        public decimal MinimumOrderValue { get; set; }
        public int UsageCount { get; set; }
        public int UsageLimit { get; set; } // 0 for unlimited
        public double UsagePercentage => UsageLimit > 0 ? (double)UsageCount / UsageLimit * 100 : (UsageCount > 0 ? 100 : 0);
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public bool IsActive { get; set; } // Overall active status
        public string StatusText { get; set; } // "Hoạt động", "Hết hạn", "Chờ kích hoạt", "Đã tắt"
        public string StatusCssClass { get; set; } // For card border/background
        public string StatusBadgeCss { get; set; } // For status text badge
        public string TimeRemainingText { get; set; }
        public string TimeRemainingCssClass { get; set; }
        // For product promotions:
        public string TargetType { get; set; } // All, Category, Product, Brand
        public int TargetProductCount { get; set; }
        public decimal RevenueGenerated { get; set; }
        public decimal SavingsProvided { get; set; }
    }

    public class PromotionStats
    {
        public int UsageCount { get; set; }
        public decimal RevenueGenerated { get; set; }
        public decimal SavingsByCustomers { get; set; }
        public decimal ConversionRate { get; set; } // Percentage
        public List<ChartDataPoint> UsageOverTime { get; set; } // For chart
        public List<OrderDetailForPromoStats> UsageDetails { get; set; }
    }
    public class ChartDataPoint { public string Label { get; set; } public decimal Value { get; set; } }
    public class OrderDetailForPromoStats { public string OrderCode { get; set; } public string CustomerName { get; set; } public DateTime UsageDate { get; set; } public decimal OrderValue { get; set; } public decimal DiscountApplied { get; set; } }



    public partial class Promotions : System.Web.UI.Page
    {
        private const int PromosPageSize = 9; // Promotions per page

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ViewState["CurrentPromotionPage"] = 1;
                ViewState["ActiveAdminPromoTab"] = "Coupons"; // Default tab
                PopulatePromotionFilterDropdowns();
                LoadPromotionStatsCards();
                BindPromotionsData();
                UpdateMainUITabs();
            }
            if (pnlPromotionModal.Visible)
            { // Ensure modal JS is set up after postback if modal was open
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ReOpenPromoModal", "document.body.style.overflow = 'hidden'; setupPromoModalClose();", true);
                // Re-initialize dropdowns for modal if they depend on selected type
                ddlDiscountTypeModal_SelectedIndexChanged(ddlDiscountTypeModal, EventArgs.Empty); // To set unit and visibility
                                                                                                  // ddlApplicableToModal_SelectedIndexChanged(ddlApplicableToModal, EventArgs.Empty); // If applicableTo is in modal
            }
        }

        private void PopulatePromotionFilterDropdowns()
        {
            // Status Filter on main page
            ddlPromotionStatusFilter.SelectedValue = ""; // Default
            // Type Filter on main page
            ddlPromotionTypeFilter.SelectedValue = "";
            // Sort filter on main page
            ddlPromotionSortFilter.SelectedValue = "created_desc";

            // Populate DropDownLists in Modal
            ddlDiscountTypeModal.SelectedValue = "percentage"; // Default
            // Populate ddlApplicableToModal with options like "all", "category", "product", "brand"
            // Populate ddlTargetIdModal based on ddlApplicableToModal (this part is dynamic)
        }

        private void UpdateMainUITabs()
        {
            string activeTab = ViewState["ActiveAdminPromoTab"]?.ToString() ?? "Coupons";
            tabBtnCoupons.CssClass = "tab-button-main flex-1 py-3 px-4 rounded-t-lg text-sm font-medium transition-colors" + (activeTab == "Coupons" ? " active" : "");
            tabBtnProductPromos.CssClass = "tab-button-main flex-1 py-3 px-4 rounded-t-lg text-sm font-medium transition-colors" + (activeTab == "ProductPromos" ? " active" : "");
            tabBtnAnalytics.CssClass = "tab-button-main flex-1 py-3 px-4 rounded-t-lg text-sm font-medium transition-colors" + (activeTab == "Analytics" ? " active" : "");

            pnlCouponsContent.Visible = (activeTab == "Coupons");
            pnlProductPromosContent.Visible = (activeTab == "ProductPromos");
            pnlAnalyticsContent.Visible = (activeTab == "Analytics");

            if (activeTab == "Analytics" && !IsPostBack) // Load charts only when tab is active and on initial load of tab
            {
                LoadAnalyticsCharts();
            }
        }

        protected void Tab_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            ViewState["ActiveAdminPromoTab"] = btn.CommandArgument;
            UpdateMainUITabs();
            ViewState["CurrentPromotionPage"] = 1; // Reset page when switching tabs
            BindPromotionsData(); // Rebind for the current tab
        }


        private void LoadPromotionStatsCards()
        {
            // TODO: Fetch data from DB
            lblTotalPromotions.Text = "18";
            lblActivePromotions.Text = "8";
            lblExpiringSoon.Text = "3";
            lblTotalSavings.Text = "45.2M VNĐ";
            lblTotalUsage.Text = "1,247";
        }

        private void BindPromotionsData()
        {
            string activeTab = ViewState["ActiveAdminPromoTab"]?.ToString() ?? "Coupons";
            int currentPage = Convert.ToInt32(ViewState["CurrentPromotionPage"]);
            string searchTerm = txtSearchPromotions.Text.Trim().ToLower();
            string statusFilter = ddlPromotionStatusFilter.SelectedValue;
            string typeFilter = ddlPromotionTypeFilter.SelectedValue;
            string sortFilter = ddlPromotionSortFilter.SelectedValue;

            List<AdminPromotionSummaryView> allPromos = GetDummyPromotions(); // This should filter by activeTab internally or here

            // Filter based on active tab
            if (activeTab == "Coupons") allPromos = allPromos.Where(p => p.Type == "coupon").ToList();
            else if (activeTab == "ProductPromos") allPromos = allPromos.Where(p => p.Type == "product_promo").ToList();
            else { /* Analytics tab doesn't show this list */ rptCoupons.DataSource = null; rptCoupons.DataBind(); return; }


            // Apply Filters
            if (!string.IsNullOrEmpty(searchTerm))
                allPromos = allPromos.Where(p => p.Name.ToLower().Contains(searchTerm) || (!string.IsNullOrEmpty(p.Code) && p.Code.ToLower().Contains(searchTerm))).ToList();
            if (!string.IsNullOrEmpty(typeFilter))
                allPromos = allPromos.Where(p => p.DiscountType == typeFilter).ToList();


            // Apply Sorting
            switch (sortFilter)
            {
                case "name_asc": allPromos = allPromos.OrderBy(p => p.Name).ToList(); break;
                case "usage_desc": allPromos = allPromos.OrderByDescending(p => p.UsageCount).ToList(); break;
                // case "value_desc": allPromos = allPromos.OrderByDescending(p => p.DiscountValue).ToList(); break; // Need DiscountValue in model
                case "expiry_asc": allPromos = allPromos.OrderBy(p => p.EndDate).ToList(); break;
                default: allPromos = allPromos.OrderByDescending(p => p.StartDate).ToList(); break;
            }

            int totalPromos = allPromos.Count;
            var pagedPromos = allPromos.Skip((currentPage - 1) * PromosPageSize).Take(PromosPageSize).ToList();

            // For now, only rptCoupons is fully implemented in ASPX. ProductPromos would be similar.
            if (activeTab == "Coupons")
            {
                rptCoupons.DataSource = pagedPromos;
                rptCoupons.DataBind();
            }
            else if (activeTab == "ProductPromos")
            {
                // Bind to rptProductPromos if you create it
            }


            SetupPromotionPagination(totalPromos, currentPage);
            lblPromotionPageInfo.Text = $"Hiển thị {(currentPage - 1) * PromosPageSize + 1}-{Math.Min(currentPage * PromosPageSize, totalPromos)} của {totalPromos} khuyến mãi";
        }

        #region Pagination for Promotions
        private void SetupPromotionPagination(int totalItems, int currentPage)
        {
            int totalPages = (int)Math.Ceiling((double)totalItems / PromosPageSize);
            lnkPromotionPrevPage.Enabled = currentPage > 1;
            lnkPromotionNextPage.Enabled = currentPage < totalPages;

            if (totalPages <= 1)
            {
                rptPromotionPager.Visible = false;
                lnkPromotionPrevPage.Visible = false;
                lnkPromotionNextPage.Visible = false;
                lblPromotionPageInfo.Visible = totalItems > 0;
                return;
            }
            rptPromotionPager.Visible = true;
            lnkPromotionPrevPage.Visible = true;
            lnkPromotionNextPage.Visible = true;
            lblPromotionPageInfo.Visible = true;

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

            rptPromotionPager.DataSource = pageNumbers;
            rptPromotionPager.DataBind();
        }

        protected void PromotionPage_Changed(object sender, EventArgs e)
        {
            string commandArgument = ((LinkButton)sender).CommandArgument;
            int currentPage = Convert.ToInt32(ViewState["CurrentPromotionPage"]);
            var filteredPromos = GetFilteredPromotionsForCount();
            int totalPages = (int)Math.Ceiling((double)filteredPromos.Count / PromosPageSize);

            if (commandArgument == "Prev") { currentPage = Math.Max(1, currentPage - 1); }
            else if (commandArgument == "Next") { currentPage = Math.Min(totalPages, currentPage + 1); }
            else { currentPage = Convert.ToInt32(commandArgument); }

            ViewState["CurrentPromotionPage"] = currentPage;
            BindPromotionsData();
        }
        private List<AdminPromotionSummaryView> GetFilteredPromotionsForCount()
        {
            // Re-apply filters to get accurate count for pagination
            string searchTerm = txtSearchPromotions.Text.Trim().ToLower();
            string statusFilter = ddlPromotionStatusFilter.SelectedValue;
            string typeFilter = ddlPromotionTypeFilter.SelectedValue;
            List<AdminPromotionSummaryView> allPromos = GetDummyPromotions(); // Get all
            string activeTab = ViewState["ActiveAdminPromoTab"]?.ToString() ?? "Coupons";
            if (activeTab == "Coupons") allPromos = allPromos.Where(p => p.Type == "coupon").ToList();
            else if (activeTab == "ProductPromos") allPromos = allPromos.Where(p => p.Type == "product_promo").ToList();


            if (!string.IsNullOrEmpty(searchTerm))
                allPromos = allPromos.Where(p => p.Name.ToLower().Contains(searchTerm) || (!string.IsNullOrEmpty(p.Code) && p.Code.ToLower().Contains(searchTerm))).ToList();
            if (!string.IsNullOrEmpty(typeFilter))
                allPromos = allPromos.Where(p => p.DiscountType == typeFilter).ToList();
            return allPromos;
        }
        #endregion

        protected void btnApplyPromotionFilters_Click(object sender, EventArgs e) { ViewState["CurrentPromotionPage"] = 1; BindPromotionsData(); }
        protected void btnResetPromotionFilters_Click(object sender, EventArgs e)
        {
            txtSearchPromotions.Text = "";
            ddlPromotionStatusFilter.ClearSelection();
            ddlPromotionTypeFilter.ClearSelection();
            ddlPromotionSortFilter.SelectedValue = "created_desc";
            ViewState["CurrentPromotionPage"] = 1;
            BindPromotionsData();
        }

        protected void Promotion_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int promotionId = Convert.ToInt32(e.CommandArgument.ToString().Split(',')[0]);

            if (e.CommandName == "Edit") LoadPromotionForEdit(promotionId);
            else if (e.CommandName == "Delete") OpenDeletePromotionModal(promotionId, ((AdminPromotionSummaryView)e.Item.DataItem).Name);
            else if (e.CommandName == "ToggleStatus") TogglePromotionStatus(promotionId, Convert.ToBoolean(e.CommandArgument.ToString().Split(',')[1]));
            else if (e.CommandName == "Duplicate") DuplicatePromotion(promotionId);
            else if (e.CommandName == "ViewStats") LoadCouponStatsModal(promotionId);
        }

        private void TogglePromotionStatus(int promoId, bool currentIsActive)
        {
            // TODO: Update status in DB
            BindPromotionsData();
        }
        private void DuplicatePromotion(int promoId)
        {
            // TODO: Logic to duplicate promotion (create a new one based on existing)
            BindPromotionsData(); // Refresh
        }


        #region Modal Logic (Create/Edit Promotion, Stats, Delete)
        protected void btnOpenCreatePromotionModal_Click(object sender, EventArgs e)
        {
            hfPromotionId.Value = "0";
            lblPromotionModalTitle.Text = "Tạo khuyến mãi mới";
            btnSavePromotionModal.Text = "Tạo khuyến mãi";
            ClearPromotionModalForm();
            pnlPromotionModal.Visible = true;
            PromoTypeTab_Click(btnTabCouponModal, EventArgs.Empty); // Default to coupon tab
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "OpenPromoModalAdd", "document.body.style.overflow = 'hidden'; setupPromoModalClose();", true);
        }

        private void LoadPromotionForEdit(int promotionId)
        {
            // TODO: Fetch promotion details from DB
            var promo = GetDummyPromotions().FirstOrDefault(p => p.PromotionId == promotionId); // Assuming Type is correctly set
            if (promo != null)
            {
                hfPromotionId.Value = promo.PromotionId.ToString();
                lblPromotionModalTitle.Text = "Chỉnh sửa khuyến mãi";
                btnSavePromotionModal.Text = "Cập nhật";

                // Determine which form to show
                if (promo.Type == "coupon")
                {
                    PromoTypeTab_Click(btnTabCouponModal, EventArgs.Empty); // Activate coupon tab and form
                    txtCouponCodeModal.Text = promo.Code;
                    txtCouponNameModal.Text = promo.Name;
                    txtCouponDescriptionModal.Text = promo.Description;
                    ddlDiscountTypeModal.SelectedValue = promo.DiscountType;
                    ddlDiscountTypeModal_SelectedIndexChanged(ddlDiscountTypeModal, EventArgs.Empty); // Update unit and visibility
                    // txtDiscountValueModal.Text = promo.DiscountValue.ToString(); // Need DiscountValue property
                    // txtMaxDiscountModal.Text = promo.MaxDiscountValue.ToString();
                    txtMinOrderModal.Text = promo.MinimumOrderValue.ToString("F0");
                    txtUsageLimitTotalModal.Text = promo.UsageLimit == 0 ? "" : promo.UsageLimit.ToString();
                    // txtUsageLimitUserModal.Text = promo.UsageLimitPerUser.ToString();
                }
                else if (promo.Type == "product_promo")
                {
                    PromoTypeTab_Click(btnTabProductPromoModal, EventArgs.Empty); // Activate product promo tab
                    // Populate product promo form fields...
                    // txtPromotionNameProductModal.Text = promo.Name;
                    // ...
                }

                txtStartDateModal.Text = promo.StartDate.ToString("yyyy-MM-ddTHH:mm");
                txtEndDateModal.Text = promo.EndDate.ToString("yyyy-MM-ddTHH:mm");
                chkIsActivePromoModal.Checked = promo.IsActive;

                pnlPromotionModal.Visible = true;
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "OpenPromoModalEdit", "document.body.style.overflow = 'hidden'; setupPromoModalClose();", true);
            }
        }

        protected void PromoTypeTab_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            string type = btn.CommandArgument;
            hfCurrentPromoType.Value = type;

            btnTabCouponModal.CssClass = "promo-type-tab-modal py-2 px-4 rounded-t-lg text-sm font-medium " + (type == "coupon" ? "active bg-primary text-white" : "border-gray-300 text-gray-500 hover:bg-gray-50");
            btnTabProductPromoModal.CssClass = "promo-type-tab-modal py-2 px-4 rounded-t-lg text-sm font-medium " + (type == "product" ? "active bg-primary text-white" : "border-gray-300 text-gray-500 hover:bg-gray-50");

            pnlCouponFormModal.Visible = (type == "coupon");
            pnlProductPromoFormModal.Visible = (type == "product");

            // Keep modal open if it was already open
            if (pnlPromotionModal.Visible)
            {
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "UpdatePromoModalTabs", "document.body.style.overflow = 'hidden'; setupPromoModalClose();", true);
            }
        }


        protected void ddlDiscountTypeModal_SelectedIndexChanged(object sender, EventArgs e)
        {
            string type = ddlDiscountTypeModal.SelectedValue;
            pnlDiscountValueModal.Visible = (type != "free_shipping");
            pnlMaxDiscountModal.Visible = (type == "percentage");
            lblDiscountUnitModal.Text = (type == "percentage") ? "%" : "VNĐ";

            // Keep modal open
            if (pnlPromotionModal.Visible)
            {
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "UpdateDiscountFields", "document.body.style.overflow = 'hidden'; setupPromoModalClose();", true);
            }
        }

        protected void btnGenerateCodeModal_Click(object sender, EventArgs e)
        {
            txtCouponCodeModal.Text = Guid.NewGuid().ToString("N").Substring(0, 8).ToUpper();
            // Keep modal open
            if (pnlPromotionModal.Visible)
            {
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "UpdateGeneratedCode", "document.body.style.overflow = 'hidden'; setupPromoModalClose();", true);
            }
        }


        protected void btnSavePromotion_Click(object sender, EventArgs e)
        {
            string validationGroup = hfCurrentPromoType.Value == "coupon" ? "CouponValidation" : "ProductPromoValidation";
            Page.Validate(validationGroup);

            if (Page.IsValid)
            {
                // TODO: Collect data based on hfCurrentPromoType.Value
                // Save to DB (new or update)
                // For example:
                // if (hfCurrentPromoType.Value == "coupon") {
                //    string code = txtCouponCodeModal.Text; ...
                // } else { ... }
                pnlPromotionModal.Visible = false;
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ClosePromoModal", "document.body.style.overflow = 'auto';", true);
                BindPromotionsData();
                LoadPromotionStatsCards();
            }
            else
            {
                pnlPromotionModal.Visible = true; // Keep modal open if validation fails
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "KeepPromoModalOpenValidation", "document.body.style.overflow = 'hidden'; setupPromoModalClose();", true);
            }
        }

        protected void btnClosePromotionModal_Click(object sender, EventArgs e)
        {
            pnlPromotionModal.Visible = false;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ClosePromoModal", "document.body.style.overflow = 'auto';", true);
        }

        private void ClearPromotionModalForm()
        {
            // Clear common fields
            txtCouponCodeModal.Text = ""; txtCouponNameModal.Text = ""; txtCouponDescriptionModal.Text = "";
            ddlDiscountTypeModal.SelectedValue = "percentage";
            txtDiscountValueModal.Text = ""; txtMaxDiscountModal.Text = ""; txtMinOrderModal.Text = "";
            txtUsageLimitTotalModal.Text = ""; txtUsageLimitUserModal.Text = "1";
            txtStartDateModal.Text = DateTime.Now.ToString("yyyy-MM-ddTHH:mm");
            txtEndDateModal.Text = DateTime.Now.AddMonths(1).ToString("yyyy-MM-ddTHH:mm");
            chkIsActivePromoModal.Checked = true; chkSendNotificationModal.Checked = false;

            // Clear product promo specific fields if any
            // ddlApplicableToModal.ClearSelection();
            // ddlTargetIdModal.Items.Clear();
            // pnlTargetSelectionModal.Visible = false;

            ddlDiscountTypeModal_SelectedIndexChanged(null, EventArgs.Empty); // Update field visibility
        }


        private void LoadCouponStatsModal(int couponId)
        {
            // TODO: Fetch detailed stats for this couponId
            var stats = GetDummyPromotionStats(couponId);
            var coupon = GetDummyPromotions().FirstOrDefault(c => c.PromotionId == couponId && c.Type == "coupon");

            lblStatsCouponCode.Text = coupon?.Code ?? "N/A";
            lblStatsUsageCountModal.Text = stats.UsageCount.ToString("N0");
            lblStatsRevenueModal.Text = stats.RevenueGenerated.ToString("N0", CultureInfo.GetCultureInfo("vi-VN")) + " VNĐ";
            lblStatsSavingModal.Text = stats.SavingsByCustomers.ToString("N0", CultureInfo.GetCultureInfo("vi-VN")) + " VNĐ";
            lblStatsConversionModal.Text = stats.ConversionRate.ToString("F1") + "%";

            gvCouponUsageDetails.DataSource = stats.UsageDetails;
            gvCouponUsageDetails.DataBind();

            pnlCouponStatsModal.Visible = true;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "OpenCouponStatsModal", "document.body.style.overflow = 'hidden'; setupPromoModalClose();", true);

        }
        protected void btnCloseCouponStatsModal_Click(object sender, EventArgs e)
        {
            pnlCouponStatsModal.Visible = false;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CloseCouponStatsModal", "document.body.style.overflow = 'auto';", true);
        }

        private void OpenDeletePromotionModal(int promotionId, string promotionName)
        {
            hfDeletePromotionId.Value = promotionId.ToString();
            litDeletePromotionName.Text = Server.HtmlEncode(promotionName);
            pnlDeletePromotionModal.Visible = true;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "OpenDeletePromoModal", "document.body.style.overflow = 'hidden'; setupPromoModalClose();", true);
        }
        protected void btnCancelDeletePromotion_Click(object sender, EventArgs e)
        {
            pnlDeletePromotionModal.Visible = false;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CloseDeletePromoModal", "document.body.style.overflow = 'auto';", true);
        }
        protected void btnConfirmDeletePromotion_Click(object sender, EventArgs e)
        {
            int promotionId = Convert.ToInt32(hfDeletePromotionId.Value);
            // TODO: Delete promotion from DB
            pnlDeletePromotionModal.Visible = false;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ConfirmDeletePromo", "document.body.style.overflow = 'auto';", true);
            BindPromotionsData();
            LoadPromotionStatsCards();
        }

        #endregion

        #region Analytics Tab
        private void LoadAnalyticsCharts()
        {
            // TODO: Fetch data for analytics charts
            var revenueLabels = new List<string> { "T1", "T2", "T3", "T4", "T5", "T6" };
            var revenueDataNormal = new List<decimal> { 45, 52, 48, 61, 55, 67 };
            var revenueDataWithPromo = new List<decimal> { 58, 73, 69, 89, 82, 95 };

            var usageLabels = new List<string> { "Mã %", "Mã cố định", "Free Ship", "Mua X Tặng Y" };
            var usageData = new List<int> { 450, 250, 200, 100 };

            // Load Top Promotions Table for Analytics
            gvTopPromotions.DataSource = GetDummyTopPerformingPromotions();
            gvTopPromotions.DataBind();
        }
        #endregion

        protected void btnExportPromotions_Click(object sender, EventArgs e)
        {
           
        }


        #region Dummy Data
        private List<AdminPromotionSummaryView> GetDummyPromotions()
        {
            var promos = new List<AdminPromotionSummaryView>();
            Random rand = new Random();
            string[] types = { "percentage", "fixed_amount", "free_shipping" };
            for (int i = 1; i <= 18; i++)
            {
                DateTime startDate = DateTime.Now.AddDays(-rand.Next(0, 60)).AddHours(rand.Next(0, 23));
                DateTime endDate = startDate.AddDays(rand.Next(10, 90));
                string status; string statusText; string statusCss; string statusBadgeCss; string timeRemText; string timeRemCss;

                if (endDate < DateTime.Now) { status = "expired"; statusText = "Hết hạn"; statusCss = "expired"; statusBadgeCss = "bg-gray-100 text-gray-700"; timeRemText = "Đã kết thúc"; timeRemCss = "text-gray-500"; }
                else if (startDate > DateTime.Now) { status = "scheduled"; statusText = "Chờ kích hoạt"; statusCss = "scheduled"; statusBadgeCss = "bg-yellow-100 text-yellow-800"; timeRemText = $"Bắt đầu sau {(startDate - DateTime.Now).Days} ngày"; timeRemCss = "text-yellow-600"; }
                else { status = "active"; statusText = "Hoạt động"; statusCss = "active"; statusBadgeCss = "bg-green-100 text-green-800"; timeRemText = $"Còn {(endDate - DateTime.Now).Days} ngày"; timeRemCss = "text-primary"; }

                string discountType = types[rand.Next(types.Length)];
                string discountDisplay = "";
                if (discountType == "percentage") discountDisplay = rand.Next(5, 50) + "%";
                else if (discountType == "fixed_amount") discountDisplay = (rand.Next(1, 10) * 10000).ToString("N0") + "đ";
                else discountDisplay = "Miễn phí";

                promos.Add(new AdminPromotionSummaryView
                {
                    PromotionId = i,
                    Type = (i % 4 == 0 ? "product_promo" : "coupon"),
                    Name = (i % 4 == 0 ? $"Giảm giá LEGO {i}" : $"Mã Giảm Giá Tháng {startDate.Month}"),
                    Description = $"Ưu đãi đặc biệt cho {(i % 4 == 0 ? "dòng LEGO" : "tháng " + startDate.Month)}",
                    Code = (i % 4 != 0) ? $"KM{startDate.Month}{i:D2}" : null,
                    DiscountDisplayValue = discountDisplay,
                    DiscountType = discountType,
                    MinimumOrderValue = (i % 2 == 0 ? 200000 : 500000) * (discountType == "free_shipping" ? 2 : 1),
                    UsageCount = rand.Next(0, 1500),
                    UsageLimit = (i % 3 == 0) ? 0 : rand.Next(500, 2000),
                    StartDate = startDate,
                    EndDate = endDate,
                    IsActive = (status == "active"),
                    StatusText = statusText,
                    StatusCssClass = "promo-card-admin " + statusCss,
                    StatusBadgeCss = statusBadgeCss,
                    TimeRemainingText = timeRemText,
                    TimeRemainingCssClass = timeRemCss,
                    TargetType = (i % 4 == 0) ? "category" : null,
                    TargetProductCount = (i % 4 == 0) ? rand.Next(5, 20) : 0,
                    RevenueGenerated = (i % 4 == 0) ? rand.Next(10, 50) * 100000m : 0,
                    SavingsProvided = (i % 4 == 0) ? rand.Next(1, 10) * 100000m : 0
                });
            }
            return promos;
        }

        private PromotionStats GetDummyPromotionStats(int couponId)
        {
            Random rand = new Random();
            var labels = new List<string>();
            var usageOverTimeData = new List<decimal>();
            for (int i = 6; i >= 0; i--)
            { // Last 7 days
                labels.Add(DateTime.Now.AddDays(-i).ToString("dd/MM"));
                usageOverTimeData.Add(rand.Next(5, 50));
            }
            var details = new List<OrderDetailForPromoStats>();
            for (int i = 0; i < rand.Next(5, 20); i++)
            {
                details.Add(new OrderDetailForPromoStats
                {
                    OrderCode = $"#TL250{rand.Next(100, 200)}",
                    CustomerName = "Khách hàng " + (char)('A' + rand.Next(0, 26)),
                    UsageDate = DateTime.Now.AddDays(-rand.Next(1, 30)),
                    OrderValue = rand.Next(200, 1500) * 1000m,
                    DiscountApplied = rand.Next(10, 100) * 1000m
                });
            }
            return new PromotionStats
            {
                UsageCount = rand.Next(500, 1500),
                RevenueGenerated = rand.Next(20, 100) * 1000000m,
                SavingsByCustomers = rand.Next(2, 20) * 1000000m,
                ConversionRate = (decimal)rand.Next(30, 80) / 10,
                UsageOverTime = labels.Zip(usageOverTimeData, (l, d) => new ChartDataPoint { Label = l, Value = d }).ToList(),
                UsageDetails = details
            };
        }
        private List<TopProductReportItem> GetDummyTopPerformingPromotions()
        {
            return GetDummyPromotions()
               .Where(p => p.Type == "coupon") // Example: only coupons
               .OrderByDescending(p => p.UsageCount)
               .Take(5)
               .Select(p => new TopProductReportItem
               { // Reusing this model, adapt if needed
                   ProductName = $"{p.Name} ({p.Code})",
                   UnitsSold = p.UsageCount, // Representing usage count
                   TotalRevenue = p.RevenueGenerated, // Assuming this property exists or is calculated
                   TrendCssClass = (p.UsageCount > 500 ? "text-green-600" : "text-red-600"), // Dummy trend
               }).ToList();
        }
        #endregion
    }
}