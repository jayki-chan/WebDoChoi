<%@ Page Title="Quản lý Danh mục - ToyLand Admin" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="Categories.aspx.cs" Inherits="WebsiteDoChoi.Admin.Categories" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitleContent" runat="server">
    <h1 class="text-xl md:text-2xl font-bold text-gray-800">Quản lý Danh mục</h1>
</asp:Content>

<asp:Content ID="AdminHeadCategories" ContentPlaceHolderID="AdminHeadContent" runat="server">
    <style>
        .category-card-admin { transition: all 0.2s ease-out; border-left: 4px solid transparent; }
        .category-card-admin:hover { transform: translateY(-3px); box-shadow: 0 6px 16px rgba(0,0,0,0.08); border-left-color: #FF6B6B; }
        .category-card-admin.parent-category { border-left-color: #4ECDC4; }
        .category-card-admin.child-category { border-left-color: #FFE66D; margin-left: 0.5rem; /* md:ml-1rem for larger indent on md+ */ }
        
        .modal-admin-category { backdrop-filter: blur(5px); }
        .icon-picker-admin { display: grid; grid-template-columns: repeat(auto-fill, minmax(40px, 1fr)); gap: 0.5rem; max-height: 180px; overflow-y: auto; padding: 0.5rem; border: 1px solid #e5e7eb; border-radius: 0.375rem; }
        .icon-option-admin { padding: 0.5rem; border: 2px solid transparent; border-radius: 0.375rem; cursor: pointer; transition: all 0.2s ease; text-align: center; }
        .icon-option-admin:hover { border-color: #FF6B6B; background-color: rgba(255, 107, 107, 0.05); }
        .icon-option-admin.selected { border-color: #FF6B6B; background-color: #FF6B6B; color: white; }
        .icon-option-admin i { font-size: 1.25rem; }

        .file-drop-zone-category { border: 2px dashed #d1d5db; transition: all 0.2s ease; }
        .file-drop-zone-category.dragover { border-color: #FF6B6B; background-color: rgba(255, 107, 107, 0.05); }
        
        .tree-line-admin { border-left: 2px dotted #d1d5db; margin-left: 0.75rem; /* 12px */ padding-left: 0.75rem; }
        .tree-node-toggle { cursor: pointer; width: 1.5rem; height: 1.5rem; display:inline-flex; align-items:center; justify-content:center; }
        .tree-node-toggle i { transition: transform 0.2s ease-out; }
        .tree-node-toggle.expanded i { transform: rotate(90deg); }
        
        .modal-body-categories-scrollable { max-height: calc(100vh - 200px); overflow-y: auto; }
        .modal-body-categories-scrollable::-webkit-scrollbar { width: 6px; }
        .modal-body-categories-scrollable::-webkit-scrollbar-track { background: #f1f5f9; }
        .modal-body-categories-scrollable::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius:3px; }
    </style>
</asp:Content>

<asp:Content ID="MainAdminContentCategories" ContentPlaceHolderID="AdminMainContent" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <asp:UpdatePanel ID="upnlCategories" runat="server">
        <ContentTemplate>
            <div class="bg-white shadow-sm px-4 md:px-6 py-3 border-b border-gray-200">
                <div class="flex items-center justify-between">
                    <h2 class="text-lg font-semibold text-gray-700">Danh sách Danh mục</h2>
                    <div class="flex items-center space-x-2">
                        <asp:LinkButton ID="btnToggleView" runat="server" OnClick="btnToggleView_Click" CssClass="bg-secondary hover:bg-opacity-90 text-white px-3 md:px-4 py-2 rounded-lg transition-colors flex items-center text-sm md:text-base">
                            <i class="fas fa-sitemap mr-1 md:mr-2"></i>
                            <asp:Literal ID="litToggleViewText" runat="server">Xem cây</asp:Literal>
                        </asp:LinkButton>
                            <span class="hidden sm:inline">Thêm danh mục</span>
                            <span class="sm:hidden">Thêm</span>
                    </div>
                </div>
            </div>

            <div class="p-4 md:p-6">
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 md:gap-6 mb-6 md:mb-8">
                    <div class="category-stats-primary rounded-xl p-4 md:p-5 text-white"><%-- Smaller padding --%>
                        <div class="flex items-center justify-between"><div><p class="text-white text-opacity-80 text-xs">Tổng danh mục</p><asp:Label ID="lblTotalCategories" runat="server" Text="0" CssClass="text-xl font-bold"></asp:Label></div><div class="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-tags text-lg"></i></div></div>
                    </div>
                    <div class="category-stats-secondary rounded-xl p-4 md:p-5 text-white">
                        <div class="flex items-center justify-between"><div><p class="text-white text-opacity-80 text-xs">Danh mục cha</p><asp:Label ID="lblParentCategories" runat="server" Text="0" CssClass="text-xl font-bold"></asp:Label></div><div class="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-folder text-lg"></i></div></div>
                    </div>
                    <div class="category-stats-accent rounded-xl p-4 md:p-5 text-dark">
                        <div class="flex items-center justify-between"><div><p class="text-dark text-opacity-80 text-xs">Danh mục con</p><asp:Label ID="lblChildCategories" runat="server" Text="0" CssClass="text-xl font-bold"></asp:Label></div><div class="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-folder-open text-lg text-dark"></i></div></div>
                    </div>
                     <div class="category-stats rounded-xl p-4 md:p-5 text-white">
                        <div class="flex items-center justify-between"><div><p class="text-white text-opacity-80 text-xs">Có SP nhiều nhất</p><asp:Label ID="lblMostProductsCategoryName" runat="server" Text="N/A" CssClass="text-base font-bold truncate block max-w-[120px]"></asp:Label><asp:Label ID="lblMostProductsCount" runat="server" Text="(0 SP)" CssClass="text-white text-opacity-80 text-xs"></asp:Label></div><div class="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-trophy text-lg"></i></div></div>
                    </div>
                </div>

                <div class="bg-white rounded-xl shadow-sm p-4 md:p-6 mb-6">
                    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4 items-end">
                        <div class="relative">
                            <label for="txtSearchCategory" class="block text-sm font-medium text-gray-700 mb-1">Tìm kiếm</label>
                            <asp:TextBox ID="txtSearchCategory" runat="server" placeholder="Tên danh mục..." CssClass="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-primary w-full"></asp:TextBox>
                            <i class="fas fa-search absolute left-3 bottom-2.5 text-gray-400"></i>
                        </div>
                        <div>
                            <label for="ddlCategoryStatusFilter" class="block text-sm font-medium text-gray-700 mb-1">Trạng thái</label>
                            <asp:DropDownList ID="ddlCategoryStatusFilter" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary">
                                <asp:ListItem Value="">Tất cả trạng thái</asp:ListItem>
                                <asp:ListItem Value="active">Hoạt động</asp:ListItem>
                                <asp:ListItem Value="inactive">Tạm dừng</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div>
                            <label for="ddlCategoryTypeFilter" class="block text-sm font-medium text-gray-700 mb-1">Loại</label>
                            <asp:DropDownList ID="ddlCategoryTypeFilter" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary">
                                <asp:ListItem Value="">Tất cả loại</asp:ListItem>
                                <asp:ListItem Value="parent">Danh mục cha</asp:ListItem>
                                <asp:ListItem Value="child">Danh mục con</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div>
                            <label for="ddlCategorySortFilter" class="block text-sm font-medium text-gray-700 mb-1">Sắp xếp</label>
                            <asp:DropDownList ID="ddlCategorySortFilter" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary">
                                <asp:ListItem Value="sort_order">Thứ tự mặc định</asp:ListItem>
                                <asp:ListItem Value="name_asc">Tên A-Z</asp:ListItem>
                                <asp:ListItem Value="name_desc">Tên Z-A</asp:ListItem>
                                <asp:ListItem Value="created_at_desc">Mới nhất</asp:ListItem>
                                <asp:ListItem Value="product_count_desc">Nhiều sản phẩm</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="flex space-x-2">
                            <asp:Button ID="btnApplyCategoryFilters" runat="server" Text="Lọc" OnClick="btnApplyCategoryFilters_Click" CssClass="w-full sm:w-auto px-4 py-2 bg-secondary text-white rounded-lg hover:bg-opacity-90" />
                            <asp:Button ID="btnResetCategoryFilters" runat="server" Text="Reset" OnClick="btnResetCategoryFilters_Click" CssClass="w-full sm:w-auto px-4 py-2 bg-gray-500 hover:bg-gray-600 text-white rounded-lg" CausesValidation="false"/>
                        </div>
                    </div>
                </div>

                <asp:Panel ID="pnlCategoriesGrid" runat="server" Visible="true">
                    <div class="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-4 md:gap-6">
                        <asp:Repeater ID="rptCategoriesGrid" runat="server" OnItemCommand="Category_ItemCommand">
                            <ItemTemplate>
                                <div class='category-card-admin bg-white rounded-xl shadow-sm p-4 md:p-5 <%# Convert.ToInt32(Eval("ParentId")) == 0 ? "parent-category" : "child-category" %>' data-category-id='<%# Eval("CategoryId") %>'>
                                    <div class="flex items-start justify-between mb-3">
                                        <div class="flex items-center space-x-3">
                                            <div class="drag-handle hidden md:block"><i class="fas fa-grip-vertical text-gray-300 hover:text-gray-500"></i></div>
                                            <div class='w-10 h-10 <%# GetCategoryIconBgColor(Eval("IconCssClass")?.ToString()) %> rounded-lg flex items-center justify-center text-white text-lg'>
                                                <i class='<%# Eval("IconCssClass", "fas fa-tag") %>'></i>
                                            </div>
                                            <div>
                                                <h3 class="font-semibold text-gray-800 text-base"><%# Eval("CategoryName") %></h3>
                                                <p class="text-xs text-gray-500"><%# Eval("Slug") %></p>
                                            </div>
                                        </div>
                                        <div class="flex items-center space-x-2">
                                            <span class='text-xs px-2 py-1 rounded-full <%# Convert.ToBoolean(Eval("IsActive")) ? "bg-green-100 text-green-800" : "bg-red-100 text-red-800" %>'><%# Convert.ToBoolean(Eval("IsActive")) ? "Hoạt động" : "Tạm dừng" %></span>
                                            <div class="relative">
                                                <asp:LinkButton ID="btnActions" runat="server" CommandName="ToggleActions" CommandArgument='<%# Eval("CategoryId") %>' CssClass="text-gray-400 hover:text-gray-600" OnClientClick='<%# "toggleCategoryDropdown(event, " + Eval("CategoryId") + "); return false;" %>'><i class="fas fa-ellipsis-v"></i></asp:LinkButton>
                                                <div id='<%# "dropdown-" + Eval("CategoryId") %>' class="hidden absolute right-0 mt-1 w-48 bg-white rounded-md shadow-lg border z-20">
                                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditCategory" CommandArgument='<%# Eval("CategoryId") %>' CssClass="w-full text-left block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"><i class="fas fa-edit mr-2"></i>Chỉnh sửa</asp:LinkButton>
                                                    <asp:LinkButton ID="btnAddSub" runat="server" CommandName="AddSubCategory" CommandArgument='<%# Eval("CategoryId") %>' Visible='<%# Convert.ToInt32(Eval("ParentId")) == 0 %>' CssClass="w-full text-left block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"><i class="fas fa-plus mr-2"></i>Thêm mục con</asp:LinkButton>
                                                    <asp:LinkButton ID="btnToggleStatus" runat="server" CommandName="ToggleStatus" CommandArgument='<%# Eval("CategoryId") + "," + Eval("IsActive") %>' CssClass="w-full text-left block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"><i class='<%# Convert.ToBoolean(Eval("IsActive")) ? "fas fa-toggle-off" : "fas fa-toggle-on" %> mr-2'></i><%# Convert.ToBoolean(Eval("IsActive")) ? "Tạm dừng" : "Kích hoạt" %></asp:LinkButton>
                                                    <hr class="my-1" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="grid grid-cols-3 gap-2 mb-3 text-center">
                                        <div><p class="text-md font-bold text-gray-800"><%# Eval("ProductCount") %></p><p class="text-2xs text-gray-500">Sản phẩm</p></div>
                                        <div><p class="text-md font-bold text-blue-600"><%# Eval("SubCategoryCount") %></p><p class="text-2xs text-gray-500">Mục con</p></div>
                                        <div><p class="text-md font-bold text-green-600"><%# Eval("SortOrder") %></p><p class="text-2xs text-gray-500">Thứ tự</p></div>
                                    </div>
                                    <div class="text-xs text-gray-600 mb-3"><p class="line-clamp-2" title='<%# Eval("Description") %>'><%# Eval("Description") %></p></div>
                                    <div class="flex items-center justify-between text-2xs text-gray-500">
                                        <span>Tạo: <%# Eval("DateCreated", "{0:dd/MM/yy}") %></span>
                                        <asp:HyperLink ID="hlViewProducts" runat="server" NavigateUrl='<%# Eval("CategoryId", "~/Admin/Products.aspx?category={0}") %>' CssClass="text-primary hover:underline">Xem SP</asp:HyperLink>
                                    </div>
                                </div>
                            </ItemTemplate>
                             <FooterTemplate>
                                <asp:Panel ID="pnlNoCategoriesGrid" runat="server" Visible='<%# rptCategoriesGrid.Items.Count == 0 %>' CssClass="col-span-full text-center py-10">
                                    <p class="text-gray-500">Không có danh mục nào.</p>
                                </asp:Panel>
                            </FooterTemplate>
                        </asp:Repeater>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlCategoriesTree" runat="server" Visible="false" CssClass="bg-white rounded-xl shadow-sm p-4 md:p-6">
                    <asp:Literal ID="litCategoryTree" runat="server"></asp:Literal> <%-- Tree HTML will be rendered here --%>
                     <asp:Panel ID="pnlNoCategoriesTree" runat="server" Visible="false" CssClass="text-center py-10">
                        <p class="text-gray-500">Không có danh mục nào để hiển thị dạng cây.</p>
                    </asp:Panel>
                </asp:Panel>

                <div class="flex flex-col sm:flex-row items-center justify-between mt-6 space-y-4 sm:space-y-0">
                    <asp:Label ID="lblCategoryPageInfo" runat="server" CssClass="text-sm text-gray-500"></asp:Label>
                    <div class="flex items-center space-x-1">
                        <asp:LinkButton ID="lnkCategoryPrevPage" runat="server" OnClick="CategoryPage_Changed" CommandArgument="Prev" CssClass="px-3 py-2 border border-gray-300 rounded-lg text-sm hover:bg-gray-50"><i class="fas fa-chevron-left"></i></asp:LinkButton>
                        <asp:Repeater ID="rptCategoryPager" runat="server" OnItemCommand="CategoryPage_Changed">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkCategoryPageNumber" runat="server" Text='<%# Eval("Text") %>' CommandName="Page" CommandArgument='<%# Eval("Value") %>' CssClass='<%# Convert.ToBoolean(Eval("IsCurrent")) ? "px-3 py-2 bg-primary text-white rounded-lg text-sm" : "px-3 py-2 border border-gray-300 rounded-lg text-sm hover:bg-gray-50" %>'></asp:LinkButton>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:LinkButton ID="lnkCategoryNextPage" runat="server" OnClick="CategoryPage_Changed" CommandArgument="Next" CssClass="px-3 py-2 border border-gray-300 rounded-lg text-sm hover:bg-gray-50"><i class="fas fa-chevron-right"></i></asp:LinkButton>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

    <asp:Panel ID="pnlCategoryModal" runat="server" Visible="false" CssClass="modal-admin-category fixed inset-0 bg-black bg-opacity-50 z-[60] flex items-center justify-center p-4">
        <div class="bg-white rounded-xl w-full max-w-2xl shadow-xl flex flex-col">
            <div class="p-4 md:p-6 border-b border-gray-200">
                <div class="flex items-center justify-between">
                    <h2 class="text-lg md:text-xl font-bold text-gray-800"><asp:Label ID="lblCategoryModalTitle" runat="server">Thêm danh mục</asp:Label></h2>
                    <asp:LinkButton ID="btnCloseCategoryModal" runat="server" OnClick="btnCloseCategoryModal_Click" CssClass="text-gray-400 hover:text-gray-600" CausesValidation="false"><i class="fas fa-times text-xl"></i></asp:LinkButton>
                </div>
            </div>
            <div class="p-4 md:p-6 space-y-5 modal-body-categories-scrollable">
                <asp:HiddenField ID="hfCategoryId" runat="server" Value="0" />
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div><label class="block text-sm font-medium text-gray-700 mb-1">Tên danh mục *</label><asp:TextBox ID="txtCategoryNameModal" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary" placeholder="Nhập tên..."></asp:TextBox><asp:RequiredFieldValidator ID="rfvCategoryNameModal" ControlToValidate="txtCategoryNameModal" ValidationGroup="CategoryValidation" ErrorMessage="Tên không được trống." Display="Dynamic" CssClass="text-red-500 text-xs mt-1" runat="server" /></div>
                    <div><label class="block text-sm font-medium text-gray-700 mb-1">Slug URL</label><asp:TextBox ID="txtCategorySlugModal" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary bg-gray-50" placeholder="Tự động tạo..." ReadOnly="true"></asp:TextBox></div>
                </div>
                <div><label class="block text-sm font-medium text-gray-700 mb-1">Mô tả</label><asp:TextBox ID="txtCategoryDescriptionModal" runat="server" TextMode="MultiLine" Rows="3" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary" placeholder="Mô tả..."></asp:TextBox></div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div><label class="block text-sm font-medium text-gray-700 mb-1">Danh mục cha</label><asp:DropDownList ID="ddlParentCategoryModal" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary" DataTextField="CategoryName" DataValueField="CategoryId"><asp:ListItem Value="0">-- Danh mục gốc --</asp:ListItem></asp:DropDownList></div>
                    <div><label class="block text-sm font-medium text-gray-700 mb-1">Thứ tự</label><asp:TextBox ID="txtSortOrderModal" runat="server" TextMode="Number" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary" Text="0"></asp:TextBox></div>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Biểu tượng</label>
                    <div class="border border-gray-300 rounded-lg p-3">
                        <div class="flex items-center space-x-3 mb-2">
                            <asp:Panel ID="pnlSelectedIconPreview" runat="server" CssClass="w-10 h-10 bg-gray-100 rounded-lg flex items-center justify-center text-gray-500 text-lg"><i class="fas fa-tag"></i></asp:Panel>
                            <asp:HiddenField ID="hfSelectedIcon" runat="server" Value="fas fa-tag" />
                            <p class="text-sm text-gray-600">Chọn một biểu tượng:</p>
                        </div>
                        <div class="icon-picker-admin">
                           <%-- Icons will be rendered by repeater or literal from code-behind --%>
                           <asp:Literal ID="litIconPicker" runat="server"></asp:Literal>
                        </div>
                    </div>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Hình ảnh danh mục (tùy chọn)</label>
                    <asp:FileUpload ID="fuCategoryImageModal" runat="server" CssClass="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-primary file:text-white hover:file:bg-opacity-90" accept="image/*" />
                    <asp:Image ID="imgCategoryImagePreviewModal" runat="server" Visible="false" CssClass="mt-2 w-24 h-24 object-cover rounded-lg border" />
                    <asp:HiddenField ID="hfExistingImageUrlModal" runat="server" />
                </div>
                <div class="border-t border-gray-200 pt-4">
                    <h4 class="text-base font-semibold text-gray-800 mb-2">Cài đặt SEO (tùy chọn)</h4>
                     <div><label class="block text-sm font-medium text-gray-700 mb-1">Tiêu đề SEO</label><asp:TextBox ID="txtSeoTitleModal" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary" placeholder="Tiêu đề SEO..."></asp:TextBox></div>
                     <div class="mt-3"><label class="block text-sm font-medium text-gray-700 mb-1">Mô tả SEO</label><asp:TextBox ID="txtSeoDescriptionModal" runat="server" TextMode="MultiLine" Rows="2" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary" placeholder="Mô tả SEO..."></asp:TextBox></div>
                </div>
                <div class="flex items-center mt-4">
                    <asp:CheckBox ID="chkIsActiveModal" runat="server" Checked="true" Text=" Kích hoạt danh mục" CssClass="text-sm text-gray-700" />
                </div>
            </div>
            <div class="p-4 md:p-6 border-t border-gray-200 bg-gray-50 flex flex-col sm:flex-row justify-end space-y-2 sm:space-y-0 sm:space-x-3">
                <asp:Button ID="btnCancelCategoryModal" runat="server" Text="Hủy" OnClick="btnCloseCategoryModal_Click" CssClass="w-full sm:w-auto px-6 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50" CausesValidation="false" />
                <asp:Button ID="btnSaveCategoryModal" runat="server" Text="Lưu danh mục" OnClick="btnSaveCategory_Click" CssClass="w-full sm:w-auto px-6 py-2 bg-primary hover:bg-opacity-90 text-white rounded-lg" ValidationGroup="CategoryValidation" />
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlDeleteModal" runat="server" Visible="false" CssClass="modal-admin-category fixed inset-0 bg-black bg-opacity-50 z-[70] flex items-center justify-center p-4">
        <div class="bg-white rounded-xl w-full max-w-md p-6 shadow-xl">
            <div class="text-center">
                <div class="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4"><i class="fas fa-exclamation-triangle text-red-600 text-2xl"></i></div>
                <h3 class="text-lg font-semibold text-gray-800 mb-2">Xác nhận xóa</h3>
                <p class="text-gray-600 mb-6">Bạn có chắc chắn muốn xóa danh mục "<asp:Literal ID="litDeleteCategoryName" runat="server"></asp:Literal>"? Các danh mục con (nếu có) cũng sẽ bị ảnh hưởng. Hành động này không thể hoàn tác.</p>
                <div class="flex space-x-4">
                    <asp:Button ID="btnCancelDelete" runat="server" Text="Hủy" OnClick="btnCancelDelete_Click" CssClass="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50" />
                    <asp:Button ID="btnConfirmDelete" runat="server" Text="Xóa" OnClick="btnConfirmDelete_Click" CssClass="flex-1 px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded-lg" />
                    <asp:HiddenField ID="hfDeleteCategoryId" runat="server" />
                </div>
            </div>
        </div>
    </asp:Panel>
</asp:Content>

<asp:Content ID="AdminScriptsCategories" ContentPlaceHolderID="AdminScriptsContent" runat="server">
    <script type="text/javascript">
        let currentCategoryView = 'Grid'; // Default
        let categoryDropdownStates = {}; // To store open/closed state of action dropdowns
        let treeNodeStates = {}; // To store expanded/collapsed state of tree nodes

        function toggleCategoryDropdown(event, categoryId) {
            event.stopPropagation(); // Prevent click from bubbling to document
            const dropdownId = `dropdown-${categoryId}`;
            const dropdown = document.getElementById(getClientIdPrefix() + dropdownId);
            
            // Close all other dropdowns
            document.querySelectorAll('[id^="' + getClientIdPrefix() + 'dropdown-"]').forEach(d => {
                if (d.id !== (getClientIdPrefix() + dropdownId) && !d.classList.contains('hidden')) {
                    d.classList.add('hidden');
                    categoryDropdownStates[d.id.replace(getClientIdPrefix() + 'dropdown-', '')] = false;
                }
            });

            if (dropdown) {
                dropdown.classList.toggle('hidden');
                categoryDropdownStates[categoryId] = !dropdown.classList.contains('hidden');
            }
        }
        
        // Close dropdowns when clicking outside
        document.addEventListener('click', function(event) {
            const openDropdowns = document.querySelectorAll('[id^="' + getClientIdPrefix() + 'dropdown-"]:not(.hidden)');
            openDropdowns.forEach(dropdown => {
                 const categoryId = dropdown.id.replace(getClientIdPrefix() + 'dropdown-', '');
                 const button = event.target.closest(`button[onclick*="toggleCategoryDropdown(event, ${categoryId})"]`);
                 if (!button && !dropdown.contains(event.target)) {
                    dropdown.classList.add('hidden');
                    categoryDropdownStates[categoryId] = false;
                 }
            });
        });


        function toggleTreeNode(event, categoryId) {
             event.stopPropagation();
            const arrow = document.getElementById(getClientIdPrefix() + `tree-arrow-${categoryId}`);
            const children = document.getElementById(getClientIdPrefix() + `tree-children-${categoryId}`);
            if (arrow && children) {
                const isHidden = children.classList.toggle('hidden');
                arrow.classList.toggle('fa-chevron-right', isHidden);
                arrow.classList.toggle('fa-chevron-down', !isHidden);
                treeNodeStates[categoryId] = !isHidden;
            }
        }
        
        function getClientIdPrefix() {
            // Helper to get the prefix for ClientIDs if inside naming containers like Repeater
            // This is a simplified version. For deeply nested controls, you might need a more robust solution or use ClientIDMode="Static".
            const firstRepeaterItemButton = document.querySelector('[id*="rptCategoriesGrid_btnEditGrid_0"]');
            if (firstRepeaterItemButton) {
                return firstRepeaterItemButton.id.substring(0, firstRepeaterItemButton.id.lastIndexOf('_') + 1);
            }
            return ''; // Fallback if no repeater items found (e.g., empty list)
        }


        // Modal functions (mostly controlled by server-side visibility)
        function openAddCategoryModalOnClient() { // Called by server if needed
            const modal = document.getElementById('<%= pnlCategoryModal.ClientID %>');
            if(modal) modal.style.display = 'flex';
            document.body.style.overflow = 'hidden';
            setupModalClose();
        }
        function closeCategoryModalOnClient() { // Called by server if needed
             const modal = document.getElementById('<%= pnlCategoryModal.ClientID %>');
            if(modal) modal.style.display = 'none';
            document.body.style.overflow = 'auto';
        }
        function openDeleteConfirmation(categoryId, categoryName) {
            document.getElementById('<%= hfDeleteCategoryId.ClientID %>').value = categoryId;
            document.getElementById('<%= litDeleteCategoryName.ClientID %>').textContent = categoryName;
            const modal = document.getElementById('<%= pnlDeleteModal.ClientID %>');
            if(modal) modal.style.display = 'flex';
            document.body.style.overflow = 'hidden';
            setupModalClose();
        }
        
        // Function to select icon in modal
        function selectIcon(iconClass, event) {
             if(event) event.preventDefault();
            document.querySelectorAll('.icon-option-admin').forEach(option => option.classList.remove('selected'));
            const targetOption = Array.from(document.querySelectorAll('.icon-option-admin')).find(opt => opt.querySelector('i')?.className === iconClass);
            if (targetOption) targetOption.classList.add('selected');
            
            const previewPanel = document.getElementById('<%= pnlSelectedIconPreview.ClientID %>');
            if(previewPanel) previewPanel.innerHTML = `<i class="${iconClass}"></i>`;
            document.getElementById('<%= hfSelectedIcon.ClientID %>').value = iconClass;
        }
        
        // Function to preview image in modal
        const categoryImageUpload = document.getElementById(getClientId('<%= fuCategoryImageModal.ClientID %>'));
        const categoryImagePreview = document.getElementById(getClientId('<%= imgCategoryImagePreviewModal.ClientID %>'));
        if (categoryImageUpload && categoryImagePreview) {
            categoryImageUpload.addEventListener('change', function() {
                if (this.files && this.files[0]) {
                    const reader = new FileReader();
                    reader.onload = function(e) {
                        categoryImagePreview.src = e.target.result;
                        categoryImagePreview.style.display = 'block';
                    }
                    reader.readAsDataURL(this.files[0]);
                } else {
                     categoryImagePreview.style.display = 'none';
                     categoryImagePreview.src = '#';
                }
            });
        }
        
        // Auto-generate slug from name in modal
        const categoryNameInputModal = document.getElementById(getClientId('<%= txtCategoryNameModal.ClientID %>'));
        const categorySlugInputModal = document.getElementById(getClientId('<%= txtCategorySlugModal.ClientID %>'));
        if(categoryNameInputModal && categorySlugInputModal){
            categoryNameInputModal.addEventListener('input', function(e) {
                categorySlugInputModal.value = generateSlug(e.target.value);
            });
        }
        function generateSlug(text) {
            if (!text) return '';
            return text.toLowerCase()
                .replace(/đ/g, 'd')
                .normalize("NFD").replace(/[\u0300-\u036f]/g, "") // Remove diacritics
                .replace(/[^\w\s-]/g, '') // Remove non-word chars except space and hyphen
                .replace(/\s+/g, '-') // Replace spaces with hyphens
                .replace(/-+/g, '-') // Replace multiple hyphens with single
                .replace(/^-+|-+$/g, ''); // Trim hyphens from start/end
        }

         // Ensure modal close logic is reapplied after UpdatePanel postbacks
        function pageLoad() { // ASP.NET AJAX's PageLoad function
            setupModalClose();
            // Re-apply active states for dropdowns/tree nodes from ViewState if necessary here,
            // or better, handle their state purely on server and re-render.
            // For example, if a tree node was expanded, its class should be set by server on rebind.
        }
        function setupModalClose() {
            const modals = document.querySelectorAll('.modal-admin-category');
            modals.forEach(modal => {
                modal.addEventListener('click', (e) => {
                    if (e.target === e.currentTarget) { // Clicked on overlay itself
                        const closeButtonId = modal.id === '<%= pnlCategoryModal.ClientID %>' ? '<%= btnCloseCategoryModal.ClientID %>' :
                                            modal.id === '<%= pnlDeleteModal.ClientID %>' ? '<%= btnCancelDelete.ClientID %>' : null;
                        if(closeButtonId) {
                             const closeButton = document.getElementById(closeButtonId);
                             if(closeButton) closeButton.click(); // Trigger server-side close to handle state
                        } else {
                             modal.style.display = 'none'; // Fallback
                        }
                         document.body.style.overflow = 'auto';
                    }
                });
            });
        }
        if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(pageLoad);
        }


        document.addEventListener('DOMContentLoaded', function () {
            pageLoad(); // Initial setup
            // Active state for mobile bottom nav
            const currentPath = window.location.pathname.toLowerCase();
            const bottomNavLinks = document.querySelectorAll('.bottom-nav .nav-item');
            let categoryLinkManuallyActivated = false;

            bottomNavLinks.forEach(link => {
                const linkHref = link.getAttribute('href');
                if (!linkHref) return;
                const linkPath = new URL(linkHref, window.location.origin).pathname.toLowerCase();
                
                if (currentPath.includes('categories.aspx') && linkPath.includes('categories.aspx')) { 
                    link.classList.add('active');
                    link.classList.remove('text-gray-600');
                    categoryLinkManuallyActivated = true;
                } else if (!categoryLinkManuallyActivated && currentPath === linkPath) {
                    link.classList.add('active');
                    link.classList.remove('text-gray-600');
                } else {
                    link.classList.remove('active');
                     if (!link.classList.contains('active')) {
                        link.classList.add('text-gray-600');
                    }
                }
            });
        });
    </script>
</asp:Content>