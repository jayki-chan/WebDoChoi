using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WebDoChoi.Business;

namespace WebsiteDoChoi.Client
{
    public partial class ProductList : System.Web.UI.Page
    {
        private int CurrentPage
        {
            get { return ViewState["CurrentPage"] as int? ?? 1; }
            set { ViewState["CurrentPage"] = value; }
        }

        private int PageSize
        {
            get { return ViewState["PageSize"] as int? ?? 24; }
            set { ViewState["PageSize"] = value; }
        }

        private string SortBy
        {
            get { return ViewState["SortBy"] as string ?? "popular"; }
            set { ViewState["SortBy"] = value; }
        }

        private string ViewMode
        {
            get { return ViewState["ViewMode"] as string ?? "grid"; }
            set { ViewState["ViewMode"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                InitializePage();
                LoadFilters();
                LoadProducts();
            }
        }

        private void InitializePage()
        {
            // Get parameters from URL
            string categoryId = Request.QueryString["categoryId"];
            string filter = Request.QueryString["filter"];
            string search = Request.QueryString["search"];

            // Set page title and breadcrumb based on parameters
            if (!string.IsNullOrEmpty(categoryId))
            {
                SetCategoryPage(categoryId);
            }
            else if (!string.IsNullOrEmpty(filter))
            {
                SetFilterPage(filter);
            }
            else if (!string.IsNullOrEmpty(search))
            {
                SetSearchPage(search);
            }
            else
            {
                SetDefaultPage();
            }

            // Initialize dropdown values
            ddlSortBy.SelectedValue = SortBy;
            ddlPageSize.SelectedValue = PageSize.ToString();
        }

        private void SetCategoryPage(string categoryId)
        {
            // Set category-specific content
            switch (categoryId)
            {
                case "1":
                    lblCategoryTitle.Text = "Đồ chơi giáo dục";
                    lblCategoryDescription.Text = "Phát triển trí tuệ và kỹ năng học tập cho trẻ em";
                    lblBreadcrumb.Text = "Đồ chơi giáo dục";
                    Page.Title = "Đồ chơi giáo dục - ToyLand";
                    break;
                case "2":
                    lblCategoryTitle.Text = "Xe & Điều khiển";
                    lblCategoryDescription.Text = "Các loại xe đồ chơi và xe điều khiển từ xa";
                    lblBreadcrumb.Text = "Xe & Điều khiển";
                    Page.Title = "Xe & Điều khiển - ToyLand";
                    break;
                // Add more cases for other categories
                default:
                    SetDefaultPage();
                    break;
            }
        }

        private void SetFilterPage(string filter)
        {
            switch (filter)
            {
                case "bestseller":
                    lblCategoryTitle.Text = "Sản phẩm bán chạy";
                    lblCategoryDescription.Text = "Những đồ chơi được yêu thích nhất";
                    lblBreadcrumb.Text = "Bán chạy";
                    Page.Title = "Sản phẩm bán chạy - ToyLand";
                    break;
                case "promotion":
                    lblCategoryTitle.Text = "Khuyến mãi";
                    lblCategoryDescription.Text = "Sản phẩm đang có giá ưu đãi";
                    lblBreadcrumb.Text = "Khuyến mãi";
                    Page.Title = "Khuyến mãi - ToyLand";
                    break;
                case "new":
                    lblCategoryTitle.Text = "Sản phẩm mới";
                    lblCategoryDescription.Text = "Những đồ chơi mới nhất";
                    lblBreadcrumb.Text = "Sản phẩm mới";
                    Page.Title = "Sản phẩm mới - ToyLand";
                    break;
                default:
                    SetDefaultPage();
                    break;
            }
        }

        private void SetSearchPage(string search)
        {
            lblCategoryTitle.Text = $"Kết quả tìm kiếm: \"{search}\"";
            lblCategoryDescription.Text = "Các sản phẩm phù hợp với từ khóa tìm kiếm";
            lblBreadcrumb.Text = "Tìm kiếm";
            Page.Title = $"Tìm kiếm: {search} - ToyLand";
        }

        private void SetDefaultPage()
        {
            lblCategoryTitle.Text = "Tất cả sản phẩm";
            lblCategoryDescription.Text = "Khám phá bộ sưu tập đồ chơi đa dạng";
            lblBreadcrumb.Text = "Sản phẩm";
            Page.Title = "Sản phẩm - ToyLand";
        }

        private void LoadFilters()
        {
            try
            {
                // Load categories
                var categories = ProductService.GetActiveCategories();
                cblCategories.DataSource = categories;
                cblCategories.DataTextField = "Name";
                cblCategories.DataValueField = "Id";
                cblCategories.DataBind();

                // Load brands
                var brands = ProductService.GetActiveBrands();
                cblBrands.DataSource = brands;
                cblBrands.DataTextField = "Name";
                cblBrands.DataValueField = "Id";
                cblBrands.DataBind();

                // Load rating options
                rblRating.Items.Add(new ListItem("4 sao trở lên", "4"));
                rblRating.Items.Add(new ListItem("3 sao trở lên", "3"));
                rblRating.Items.Add(new ListItem("2 sao trở lên", "2"));
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadFilters Error: {ex.Message}");
            }
        }

        private void LoadProducts()
        {
            try
            {
                // Get selected filters
                var selectedCategories = cblCategories.Items.Cast<ListItem>()
                    .Where(item => item.Selected)
                    .Select(item => int.Parse(item.Value))
                    .ToList();

                var selectedBrands = cblBrands.Items.Cast<ListItem>()
                    .Where(item => item.Selected)
                    .Select(item => int.Parse(item.Value))
                    .ToList();

                decimal? minPrice = null;
                decimal? maxPrice = null;
                if (!string.IsNullOrEmpty(txtPriceFrom.Text) && !string.IsNullOrEmpty(txtPriceTo.Text))
                {
                    if (decimal.TryParse(txtPriceFrom.Text, out decimal priceFrom) &&
                        decimal.TryParse(txtPriceTo.Text, out decimal priceTo))
                    {
                        minPrice = priceFrom;
                        maxPrice = priceTo;
                    }
                }

                int? minRating = null;
                if (!string.IsNullOrEmpty(rblRating.SelectedValue))
                {
                    if (int.TryParse(rblRating.SelectedValue, out int rating))
                    {
                        minRating = rating;
                    }
                }

                // Get products using ProductService
                var products = ProductService.SearchProducts(
                    keyword: "",
                    categoryId: selectedCategories.Count > 0 ? (int?)selectedCategories.First() : null,
                    brandId: selectedBrands.Count > 0 ? (int?)selectedBrands.First() : null,
                    minPrice: minPrice,
                    maxPrice: maxPrice,
                    minRating: minRating,
                    pageSize: PageSize,
                    pageNumber: CurrentPage,
                    sortBy: SortBy
                );

                // Bind to repeater
                rptProducts.DataSource = products;
                rptProducts.DataBind();

                // Update UI elements
                UpdateProductCount(products.Count);
                LoadPagination(products.Count);

                // Show/hide no products message
                pnlNoProducts.Visible = !products.Any();
            }
            catch (Exception ex)
            {
                // Log error
                System.Diagnostics.Debug.WriteLine($"LoadProducts Error: {ex.Message}");
                // Show error message to user
                pnlNoProducts.Visible = true;
            }
        }

        private void UpdateProductCount(int totalCount)
        {
            int startIndex = (CurrentPage - 1) * PageSize + 1;
            int endIndex = Math.Min(CurrentPage * PageSize, totalCount);

            lblCurrentRange.Text = $"{startIndex}-{endIndex}";
            lblTotalProducts.Text = totalCount.ToString();
        }

        private void LoadPagination(int totalCount)
        {
            int totalPages = (int)Math.Ceiling((double)totalCount / PageSize);
            var paginationData = new List<object>();

            for (int i = 1; i <= totalPages; i++)
            {
                paginationData.Add(new
                {
                    PageNumber = i,
                    IsCurrentPage = i == CurrentPage
                });
            }

            rptPagination.DataSource = paginationData;
            rptPagination.DataBind();

            // Enable/disable navigation buttons
            btnPrevPage.Enabled = CurrentPage > 1;
            btnNextPage.Enabled = CurrentPage < totalPages;
        }

        // Helper method to generate star ratings
        protected string GenerateStars(double rating)
        {
            string stars = "";
            int fullStars = (int)Math.Floor(rating);
            bool hasHalfStar = (rating - fullStars) >= 0.5;

            // Add full stars
            for (int i = 0; i < fullStars; i++)
            {
                stars += "<i class='fas fa-star'></i>";
            }

            // Add half star
            if (hasHalfStar)
            {
                stars += "<i class='fas fa-star-half-alt'></i>";
            }

            // Add empty stars
            int totalStars = fullStars + (hasHalfStar ? 1 : 0);
            for (int i = totalStars; i < 5; i++)
            {
                stars += "<i class='far fa-star'></i>";
            }

            return stars;
        }

        // Event Handlers
        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            CurrentPage = 1; // Reset to first page when applying filters
            LoadProducts();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            // Clear all filter selections
            foreach (ListItem item in cblCategories.Items)
                item.Selected = false;
            foreach (ListItem item in cblBrands.Items)
                item.Selected = false;

            rblRating.ClearSelection();
            txtPriceFrom.Text = "";
            txtPriceTo.Text = "";
            //txtPriceRange.Text = "500000"; // Reset price range slider to middle value

            // Reset to first page and reload products
            CurrentPage = 1;
            LoadProducts();
        }

