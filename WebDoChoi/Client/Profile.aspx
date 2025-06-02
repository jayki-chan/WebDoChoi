<%@ Page Title="Tài khoản của tôi - ToyLand" Language="C#" MasterPageFile="/Site.Master" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="WebsiteDoChoi.Client.Profile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Baloo+2:wght@400;500;600;700&display=swap');
        
        body {
            font-family: 'Baloo 2', cursive;
            padding-bottom: 80px;
        }
        
        .tab-content {
            display: none;
        }
        
        .tab-content.active {
            display: block;
        }
        
        .tab-button.active {
            background-color: #FF6B6B;
            color: white;
        }

        /* Bottom Navigation Styles */
        .bottom-nav {
            position: fixed;
            bottom: 0;
            left: 0;
            right: 0;
            background: white;
            border-top: 1px solid #e5e7eb;
            z-index: 50;
            box-shadow: 0 -2px 10px rgba(0,0,0,0.1);
        }

        .nav-item {
            transition: all 0.3s ease;
        }

        .nav-item.active {
            color: #FF6B6B;
            transform: translateY(-2px);
        }

        .nav-item:not(.active):hover {
            color: #FF6B6B;
        }

        /* Hide desktop navigation on mobile */
        @media (max-width: 767px) {
            .desktop-nav {
                display: none !important;
            }
        }

        /* Show desktop navigation on desktop */
        @media (min-width: 768px) {
            .bottom-nav {
                display: none !important;
            }
            body {
                padding-bottom: 0;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Mobile Bottom Navigation -->
    <nav class="bottom-nav md:hidden">
        <div class="flex justify-around items-center py-2">
            <asp:HyperLink ID="lnkHome" runat="server" NavigateUrl="/Client/Default.aspx" 
                CssClass="nav-item flex flex-col items-center py-1 px-2 text-center min-w-0 text-gray-600">
                <i class="fas fa-home text-lg mb-1"></i>
                <span class="text-xs truncate">Trang chủ</span>
            </asp:HyperLink>
            <asp:HyperLink ID="lnkProducts" runat="server" NavigateUrl="/Client/ProductList.aspx" 
                CssClass="nav-item flex flex-col items-center py-1 px-2 text-center min-w-0 text-gray-600">
                <i class="fas fa-star text-lg mb-1"></i>
                <span class="text-xs truncate">Sản phẩm</span>
            </asp:HyperLink>
            <asp:HyperLink ID="lnkBestSeller" runat="server" NavigateUrl="/Client/BestSeller.aspx" 
                CssClass="nav-item flex flex-col items-center py-1 px-2 text-center min-w-0 text-gray-600">
                <i class="fas fa-fire text-lg mb-1"></i>
                <span class="text-xs truncate">Bán chạy</span>
            </asp:HyperLink>
            <asp:HyperLink ID="lnkPromotions" runat="server" NavigateUrl="/Client/Promotions.aspx" 
                CssClass="nav-item flex flex-col items-center py-1 px-2 text-center min-w-0 text-gray-600">
                <i class="fas fa-tag text-lg mb-1"></i>
                <span class="text-xs truncate">Khuyến mãi</span>
            </asp:HyperLink>
            <asp:HyperLink ID="lnkAccount" runat="server" NavigateUrl="/Client/Profile.aspx" 
                CssClass="nav-item active flex flex-col items-center py-1 px-2 text-center min-w-0">
                <i class="fas fa-user text-lg mb-1"></i>
                <span class="text-xs truncate">Tài khoản</span>
            </asp:HyperLink>
        </div>
    </nav>

    <!-- Breadcrumb -->
    <div class="bg-white border-b">
        <div class="container mx-auto px-4 py-3">
            <nav class="flex text-sm">
                <asp:HyperLink ID="lnkBreadcrumbHome" runat="server" NavigateUrl="/Client/Default.aspx" 
                    CssClass="text-gray-500 hover:text-primary">Trang chủ</asp:HyperLink>
                <span class="mx-2 text-gray-400">/</span>
                <span class="text-gray-800">Tài khoản của tôi</span>
            </nav>
        </div>
    </div>

    <!-- Main Content -->
    <div class="container mx-auto px-4 py-6">
        <div class="flex flex-col lg:flex-row gap-6">
            <!-- Sidebar Menu -->
            <div class="w-full lg:w-1/4">
                <div class="bg-white rounded-lg shadow-md p-4">
                    <!-- User Info -->
                    <div class="flex items-center mb-6 pb-4 border-b">
                        <div class="w-16 h-16 bg-gradient-to-br from-primary to-secondary rounded-full flex items-center justify-center text-white text-xl font-bold">
                            <asp:Label ID="lblUserInitials" runat="server" Text="NVN"></asp:Label>
                        </div>
                        <div class="ml-3">
                            <h3 class="font-bold text-dark">
                                <asp:Label ID="lblUserName" runat="server" Text="Nguyễn Văn Nam"></asp:Label>
                            </h3>
                            <p class="text-sm text-gray-500">
                                <asp:Label ID="lblMembershipLevel" runat="server" Text="Thành viên VIP"></asp:Label>
                            </p>
                            <div class="flex items-center text-xs text-yellow-500">
                                <asp:Literal ID="litUserRating" runat="server">
                                    <i class="fas fa-star"></i>
                                    <i class="fas fa-star"></i>
                                    <i class="fas fa-star"></i>
                                    <i class="fas fa-star"></i>
                                    <i class="fas fa-star"></i>
                                </asp:Literal>
                            </div>
                        </div>
                    </div>

                    <!-- Menu Items -->
                    <nav class="space-y-1">
                        <asp:LinkButton ID="btnDashboard" runat="server" 
                            CssClass="tab-button active w-full text-left px-3 py-2 rounded-lg transition-colors flex items-center"
                            OnClientClick="showTab('dashboard'); return false;">
                            <i class="fas fa-tachometer-alt w-5 mr-2"></i>
                            <span>Tổng quan</span>
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnOrders" runat="server" 
                            CssClass="tab-button w-full text-left px-3 py-2 rounded-lg hover:bg-gray-100 transition-colors flex items-center"
                            OnClientClick="showTab('orders'); return false;">
                            <i class="fas fa-shopping-bag w-5 mr-2"></i>
                            <span>Đơn hàng</span>
                            <span class="ml-auto bg-primary text-white text-xs px-2 py-1 rounded-full">
                                <asp:Label ID="lblOrderCount" runat="server" Text="5"></asp:Label>
                            </span>
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnWishlist" runat="server" 
                            CssClass="tab-button w-full text-left px-3 py-2 rounded-lg hover:bg-gray-100 transition-colors flex items-center"
                            OnClientClick="showTab('wishlist'); return false;">
                            <i class="fas fa-heart w-5 mr-2"></i>
                            <span>Yêu thích</span>
                            <span class="ml-auto bg-secondary text-white text-xs px-2 py-1 rounded-full">
                                <asp:Label ID="lblWishlistCount" runat="server" Text="12"></asp:Label>
                            </span>
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnProfile" runat="server" 
                            CssClass="tab-button w-full text-left px-3 py-2 rounded-lg hover:bg-gray-100 transition-colors flex items-center"
                            OnClientClick="showTab('profile'); return false;">
                            <i class="fas fa-user w-5 mr-2"></i>
                            <span>Thông tin cá nhân</span>
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnAddresses" runat="server" 
                            CssClass="tab-button w-full text-left px-3 py-2 rounded-lg hover:bg-gray-100 transition-colors flex items-center"
                            OnClientClick="showTab('addresses'); return false;">
                            <i class="fas fa-map-marker-alt w-5 mr-2"></i>
                            <span>Địa chỉ giao hàng</span>
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnSecurity" runat="server" 
                            CssClass="tab-button w-full text-left px-3 py-2 rounded-lg hover:bg-gray-100 transition-colors flex items-center"
                            OnClientClick="showTab('security'); return false;">
                            <i class="fas fa-shield-alt w-5 mr-2"></i>
                            <span>Bảo mật</span>
                        </asp:LinkButton>
                        <hr class="my-2">
                        <asp:LinkButton ID="btnLogout" runat="server" 
                            CssClass="w-full text-left px-3 py-2 rounded-lg hover:bg-red-50 hover:text-red-600 transition-colors flex items-center text-gray-600"
                            OnClick="btnLogout_Click">
                            <i class="fas fa-sign-out-alt w-5 mr-2"></i>
                            <span>Đăng xuất</span>
                        </asp:LinkButton>
                    </nav>
                </div>
            </div>

            <!-- Main Content Area -->
            <div class="w-full lg:w-3/4">
                <!-- Dashboard Tab -->
                <div id="dashboard" class="tab-content active">
                    <div class="bg-white rounded-lg shadow-md p-6 mb-6">
                        <h2 class="text-2xl font-bold text-dark mb-4">
                            Chào mừng trở lại, <asp:Label ID="lblWelcomeName" runat="server" Text="Nam"></asp:Label>! 👋
                        </h2>
                        <p class="text-gray-600 mb-4">Đây là tổng quan về tài khoản và hoạt động mua sắm của bạn tại ToyLand.</p>
                        
                        <!-- Stats Cards -->
                        <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
                            <div class="bg-gradient-to-br from-primary to-pink-500 text-white p-4 rounded-lg">
                                <div class="flex items-center justify-between">
                                    <div>
                                        <p class="text-sm opacity-80">Tổng đơn hàng</p>
                                        <p class="text-2xl font-bold">
                                            <asp:Label ID="lblTotalOrders" runat="server" Text="24"></asp:Label>
                                        </p>
                                    </div>
                                    <i class="fas fa-shopping-bag text-2xl opacity-60"></i>
                                </div>
                            </div>
                            <div class="bg-gradient-to-br from-secondary to-teal-500 text-white p-4 rounded-lg">
                                <div class="flex items-center justify-between">
                                    <div>
                                        <p class="text-sm opacity-80">Đã chi tiêu</p>
                                        <p class="text-2xl font-bold">
                                            <asp:Label ID="lblTotalSpent" runat="server" Text="12.5M"></asp:Label>
                                        </p>
                                    </div>
                                    <i class="fas fa-credit-card text-2xl opacity-60"></i>
                                </div>
                            </div>
                            <div class="bg-gradient-to-br from-accent to-yellow-500 text-white p-4 rounded-lg">
                                <div class="flex items-center justify-between">
                                    <div>
                                        <p class="text-sm opacity-80">Tiết kiệm</p>
                                        <p class="text-2xl font-bold">
                                            <asp:Label ID="lblTotalSaved" runat="server" Text="850K"></asp:Label>
                                        </p>
                                    </div>
                                    <i class="fas fa-piggy-bank text-2xl opacity-60"></i>
                                </div>
                            </div>
                            <div class="bg-gradient-to-br from-dark to-gray-700 text-white p-4 rounded-lg">
                                <div class="flex items-center justify-between">
                                    <div>
                                        <p class="text-sm opacity-80">Điểm thưởng</p>
                                        <p class="text-2xl font-bold">
                                            <asp:Label ID="lblRewardPoints" runat="server" Text="1,250"></asp:Label>
                                        </p>
                                    </div>
                                    <i class="fas fa-star text-2xl opacity-60"></i>
                                </div>
                            </div>
                        </div>

                        <!-- Recent Orders -->
                        <div class="grid lg:grid-cols-2 gap-6">
                            <div>
                                <h3 class="text-lg font-bold text-dark mb-3">Đơn hàng gần đây</h3>
                                <div class="space-y-3">
                                    <asp:Repeater ID="rptRecentOrders" runat="server">
                                        <ItemTemplate>
                                            <div class="flex items-center p-3 border rounded-lg hover:bg-gray-50">
                                                <asp:Image ID="imgOrderProduct" runat="server" 
                                                    ImageUrl='<%# Eval("ProductImage") %>' 
                                                    AlternateText="Sản phẩm" 
                                                    CssClass="w-12 h-12 rounded-lg object-cover" />
                                                <div class="ml-3 flex-grow">
                                                    <h4 class="font-medium text-sm"><%# Eval("ProductName") %></h4>
                                                    <p class="text-xs text-gray-500">Đơn hàng #<%# Eval("OrderCode") %></p>
                                                </div>
                                                <div class="text-right">
                                                    <p class="text-sm font-bold text-primary"><%# Eval("TotalAmount", "{0:N0}") %>đ</p>
                                                    <span class="text-xs bg-green-100 text-green-600 px-2 py-1 rounded"><%# Eval("StatusText") %></span>
                                                </div>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                                <asp:HyperLink ID="lnkViewAllOrders" runat="server" 
                                    NavigateUrl="#" 
                                    CssClass="block text-center text-primary hover:underline mt-3"
                                    OnClientClick="showTab('orders'); return false;">Xem tất cả đơn hàng</asp:HyperLink>
                            </div>
                            
                            <div>
                                <h3 class="text-lg font-bold text-dark mb-3">Thông báo</h3>
                                <div class="space-y-3">
                                    <asp:Repeater ID="rptNotifications" runat="server">
                                        <ItemTemplate>
                                            <div class="p-3 bg-<%# Eval("ColorClass") %>-50 border-l-4 border-<%# Eval("ColorClass") %>-500 rounded">
                                                <p class="text-sm font-medium text-<%# Eval("ColorClass") %>-800"><%# Eval("Title") %></p>
                                                <p class="text-xs text-<%# Eval("ColorClass") %>-600"><%# Eval("Message") %></p>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Orders Tab -->
                <div id="orders" class="tab-content">
                    <div class="bg-white rounded-lg shadow-md p-6">
                        <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-6">
                            <h2 class="text-2xl font-bold text-dark mb-4 md:mb-0">Đơn hàng của tôi</h2>
                            <div class="flex space-x-2">
                                <asp:DropDownList ID="ddlOrderStatus" runat="server" 
                                    CssClass="px-3 py-2 border rounded-lg focus:outline-none focus:border-primary"
                                    OnSelectedIndexChanged="ddlOrderStatus_SelectedIndexChanged"
                                    AutoPostBack="true">
                                    <asp:ListItem Value="all" Text="Tất cả đơn hàng" Selected="True" />
                                    <asp:ListItem Value="pending" Text="Chờ xác nhận" />
                                    <asp:ListItem Value="processing" Text="Đang xử lý" />
                                    <asp:ListItem Value="shipping" Text="Đang giao" />
                                    <asp:ListItem Value="delivered" Text="Đã giao" />
                                    <asp:ListItem Value="cancelled" Text="Đã hủy" />
                                </asp:DropDownList>
                            </div>
                        </div>

                        <div class="space-y-4">
                            <asp:Repeater ID="rptOrders" runat="server" OnItemCommand="rptOrders_ItemCommand">
                                <ItemTemplate>
                                    <div class="border rounded-lg p-4 hover:shadow-md transition-shadow">
                                        <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-3">
                                            <div>
                                                <h3 class="font-bold text-dark">Đơn hàng #<%# Eval("OrderCode") %></h3>
                                                <p class="text-sm text-gray-500">Đặt ngày: <%# Eval("OrderDate", "{0:dd/MM/yyyy}") %></p>
                                            </div>
                                            <span class="bg-<%# Eval("StatusColor") %>-100 text-<%# Eval("StatusColor") %>-600 px-3 py-1 rounded-full text-sm font-medium">
                                                <%# Eval("StatusText") %>
                                            </span>
                                        </div>
                                        <div class="space-y-2">
                                            <asp:Repeater ID="rptOrderItems" runat="server" DataSource='<%# Eval("OrderItems") %>'>
                                                <ItemTemplate>
                                                    <div class="flex items-center">
                                                        <asp:Image ID="imgProduct" runat="server" 
                                                            ImageUrl='<%# Eval("ProductImage") %>' 
                                                            AlternateText="Sản phẩm" 
                                                            CssClass="w-12 h-12 rounded-lg object-cover" />
                                                        <div class="ml-3 flex-grow">
                                                            <h4 class="font-medium"><%# Eval("ProductName") %></h4>
                                                            <p class="text-sm text-gray-500">Số lượng: <%# Eval("Quantity") %></p>
                                                        </div>
                                                        <p class="font-bold text-primary"><%# Eval("Price", "{0:N0}") %>đ</p>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </div>
                                        <div class="flex flex-col md:flex-row justify-between items-start md:items-center mt-4 pt-3 border-t">
                                            <p class="text-sm text-gray-600">
                                                Tổng tiền: <span class="font-bold text-dark"><%# Eval("TotalAmount", "{0:N0}") %>đ</span>
                                            </p>
                                            <div class="flex space-x-2 mt-2 md:mt-0">
                                                <asp:LinkButton ID="btnViewDetails" runat="server" 
                                                    CommandName="ViewDetails" 
                                                    CommandArgument='<%# Eval("Id") %>'
                                                    CssClass="px-4 py-2 border border-primary text-primary rounded hover:bg-primary hover:text-white transition-colors">
                                                    Xem chi tiết
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnReorder" runat="server" 
                                                    CommandName="Reorder" 
                                                    CommandArgument='<%# Eval("Id") %>'
                                                    CssClass="px-4 py-2 bg-primary text-white rounded hover:bg-primary-dark transition-colors"
                                                    Visible='<%# Convert.ToString(Eval("Status")) == "delivered" %>'>
                                                    Mua lại
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnCancelOrder" runat="server" 
                                                    CommandName="Cancel" 
                                                    CommandArgument='<%# Eval("Id") %>'
                                                    CssClass="px-4 py-2 border border-red-300 text-red-600 rounded hover:bg-red-50 transition-colors"
                                                    Visible='<%# Convert.ToString(Eval("Status")) == "pending" || Convert.ToString(Eval("Status")) == "processing" %>'
                                                    OnClientClick="return confirm('Bạn có chắc chắn muốn hủy đơn hàng này?');">
                                                    Hủy đơn
                                                </asp:LinkButton>
                                            </div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>

                        <!-- Pagination -->
                        <div class="flex justify-center mt-6">
                            <div class="flex space-x-1">
                                <asp:LinkButton ID="btnOrdersPrevPage" runat="server" 
                                    CssClass="px-3 py-1 rounded bg-gray-200 text-gray-600 hover:bg-primary hover:text-white transition-colors"
                                    OnClick="btnOrdersPrevPage_Click">
                                    <i class="fas fa-chevron-left"></i>
                                </asp:LinkButton>
                                
                                <asp:Repeater ID="rptOrdersPagination" runat="server">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnOrdersPage" runat="server" 
                                            Text='<%# Eval("PageNumber") %>'
                                            CommandArgument='<%# Eval("PageNumber") %>'
                                            CssClass='<%# Convert.ToBoolean(Eval("IsCurrentPage")) ? "px-3 py-1 rounded bg-primary text-white" : "px-3 py-1 rounded bg-gray-200 text-gray-600 hover:bg-primary hover:text-white transition-colors" %>'
                                            OnClick="btnOrdersPage_Click" />
                                    </ItemTemplate>
                                </asp:Repeater>
                                
                                <asp:LinkButton ID="btnOrdersNextPage" runat="server" 
                                    CssClass="px-3 py-1 rounded bg-gray-200 text-gray-600 hover:bg-primary hover:text-white transition-colors"
                                    OnClick="btnOrdersNextPage_Click">
                                    <i class="fas fa-chevron-right"></i>
                                </asp:LinkButton>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Wishlist Tab -->
                <div id="wishlist" class="tab-content">
                    <div class="bg-white rounded-lg shadow-md p-6">
                        <h2 class="text-2xl font-bold text-dark mb-6">Danh sách yêu thích</h2>
                        
                        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                            <asp:Repeater ID="rptWishlist" runat="server" OnItemCommand="rptWishlist_ItemCommand">
                                <ItemTemplate>
                                    <div class="border rounded-lg p-4 group hover:shadow-md transition-shadow">
                                        <div class="relative">
                                            <asp:Image ID="imgWishlistProduct" runat="server" 
                                                ImageUrl='<%# Eval("ProductImage") %>' 
                                                AlternateText="Sản phẩm" 
                                                CssClass="w-full h-40 object-cover rounded-lg mb-3" />
                                            <asp:LinkButton ID="btnRemoveFromWishlist" runat="server" 
                                                CommandName="RemoveFromWishlist" 
                                                CommandArgument='<%# Eval("Id") %>'
                                                CssClass="absolute top-2 right-2 w-8 h-8 bg-white rounded-full flex items-center justify-center text-red-500 shadow-md hover:bg-red-50"
                                                OnClientClick="return confirm('Bạn có muốn xóa sản phẩm này khỏi danh sách yêu thích?');">
                                                <i class="fas fa-heart"></i>
                                            </asp:LinkButton>
                                        </div>
                                        <h3 class="font-medium text-gray-800 mb-2"><%# Eval("ProductName") %></h3>
                                        <div class="flex items-center text-xs mb-2">
                                            <div class="flex text-yellow-400">
                                            </div>
                                            <span class="text-gray-500 ml-1">(<%# Eval("ReviewCount") %>)</span>
                                        </div>
                                        <div class="flex justify-between items-center mb-3">
                                            <div>
                                                <span class="text-primary font-bold"><%# Eval("Price", "{0:N0}") %>đ</span>
                                                <asp:Panel ID="pnlWishlistOriginalPrice" runat="server" 
                                                    Visible='<%# Convert.ToDecimal(Eval("OriginalPrice")) > 0 %>' 
                                                    CssClass="inline">
                                                    <span class="text-gray-500 text-xs line-through ml-1"><%# Eval("OriginalPrice", "{0:N0}") %>đ</span>
                                                </asp:Panel>
                                            </div>
                                            <span class="bg-<%# Convert.ToBoolean(Eval("InStock")) ? "green" : "red" %>-100 text-<%# Convert.ToBoolean(Eval("InStock")) ? "green" : "red" %>-600 text-xs px-2 py-1 rounded">
                                                <%# Convert.ToBoolean(Eval("InStock")) ? "Còn hàng" : "Hết hàng" %>
                                            </span>
                                        </div>
                                        <asp:LinkButton ID="btnAddToCartFromWishlist" runat="server" 
                                            CommandName="AddToCart" 
                                            CommandArgument='<%# Eval("Id") %>'
                                            CssClass='<%# Convert.ToBoolean(Eval("InStock")) ? "w-full bg-primary text-white py-2 rounded hover:bg-primary-dark transition-colors" : "w-full bg-gray-300 text-gray-500 py-2 rounded cursor-not-allowed" %>'
                                            Enabled='<%# Convert.ToBoolean(Eval("InStock")) %>'>
                                            <%# Convert.ToBoolean(Eval("InStock")) ? "<i class=\"fas fa-shopping-cart mr-1\"></i> Thêm vào giỏ" : "<i class=\"fas fa-ban mr-1\"></i> Hết hàng" %>
                                        </asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                </div>

                <!-- Profile Tab -->
                <div id="profile" class="tab-content">
                    <div class="bg-white rounded-lg shadow-md p-6">
                        <h2 class="text-2xl font-bold text-dark mb-6">Thông tin cá nhân</h2>
                        
                        <div class="space-y-6">
                            <div class="flex flex-col lg:flex-row gap-6">
                                <div class="lg:w-1/4">
                                    <div class="text-center">
                                        <div class="w-32 h-32 bg-gradient-to-br from-primary to-secondary rounded-full flex items-center justify-center text-white text-4xl font-bold mx-auto mb-4">
                                            <asp:Label ID="lblProfileInitials" runat="server" Text="NVN"></asp:Label>
                                        </div>
                                        <asp:FileUpload ID="fuProfileImage" runat="server" Style="display: none;" 
                                            OnChange="document.getElementById('btnUploadImage').click();" />
                                        <asp:Button ID="btnUploadImage" runat="server" Style="display: none;" 
                                            OnClick="btnUploadImage_Click" />
                                        <button type="button" class="text-primary hover:underline text-sm" 
                                            onclick="document.getElementById('<%= fuProfileImage.ClientID %>').click();">
                                            <i class="fas fa-camera mr-1"></i> Thay đổi ảnh
                                        </button>
                                    </div>
                                </div>
                                
                                <div class="lg:w-3/4 space-y-4">
                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-1">Họ và tên *</label>
                                            <asp:TextBox ID="txtFullName" runat="server" 
                                                CssClass="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-primary"
                                                Text="Nguyễn Văn Nam" />
                                            <asp:RequiredFieldValidator ID="rfvFullName" runat="server" 
                                                ControlToValidate="txtFullName" 
                                                ErrorMessage="Vui lòng nhập họ tên" 
                                                CssClass="text-red-500 text-xs" 
                                                Display="Dynamic" 
                                                ValidationGroup="ProfileUpdate" />
                                        </div>
                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-1">Email *</label>
                                            <asp:TextBox ID="txtEmail" runat="server" 
                                                TextMode="Email"
                                                CssClass="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-primary"
                                                Text="nam.nguyen@email.com" />
                                            <asp:RequiredFieldValidator ID="rfvEmail" runat="server" 
                                                ControlToValidate="txtEmail" 
                                                ErrorMessage="Vui lòng nhập email" 
                                                CssClass="text-red-500 text-xs" 
                                                Display="Dynamic" 
                                                ValidationGroup="ProfileUpdate" />
                                            <asp:RegularExpressionValidator ID="revEmail" runat="server" 
                                                ControlToValidate="txtEmail" 
                                                ErrorMessage="Email không hợp lệ" 
                                                ValidationExpression="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$" 
                                                CssClass="text-red-500 text-xs" 
                                                Display="Dynamic" 
                                                ValidationGroup="ProfileUpdate" />
                                        </div>
                                    </div>
                                    
                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-1">Số điện thoại</label>
                                            <asp:TextBox ID="txtPhone" runat="server" 
                                                CssClass="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-primary"
                                                Text="0987 654 321" />
                                        </div>
                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-1">Ngày sinh</label>
                                            <asp:TextBox ID="txtBirthDate" runat="server" 
                                                TextMode="Date"
                                                CssClass="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-primary"
                                                Text="1990-05-15" />
                                        </div>
                                    </div>
                                    
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 mb-1">Giới tính</label>
                                        <asp:RadioButtonList ID="rblGender" runat="server" 
                                            CssClass="flex space-x-4" 
                                            RepeatDirection="Horizontal" 
                                            RepeatLayout="Flow">
                                            <asp:ListItem Value="male" Text="Nam" Selected="True" />
                                            <asp:ListItem Value="female" Text="Nữ" />
                                            <asp:ListItem Value="other" Text="Khác" />
                                        </asp:RadioButtonList>
                                    </div>
                                    
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 mb-1">Địa chỉ</label>
                                        <asp:TextBox ID="txtAddress" runat="server" 
                                            TextMode="MultiLine" 
                                            Rows="3"
                                            CssClass="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-primary" 
                                            placeholder="Nhập địa chỉ của bạn"
                                            Text="123 Đường ABC, Phường XYZ, Quận 1, TP.HCM" />
                                    </div>
                                    
                                    <div class="flex space-x-3">
                                        <asp:Button ID="btnSaveProfile" runat="server" 
                                            Text="Lưu thay đổi" 
                                            CssClass="bg-primary text-white px-6 py-2 rounded-lg hover:bg-primary-dark transition-colors"
                                            OnClick="btnSaveProfile_Click" 
                                            ValidationGroup="ProfileUpdate" />
                                        <asp:Button ID="btnCancelProfile" runat="server" 
                                            Text="Hủy" 
                                            CssClass="border border-gray-300 text-gray-700 px-6 py-2 rounded-lg hover:bg-gray-50 transition-colors"
                                            OnClick="btnCancelProfile_Click" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Addresses Tab -->
                <div id="addresses" class="tab-content">
                    <div class="bg-white rounded-lg shadow-md p-6">
                        <div class="flex justify-between items-center mb-6">
                            <h2 class="text-2xl font-bold text-dark">Địa chỉ giao hàng</h2>
                            <asp:Button ID="btnAddNewAddress" runat="server" 
                                Text="Thêm địa chỉ mới" 
                                CssClass="bg-primary text-white px-4 py-2 rounded-lg hover:bg-primary-dark transition-colors"
                                OnClick="btnAddNewAddress_Click" />
                        </div>
                        
                        <div class="space-y-4">
                            <asp:Repeater ID="rptAddresses" runat="server" OnItemCommand="rptAddresses_ItemCommand">
                                <ItemTemplate>
                                    <div class="border rounded-lg p-4 relative">
                                        <asp:Panel ID="pnlDefaultBadge" runat="server" Visible='<%# Convert.ToBoolean(Eval("IsDefault")) %>'>
                                            <div class="absolute top-3 right-3">
                                                <span class="bg-primary text-white text-xs px-2 py-1 rounded">Mặc định</span>
                                            </div>
                                        </asp:Panel>
                                        <div class="pr-20">
                                            <h3 class="font-bold text-dark mb-1"><%# Eval("RecipientName") %></h3>
                                            <p class="text-gray-600 text-sm mb-1"><%# Eval("PhoneNumber") %></p>
                                            <p class="text-gray-600 text-sm"><%# Eval("FullAddress") %></p>
                                        </div>
                                        <div class="flex space-x-2 mt-3">
                                            <asp:LinkButton ID="btnEditAddress" runat="server" 
                                                CommandName="Edit" 
                                                CommandArgument='<%# Eval("Id") %>'
                                                CssClass="text-primary hover:underline text-sm">
                                                <i class="fas fa-edit mr-1"></i> Chỉnh sửa
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnSetDefaultAddress" runat="server" 
                                                CommandName="SetDefault" 
                                                CommandArgument='<%# Eval("Id") %>'
                                                CssClass="text-primary hover:underline text-sm"
                                                Visible='<%# !Convert.ToBoolean(Eval("IsDefault")) %>'>
                                                <i class="fas fa-star mr-1"></i> Đặt làm mặc định
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnDeleteAddress" runat="server" 
                                                CommandName="Delete" 
                                                CommandArgument='<%# Eval("Id") %>'
                                                CssClass="text-red-600 hover:underline text-sm"
                                                OnClientClick="return confirm('Bạn có chắc chắn muốn xóa địa chỉ này?');"
                                                Visible='<%# !Convert.ToBoolean(Eval("IsDefault")) %>'>
                                                <i class="fas fa-trash mr-1"></i> Xóa
                                            </asp:LinkButton>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                </div>

                <!-- Security Tab -->
                <div id="security" class="tab-content">
                    <div class="bg-white rounded-lg shadow-md p-6">
                        <h2 class="text-2xl font-bold text-dark mb-6">Bảo mật tài khoản</h2>
                        
                        <div class="space-y-6">
                            <!-- Change Password -->
                            <div class="border rounded-lg p-4">
                                <h3 class="text-lg font-bold text-dark mb-4">Đổi mật khẩu</h3>
                                <div class="space-y-4">
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 mb-1">Mật khẩu hiện tại</label>
                                        <asp:TextBox ID="txtCurrentPassword" runat="server" 
                                            TextMode="Password"
                                            CssClass="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-primary" />
                                        <asp:RequiredFieldValidator ID="rfvCurrentPassword" runat="server" 
                                            ControlToValidate="txtCurrentPassword" 
                                            ErrorMessage="Vui lòng nhập mật khẩu hiện tại" 
                                            CssClass="text-red-500 text-xs" 
                                            Display="Dynamic" 
                                            ValidationGroup="ChangePassword" />
                                    </div>
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 mb-1">Mật khẩu mới</label>
                                        <asp:TextBox ID="txtNewPassword" runat="server" 
                                            TextMode="Password"
                                            CssClass="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-primary" />
                                        <asp:RequiredFieldValidator ID="rfvNewPassword" runat="server" 
                                            ControlToValidate="txtNewPassword" 
                                            ErrorMessage="Vui lòng nhập mật khẩu mới" 
                                            CssClass="text-red-500 text-xs" 
                                            Display="Dynamic" 
                                            ValidationGroup="ChangePassword" />
                                        <asp:RegularExpressionValidator ID="revNewPassword" runat="server" 
                                            ControlToValidate="txtNewPassword" 
                                            ErrorMessage="Mật khẩu phải có ít nhất 6 ký tự" 
                                            ValidationExpression=".{6,}" 
                                            CssClass="text-red-500 text-xs" 
                                            Display="Dynamic" 
                                            ValidationGroup="ChangePassword" />
                                    </div>
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 mb-1">Xác nhận mật khẩu mới</label>
                                        <asp:TextBox ID="txtConfirmPassword" runat="server" 
                                            TextMode="Password"
                                            CssClass="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-primary" />
                                        <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server" 
                                            ControlToValidate="txtConfirmPassword" 
                                            ErrorMessage="Vui lòng xác nhận mật khẩu mới" 
                                            CssClass="text-red-500 text-xs" 
                                            Display="Dynamic" 
                                            ValidationGroup="ChangePassword" />
                                        <asp:CompareValidator ID="cvConfirmPassword" runat="server" 
                                            ControlToValidate="txtConfirmPassword" 
                                            ControlToCompare="txtNewPassword" 
                                            ErrorMessage="Mật khẩu xác nhận không khớp" 
                                            CssClass="text-red-500 text-xs" 
                                            Display="Dynamic" 
                                            ValidationGroup="ChangePassword" />
                                    </div>
                                    <asp:Button ID="btnChangePassword" runat="server" 
                                        Text="Đổi mật khẩu" 
                                        CssClass="bg-primary text-white px-6 py-2 rounded-lg hover:bg-primary-dark transition-colors"
                                        OnClick="btnChangePassword_Click" 
                                        ValidationGroup="ChangePassword" />
                                </div>
                            </div>
                            
                            <!-- Two-Factor Authentication -->
                            <div class="border rounded-lg p-4">
                                <div class="flex justify-between items-start">
                                    <div>
                                        <h3 class="text-lg font-bold text-dark mb-2">Xác thực 2 bước</h3>
                                        <p class="text-gray-600 text-sm">Tăng cường bảo mật tài khoản với xác thực 2 bước</p>
                                    </div>
                                    <div class="flex items-center">
                                        <asp:CheckBox ID="chkTwoFactorAuth" runat="server" 
                                            CssClass="toggle-switch mr-2" 
                                            OnCheckedChanged="chkTwoFactorAuth_CheckedChanged" 
                                            AutoPostBack="true" />
                                        <span class="text-sm text-gray-500">
                                            <asp:Label ID="lblTwoFactorStatus" runat="server" Text="Chưa kích hoạt"></asp:Label>
                                        </span>
                                    </div>
                                </div>
                                <asp:Button ID="btnActivateTwoFactor" runat="server" 
                                    Text="Kích hoạt ngay" 
                                    CssClass="mt-3 text-primary hover:underline text-sm bg-transparent border-0"
                                    OnClick="btnActivateTwoFactor_Click" />
                            </div>
                            
                            <!-- Login History -->
                            <div class="border rounded-lg p-4">
                                <h3 class="text-lg font-bold text-dark mb-4">Lịch sử đăng nhập</h3>
                                <div class="space-y-3">
                                    <asp:Repeater ID="rptLoginHistory" runat="server">
                                        <ItemTemplate>
                                            <div class="flex justify-between items-center text-sm">
                                                <div class="flex items-center">
                                                    <i class="fas fa-<%# Eval("DeviceIcon") %> text-<%# Eval("DeviceColor") %>-500 mr-2"></i>
                                                    <span><%# Eval("DeviceInfo") %></span>
                                                </div>
                                                <div class="text-right">
                                                    <p class="text-gray-600"><%# Eval("LoginTime") %></p>
                                                    <p class="text-xs text-gray-500">IP: <%# Eval("IpAddress") %></p>
                                                </div>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                                <asp:Button ID="btnViewAllLoginHistory" runat="server" 
                                    Text="Xem tất cả" 
                                    CssClass="mt-3 text-primary hover:underline text-sm bg-transparent border-0"
                                    OnClick="btnViewAllLoginHistory_Click" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Back to top button -->
    <asp:Button ID="btnBackToTop" runat="server" 
        CssClass="fixed bottom-20 right-4 bg-primary text-white w-10 h-10 rounded-full flex items-center justify-center shadow-lg z-40 hover:bg-dark transition-colors" 
        Style="display: none;" 
        OnClientClick="window.scrollTo({ top: 0, behavior: 'smooth' }); return false;">
    </asp:Button>

    <script>
        // Tab functionality
        function showTab(tabName) {
            // Remove active class from all buttons and content
            document.querySelectorAll('.tab-button').forEach(btn => btn.classList.remove('active'));
            document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
            
            // Add active class to clicked button and corresponding content
            event.target.classList.add('active');
            document.getElementById(tabName).classList.add('active');
        }

        // Back to Top Button
        const backToTopButton = document.getElementById('<%= btnBackToTop.ClientID %>');
        window.addEventListener('scroll', () => {
            if (window.scrollY > 300) {
                backToTopButton.style.display = 'flex';
            } else {
                backToTopButton.style.display = 'none';
            }
        });

        // Bottom Navigation Active State
        const navItems = document.querySelectorAll('.nav-item');
        navItems.forEach(item => {
            item.addEventListener('click', (e) => {
                // Remove active class from all items
                navItems.forEach(nav => {
                    nav.classList.remove('active');
                    nav.classList.add('text-gray-600');
                });
                // Add active class to clicked item
                item.classList.add('active');
                item.classList.remove('text-gray-600');
            });
        });

        // Radio button styling for gender
        document.addEventListener('DOMContentLoaded', function () {
            const radioButtons = document.querySelectorAll('input[type="radio"]');
            radioButtons.forEach(radio => {
                radio.addEventListener('change', function () {
                    // Custom styling can be added here if needed
                });
            });
        });
    </script>
</asp:Content>