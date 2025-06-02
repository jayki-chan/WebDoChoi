using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Text; // For StringBuilder in TreeView


namespace WebsiteDoChoi.Admin
{
    public class AdminCategoryView
    {
        public int CategoryId { get; set; }
        public string CategoryName { get; set; }
        public string Slug { get; set; }
        public string Description { get; set; }
        public int ParentId { get; set; }
        public string ParentCategoryName { get; set; } // For display
        public int SortOrder { get; set; }
        public string IconCssClass { get; set; }
        public string ImageUrl { get; set; }
        public bool IsActive { get; set; }
        public DateTime DateCreated { get; set; }
        public int ProductCount { get; set; }
        public int SubCategoryCount { get; set; }
        public List<AdminCategoryView> Children { get; set; } = new List<AdminCategoryView>();
    }

    public class FontAwesomeIcon
    {
        public string ClassName { get; set; }
        public string Unicode { get; set; } // Not strictly needed for this display but good to have
    }


    public partial class Categories : System.Web.UI.Page
    {
        private const int CategoriesPageSize = 9; // Categories per page for grid view

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ViewState["CurrentCategoryPage"] = 1;
                ViewState["CategoryViewMode"] = "Grid"; // Default "Grid" or "Tree"
                PopulateCategoryFilterDropdowns();
                LoadCategoryStats();
                BindCategories();
                UpdateViewModeUI();
            }
            // Ensure modal script is registered if modal is meant to be open after postback
            if (pnlCategoryModal.Visible)
            {
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ReOpenModalScript", "document.body.style.overflow = 'hidden'; setupModalClose();", true);
            }
        }

        private void PopulateCategoryFilterDropdowns()
        {
            ddlCategoryTypeFilter.SelectedValue = "";
            ddlCategorySortFilter.SelectedValue = "sort_order";
            ddlCategoryStatusFilter.SelectedValue = "";

            // Populate Parent Category DropDown in Modal
            ddlParentCategoryModal.Items.Clear();
            ddlParentCategoryModal.Items.Add(new ListItem("-- Danh mục gốc --", "0"));
            var parentCategories = GetDummyAdminCategories().Where(c => c.ParentId == 0).OrderBy(c => c.CategoryName).ToList(); // Fetch only top-level for parent selection
            foreach (var cat in parentCategories)
            {
                ddlParentCategoryModal.Items.Add(new ListItem(cat.CategoryName, cat.CategoryId.ToString()));
            }

            // Populate Icon Picker
            litIconPicker.Text = RenderIconPicker();
        }

        private void LoadCategoryStats()
        {
            // TODO: Fetch actual stats from DB
            var allCats = GetDummyAdminCategories();
            lblTotalCategories.Text = allCats.Count.ToString();
            lblParentCategories.Text = allCats.Count(c => c.ParentId == 0).ToString();
            lblChildCategories.Text = allCats.Count(c => c.ParentId != 0).ToString();
            var mostProductsCat = allCats.OrderByDescending(c => c.ProductCount).FirstOrDefault();
            if (mostProductsCat != null)
            {
                lblMostProductsCount.Text = $"({mostProductsCat.ProductCount} SP)";
            }
            else
            {
                lblMostProductsCategoryName.Text = "N/A";
                lblMostProductsCount.Text = "";
            }
        }

        private void BindCategories()
        {
            int currentPage = Convert.ToInt32(ViewState["CurrentCategoryPage"]);
            string searchTerm = txtSearchCategory.Text.Trim().ToLower();
            string statusFilter = ddlCategoryStatusFilter.SelectedValue;
            string typeFilter = ddlCategoryTypeFilter.SelectedValue;
            string sortFilter = ddlCategorySortFilter.SelectedValue;

            List<AdminCategoryView> allCategories = GetDummyAdminCategories();

            // Apply Filters
            if (!string.IsNullOrEmpty(searchTerm))
                allCategories = allCategories.Where(c => c.CategoryName.ToLower().Contains(searchTerm) || c.Slug.ToLower().Contains(searchTerm)).ToList();
            if (!string.IsNullOrEmpty(statusFilter))
                allCategories = allCategories.Where(c => (c.IsActive && statusFilter == "active") || (!c.IsActive && statusFilter == "inactive")).ToList();
            if (!string.IsNullOrEmpty(typeFilter))
            {
                if (typeFilter == "parent") allCategories = allCategories.Where(c => c.ParentId == 0).ToList();
                else if (typeFilter == "child") allCategories = allCategories.Where(c => c.ParentId != 0).ToList();
            }

            // Apply Sorting
            switch (sortFilter)
            {
                case "name_asc": allCategories = allCategories.OrderBy(c => c.CategoryName).ToList(); break;
                case "name_desc": allCategories = allCategories.OrderByDescending(c => c.CategoryName).ToList(); break;
                case "created_at_desc": allCategories = allCategories.OrderByDescending(c => c.DateCreated).ToList(); break;
                case "product_count_desc": allCategories = allCategories.OrderByDescending(c => c.ProductCount).ToList(); break;
                default: allCategories = allCategories.OrderBy(c => c.SortOrder).ThenBy(c => c.CategoryName).ToList(); break; // Default sort_order
            }

            if (ViewState["CategoryViewMode"].ToString() == "Grid")
            {
                pnlCategoriesGrid.Visible = true;
                pnlCategoriesTree.Visible = false;
                int totalCategories = allCategories.Count;
                var pagedCategories = allCategories.Skip((currentPage - 1) * CategoriesPageSize).Take(CategoriesPageSize).ToList();
                rptCategoriesGrid.DataSource = pagedCategories;
                rptCategoriesGrid.DataBind();
                SetupCategoryPagination(totalCategories, currentPage);
                lblCategoryPageInfo.Text = $"Hiển thị {(currentPage - 1) * CategoriesPageSize + 1}-{Math.Min(currentPage * CategoriesPageSize, totalCategories)} trong tổng số {totalCategories} danh mục";
            }
            else // Tree View
            {
                pnlCategoriesGrid.Visible = false;
                pnlCategoriesTree.Visible = true;
                litCategoryTree.Text = BuildCategoryTreeHtml(allCategories.Where(c => c.ParentId == 0).ToList(), allCategories);
                pnlNoCategoriesTree.Visible = !allCategories.Any(c => c.ParentId == 0);
                // Hide pagination for tree view
                lblCategoryPageInfo.Visible = false;
                FindControl("lnkCategoryPrevPage").Visible = false; // FindControl as it's outside UpdatePanel but needs to be part of it
                FindControl("rptCategoryPager").Visible = false;
                FindControl("lnkCategoryNextPage").Visible = false;

            }
        }

        private string BuildCategoryTreeHtml(List<AdminCategoryView> parentCategories, List<AdminCategoryView> allCategories, int level = 0)
        {
            if (!parentCategories.Any()) return "";

            StringBuilder sb = new StringBuilder();
            foreach (var cat in parentCategories.OrderBy(c => c.SortOrder))
            {
                var children = allCategories.Where(c => c.ParentId == cat.CategoryId).OrderBy(c => c.SortOrder).ToList();
                sb.Append($"<div class='category-tree-item mb-2' data-category-id='{cat.CategoryId}'>");
                sb.Append($"  <div class='flex items-center justify-between p-3 border {(level == 0 ? "border-gray-200 parent-category" : "border-gray-100 child-category")} rounded-lg hover:border-secondary transition-colors {(level > 0 ? "ml-4" : "")}'>");
                sb.Append($"      <div class='flex items-center space-x-3'>");
                if (children.Any())
                {
                    sb.Append($"          <button type='button' class='tree-node-toggle text-gray-400 hover:text-gray-600' onclick='toggleTreeNode(event, {cat.CategoryId})'><i class='fas fa-chevron-right' id='{upnlCategories.ClientID}_tree-arrow-{cat.CategoryId}'></i></button>");
                }
                else
                {
                    sb.Append($"          <span class='tree-node-toggle text-gray-300'><i class='fas fa-minus'></i></span>"); // Placeholder for alignment
                }
                sb.Append($"          <div class='w-8 h-8 {GetCategoryIconBgColor(cat.IconCssClass)} rounded-lg flex items-center justify-center text-white text-base'><i class='{cat.IconCssClass ?? "fas fa-tag"}'></i></div>");
                sb.Append($"          <div><h4 class='font-medium text-gray-800 text-sm'>{cat.CategoryName}</h4><p class='text-xs text-gray-500'>{cat.ProductCount} SP • {cat.SubCategoryCount} mục con</p></div>");
                sb.Append($"      </div>");
                sb.Append($"      <div class='flex items-center space-x-2'>");
                sb.Append($"          <span class='text-xs px-2 py-1 rounded-full {(cat.IsActive ? "bg-green-100 text-green-800" : "bg-red-100 text-red-800")}'>{(cat.IsActive ? "Hoạt động" : "Tạm dừng")}</span>");

                // Actions (Edit, Add Sub, Toggle Status, Delete) - Simplified for tree view, could open modal
                sb.Append($"          <asp:LinkButton runat=\"server\" CommandName=\"EditCategory\" CommandArgument=\"{cat.CategoryId}\" OnClick=\"TreeAction_Click\" CssClass=\"text-gray-400 hover:text-primary\" ToolTip=\"Sửa\"><i class=\"fas fa-edit\"></i></asp:LinkButton>");
                if (level < 2)
                { // Limit nesting for "Add Sub" in tree view for simplicity
                    sb.Append($"          <asp:LinkButton runat=\"server\" CommandName=\"AddSubCategory\" CommandArgument=\"{cat.CategoryId}\" OnClick=\"TreeAction_Click\" CssClass=\"text-gray-400 hover:text-green-500\" ToolTip=\"Thêm mục con\"><i class=\"fas fa-plus-circle\"></i></asp:LinkButton>");
                }
                sb.Append($"          <asp:LinkButton runat=\"server\" CommandName=\"ToggleStatus\" CommandArgument=\"{cat.CategoryId},{cat.IsActive}\" OnClick=\"TreeAction_Click\" CssClass=\"text-gray-400 hover:text-yellow-500\" ToolTip=\"{(cat.IsActive ? "Tạm dừng" : "Kích hoạt")}\"><i class=\"fas fa-toggle-on\"></i></asp:LinkButton>");
                sb.Append($"          <asp:LinkButton runat=\"server\" CommandName=\"DeleteCategory\" CommandArgument=\"{cat.CategoryId}\" OnClientClick=\"return openDeleteConfirmation('{cat.CategoryId}', '{Server.HtmlEncode(cat.CategoryName.Replace("'", "\\'"))}');\" CssClass=\"text-gray-400 hover:text-red-500\" ToolTip=\"Xóa\"><i class=\"fas fa-trash\"></i></asp:LinkButton>");

                sb.Append($"      </div>");
                sb.Append($"  </div>");

                if (children.Any())
                {
                    sb.Append($"  <div class='tree-children ml-4 mt-2 space-y-2 hidden' id='{upnlCategories.ClientID}_tree-children-{cat.CategoryId}'>");
                    sb.Append($"      <div class='tree-line-admin'>");
                    sb.Append(BuildCategoryTreeHtml(children, allCategories, level + 1)); // Recursive call
                    sb.Append($"      </div>");
                    sb.Append($"  </div>");
                }
                sb.Append($"</div>");
            }
            return sb.ToString();
        }
        protected void TreeAction_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            string commandName = btn.CommandName;
            string[] commandArgs = btn.CommandArgument.Split(',');
            int categoryId = Convert.ToInt32(commandArgs[0]);

            if (commandName == "EditCategory") LoadCategoryForEdit(categoryId);
            else if (commandName == "AddSubCategory") OpenAddSubCategoryModal(categoryId);
            else if (commandName == "ToggleStatus") ToggleCategoryStatus(categoryId, Convert.ToBoolean(commandArgs[1]));
            // Delete is handled by client-side confirmation first, then server-side if needed

            // Important: After action, re-bind to reflect changes, ensuring modal stays visible if it should
            if (pnlCategoryModal.Visible)
            {
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ReOpenModalTreeAction", "document.body.style.overflow = 'hidden'; setupModalClose();", true);
            }
        }


        #region Pagination for Categories
        private void SetupCategoryPagination(int totalItems, int currentPage)
        {
            int totalPages = (int)Math.Ceiling((double)totalItems / CategoriesPageSize);
            lnkCategoryPrevPage.Enabled = currentPage > 1;
            lnkCategoryNextPage.Enabled = currentPage < totalPages;

            if (totalPages <= 1)
            {
                rptCategoryPager.Visible = false;
                lnkCategoryPrevPage.Visible = false;
                lnkCategoryNextPage.Visible = false;
                lblCategoryPageInfo.Visible = totalItems > 0;
                return;
            }
            rptCategoryPager.Visible = true;
            lnkCategoryPrevPage.Visible = true;
            lnkCategoryNextPage.Visible = true;
            lblCategoryPageInfo.Visible = true;


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

            rptCategoryPager.DataSource = pageNumbers;
            rptCategoryPager.DataBind();
        }

        protected void CategoryPage_Changed(object sender, EventArgs e)
        {
            string commandArgument = ((LinkButton)sender).CommandArgument;
            int currentPage = Convert.ToInt32(ViewState["CurrentCategoryPage"]);
            var filteredCategories = GetFilteredCategoriesForCount();
            int totalPages = (int)Math.Ceiling((double)filteredCategories.Count / CategoriesPageSize);

            if (commandArgument == "Prev") { currentPage = Math.Max(1, currentPage - 1); }
            else if (commandArgument == "Next") { currentPage = Math.Min(totalPages, currentPage + 1); }
            else { currentPage = Convert.ToInt32(commandArgument); }

            ViewState["CurrentCategoryPage"] = currentPage;
            BindCategories();
        }
        private List<AdminCategoryView> GetFilteredCategoriesForCount()
        {
            string searchTerm = txtSearchCategory.Text.Trim().ToLower();
            string statusFilter = ddlCategoryStatusFilter.SelectedValue;
            string typeFilter = ddlCategoryTypeFilter.SelectedValue;
            List<AdminCategoryView> allCategories = GetDummyAdminCategories();

            if (!string.IsNullOrEmpty(searchTerm))
                allCategories = allCategories.Where(c => c.CategoryName.ToLower().Contains(searchTerm) || c.Slug.ToLower().Contains(searchTerm)).ToList();
            if (!string.IsNullOrEmpty(statusFilter))
                allCategories = allCategories.Where(c => (c.IsActive && statusFilter == "active") || (!c.IsActive && statusFilter == "inactive")).ToList();
            if (!string.IsNullOrEmpty(typeFilter))
            {
                if (typeFilter == "parent") allCategories = allCategories.Where(c => c.ParentId == 0).ToList();
                else if (typeFilter == "child") allCategories = allCategories.Where(c => c.ParentId != 0).ToList();
            }
            return allCategories;
        }
        #endregion

        protected void btnToggleView_Click(object sender, EventArgs e)
        {
            if (ViewState["CategoryViewMode"].ToString() == "Grid")
            {
                ViewState["CategoryViewMode"] = "Tree";
                litToggleViewText.Text = "Xem lưới";
            }
            else
            {
                ViewState["CategoryViewMode"] = "Grid";
                litToggleViewText.Text = "Xem cây";
            }
            BindCategories();
        }

        private void UpdateViewModeUI()
        { // Called from Page_Load or after view toggle
            if (ViewState["CategoryViewMode"].ToString() == "Grid")
            {
                litToggleViewText.Text = "Xem cây";
            }
            else
            {
                litToggleViewText.Text = "Xem lưới";
            }
        }


        protected void btnApplyCategoryFilters_Click(object sender, EventArgs e)
        {
            ViewState["CurrentCategoryPage"] = 1;
            BindCategories();
        }
        protected void btnResetCategoryFilters_Click(object sender, EventArgs e)
        {
            txtSearchCategory.Text = "";
            ddlCategoryStatusFilter.ClearSelection();
            ddlCategoryTypeFilter.ClearSelection();
            ddlCategorySortFilter.ClearSelection();
            ViewState["CurrentCategoryPage"] = 1;
            BindCategories();
        }

        protected void Category_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string[] args = e.CommandArgument.ToString().Split(',');
            int categoryId = Convert.ToInt32(args[0]);

            if (e.CommandName == "EditCategory") LoadCategoryForEdit(categoryId);
            else if (e.CommandName == "DeleteCategory") OpenDeleteConfirmationModal(categoryId, GetCategoryNameById(categoryId) /* Fetch name */);
            else if (e.CommandName == "AddSubCategory") OpenAddSubCategoryModal(categoryId);
            else if (e.CommandName == "ToggleStatus") ToggleCategoryStatus(categoryId, Convert.ToBoolean(args[1]));
        }

        private void OpenAddSubCategoryModal(int parentId)
        {
            hfCategoryId.Value = "0"; // New category
            lblCategoryModalTitle.Text = "Thêm danh mục con";
            ClearCategoryModalForm();
            ddlParentCategoryModal.SelectedValue = parentId.ToString();
            pnlCategoryModal.Visible = true;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "OpenModalAddSub", "document.body.style.overflow = 'hidden'; setupModalClose(); selectIcon('fas fa-tag', null);", true); // Select default icon
        }

        private void ToggleCategoryStatus(int categoryId, bool currentIsActive)
        {
            // TODO: Update status in DB
            // UpdateCategoryStatusInDB(categoryId, !currentIsActive);
            BindCategories();
        }

        private string GetCategoryNameById(int categoryId)
        {
            // Placeholder: fetch from your data source
            var cat = GetDummyAdminCategories().FirstOrDefault(c => c.CategoryId == categoryId);
            return cat != null ? cat.CategoryName : "Không rõ";
        }



        #region Category Modal
        protected void btnOpenAddCategoryModal_Click(object sender, EventArgs e)
        {
            hfCategoryId.Value = "0";
            lblCategoryModalTitle.Text = "Thêm danh mục mới";
            ClearCategoryModalForm();
            pnlCategoryModal.Visible = true;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "OpenModalAdd", "document.body.style.overflow = 'hidden'; setupModalClose(); selectIcon('fas fa-tag', null);", true);
        }

        private void LoadCategoryForEdit(int categoryId)
        {
            // TODO: Fetch category by ID from DB
            AdminCategoryView category = GetDummyAdminCategories().FirstOrDefault(c => c.CategoryId == categoryId);
            if (category != null)
            {
                hfCategoryId.Value = category.CategoryId.ToString();
                lblCategoryModalTitle.Text = "Chỉnh sửa danh mục";
                txtCategoryNameModal.Text = category.CategoryName;
                txtCategorySlugModal.Text = category.Slug;
                txtCategoryDescriptionModal.Text = category.Description;
                ddlParentCategoryModal.SelectedValue = category.ParentId.ToString();
                txtSortOrderModal.Text = category.SortOrder.ToString();
                hfSelectedIcon.Value = category.IconCssClass;
                chkIsActiveModal.Checked = category.IsActive;
                // txtSeoTitleModal.Text = category.SeoTitle;
                // txtSeoDescriptionModal.Text = category.SeoDescription;
                if (!string.IsNullOrEmpty(category.ImageUrl))
                {
                    imgCategoryImagePreviewModal.ImageUrl = ResolveUrl(category.ImageUrl); // Assuming relative path
                    imgCategoryImagePreviewModal.Visible = true;
                    hfExistingImageUrlModal.Value = category.ImageUrl;
                }
                else
                {
                    imgCategoryImagePreviewModal.Visible = false;
                    hfExistingImageUrlModal.Value = "";
                }

                pnlCategoryModal.Visible = true;
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "OpenModalEdit", $"document.body.style.overflow = 'hidden'; setupModalClose(); selectIcon('{category.IconCssClass}', null);", true);
            }
        }

        protected void btnCloseCategoryModal_Click(object sender, EventArgs e)
        {
            pnlCategoryModal.Visible = false;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CloseModalScriptCat", "document.body.style.overflow = 'auto';", true);
        }

        protected void btnSaveCategory_Click(object sender, EventArgs e)
        {
            Page.Validate("CategoryValidation");
            if (Page.IsValid)
            {
                int categoryId = Convert.ToInt32(hfCategoryId.Value);
                AdminCategoryView category = new AdminCategoryView
                {
                    CategoryId = categoryId,
                    CategoryName = txtCategoryNameModal.Text.Trim(),
                    Description = txtCategoryDescriptionModal.Text.Trim(),
                    ParentId = Convert.ToInt32(ddlParentCategoryModal.SelectedValue),
                    SortOrder = Convert.ToInt32(txtSortOrderModal.Text),
                    IconCssClass = hfSelectedIcon.Value,
                    IsActive = chkIsActiveModal.Checked,
                    // SeoTitle = txtSeoTitleModal.Text.Trim(),
                    // SeoDescription = txtSeoDescriptionModal.Text.Trim()
                };

                string imageUrl = hfExistingImageUrlModal.Value; // Keep existing if no new file
                if (fuCategoryImageModal.HasFile)
                {
                    try
                    {
                        string uploadFolder = Server.MapPath("~/Content/Images/Categories/");
                        if (!Directory.Exists(uploadFolder)) Directory.CreateDirectory(uploadFolder);
                        string fileName = Path.GetFileNameWithoutExtension(fuCategoryImageModal.FileName);
                        string fileExtension = Path.GetExtension(fuCategoryImageModal.FileName);
                    }
                    catch (Exception ex)
                    {
                        // Handle upload error - maybe show message
                        pnlCategoryModal.Visible = true; // Keep modal open
                        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ReOpenModalOnError", "document.body.style.overflow = 'hidden'; setupModalClose();", true);
                        return;
                    }
                }
                category.ImageUrl = imageUrl;

                // TODO: Save category to DB (insert if categoryId == 0, else update)
                // SaveCategoryToDb(category);

                pnlCategoryModal.Visible = false;
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CloseModalAndNotify", $"document.body.style.overflow = 'auto'; showNotification('Danh mục đã được lưu thành công!', 'success');", true);
                BindCategories(); // Refresh list
                LoadCategoryStats(); // Refresh stats
            }
            else
            {
                pnlCategoryModal.Visible = true; // Keep modal open if validation fails
                ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ReOpenModalValidation", "document.body.style.overflow = 'hidden'; setupModalClose();", true);
            }
        }

        private void ClearCategoryModalForm()
        {
            txtCategoryNameModal.Text = "";
            txtCategorySlugModal.Text = "";
            txtCategoryDescriptionModal.Text = "";
            ddlParentCategoryModal.ClearSelection();
            if (ddlParentCategoryModal.Items.FindByValue("0") != null) ddlParentCategoryModal.SelectedValue = "0";
            txtSortOrderModal.Text = "0";
            hfSelectedIcon.Value = "fas fa-tag"; // Default icon
            imgCategoryImagePreviewModal.Visible = false;
            imgCategoryImagePreviewModal.ImageUrl = "";
            hfExistingImageUrlModal.Value = "";
            // txtSeoTitleModal.Text = "";
            // txtSeoDescriptionModal.Text = "";
            chkIsActiveModal.Checked = true;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "ResetIconPreview", "selectIcon('fas fa-tag', null);", true);
        }
        #endregion

        #region Delete Confirmation Modal
        private void OpenDeleteConfirmationModal(int categoryId, string categoryName)
        {
            hfDeleteCategoryId.Value = categoryId.ToString();
            litDeleteCategoryName.Text = Server.HtmlEncode(categoryName);
            pnlDeleteModal.Visible = true;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "OpenDeleteModalScript", "document.body.style.overflow = 'hidden'; setupModalClose();", true);
        }
        protected void btnCancelDelete_Click(object sender, EventArgs e)
        {
            pnlDeleteModal.Visible = false;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CloseDeleteModalScript", "document.body.style.overflow = 'auto';", true);
        }
        protected void btnConfirmDelete_Click(object sender, EventArgs e)
        {
            int categoryId = Convert.ToInt32(hfDeleteCategoryId.Value);
            // TODO: Delete category from DB (handle children appropriately - e.g., reassign or delete)
            // DeleteCategoryFromDb(categoryId);
            pnlDeleteModal.Visible = false;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CloseDeleteModalAndRefresh", "document.body.style.overflow = 'auto';", true);
            BindCategories();
            LoadCategoryStats();
        }
        #endregion

        protected void btnExportCategories_Click(object sender, EventArgs e) // Renamed from exportCustomers
        {
           
        }

        // Icon Picker HTML Generation
        private string RenderIconPicker()
        {
            var icons = GetFontAwesomeIcons(); // Get your list of icons
            StringBuilder sb = new StringBuilder();
            foreach (var icon in icons)
            {
                sb.Append($"<div class='icon-option-admin' onclick=\"selectIcon('{icon.ClassName}', event)\" title='{icon.ClassName}'><i class='{icon.ClassName}'></i></div>");
            }
            return sb.ToString();
        }
        private List<FontAwesomeIcon> GetFontAwesomeIcons()
        {
            // This list should be comprehensive or fetched dynamically if possible
            return new List<FontAwesomeIcon> {
                new FontAwesomeIcon { ClassName="fas fa-tag"}, new FontAwesomeIcon { ClassName="fas fa-puzzle-piece"},
                new FontAwesomeIcon { ClassName="fas fa-car"}, new FontAwesomeIcon { ClassName="fas fa-robot"},
                new FontAwesomeIcon { ClassName="fas fa-building"}, new FontAwesomeIcon { ClassName="fas fa-baby"},
                new FontAwesomeIcon { ClassName="fas fa-chess"}, new FontAwesomeIcon { ClassName="fas fa-paint-brush"},
                new FontAwesomeIcon { ClassName="fas fa-basketball-ball"}, new FontAwesomeIcon { ClassName="fas fa-graduation-cap"},
                new FontAwesomeIcon { ClassName="fas fa-book"}, new FontAwesomeIcon { ClassName="fas fa-shapes"},
                new FontAwesomeIcon { ClassName="fas fa-rocket"}, new FontAwesomeIcon { ClassName="fas fa-gamepad"},
                new FontAwesomeIcon { ClassName="fas fa-music"}, new FontAwesomeIcon { ClassName="fas fa-palette"}
                // Add more icons
            };
        }
        protected string GetCategoryIconBgColor(string iconClass)
        {
            // Simple logic for varied icon backgrounds in grid (optional)
            if (string.IsNullOrEmpty(iconClass)) return "bg-gray-300";
            int hash = Math.Abs(iconClass.GetHashCode());
            string[] colors = { "bg-blue-500", "bg-green-500", "bg-purple-500", "bg-red-500", "bg-yellow-500", "bg-indigo-500", "bg-pink-500" };
            return colors[hash % colors.Length];
        }

        #region Dummy Data
        private List<AdminCategoryView> GetDummyAdminCategories()
        {
            var categories = new List<AdminCategoryView>();
            Random rand = new Random();
            // Parent Categories
            for (int i = 1; i <= 8; i++)
            {
                var parent = new AdminCategoryView
                {
                    CategoryId = i,
                    CategoryName = $"Danh mục cha {i}",
                    Slug = $"danh-muc-cha-{i}",
                    Description = $"Mô tả cho danh mục cha số {i}. Đây là một danh mục quan trọng.",
                    ParentId = 0,
                    SortOrder = i,
                    IconCssClass = GetFontAwesomeIcons()[i % GetFontAwesomeIcons().Count].ClassName,
                    ImageUrl = (i % 3 == 0) ? $"https://api.placeholder.com/150/150?text=Cat{i}" : "",
                    IsActive = (i % 5 != 0),
                    DateCreated = DateTime.Now.AddMonths(-i),
                    ProductCount = rand.Next(10, 100)
                };
                categories.Add(parent);
            }
            // Child Categories
            for (int i = 1; i <= 5; i++)
            { // Add some children to first few parents
                for (int j = 1; j <= rand.Next(1, 4); j++)
                {
                    int childId = 100 + i * 10 + j;
                    categories.Add(new AdminCategoryView
                    {
                        CategoryId = childId,
                        CategoryName = $"Mục con {j} của Cha {i}",
                        Slug = $"muc-con-{j}-cha-{i}",
                        Description = $"Mô tả cho mục con {j} thuộc danh mục cha {i}.",
                        ParentId = i,
                        SortOrder = j,
                        IconCssClass = GetFontAwesomeIcons()[(i + j) % GetFontAwesomeIcons().Count].ClassName,
                        IsActive = (childId % 6 != 0),
                        DateCreated = DateTime.Now.AddMonths(-i).AddDays(j),
                        ProductCount = rand.Next(5, 50)
                    });
                }
            }
            // Calculate SubCategoryCount
            foreach (var cat in categories)
            {
                cat.SubCategoryCount = categories.Count(c => c.ParentId == cat.CategoryId);
            }
            return categories;
        }
        #endregion
    }
}