        protected void ddlSortBy_SelectedIndexChanged(object sender, EventArgs e)
        {
            SortBy = ddlSortBy.SelectedValue;
            CurrentPage = 1;
            LoadProducts();
        }

        protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
        {
            PageSize = Convert.ToInt32(ddlPageSize.SelectedValue);
            CurrentPage = 1;
            LoadProducts();
        }

        protected void btnGridView_Click(object sender, EventArgs e)
        {
            ViewMode = "grid";
            btnGridView.CssClass = "p-2 border rounded hover:bg-gray-50 transition-colors bg-primary text-white";
            btnListView.CssClass = "p-2 border rounded hover:bg-gray-50 transition-colors";
        }

        protected void btnListView_Click(object sender, EventArgs e)
        {
            ViewMode = "list";
            btnListView.CssClass = "p-2 border rounded hover:bg-gray-50 transition-colors bg-primary text-white";
            btnGridView.CssClass = "p-2 border rounded hover:bg-gray-50 transition-colors";
        }

        protected void btnPrevPage_Click(object sender, EventArgs e)
        {
            if (CurrentPage > 1)
            {
                CurrentPage--;
                LoadProducts();
            }
        }

        protected void btnNextPage_Click(object sender, EventArgs e)
        {
            CurrentPage++;
            LoadProducts();
        }

