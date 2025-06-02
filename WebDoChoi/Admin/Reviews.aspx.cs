using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;


namespace WebsiteDoChoi.Admin
{
    public class AdminReviewItemView
    {
        public int ReviewId { get; set; }
        public int ProductId { get; set; }
        public string ProductName { get; set; }
        public string ProductImageUrl { get; set; }
        public string CustomerName { get; set; }
        public DateTime ReviewDate { get; set; }
        public bool IsVerifiedPurchase { get; set; }
        public int Rating { get; set; } // 1-5
        public string ReviewTitle { get; set; }
        public string ReviewText { get; set; }
        public List<string> ImageUrls { get; set; } = new List<string>();
        public int HelpfulCount { get; set; }
        public int ViewCount { get; set; }
        public string OrderCode { get; set; }
        public int OrderId { get; set; }
        public string Status { get; set; } // pending, approved, rejected, reported
        public string StatusText { get; set; }
        public string StatusBadgeCss { get; set; }
        public string CardCssClass { get; set; } // For overall card styling based on status
        public string AdminResponseText { get; set; }
        public DateTime? AdminResponseDate { get; set; }
        public bool IsActive { get; set; } // For toggle status action
    }

    public class AdminReviewStatsData
    {
        public List<int> RatingData { get; set; } // Counts for 5,4,3,2,1 stars
        public List<string> TimelineLabels { get; set; }
        public List<int> TimelineNewData { get; set; }
        public List<int> TimelineApprovedData { get; set; }
    }


