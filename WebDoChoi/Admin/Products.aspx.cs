using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO; // For file uploads
using System.Globalization;
using System.Web;

namespace WebsiteDoChoi.Admin
{
    public class AdminProductListItem // For GridView and Repeater
    {
        public int ProductId { get; set; }
        public string ProductName { get; set; }
        public string SKU { get; set; }
        public string ImageUrl { get; set; }
        public string CategoryName { get; set; }
        public decimal SalePrice { get; set; }
        public decimal OriginalPrice { get; set; }
        public int StockQuantity { get; set; }
        public int SoldCount { get; set; }
        public string Status { get; set; } // "active", "inactive", "outofstock"
        public string StatusText { get; set; }
        public bool IsHot { get; set; }
        public bool IsNew { get; set; }
        public bool IsSale { get; set; }
    }

    public class AdminProductImage // For existing images in modal
    {
        public int ImageId { get; set; }
        public string ImageUrl { get; set; }
    }


    public partial class Products : System.Web.UI.Page
    {
        private const int PageSizeAdmin = 12; // Products per page for admin grid

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ViewState["CurrentPage"] = 1;
                ViewState["ViewMode"] = "Grid"; // Default view
                PopulateFilterDropdowns();
                BindProducts();
                UpdateViewModeUI();
            }
        }

        private void PopulateFilterDropdowns()
        {
            // TODO: Populate ddlCategoryFilter and ddlCategoryModal from database
            ddlCategoryFilter.Items.Add(new ListItem("Đồ chơi giáo dục", "cat_edu"));
            ddlCategoryFilter.Items.Add(new ListItem("Robot & Nhân vật", "cat_robot"));

            ddlCategoryModal.Items.Clear();
            ddlCategoryModal.Items.Add(new ListItem("Chọn danh mục", ""));
            ddlCategoryModal.Items.Add(new ListItem("Đồ chơi giáo dục", "cat_edu_modal"));
            ddlCategoryModal.Items.Add(new ListItem("Robot & Nhân vật", "cat_robot_modal"));

            // Age range can be static or dynamic
            ddlAgeRangeModal.Items.Clear();
            ddlAgeRangeModal.Items.Add(new ListItem("Chọn độ tuổi", ""));
            ddlAgeRangeModal.Items.Add(new ListItem("0-2 tuổi", "0-2"));
            ddlAgeRangeModal.Items.Add(new ListItem("3-5 tuổi", "3-5"));
        }

        private void BindProducts()
        {
            int currentPage = Convert.ToInt32(ViewState["CurrentPage"]);
            string searchTerm = txtSearchProduct.Text.Trim();
            string categoryFilter = ddlCategoryFilter.SelectedValue;
            string statusFilter = ddlStatusFilter.SelectedValue;

            // TODO: Replace with actual data fetching from database with filtering and pagination
            List<AdminProductListItem> allProducts = GetDummyAdminProducts();

            // Apply filters
            if (!string.IsNullOrEmpty(searchTerm))
                allProducts = allProducts.Where(p => p.ProductName.ToLower().Contains(searchTerm.ToLower()) || p.SKU.ToLower().Contains(searchTerm.ToLower())).ToList();
            if (!string.IsNullOrEmpty(categoryFilter))
                allProducts = allProducts.Where(p => p.CategoryName.Contains(categoryFilter.Replace("cat_", ""))).ToList(); // Simple match
            if (!string.IsNullOrEmpty(statusFilter))
                allProducts = allProducts.Where(p => p.Status == statusFilter).ToList();


            int totalProducts = allProducts.Count;
            var pagedProducts = allProducts.Skip((currentPage - 1) * PageSizeAdmin).Take(PageSizeAdmin).ToList();

            if (ViewState["ViewMode"].ToString() == "Grid")
            {
                rptProductsGrid.DataSource = pagedProducts;
                rptProductsGrid.DataBind();
                pnlGridView.Visible = true;
                pnlListView.Visible = false;
            }
            else // List
            {
                gvProductsList.DataSource = pagedProducts;
                gvProductsList.DataBind();
                pnlGridView.Visible = false;
                pnlListView.Visible = true;
            }

            SetupPagination(totalProducts, currentPage);
            lblPageInfo.Text = $"Hiển thị {(currentPage - 1) * PageSizeAdmin + 1}-{Math.Min(currentPage * PageSizeAdmin, totalProducts)} trong tổng số {totalProducts} sản phẩm";
        }

        #region Pagination
        private void SetupPagination(int totalItems, int currentPage)
        {
            int totalPages = (int)Math.Ceiling((double)totalItems / PageSizeAdmin);
            lnkPrevPage.Enabled = currentPage > 1;
            lnkNextPage.Enabled = currentPage < totalPages;

            if (totalPages <= 1)
            {
                rptPager.Visible = false;
                lnkPrevPage.Visible = false;
                lnkNextPage.Visible = false;
                lblPageInfo.Visible = totalItems > 0; // Show if there are items, even if only one page
                return;
            }
            rptPager.Visible = true;
            lnkPrevPage.Visible = true;
            lnkNextPage.Visible = true;
            lblPageInfo.Visible = true;

            var pageNumbers = new List<object>();
            // Simple pagination: show current, prev, next, first, last, and ellipsis
            // More complex logic can be added for better UX with many pages
            int startPage = Math.Max(1, currentPage - 2);
            int endPage = Math.Min(totalPages, currentPage + 2);

            if (startPage > 1) pageNumbers.Add(new { Text = "1", Value = "1", IsCurrent = false });
            if (startPage > 2) pageNumbers.Add(new { Text = "...", Value = (startPage - 1).ToString(), IsCurrent = false }); // Ellipsis

            for (int i = startPage; i <= endPage; i++)
            {
                pageNumbers.Add(new { Text = i.ToString(), Value = i.ToString(), IsCurrent = (i == currentPage) });
            }
            if (endPage < totalPages - 1) pageNumbers.Add(new { Text = "...", Value = (endPage + 1).ToString(), IsCurrent = false }); // Ellipsis
            if (endPage < totalPages) pageNumbers.Add(new { Text = totalPages.ToString(), Value = totalPages.ToString(), IsCurrent = false });

            rptPager.DataSource = pageNumbers;
            rptPager.DataBind();
        }

        protected void Page_Changed(object sender, EventArgs e)
        {
            string commandArgument = ((LinkButton)sender).CommandArgument;
            int currentPage = Convert.ToInt32(ViewState["CurrentPage"]);
            int totalPages = (int)Math.Ceiling((double)GetDummyAdminProducts().Count / PageSizeAdmin); // Recalculate based on actual total count

            if (commandArgument == "Prev") { currentPage = Math.Max(1, currentPage - 1); }
            else if (commandArgument == "Next") { currentPage = Math.Min(totalPages, currentPage + 1); }
            else { currentPage = Convert.ToInt32(commandArgument); }

            ViewState["CurrentPage"] = currentPage;
            BindProducts();
        }
        #endregion

        #region View Mode and Filters
        protected void btnViewMode_Click(object sender, EventArgs e)
        {
            string viewMode = ((LinkButton)sender).CommandArgument;
            ViewState["ViewMode"] = viewMode;
            UpdateViewModeUI();
            BindProducts(); // Rebind to apply new view
        }

        private void UpdateViewModeUI()
        {
            if (ViewState["ViewMode"].ToString() == "Grid")
            {
                btnGridView.CssClass = "tab-button-admin active px-4 py-2 rounded-lg transition-colors";
                btnListView.CssClass = "tab-button-admin px-4 py-2 rounded-lg border border-gray-300 hover:bg-gray-50 transition-colors";
            }
            else
            {
                btnGridView.CssClass = "tab-button-admin px-4 py-2 rounded-lg border border-gray-300 hover:bg-gray-50 transition-colors";
                btnListView.CssClass = "tab-button-admin active px-4 py-2 rounded-lg transition-colors";
            }
        }

        protected void Filter_Changed(object sender, EventArgs e)
        {
            ViewState["CurrentPage"] = 1;
            BindProducts();
        }
        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            ViewState["CurrentPage"] = 1;
            BindProducts();
        }

        #endregion

        #region Product Modal (Add/Edit)
        protected void btnOpenAddProductModal_Click(object sender, EventArgs e)
        {
            hfProductId.Value = "0"; // Indicates new product
            lblModalTitle.Text = "Thêm sản phẩm mới";
            ClearProductModalForm();
            LoadExistingImages(0); // No existing images for new product
            pnlProductModal.Visible = true;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "OpenModalScript", "document.body.style.overflow = 'hidden'; setupModalClose();", true);
        }

        protected void Product_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int productId = Convert.ToInt32(e.CommandArgument);
            if (e.CommandName == "EditProduct")
            {
                LoadProductForEdit(productId);
            }
            else if (e.CommandName == "DeleteProduct")
            {
                DeleteProduct(productId);
            }
        }
        protected void gvProductsList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditProduct" || e.CommandName == "DeleteProduct")
            {
                int rowIndex = Convert.ToInt32(e.CommandArgument); // Assuming CommandArgument is RowIndex for simplicity, better to use DataKeys
                int productId = Convert.ToInt32(gvProductsList.DataKeys[rowIndex].Value);

                if (e.CommandName == "EditProduct")
                {
                    LoadProductForEdit(productId);
                }
                else if (e.CommandName == "DeleteProduct")
                {
                    DeleteProduct(productId);
                }
            }
        }
        protected void gvProductsList_RowEditing(object sender, GridViewEditEventArgs e)
        {
            // This event is for GridView's built-in edit mode, which we are not using with modal.
            // Can be left empty or used if you switch to inline editing.
            // For modal editing, CommandName="EditProduct" in RowCommand is preferred.
            int productId = Convert.ToInt32(gvProductsList.DataKeys[e.NewEditIndex].Value);
            LoadProductForEdit(productId);
        }
        protected void gvProductsList_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            // Similar to RowEditing, this is for built-in delete.
            int productId = Convert.ToInt32(gvProductsList.DataKeys[e.RowIndex].Value);
            DeleteProduct(productId);
        }


        private void LoadProductForEdit(int productId)
        {
            // TODO: Fetch product by ID from database
            AdminProductListItem product = GetDummyAdminProducts().FirstOrDefault(p => p.ProductId == productId);
            if (product != null)
            {
                hfProductId.Value = product.ProductId.ToString();
                lblModalTitle.Text = "Chỉnh sửa sản phẩm";
                txtProductNameModal.Text = product.ProductName;
                txtSKUModal.Text = product.SKU;
                // txtBarcodeModal.Text = product.Barcode; // Add Barcode to model if needed
                ddlCategoryModal.SelectedValue = "cat_robot_modal"; // Map real category ID/value
                ddlAgeRangeModal.SelectedValue = "3-5"; // Map real age range
                txtShortDescriptionModal.Text = "Mô tả ngắn demo cho " + product.ProductName;

                txtSalePriceModal.Text = product.SalePrice.ToString("F0");
                txtOriginalPriceModal.Text = product.OriginalPrice > 0 ? product.OriginalPrice.ToString("F0") : "";
                txtStockQuantityModal.Text = product.StockQuantity.ToString();
                // txtLowStockWarningModal.Text = product.LowStockWarning.ToString();
                ddlStatusModal.SelectedValue = product.Status;

                chkIsHotModal.Checked = product.IsHot;
                chkIsNewModal.Checked = product.IsNew;
                chkIsSaleModal.Checked = product.IsSale;
                // chkIsBestSellerModal.Checked = product.IsBestSeller;

                txtFullDescriptionModal.Text = "Đây là mô tả chi tiết đầy đủ cho sản phẩm " + product.ProductName + ". Bao gồm các tính năng, ưu điểm, và cách sử dụng cụ thể.";

                LoadExistingImages(productId);

                pnlProductModal.Visible = true;
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "OpenModalScript", "document.body.style.overflow = 'hidden'; setupModalClose();", true);
            }
        }

        private void LoadExistingImages(int productId)
        {
            // TODO: Fetch existing images for the product from DB
            if (productId > 0)
            { // Only for existing products
                var images = new List<AdminProductImage> {
                    new AdminProductImage { ImageId = 10, ImageUrl = "https://api.placeholder.com/100/100?text=Img1"},
                    new AdminProductImage { ImageId = 11, ImageUrl = "https://api.placeholder.com/100/100?text=Img2"}
                };
                rptExistingImages.DataSource = images;
                rptExistingImages.DataBind();
            }
            else
            {
                rptExistingImages.DataSource = null;
                rptExistingImages.DataBind();
            }
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ClearClientPreviews", "if(typeof imagePreviewContainerModal !== 'undefined' && imagePreviewContainerModal) { const clientPreviews = imagePreviewContainerModal.querySelectorAll('.client-preview'); clientPreviews.forEach(cp => cp.remove()); }", true);

        }

        protected void rptExistingImages_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteImage")
            {
                int imageId = Convert.ToInt32(e.CommandArgument);
                int productId = Convert.ToInt32(hfProductId.Value); // Ensure hfProductId has the current product ID
                                                                    // TODO: Delete image record from database for the product
                                                                    // TODO: Optionally delete the physical file from server

                // After deleting, reload images for the current product
                LoadExistingImages(productId);
                // Keep modal open
                pnlProductModal.Visible = true;
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ReOpenModalScript", "document.body.style.overflow = 'hidden'; setupModalClose();", true);
            }
        }


        protected void btnCloseModal_Click(object sender, EventArgs e)
        {
            pnlProductModal.Visible = false;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CloseModalScript", "document.body.style.overflow = 'auto';", true);
        }

        protected void btnSaveProduct_Click(object sender, EventArgs e)
        {
            Page.Validate("ProductModalValidation");
            if (Page.IsValid)
            {
                // Collect data from modal form
                int productId = Convert.ToInt32(hfProductId.Value);
                string productName = txtProductNameModal.Text.Trim();
                // ... collect all other fields ...
                string status = ((Button)sender).CommandName == "SaveDraft" ? "draft" : ddlStatusModal.SelectedValue;


                // Handle Image Uploads
                List<string> uploadedImagePaths = new List<string>();
                if (fuProductImages.HasFiles)
                {
                    string uploadFolder = Server.MapPath("~/Content/Images/Products/");
                    if (!Directory.Exists(uploadFolder))
                    {
                        Directory.CreateDirectory(uploadFolder);
                    }
                    foreach (HttpPostedFile uploadedFile in fuProductImages.PostedFiles)
                    {
                        if (uploadedFile.ContentLength > 0 && (uploadedFile.ContentType == "image/jpeg" || uploadedFile.ContentType == "image/png" || uploadedFile.ContentType == "image/gif" || uploadedFile.ContentType == "image/webp"))
                        {
                            string fileName = Path.GetFileNameWithoutExtension(uploadedFile.FileName);
                            string fileExtension = Path.GetExtension(uploadedFile.FileName);
                            string uniqueFileName = $"{fileName}_{DateTime.Now.Ticks}{fileExtension}";
                            string filePath = Path.Combine(uploadFolder, uniqueFileName);
                            uploadedFile.SaveAs(filePath);
                            uploadedImagePaths.Add($"/Content/Images/Products/{uniqueFileName}"); // Relative path to store in DB
                        }
                    }
                }

                // TODO: Save product data (new or update) to database
                // If productId == 0, it's a new product. Otherwise, update.
                // Save uploadedImagePaths to database, associated with the product.

                pnlProductModal.Visible = false;
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CloseModalScriptAndAlert", "document.body.style.overflow = 'auto'; alert('Sản phẩm đã được lưu thành công!');", true);
                BindProducts(); // Refresh product list
            }
            else
            {
                // Modal stays open due to validation failure
                pnlProductModal.Visible = true; // Ensure it stays visible
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ModalValidationFail", "document.body.style.overflow = 'hidden'; setupModalClose();", true);
            }
        }

        private void ClearProductModalForm()
        {
            txtProductNameModal.Text = "";
            txtSKUModal.Text = "";
            txtBarcodeModal.Text = "";
            ddlCategoryModal.ClearSelection();
            ddlAgeRangeModal.ClearSelection();
            txtShortDescriptionModal.Text = "";
            txtSalePriceModal.Text = "";
            txtOriginalPriceModal.Text = "";
            txtStockQuantityModal.Text = "";
            // txtLowStockWarningModal.Text = "";
            ddlStatusModal.SelectedValue = "active";
            chkIsHotModal.Checked = false;
            chkIsNewModal.Checked = false;
            chkIsSaleModal.Checked = false;
            // chkIsBestSellerModal.Checked = false;
            txtFullDescriptionModal.Text = "";
            rptExistingImages.DataSource = null; // Clear existing images previews
            rptExistingImages.DataBind();
            // Clear client-side previews (important if modal is reused without full page refresh)
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ClearClientPreviews", "if(typeof imagePreviewContainerModal !== 'undefined' && imagePreviewContainerModal) { imagePreviewContainerModal.innerHTML = ''; }", true);
        }


        private void DeleteProduct(int productId)
        {
            // TODO: Implement product deletion logic (database)
            // Consider soft delete vs hard delete
            // Remove product from CurrentProductList (if using session for demo) or re-fetch

            // For demo, just rebind
            BindProducts();
            ScriptManager.RegisterStartupScript(this, GetType(), "DeleteSuccess", "alert('Sản phẩm đã được xóa.');", true);
        }

        protected string GetStatusBadgeCss(object statusObj)
        {
            string status = statusObj?.ToString().ToLower() ?? "";
            switch (status)
            {
                case "active": return "bg-green-100 text-green-800";
                case "inactive": return "bg-gray-100 text-gray-800";
                case "outofstock": return "bg-red-100 text-red-800";
                case "draft": return "bg-blue-100 text-blue-800";
                default: return "bg-gray-100 text-gray-800";
            }
        }

        #endregion

        #region Dummy Data (Replace with Database calls)
        private List<AdminProductListItem> GetDummyAdminProducts()
        {
            var products = new List<AdminProductListItem>();
            for (int i = 1; i <= 30; i++)
            {
                products.Add(new AdminProductListItem
                {
                    ProductId = i,
                    ProductName = $"Đồ chơi Robot Biến Hình {i}",
                    SKU = $"TOY-ROBO-{i:D3}",
                    ImageUrl = $"https://api.placeholder.com/300/300?text=Toy{i}",
                    CategoryName = (i % 3 == 0) ? "Robot & Nhân vật" : ((i % 3 == 1) ? "Đồ chơi giáo dục" : "Xe điều khiển"),
                    SalePrice = 500000 + (i * 10000),
                    OriginalPrice = (i % 2 == 0) ? (600000 + (i * 10000)) : (500000 + (i * 10000)),
                    StockQuantity = 20 + i,
                    SoldCount = 100 - i,
                    Status = (i % 5 == 0) ? "outofstock" : ((i % 4 == 0) ? "inactive" : "active"),
                    StatusText = (i % 5 == 0) ? "Hết hàng" : ((i % 4 == 0) ? "Tạm dừng" : "Đang bán"),
                    IsHot = (i % 7 == 0),
                    IsNew = (DateTime.Now.AddDays(-i * 3) > DateTime.Now.AddMonths(-1)), // New if within last month
                    IsSale = (i % 2 == 0) && (600000 + (i * 10000)) > (500000 + (i * 10000))
                });
            }
            return products;
        }
        #endregion
    }
}