        protected void btnPage_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            CurrentPage = Convert.ToInt32(btn.CommandArgument);
            LoadProducts();
        }

        protected void rptProducts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int productId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "AddToCart")
            {
                AddToCart(productId);
            }
            else if (e.CommandName == "AddToWishlist")
            {
                AddToWishlist(productId);
            }
        }

        private void AddToCart(int productId)
        {
            try
            {
                // Get user ID if logged in
                int? userId = null;
                if (Session["UserId"] != null)
                {
                    userId = Convert.ToInt32(Session["UserId"]);
                }

                // Get session ID for guest users
                string sessionId = Session.SessionID;

                // Add to cart using CartService
                var result = CartService.AddToCart(userId, sessionId, productId);

                if (result.IsSuccess)
                {
                    // Show success message
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "success",
                        $"alert('{result.Message}');", true);
                }
                else
                {
                    // Show error message
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "error",
                        $"alert('{result.Message}');", true);
                }
            }
            catch (Exception ex)
            {
                // Log error
                System.Diagnostics.Debug.WriteLine($"AddToCart Error: {ex.Message}");
                // Show error message
                ScriptManager.RegisterStartupScript(this, this.GetType(), "error",
                    "alert('Có lỗi xảy ra khi thêm sản phẩm vào giỏ hàng!');", true);
            }
        }

        private void AddToWishlist(int productId)
        {
            // Get wishlist from session
            var wishlistItems = Session["WishlistItems"] as List<int> ?? new List<int>();

            if (!wishlistItems.Contains(productId))
            {
                wishlistItems.Add(productId);
                Session["WishlistItems"] = wishlistItems;

                ScriptManager.RegisterStartupScript(this, this.GetType(), "wishlist",
                    "alert('Đã thêm sản phẩm vào danh sách yêu thích!');", true);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "wishlist_exists",
                    "alert('Sản phẩm đã có trong danh sách yêu thích!');", true);
            }
        }

        // Filter event handlers
        protected void cblCategories_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Uncheck all other categories except the one just selected
            CheckBoxList cbl = (CheckBoxList)sender;
            for (int i = 0; i < cbl.Items.Count; i++)
            {
                if (i != cbl.SelectedIndex)
                {
                    cbl.Items[i].Selected = false;
                }
            }

            CurrentPage = 1;
            LoadProducts();
        }

        protected void cblAgeGroups_SelectedIndexChanged(object sender, EventArgs e)
        {
            CurrentPage = 1;
            LoadProducts();
        }

        protected void cblBrands_SelectedIndexChanged(object sender, EventArgs e)
        {
            CurrentPage = 1;
            LoadProducts();
        }

        protected void rblRating_SelectedIndexChanged(object sender, EventArgs e)
        {
            CurrentPage = 1;
            LoadProducts();
        }

        protected void btnAddToCart_Click(object sender, EventArgs e)
        {
            try
            {
                // Get product ID from command argument
                LinkButton btn = (LinkButton)sender;
                int productId = Convert.ToInt32(btn.CommandArgument);

                // Get user ID if logged in
                int? userId = null;
                if (Session["UserId"] != null)
                {
                    userId = Convert.ToInt32(Session["UserId"]);
                }

                // Get session ID for guest users
                string sessionId = Session.SessionID;

                // Add to cart using CartService
                var result = CartService.AddToCart(userId, sessionId, productId);

                if (result.IsSuccess)
                {
                    // Show success message
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "success",
                        $"alert('{result.Message}');", true);
                }
                else
                {
                    // Show error message
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "error",
                        $"alert('{result.Message}');", true);
                }
            }
            catch (Exception ex)
            {
                // Log error
                System.Diagnostics.Debug.WriteLine($"btnAddToCart_Click Error: {ex.Message}");
                // Show error message
                ScriptManager.RegisterStartupScript(this, this.GetType(), "error",
                    "alert('Có lỗi xảy ra khi thêm sản phẩm vào giỏ hàng!');", true);
            }
        }
    }
}