    public partial class Reviews : System.Web.UI.Page
    {
        private const int ReviewsPageSize = 10;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ViewState["CurrentReviewPage"] = 1;
                PopulateReviewFilterDropdowns();
                LoadReviewStatsCards();
                LoadReviewChartsData();
                BindReviews();
            }
            if (pnlDeleteReviewModal.Visible)
            {
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ReOpenDeleteReviewModal", "document.body.style.overflow = 'hidden'; setupAdminReviewModalClose();", true);
            }
        }

        private void PopulateReviewFilterDropdowns()
        {
            // Product Filter (needs data from DB)
            ddlProductFilter.Items.Clear();
            ddlProductFilter.Items.Add(new ListItem("Tất cả sản phẩm", ""));
        }

        private void LoadReviewStatsCards()
        {
            // TODO: Fetch actual stats from DB
            lblTotalReviews.Text = "1,247";
            lblPendingReviews.Text = "23";
            lblApprovedReviews.Text = "1,198";
            lblAverageRating.Text = "4.6";
            lblReportedReviews.Text = "7";
        }

        private void LoadReviewChartsData()
        {
            // TODO: Fetch chart data from DB
            var ratingData = new List<int> { 687, 324, 156, 58, 22 }; // 5 to 1 star
            var timelineLabels = new List<string> { "T2", "T3", "T4", "T5", "T6", "T7", "CN" }; // Last 7 days
            var timelineNew = new List<int> { 45, 52, 38, 67, 83, 91, 76 };
            var timelineApproved = new List<int> { 42, 48, 35, 63, 78, 85, 71 };

            // Pass data to client-side script for chart rendering
            // Instead of direct JS string, store in a client-accessible variable or use RegisterStartupScript
            string script = $"var adminReviewChartData = {{ ratingData: {SerializeToJson(ratingData)}, timelineLabels: {SerializeToJson(timelineLabels)}, timelineNewData: {SerializeToJson(timelineNew)}, timelineApprovedData: {SerializeToJson(timelineApproved)} }}; if(typeof initializeAdminReviewCharts === 'function') initializeAdminReviewCharts(adminReviewChartData.ratingData, adminReviewChartData.timelineLabels, adminReviewChartData.timelineNewData, adminReviewChartData.timelineApprovedData);";
            ScriptManager.RegisterStartupScript(this.upnlReviewsPage, this.GetType(), "AdminReviewChartsScript", script, true);
        }

        protected void ddlTimelinePeriod_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadReviewChartsData(); // Reload chart with new period
            // upnlReviewsPage.Update(); // If charts are inside the UpdatePanel
        }


        private void BindReviews()
        {
            int currentPage = Convert.ToInt32(ViewState["CurrentReviewPage"]);
            string searchTerm = txtSearchReviews.Text.Trim().ToLower();
            string statusFilter = ddlReviewStatusFilter.SelectedValue;
            string ratingFilter = ddlRatingFilter.SelectedValue;
            string productFilter = ddlProductFilter.SelectedValue;

            List<AdminReviewItemView> allReviews = GetDummyAdminReviews();

            // Apply Filters
            if (!string.IsNullOrEmpty(searchTerm))
                allReviews = allReviews.Where(r => r.ProductName.ToLower().Contains(searchTerm) || r.CustomerName.ToLower().Contains(searchTerm) || r.ReviewText.ToLower().Contains(searchTerm)).ToList();
            if (!string.IsNullOrEmpty(statusFilter))
                allReviews = allReviews.Where(r => r.Status == statusFilter).ToList();
            if (!string.IsNullOrEmpty(ratingFilter) && int.TryParse(ratingFilter, out int rating))
                allReviews = allReviews.Where(r => r.Rating == rating).ToList();
            if (!string.IsNullOrEmpty(productFilter) && int.TryParse(productFilter, out int prodId))
                allReviews = allReviews.Where(r => r.ProductId == prodId).ToList();

            // Apply Sorting
       

            int totalReviews = allReviews.Count;
            var pagedReviews = allReviews.Skip((currentPage - 1) * ReviewsPageSize).Take(ReviewsPageSize).ToList();

            rptReviews.DataSource = pagedReviews;
            rptReviews.DataBind();

            SetupReviewPagination(totalReviews, currentPage);
            lblReviewPageInfo.Text = $"Hiển thị {(currentPage - 1) * ReviewsPageSize + 1}-{Math.Min(currentPage * ReviewsPageSize, totalReviews)} của {totalReviews} đánh giá";
        }

        #region Pagination for Reviews
        private void SetupReviewPagination(int totalItems, int currentPage)
        {
            int totalPages = (int)Math.Ceiling((double)totalItems / ReviewsPageSize);
            lnkReviewPrevPage.Enabled = currentPage > 1;
            lnkReviewNextPage.Enabled = currentPage < totalPages;

            if (totalPages <= 1) { rptReviewPager.Visible = false; lnkReviewPrevPage.Visible = false; lnkReviewNextPage.Visible = false; lblReviewPageInfo.Visible = totalItems > 0; return; }
            rptReviewPager.Visible = true; lnkReviewPrevPage.Visible = true; lnkReviewNextPage.Visible = true; lblReviewPageInfo.Visible = true;

            var pageNumbers = new List<object>();
            for (int i = 1; i <= totalPages; i++) pageNumbers.Add(new { Text = i.ToString(), Value = i.ToString(), IsCurrent = (i == currentPage) }); // Simplified pager
            rptReviewPager.DataSource = pageNumbers; rptReviewPager.DataBind();
        }

        protected void ReviewPage_Changed(object sender, EventArgs e)
        {
            string commandArgument = ((LinkButton)sender).CommandArgument;
            int currentPage = Convert.ToInt32(ViewState["CurrentReviewPage"]);
            var filteredReviews = GetFilteredReviewsForCount();
            int totalPages = (int)Math.Ceiling((double)filteredReviews.Count / ReviewsPageSize);

            if (commandArgument == "Prev") { currentPage = Math.Max(1, currentPage - 1); }
            else if (commandArgument == "Next") { currentPage = Math.Min(totalPages, currentPage + 1); }
            else { currentPage = Convert.ToInt32(commandArgument); }

            ViewState["CurrentReviewPage"] = currentPage;
            BindReviews();
        }
        private List<AdminReviewItemView> GetFilteredReviewsForCount()
        {
            // Re-apply filters to get count for pagination
            string searchTerm = txtSearchReviews.Text.Trim().ToLower();
            string statusFilter = ddlReviewStatusFilter.SelectedValue;
            string ratingFilter = ddlRatingFilter.SelectedValue;
            string productFilter = ddlProductFilter.SelectedValue;
            List<AdminReviewItemView> allReviews = GetDummyAdminReviews();

            if (!string.IsNullOrEmpty(searchTerm)) allReviews = allReviews.Where(r => r.ProductName.ToLower().Contains(searchTerm) || r.CustomerName.ToLower().Contains(searchTerm) || r.ReviewText.ToLower().Contains(searchTerm)).ToList();
            if (!string.IsNullOrEmpty(statusFilter)) allReviews = allReviews.Where(r => r.Status == statusFilter).ToList();
            if (!string.IsNullOrEmpty(ratingFilter) && int.TryParse(ratingFilter, out int rating)) allReviews = allReviews.Where(r => r.Rating == rating).ToList();
            if (!string.IsNullOrEmpty(productFilter) && int.TryParse(productFilter, out int prodId)) allReviews = allReviews.Where(r => r.ProductId == prodId).ToList();
            return allReviews;
        }
        #endregion

        protected void btnApplyReviewFilters_Click(object sender, EventArgs e) { ViewState["CurrentReviewPage"] = 1; BindReviews(); UpdateActiveFiltersPanel(); }
        protected void btnResetReviewFilters_Click(object sender, EventArgs e)
        {
            txtSearchReviews.Text = "";
            ddlReviewStatusFilter.ClearSelection();
            ddlRatingFilter.ClearSelection();
            ddlProductFilter.ClearSelection();
            ViewState["CurrentReviewPage"] = 1;
            BindReviews();
            UpdateActiveFiltersPanel();
            ShowAdminNotification("Đã reset bộ lọc đánh giá.", "info");
        }

        private void UpdateActiveFiltersPanel()
        {
            var activeFiltersList = new List<object>();
            if (!string.IsNullOrEmpty(txtSearchReviews.Text)) activeFiltersList.Add(new { FilterText = $"Tìm: \"{txtSearchReviews.Text}\"", FilterType = "Search", FilterValue = txtSearchReviews.Text });
            if (!string.IsNullOrEmpty(ddlReviewStatusFilter.SelectedValue)) activeFiltersList.Add(new { FilterText = $"Trạng thái: {ddlReviewStatusFilter.SelectedItem.Text}", FilterType = "Status", FilterValue = ddlReviewStatusFilter.SelectedValue });
            if (!string.IsNullOrEmpty(ddlRatingFilter.SelectedValue)) activeFiltersList.Add(new { FilterText = $"Rating: {ddlRatingFilter.SelectedItem.Text}", FilterType = "Rating", FilterValue = ddlRatingFilter.SelectedValue });
            if (!string.IsNullOrEmpty(ddlProductFilter.SelectedValue)) activeFiltersList.Add(new { FilterText = $"Sản phẩm: {ddlProductFilter.SelectedItem.Text}", FilterType = "Product", FilterValue = ddlProductFilter.SelectedValue });

            rptActiveFilters.DataSource = activeFiltersList;
            rptActiveFilters.DataBind();
            pnlActiveFilters.Visible = activeFiltersList.Any();
        }
        protected void rptActiveFilters_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string filterType = e.CommandName;
            // string filterValue = e.CommandArgument.ToString(); // Value of the filter to remove

            if (filterType == "Search") txtSearchReviews.Text = "";
            else if (filterType == "Status") ddlReviewStatusFilter.ClearSelection();
            else if (filterType == "Rating") ddlRatingFilter.ClearSelection();
            else if (filterType == "Product") ddlProductFilter.ClearSelection();

            ViewState["CurrentReviewPage"] = 1;
            BindReviews();
            UpdateActiveFiltersPanel();
        }



        protected void rptReviews_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int reviewId = Convert.ToInt32(e.CommandArgument.ToString().Split(',')[0]);
            string commandName = e.CommandName;

            if (commandName == "Approve") UpdateReviewStatus(reviewId, "approved", "Đã duyệt đánh giá.");
            else if (commandName == "Reject") UpdateReviewStatus(reviewId, "rejected", "Đã từ chối đánh giá.");
            else if (commandName == "Delete") OpenDeleteReviewModal(reviewId, "Đánh giá ID " + reviewId); // Get actual title if possible
            else if (commandName == "Respond")
            {
                // Show response panel for this item
                Panel pnlResponse = (Panel)e.Item.FindControl("pnlResponseArea");
                if (pnlResponse != null) pnlResponse.Visible = !pnlResponse.Visible;
            }
            else if (commandName == "ViewDetail") { LoadReviewDetailModal(reviewId); }
            else if (commandName == "ToggleStatus") { UpdateReviewStatus(reviewId, Convert.ToBoolean(e.CommandArgument.ToString().Split(',')[1]) ? "inactive" : "approved", "Đã cập nhật trạng thái."); }
            else if (commandName == "SubmitReply")
            {
                TextBox txtReply = (TextBox)e.Item.FindControl("txtAdminReply");
                // TODO: Save reply txtReply.Text for reviewId
                ShowAdminNotification("Phản hồi đã được lưu.", "success");
                Panel pnlResponse = (Panel)e.Item.FindControl("pnlResponseArea");
                if (pnlResponse != null) pnlResponse.Visible = false;
                BindReviews(); // Rebind to show response
            }
            else if (commandName == "CancelReply")
            {
                Panel pnlResponse = (Panel)e.Item.FindControl("pnlResponseArea");
                if (pnlResponse != null) pnlResponse.Visible = false;
            }
        }

        private void UpdateReviewStatus(int reviewId, string newStatus, string successMessage)
        {
            // TODO: Update review status in DB
            ShowAdminNotification(successMessage, "success");
            BindReviews();
        }

        #region Bulk Actions
        protected void btnToggleBulkActions_Click(object sender, EventArgs e)
        {
            pnlBulkActionsBar.Visible = !pnlBulkActionsBar.Visible;
            if (!pnlBulkActionsBar.Visible)
            { // Clear selection if hiding bar
                chkSelectAll.Checked = false;
                // selectedReviewIdsForBulk.Clear(); // Assuming this is client-side managed
                // Call JS to update UI
                ScriptManager.RegisterStartupScript(this, GetType(), "ClearBulkSelection", "selectedReviewIdsForBulk = []; updateSelectedReviewsCount(); document.querySelectorAll('.review-checkbox').forEach(cb => cb.checked = false);", true);
            }
        }
        protected void btnCloseBulkBar_Click(object sender, EventArgs e)
        {
            pnlBulkActionsBar.Visible = false;
            ScriptManager.RegisterStartupScript(this, GetType(), "ClearBulkSelectionClose", "selectedReviewIdsForBulk = []; updateSelectedReviewsCount(); document.querySelectorAll('.review-checkbox').forEach(cb => cb.checked = false);", true);
        }

        protected void btnBulkApprove_Click(object sender, EventArgs e)
        {
            string selectedIds = Request.Form["selectedReviewIdsHiddenField"]; // Assuming a hidden field updated by JS
            if (!string.IsNullOrEmpty(selectedIds))
            {
                List<int> idsToProcess = selectedIds.Split(',').Select(int.Parse).ToList();
                // TODO: Update status to 'approved' for these IDs in DB
                ShowAdminNotification($"Đã duyệt {idsToProcess.Count} đánh giá.", "success");
                BindReviews();
            }
            else { ShowAdminNotification("Vui lòng chọn ít nhất một đánh giá.", "warning"); }
            pnlBulkActionsBar.Visible = false; // Hide after action
        }
        // Implement btnBulkReject_Click and btnBulkDelete_Click similarly
        protected void btnBulkReject_Click(object sender, EventArgs e) { /* ... */ ShowAdminNotification("Đã từ chối các đánh giá đã chọn.", "success"); BindReviews(); pnlBulkActionsBar.Visible = false; }
        protected void btnBulkDelete_Click(object sender, EventArgs e) { /* ... */ ShowAdminNotification("Đã xóa các đánh giá đã chọn.", "success"); BindReviews(); pnlBulkActionsBar.Visible = false; }

        #endregion

        #region Modal and Delete Logic
        private void LoadReviewDetailModal(int reviewId)
        {
            // TODO: Fetch review details and populate a modal (pnlReviewDetailModal)
            ShowAdminNotification("Chức năng Xem chi tiết đánh giá đang phát triển.", "info");
        }
        private void OpenDeleteReviewModal(int reviewId, string reviewTitle)
        {
            hfDeleteReviewId.Value = reviewId.ToString();
            litDeleteReviewTitle.Text = Server.HtmlEncode(reviewTitle); // Show a part of review or product name
            pnlDeleteReviewModal.Visible = true;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "OpenDeleteReviewModalScript", "document.body.style.overflow = 'hidden'; setupAdminReviewModalClose();", true);
        }
        protected void btnCancelDeleteReview_Click(object sender, EventArgs e)
        {
            pnlDeleteReviewModal.Visible = false;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CloseDeleteReviewModalScript", "document.body.style.overflow = 'auto';", true);
        }
        protected void btnConfirmDeleteReview_Click(object sender, EventArgs e)
        {
            int reviewId = Convert.ToInt32(hfDeleteReviewId.Value);
            // TODO: Delete review from DB
            ShowAdminNotification($"Đã xóa đánh giá (ID: {reviewId}).", "success");
            pnlDeleteReviewModal.Visible = false;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ConfirmDeleteReview", "document.body.style.overflow = 'auto';", true);
            BindReviews(); LoadReviewStatsCards();
        }
        #endregion

        protected void btnExportReviews_Click(object sender, EventArgs e)
        {
            // TODO: Export logic for reviews
            ShowAdminNotification("Chức năng Xuất Excel đang được phát triển.", "info");
        }

        protected string GetStatusBadgeCss(object statusObj) { /* ... from previous AdminOrder code ... */ return "bg-gray-200 text-gray-700"; } // Adapt for review statuses
        protected string GetInitials(string name) { if (string.IsNullOrWhiteSpace(name)) return "?"; string[] parts = name.Split(' '); return parts.Length > 1 ? $"{parts[0][0]}{parts.Last()[0]}".ToUpper() : name.Substring(0, 1).ToUpper(); }
        protected string GetAvatarBgClass(string name) { /* ... from Customers page ... */ return "bg-blue-500"; }

        private string SerializeToJson(object obj) => new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(obj);
        private void ShowAdminNotification(string message, string type = "info") => ScriptManager.RegisterStartupScript(this.upnlReviewsPage, this.GetType(), Guid.NewGuid().ToString(), $"showNotification('{type.ToUpper()}', '{message.Replace("'", "\\\'")}', '{type}');", true); // Updated to match JS signature

        #region Dummy Data
        private List<AdminReviewItemView> GetDummyAdminReviews()
        {
            var reviews = new List<AdminReviewItemView>(); Random rand = new Random();
            string[] statuses = { "pending", "approved", "rejected", "reported" };
            string[] products = { "Robot biến hình thông minh", "Bộ xếp hình LEGO City", "Xe đua điều khiển từ xa", "Búp bê Elsa" };
            for (int i = 1; i <= 30; i++)
            {
                string currentStatus = statuses[rand.Next(statuses.Length)];
                reviews.Add(new AdminReviewItemView
                {
                    ReviewId = i,
                    ProductId = rand.Next(1, 5),
                    ProductName = products[rand.Next(products.Length)],
                    ProductImageUrl = $"https://api.placeholder.com/80/80?text=P{i}",
                    CustomerName = $"Khách hàng {(char)('A' + rand.Next(0, 26))} {rand.Next(1, 100)}",
                    ReviewDate = DateTime.Now.AddDays(-rand.Next(1, 60)).AddHours(-rand.Next(0, 23)),
                    IsVerifiedPurchase = (i % 2 == 0),
                    Rating = rand.Next(1, 6),
                    ReviewTitle = (i % 3 == 0) ? $"Tuyệt vời!" : ((i % 3 == 1) ? "Khá ổn" : "Không hài lòng lắm"),
                    ReviewText = "Đây là nội dung đánh giá mẫu cho sản phẩm. " + string.Join(" ", Enumerable.Repeat("Lorem ipsum dolor sit amet. ", rand.Next(5, 25))),
                    ImageUrls = (i % 4 == 0) ? new List<string> { $"https://api.placeholder.com/100/100?text=R{i}A", $"https://api.placeholder.com/100/100?text=R{i}B" } : new List<string>(),
                    HelpfulCount = rand.Next(0, 50),
                    ViewCount = rand.Next(10, 300),
                    OrderId = 1000 + i,
                    OrderCode = $"TL25{i:D4}",
                    Status = currentStatus,
                    StatusText = GetStatusTextForReview(currentStatus),
                    StatusBadgeCss = GetReviewStatusBadgeCss(currentStatus),
                    CardCssClass = "status-" + currentStatus,
                    AdminResponseText = (currentStatus == "approved" && i % 2 == 0) ? "Cảm ơn bạn đã đánh giá!" : "",
                    AdminResponseDate = (currentStatus == "approved" && i % 2 == 0) ? DateTime.Now.AddDays(-rand.Next(0, 2)) : (DateTime?)null,
                    IsActive = (currentStatus == "approved") // For ToggleStatus action
                });
            }
            return reviews;
        }
        private List<object> GetDummyProductsForFilter()
        {
            return new List<object> { new { ProductId = 1, ProductName = "Robot biến hình" }, new { ProductId = 2, ProductName = "LEGO City" }, new { ProductId = 3, ProductName = "Xe đua RC" } };
        }
        private string GetStatusTextForReview(string status)
        {
            switch (status) { case "pending": return "Chờ duyệt"; case "approved": return "Đã duyệt"; case "rejected": return "Từ chối"; case "reported": return "Báo cáo"; default: return "Không rõ"; }
        }
        private string GetReviewStatusBadgeCss(string status)
        {
            switch (status) { case "pending": return "bg-yellow-100 text-yellow-800"; case "approved": return "bg-green-100 text-green-800"; case "rejected": return "bg-red-100 text-red-800"; case "reported": return "bg-purple-100 text-purple-800"; default: return "bg-gray-100 text-gray-800"; }
        }

        #endregion
    }
}