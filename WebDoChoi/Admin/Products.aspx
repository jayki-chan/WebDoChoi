<%@ Page Title="Quản lý Sản phẩm - ToyLand Admin" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="Products.aspx.cs" Inherits="WebsiteDoChoi.Admin.Products" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitleContent" runat="server">
    <h1 class="text-xl md:text-2xl font-bold text-gray-800">Quản lý Sản phẩm</h1>
</asp:Content>

<asp:Content ID="AdminHead" ContentPlaceHolderID="AdminHeadContent" runat="server">
    <style>
        .product-image-admin { aspect-ratio: 1 / 1; object-fit: cover; }
        .badge-hot { background: linear-gradient(45deg, #ff6b6b, #ee5a6f); }
        .badge-new { background: linear-gradient(45deg, #4ecdc4, #44a08d); }
        .badge-sale { background: linear-gradient(45deg, #ffe66d, #ffb347); }
        .product-card-admin:hover { transform: translateY(-2px); box-shadow: 0 8px 25px rgba(0,0,0,0.1); }
        .product-card-admin { transition: all 0.3s ease; }
        .modal-admin { backdrop-filter: blur(5px); }
        .image-preview-container { position: relative; overflow: hidden; border-radius: 0.5rem; }
        .image-preview-container img { transition: transform 0.3s ease; }
        .image-preview-container:hover img { transform: scale(1.05); }
        .tab-button-admin.active { background: linear-gradient(45deg, #FF6B6B, #ee5a6f); color: white; }
        .file-drop-zone-admin { border: 2px dashed #d1d5db; transition: all 0.3s ease; }
        .file-drop-zone-admin.dragover { border-color: #FF6B6B; background-color: rgba(255, 107, 107, 0.05); }
        .modal-body-scrollable::-webkit-scrollbar { width: 6px; }
        .modal-body-scrollable::-webkit-scrollbar-track { background: #f1f5f9; border-radius: 3px; }
        .modal-body-scrollable::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 3px; }
        .modal-body-scrollable::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
        .modal-body-scrollable { scrollbar-width: thin; scrollbar-color: #cbd5e1 #f1f5f9; max-height: calc(100vh - 200px); overflow-y: auto; }
    </style>
</asp:Content>

<asp:Content ID="MainAdminContent" ContentPlaceHolderID="AdminMainContent" runat="server">
    <div class="bg-white shadow-sm px-4 md:px-6 py-3 border-b border-gray-200">
        <div class="flex items-center justify-between">
            <h2 class="text-lg font-semibold text-gray-700">Danh sách sản phẩm</h2>
                
                <span class="hidden sm:inline">Thêm sản phẩm</span>
                <span class="sm:hidden">Thêm</span>
        </div>
    </div>

    <div class="p-4 md:p-6 bg-white border-b border-gray-200">
        <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between space-y-4 lg:space-y-0">
            <div class="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-4 items-center">
                <div class="relative w-full sm:w-auto">
                    <asp:TextBox ID="txtSearchProduct" runat="server" placeholder="Tìm kiếm sản phẩm..." CssClass="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-primary w-full sm:w-64"></asp:TextBox>
                    <i class="fas fa-search absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"></i>
                </div>
                <asp:DropDownList ID="ddlCategoryFilter" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" CssClass="w-full sm:w-auto border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary">
                    <asp:ListItem Value="">Tất cả danh mục</asp:ListItem>
                    <%-- Populate from code-behind --%>
                </asp:DropDownList>
                <asp:DropDownList ID="ddlStatusFilter" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" CssClass="w-full sm:w-auto border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary">
                    <asp:ListItem Value="">Tất cả trạng thái</asp:ListItem>
                    <asp:ListItem Value="active">Đang bán</asp:ListItem>
                    <asp:ListItem Value="inactive">Tạm dừng</asp:ListItem>
                    <asp:ListItem Value="outofstock">Hết hàng</asp:ListItem>
                </asp:DropDownList>
                 <asp:Button ID="btnApplyFilters" runat="server" Text="Lọc" OnClick="btnApplyFilters_Click" CssClass="px-4 py-2 bg-secondary text-white rounded-lg hover:bg-opacity-90" />
            </div>
            <div class="flex items-center space-x-2">
                <asp:LinkButton ID="btnGridView" runat="server" OnClick="btnViewMode_Click" CommandArgument="Grid" CssClass="tab-button-admin active px-4 py-2 rounded-lg transition-colors" ToolTip="Xem dạng lưới"><i class="fas fa-th-large"></i></asp:LinkButton>
                <asp:LinkButton ID="btnListView" runat="server" OnClick="btnViewMode_Click" CommandArgument="List" CssClass="tab-button-admin px-4 py-2 rounded-lg border border-gray-300 hover:bg-gray-50 transition-colors" ToolTip="Xem dạng danh sách"><i class="fas fa-list"></i></asp:LinkButton>
            </div>
        </div>
    </div>

    <div class="p-4 md:p-6">
        <asp:Panel ID="pnlGridView" runat="server">
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 md:gap-6">
                <asp:Repeater ID="rptProductsGrid" runat="server" OnItemCommand="Product_ItemCommand">
                    <ItemTemplate>
                        <div class="product-card-admin bg-white rounded-xl shadow-sm overflow-hidden flex flex-col">
                            <div class="relative">
                                <asp:Image ID="imgProductGrid" runat="server" ImageUrl='<%# Eval("ImageUrl", "https://api.placeholder.com/300/300?text=Toy") %>' AlternateText='<%# Eval("ProductName") %>' CssClass="product-image-admin w-full" />
                                <div class="absolute top-3 left-3 space-x-1">
                                    <asp:Label ID="lblBadgeHotGrid" runat="server" Text="HOT" Visible='<%# Convert.ToBoolean(Eval("IsHot")) %>' CssClass="badge-hot text-white text-xs px-2 py-1 rounded-full"></asp:Label>
                                    <asp:Label ID="lblBadgeNewGrid" runat="server" Text="MỚI" Visible='<%# Convert.ToBoolean(Eval("IsNew")) %>' CssClass="badge-new text-white text-xs px-2 py-1 rounded-full"></asp:Label>
                                    <asp:Label ID="lblBadgeSaleGrid" runat="server" Text="SALE" Visible='<%# Convert.ToBoolean(Eval("IsSale")) %>' CssClass="badge-sale text-dark text-xs px-2 py-1 rounded-full"></asp:Label>
                                </div>
                                <%-- Optional: Favorite button (if admin needs this) --%>
                            </div>
                            <div class="p-4 flex flex-col flex-grow">
                                <div class="flex items-start justify-between mb-2">
                                    <h3 class="font-semibold text-gray-800 text-sm line-clamp-2"><%# Eval("ProductName") %></h3>
                                    <span class='text-xs px-2 py-1 rounded-full ml-2' ><%# Eval("StatusText") %></span>
                                </div>
                                <div class="flex items-center justify-between mb-2">
                                    <div class="flex items-baseline space-x-2">
                                        <span class="text-primary font-bold"><%# Eval("SalePrice", "{0:N0}đ") %></span>
                                        <asp:Label ID="lblOriginalPriceGrid" runat="server" Text='<%# Eval("OriginalPrice", "{0:N0}đ") %>' Visible='<%# Convert.ToDecimal(Eval("OriginalPrice")) > Convert.ToDecimal(Eval("SalePrice")) %>' CssClass="text-gray-400 line-through text-sm"></asp:Label>
                                    </div>
                                </div>
                                <div class="flex items-center justify-between text-sm text-gray-500 mb-3">
                                    <span>Tồn: <%# Eval("StockQuantity") %></span>
                                    <span>Đã bán: <%# Eval("SoldCount") %></span>
                                </div>
                                <div class="mt-auto flex items-center space-x-2">
                                    <asp:LinkButton ID="btnEditGrid" runat="server" CommandName="EditProduct" CommandArgument='<%# Eval("ProductId") %>' CssClass="flex-1 bg-primary hover:bg-opacity-90 text-white py-2 px-3 rounded-lg text-sm transition-colors text-center"><i class="fas fa-edit mr-1"></i> Sửa</asp:LinkButton>
                                    <asp:HyperLink ID="hlViewGrid" runat="server" NavigateUrl='<%# Eval("ProductId", "/Client/ProductDetail.aspx?id={0}") %>' Target="_blank" CssClass="px-3 py-2 text-gray-600 hover:text-primary transition-colors" ToolTip="Xem"><i class="fas fa-eye"></i></asp:HyperLink>
                                    <asp:LinkButton ID="btnDeleteGrid" runat="server" CommandName="DeleteProduct" CommandArgument='<%# Eval("ProductId") %>' OnClientClick="return confirm('Bạn có chắc chắn muốn xóa sản phẩm này?');" CssClass="px-3 py-2 text-gray-600 hover:text-red-500 transition-colors" ToolTip="Xóa"><i class="fas fa-trash"></i></asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        <asp:Panel ID="pnlNoProductsGrid" runat="server" Visible='<%# rptProductsGrid.Items.Count == 0 %>' CssClass="col-span-full text-center py-10">
                            <p class="text-gray-500">Không tìm thấy sản phẩm nào.</p>
                        </asp:Panel>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlListView" runat="server" Visible="false" CssClass="overflow-x-auto">
             <div class="bg-white rounded-xl shadow-sm overflow-hidden">
                <asp:GridView ID="gvProductsList" runat="server" AutoGenerateColumns="False" 
                    CssClass="w-full min-w-full" DataKeyNames="ProductId"
                    HeaderStyle-CssClass="bg-gray-50" RowStyle-CssClass="hover:bg-gray-50"
                    EmptyDataText="Không có sản phẩm nào để hiển thị." GridLines="None"
                    OnRowCommand="gvProductsList_RowCommand" OnRowDeleting="gvProductsList_RowDeleting" OnRowEditing="gvProductsList_RowEditing">
                    <Columns>
                        <asp:TemplateField HeaderText="Sản phẩm" HeaderStyle-CssClass="px-4 md:px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" ItemStyle-CssClass="px-4 md:px-6 py-4 whitespace-nowrap">
                            <ItemTemplate>
                                <div class="flex items-center">
                                    <asp:Image ID="imgProductList" runat="server" ImageUrl='<%# Eval("ImageUrl", "https://api.placeholder.com/100/100?text=Toy") %>' AlternateText='<%# Eval("ProductName") %>' CssClass="h-12 w-12 rounded-lg object-cover" />
                                    <div class="ml-4">
                                        <div class="text-sm font-medium text-gray-900 line-clamp-2"><%# Eval("ProductName") %></div>
                                        <div class="text-sm text-gray-500">SKU: <%# Eval("SKU") %></div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="CategoryName" HeaderText="Danh mục" HeaderStyle-CssClass="px-4 md:px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" ItemStyle-CssClass="px-4 md:px-6 py-4 whitespace-nowrap text-sm text-gray-500" />
                        <asp:BoundField DataField="SalePrice" HeaderText="Giá bán" DataFormatString="{0:N0}đ" HeaderStyle-CssClass="px-4 md:px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" ItemStyle-CssClass="px-4 md:px-6 py-4 whitespace-nowrap text-sm text-gray-900" />
                        <asp:BoundField DataField="StockQuantity" HeaderText="Tồn kho" HeaderStyle-CssClass="px-4 md:px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" ItemStyle-CssClass="px-4 md:px-6 py-4 whitespace-nowrap text-sm text-gray-500" />
                        <asp:TemplateField HeaderText="Trạng thái" HeaderStyle-CssClass="px-4 md:px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" ItemStyle-CssClass="px-4 md:px-6 py-4 whitespace-nowrap">
                            <ItemTemplate>
                                <span class=''><%# Eval("StatusText") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Thao tác" HeaderStyle-CssClass="px-4 md:px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" ItemStyle-CssClass="px-4 md:px-6 py-4 whitespace-nowrap text-sm font-medium">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnEditList" runat="server" CommandName="EditProduct" CommandArgument='<%# Eval("ProductId") %>' CssClass="text-primary hover:text-primary-dark mr-2" ToolTip="Sửa"><i class="fas fa-edit"></i></asp:LinkButton>
                                <asp:HyperLink ID="hlViewList" runat="server" NavigateUrl='<%# Eval("ProductId", "/Client/ProductDetail.aspx?id={0}") %>' Target="_blank" CssClass="text-secondary hover:text-secondary-dark mr-2" ToolTip="Xem"><i class="fas fa-eye"></i></asp:HyperLink>
                                <asp:LinkButton ID="btnDeleteList" runat="server" CommandName="DeleteProduct" CommandArgument='<%# Eval("ProductId") %>' OnClientClick="return confirm('Bạn có chắc chắn muốn xóa sản phẩm này?');" CssClass="text-red-500 hover:text-red-700" ToolTip="Xóa"><i class="fas fa-trash"></i></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </asp:Panel>

        <div class="flex flex-col sm:flex-row items-center justify-between mt-6 space-y-4 sm:space-y-0">
            <asp:Label ID="lblPageInfo" runat="server" CssClass="text-sm text-gray-500"></asp:Label>
            <div class="flex items-center space-x-1">
                <asp:LinkButton ID="lnkPrevPage" runat="server" OnClick="Page_Changed" CommandArgument="Prev" CssClass="px-3 py-2 border border-gray-300 rounded-lg text-sm hover:bg-gray-50"><i class="fas fa-chevron-left"></i></asp:LinkButton>
                <asp:Repeater ID="rptPager" runat="server" OnItemCommand="Page_Changed">
                    <ItemTemplate>
                        <asp:LinkButton ID="lnkPageNumber" runat="server" Text='<%# Eval("Text") %>' CommandName="Page" CommandArgument='<%# Eval("Value") %>' CssClass='<%# Convert.ToBoolean(Eval("IsCurrent")) ? "px-3 py-2 bg-primary text-white rounded-lg text-sm" : "px-3 py-2 border border-gray-300 rounded-lg text-sm hover:bg-gray-50" %>'></asp:LinkButton>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:LinkButton ID="lnkNextPage" runat="server" OnClick="Page_Changed" CommandArgument="Next" CssClass="px-3 py-2 border border-gray-300 rounded-lg text-sm hover:bg-gray-50"><i class="fas fa-chevron-right"></i></asp:LinkButton>
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlProductModal" runat="server" Visible="false" CssClass="modal-admin fixed inset-0 bg-black bg-opacity-50 z-[60] flex items-center justify-center p-4">
        <div class="bg-white rounded-xl w-full max-w-4xl shadow-xl">
            <div class="p-4 md:p-6 border-b border-gray-200">
                <div class="flex items-center justify-between">
                    <h2 class="text-lg md:text-xl font-bold text-gray-800"><asp:Label ID="lblModalTitle" runat="server">Thêm sản phẩm mới</asp:Label></h2>
                    <asp:LinkButton ID="btnCloseModal" runat="server" OnClick="btnCloseModal_Click" CssClass="text-gray-400 hover:text-gray-600" CausesValidation="false"><i class="fas fa-times text-xl"></i></asp:LinkButton>
                </div>
            </div>
            <div class="p-4 md:p-6 space-y-6 modal-body-scrollable">
                 <asp:HiddenField ID="hfProductId" runat="server" Value="0" />
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <div class="space-y-4">
                        <h3 class="text-base font-semibold text-gray-800">Thông tin cơ bản</h3>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Tên sản phẩm *</label>
                            <asp:TextBox ID="txtProductNameModal" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary" placeholder="Nhập tên sản phẩm..."></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvProductName" runat="server" ControlToValidate="txtProductNameModal" ErrorMessage="Tên sản phẩm không được để trống." Display="Dynamic" CssClass="text-red-500 text-xs mt-1" ValidationGroup="ProductModalValidation"></asp:RequiredFieldValidator>
                        </div>
                         <div class="grid grid-cols-2 gap-4">
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">SKU *</label>
                                <asp:TextBox ID="txtSKUModal" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary" placeholder="TOY-001"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvSKU" runat="server" ControlToValidate="txtSKUModal" ErrorMessage="SKU không được để trống." Display="Dynamic" CssClass="text-red-500 text-xs mt-1" ValidationGroup="ProductModalValidation"></asp:RequiredFieldValidator>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Mã vạch (Barcode)</label>
                                <asp:TextBox ID="txtBarcodeModal" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary" placeholder="1234567890123"></asp:TextBox>
                            </div>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Danh mục *</label>
                            <asp:DropDownList ID="ddlCategoryModal" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary">
                                 <asp:ListItem Value="">Chọn danh mục</asp:ListItem>
                                <%-- Populated from code-behind --%>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvCategoryModal" runat="server" ControlToValidate="ddlCategoryModal" InitialValue="" ErrorMessage="Vui lòng chọn danh mục." Display="Dynamic" CssClass="text-red-500 text-xs mt-1" ValidationGroup="ProductModalValidation"></asp:RequiredFieldValidator>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Độ tuổi phù hợp</label>
                            <asp:DropDownList ID="ddlAgeRangeModal" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary">
                                 <asp:ListItem Value="">Chọn độ tuổi</asp:ListItem>
                                 <%-- Static or dynamic population --%>
                                  <asp:ListItem Value="0-2">0-2 tuổi</asp:ListItem>
                                  <asp:ListItem Value="3-5">3-5 tuổi</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                         <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Mô tả ngắn</label>
                            <asp:TextBox ID="txtShortDescriptionModal" runat="server" TextMode="MultiLine" Rows="3" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary" placeholder="Mô tả ngắn về sản phẩm..."></asp:TextBox>
                        </div>
                    </div>
                    <div class="space-y-4">
                        <h3 class="text-base font-semibold text-gray-800">Hình ảnh sản phẩm</h3>
                        <div class="file-drop-zone-admin border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
                            <i class="fas fa-cloud-upload-alt text-3xl text-gray-400 mb-4"></i>
                            <p class="text-gray-600 mb-2">Kéo thả ảnh vào đây hoặc</p>
                            <asp:FileUpload ID="fuProductImages" runat="server" AllowMultiple="true" CssClass="hidden" onchange="previewFiles(this.files)"/>
                            <asp:Button ID="btnTriggerFileUpload" runat="server" Text="Chọn từ máy tính" OnClientClick="document.getElementById(getClientId('<%= fuProductImages.ClientID %>')).click(); return false;" CssClass="text-primary hover:text-primary-dark font-medium bg-transparent border-0 p-0" />
                            <p class="text-xs text-gray-500 mt-2">PNG, JPG, WEBP (tối đa 5MB/ảnh, tối đa 5 ảnh)</p>
                        </div>
                        <div id="imagePreviewContainerModal" class="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 gap-2">
                            <%-- Preview images will be added here by JavaScript --%>
                            <asp:Repeater ID="rptExistingImages" runat="server" OnItemCommand="rptExistingImages_ItemCommand">
                                <ItemTemplate>
                                     <div class="image-preview-container relative group">
                                        <asp:Image ID="imgExisting" runat="server" ImageUrl='<%# Eval("ImageUrl") %>' CssClass="w-full h-24 object-cover rounded-lg" />
                                        <asp:LinkButton ID="btnDeleteExistingImage" runat="server" CommandName="DeleteImage" CommandArgument='<%# Eval("ImageId") %>' CssClass="absolute top-1 right-1 w-6 h-6 bg-red-500 text-white rounded-full text-xs flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity" OnClientClick="return confirm('Xóa ảnh này?');">
                                            <i class="fas fa-times"></i>
                                        </asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                </div>
                <div class="border-t border-gray-200 pt-6">
                     <h3 class="text-base font-semibold text-gray-800 mb-4">Giá và tồn kho</h3>
                     <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                         <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Giá bán * (VNĐ)</label>
                            <asp:TextBox ID="txtSalePriceModal" runat="server" TextMode="Number" step="1000" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary" placeholder="0"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvSalePrice" runat="server" ControlToValidate="txtSalePriceModal" ErrorMessage="Giá bán không được trống." Display="Dynamic" CssClass="text-red-500 text-xs mt-1" ValidationGroup="ProductModalValidation"></asp:RequiredFieldValidator>
                            <asp:CompareValidator ID="cvSalePrice" runat="server" ControlToValidate="txtSalePriceModal" Type="Currency" Operator="DataTypeCheck" ErrorMessage="Giá bán không hợp lệ." Display="Dynamic" CssClass="text-red-500 text-xs mt-1" ValidationGroup="ProductModalValidation"></asp:CompareValidator>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Giá gốc (VNĐ)</label>
                            <asp:TextBox ID="txtOriginalPriceModal" runat="server" TextMode="Number" step="1000" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary" placeholder="0"></asp:TextBox>
                             <asp:CompareValidator ID="cvOriginalPrice" runat="server" ControlToValidate="txtOriginalPriceModal" Type="Currency" Operator="DataTypeCheck" ErrorMessage="Giá gốc không hợp lệ." Display="Dynamic" CssClass="text-red-500 text-xs mt-1" ValidationGroup="ProductModalValidation"></asp:CompareValidator>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Số lượng tồn kho *</label>
                            <asp:TextBox ID="txtStockQuantityModal" runat="server" TextMode="Number" step="1" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary" placeholder="0"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvStock" runat="server" ControlToValidate="txtStockQuantityModal" ErrorMessage="Số lượng tồn không được trống." Display="Dynamic" CssClass="text-red-500 text-xs mt-1" ValidationGroup="ProductModalValidation"></asp:RequiredFieldValidator>
                            <asp:CompareValidator ID="cvStock" runat="server" ControlToValidate="txtStockQuantityModal" Type="Integer" Operator="DataTypeCheck" ErrorMessage="Số lượng không hợp lệ." Display="Dynamic" CssClass="text-red-500 text-xs mt-1" ValidationGroup="ProductModalValidation"></asp:CompareValidator>
                        </div>
                     </div>
                </div>
                <div class="border-t border-gray-200 pt-6">
                    <h3 class="text-base font-semibold text-gray-800 mb-4">Mô tả chi tiết</h3>
                    <asp:TextBox ID="txtFullDescriptionModal" runat="server" TextMode="MultiLine" Rows="6" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary" placeholder="Mô tả chi tiết về sản phẩm, tính năng, cách sử dụng..."></asp:TextBox>
                    <%-- Consider using a Rich Text Editor control here if available --%>
                </div>
                <div class="border-t border-gray-200 pt-6">
                     <h3 class="text-base font-semibold text-gray-800 mb-4">Tính năng đặc biệt & Trạng thái</h3>
                     <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 mb-4">
                        <asp:CheckBox ID="chkIsHotModal" runat="server" Text=" Sản phẩm HOT" CssClass="flex items-center text-sm text-gray-700"/>
                        <asp:CheckBox ID="chkIsNewModal" runat="server" Text=" Sản phẩm MỚI" CssClass="flex items-center text-sm text-gray-700"/>
                        <asp:CheckBox ID="chkIsSaleModal" runat="server" Text=" Khuyến mãi" CssClass="flex items-center text-sm text-gray-700"/>
                        <asp:CheckBox ID="chkIsBestSellerModal" runat="server" Text=" Bán chạy" CssClass="flex items-center text-sm text-gray-700"/>
                     </div>
                     <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Trạng thái hiển thị</label>
                        <asp:DropDownList ID="ddlStatusModal" runat="server" CssClass="w-full md:w-1/2 border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary">
                            <asp:ListItem Value="active" Selected="True">Đang bán</asp:ListItem>
                            <asp:ListItem Value="inactive">Tạm dừng</asp:ListItem>
                            <asp:ListItem Value="draft">Nháp</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
            </div>
            <div class="p-4 md:p-6 border-t border-gray-200 bg-gray-50 flex flex-col sm:flex-row justify-end space-y-2 sm:space-y-0 sm:space-x-3">
                <asp:Button ID="btnCancelModal" runat="server" Text="Hủy" OnClick="btnCloseModal_Click" CssClass="w-full sm:w-auto px-6 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors" CausesValidation="false" />
                <asp:Button ID="btnSaveDraftModal" runat="server" Text="Lưu nháp" OnClick="btnSaveProduct_Click" CommandName="SaveDraft" CssClass="w-full sm:w-auto px-6 py-2 bg-gray-500 hover:bg-gray-600 text-white rounded-lg transition-colors" ValidationGroup="ProductModalValidation" />
                <asp:Button ID="btnSaveProductModal" runat="server" Text="Lưu sản phẩm" OnClick="btnSaveProduct_Click" CommandName="Save" CssClass="w-full sm:w-auto px-6 py-2 bg-primary hover:bg-opacity-90 text-white rounded-lg transition-colors" ValidationGroup="ProductModalValidation" />
            </div>
        </div>
    </asp:Panel>
</asp:Content>

<asp:Content ID="AdminScripts" ContentPlaceHolderID="AdminScriptsContent" runat="server">
    <script type="text/javascript">
        function switchView(view) {
            const gridViewPanel = document.getElementById('<%= pnlGridView.ClientID %>');
            const listViewPanel = document.getElementById('<%= pnlListView.ClientID %>');
            const gridButton = document.getElementById('<%= btnGridView.ClientID %>');
            const listButton = document.getElementById('<%= btnListView.ClientID %>');

            if (view === 'grid') {
                if(gridViewPanel) gridViewPanel.style.display = 'block';
                if(listViewPanel) listViewPanel.style.display = 'none';
                if(gridButton) gridButton.classList.add('active');
                if(listButton) listButton.classList.remove('active');
            } else {
                if(gridViewPanel) gridViewPanel.style.display = 'none';
                if(listViewPanel) listViewPanel.style.display = 'block';
                if(gridButton) gridButton.classList.remove('active');
                if(listButton) listButton.classList.add('active');
            }
        }
        
        // Functions openProductModal, closeProductModal, handleFiles, etc.
        // can be defined here or called via ScriptManager if they need server data initially
        // For simplicity with ASP.NET postbacks controlling modal visibility,
        // direct JS functions for open/close might not be needed if buttons trigger postbacks.
        // However, if btnOpenAddProductModal is client-side only, then:
        // function openAddProductModal() {
        //    document.getElementById('<%= pnlProductModal.ClientID %>').style.display = 'flex';
        //    document.getElementById('<%= lblModalTitle.ClientID %>').textContent = 'Thêm sản phẩm mới';
        //    document.body.style.overflow = 'hidden';
        // }
        // function closeProductModal() {
        //    document.getElementById('<%= pnlProductModal.ClientID %>').style.display = 'none';
        //    document.body.style.overflow = 'auto';
        // }
        
        // Image preview for FileUpload
        const imagePreviewContainerModal = document.getElementById('imagePreviewContainerModal');
        const fileUploadControl = document.getElementById(getClientId('<%= fuProductImages.ClientID %>'));

        function getClientId(serverID) {
             // In case the control is not found, return a dummy or the serverID itself
             // to prevent JS errors, though this means the script won't work as intended.
            const element = document.querySelector('[id$="' + serverID + '"]');
            return element ? element.id : serverID;
        }

        function previewFiles(files) {
            if (!imagePreviewContainerModal) return;
            // imagePreviewContainerModal.innerHTML = ''; // Clear existing client-side previews, keep server-rendered existing images
            
            // Filter out existing server-rendered previews if needed or manage them separately
            const clientPreviews = imagePreviewContainerModal.querySelectorAll('.client-preview');
            clientPreviews.forEach(cp => cp.remove());


            if (files) {
                Array.from(files).forEach(file => {
                    if (file.type.startsWith('image/')) {
                        const reader = new FileReader();
                        reader.onload = (e) => {
                            const previewDiv = document.createElement('div');
                            previewDiv.className = 'image-preview-container relative group client-preview'; // Add client-preview class
                            previewDiv.innerHTML = `
                                <img src="${e.target.result}" alt="Preview" class="w-full h-24 object-cover rounded-lg">
                                <button type="button" class="absolute top-1 right-1 w-5 h-5 bg-red-500 text-white rounded-full text-2xs flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity" onclick="removePreview(this.parentElement, '${file.name}');">
                                    <i class="fas fa-times"></i>
                                </button>
                            `;
                            previewDiv.dataset.fileName = file.name; // Store filename for removal logic
                            imagePreviewContainerModal.appendChild(previewDiv);
                        };
                        reader.readAsDataURL(file);
                    }
                });
            }
        }
        function removePreview(previewElement, fileName) {
            previewElement.remove();
            // If you need to track removed files for server-side logic (e.g., not to upload them), add code here
            console.log("Client-side preview removed for:", fileName);
        }

        // Drag and drop for file upload
        const dropZone = document.querySelector('.file-drop-zone-admin');
        if(dropZone && fileUploadControl) {
            dropZone.addEventListener('dragover', (e) => { e.preventDefault(); dropZone.classList.add('dragover'); });
            dropZone.addEventListener('dragleave', (e) => { e.preventDefault(); dropZone.classList.remove('dragover'); });
            dropZone.addEventListener('drop', (e) => {
                e.preventDefault();
                dropZone.classList.remove('dragover');
                if (e.dataTransfer.files.length) {
                    fileUploadControl.files = e.dataTransfer.files; // Assign to FileUpload
                    previewFiles(e.dataTransfer.files); // Trigger preview
                }
            });
        }
        
        // Make sure the modal close works even after postbacks
        function setupModalClose() {
            const modal = document.getElementById('<%= pnlProductModal.ClientID %>');
            if (modal) {
                modal.addEventListener('click', (e) => {
                    if (e.target === e.currentTarget) {
                        // Trigger the server-side close button to handle state if needed
                        const closeButton = document.getElementById('<%= btnCloseModal.ClientID %>');
                        if(closeButton) closeButton.click();
                        else modal.style.display = 'none'; // Fallback if server button not found
                        document.body.style.overflow = 'auto';
                    }
                });
            }
        }
        setupModalClose();
        // Ensure setupModalClose is called after any UpdatePanel partial postback if modal is in an UpdatePanel
        // Sys.WebForms.PageRequestManager.getInstance().add_endRequest(setupModalClose);
    </script>
</asp:Content>