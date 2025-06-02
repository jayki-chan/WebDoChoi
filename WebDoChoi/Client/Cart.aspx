<%@ Page Title="Giỏ hàng & Thanh toán - ToyLand" Language="C#" MasterPageFile="/Site.Master" AutoEventWireup="true" CodeBehind="Cart.aspx.cs" Inherits="WebsiteDoChoi.Client.Cart" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="head" runat="server">
    <%-- Tailwind CSS and Font Awesome are likely in Site.Master. If not, include them. --%>
    <%-- <script src="https://cdn.tailwindcss.com"></script> --%>
    <%-- <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" /> --%>

    <script>
        // Ensure Tailwind config is loaded, preferably from Site.Master.
        // This is a fallback/extension mechanism.
        if (typeof tailwind === 'object' && tailwind.config) {
            tailwind.config = {
                ...tailwind.config,
                theme: {
                    ...(tailwind.config.theme || {}),
                    extend: {
                        ...(tailwind.config.theme?.extend || {}),
                        colors: {
                            ...(tailwind.config.theme?.extend?.colors || {}),
                            primary: "#FF6B6B",
                            secondary: "#4ECDC4",
                            accent: "#FFE66D",
                            dark: "#1A535C",
                            light: "#F7FFF7",
                        },
                    },
                },
            };
        } else {
            window.tailwind = {
                config: {
                    theme: {
                        extend: {
                            colors: {
                                primary: "#FF6B6B",
                                secondary: "#4ECDC4",
                                accent: "#FFE66D",
                                dark: "#1A535C",
                                light: "#F7FFF7",
                            },
                        },
                    },
                }
            };
        }
    </script>
    <style>
        @import url("https://fonts.googleapis.com/css2?family=Baloo+2:wght@400;500;600;700&display=swap");

        /* Body font-family might be better in Site.Master or a global CSS */
        /* body { font-family: "Baloo 2", cursive; } */

        .step-indicator.step-active { background-color: #FF6B6B; color: white; } /* primary */
        .step-indicator.step-completed { background-color: #4ECDC4; color: white; } /* secondary */
        .step-indicator.step-inactive { background-color: #e5e7eb; color: #6b7280; }

        .quantity-input::-webkit-outer-spin-button,
        .quantity-input::-webkit-inner-spin-button { -webkit-appearance: none; margin: 0; }
        .quantity-input { -moz-appearance: textfield; }

        .payment-method-label.selected { border-color: #FF6B6B; background-color: #fef2f2; } /* primary and light primary */
        .payment-method-label { transition: all 0.3s ease; }

        /* Bottom Navigation Styles - Likely from Site.Master or global CSS */
        /* Ensure these are consistent with your site's global styling */
        .bottom-nav { position: fixed; bottom: 0; left: 0; right: 0; background: white; border-top: 1px solid #e5e7eb; z-index: 50; box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1); }
        .nav-item { transition: all 0.3s ease; }
        .nav-item.active { color: #FF6B6B; transform: translateY(-2px); } /* primary */
        .nav-item:not(.active):hover { color: #FF6B6B; } /* primary */

        @media (max-width: 767px) {
            body { padding-bottom: 80px; } /* For bottom nav */
            .desktop-nav { display: none !important; }
        }
        @media (min-width: 768px) {
            .bottom-nav { display: none !important; }
            /* body { padding-bottom: 0; } /* Reset if not needed */
        }
    </style>
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="MainContent" runat="server">
    <nav class="bottom-nav md:hidden">
        <div class="flex justify-around items-center py-2">
            <asp:HyperLink ID="lnkHomeBottomNav" runat="server" NavigateUrl="/Client/Default.aspx" CssClass="nav-item flex flex-col items-center py-1 px-2 text-center min-w-0 text-gray-600">
                <i class="fas fa-home text-lg mb-1"></i><span class="text-xs truncate">Trang chủ</span>
            </asp:HyperLink>
            <asp:HyperLink ID="lnkProductsBottomNav" runat="server" NavigateUrl="/Client/ProductList.aspx" CssClass="nav-item flex flex-col items-center py-1 px-2 text-center min-w-0 text-gray-600">
                <i class="fas fa-star text-lg mb-1"></i><span class="text-xs truncate">Sản phẩm</span>
            </asp:HyperLink>
            <asp:HyperLink ID="lnkCartBottomNav" runat="server" NavigateUrl="/Client/Cart.aspx" CssClass="nav-item active flex flex-col items-center py-1 px-2 text-center min-w-0"> <%-- Mark Cart as active --%>
                <i class="fas fa-shopping-cart text-lg mb-1"></i><span class="text-xs truncate">Giỏ hàng</span>
            </asp:HyperLink>
            <asp:HyperLink ID="lnkPromotionsBottomNav" runat="server" NavigateUrl="/Client/Promotions.aspx" CssClass="nav-item flex flex-col items-center py-1 px-2 text-center min-w-0 text-gray-600">
                <i class="fas fa-tag text-lg mb-1"></i><span class="text-xs truncate">Khuyến mãi</span>
            </asp:HyperLink>
            <asp:HyperLink ID="lnkAccountBottomNav" runat="server" NavigateUrl="/Client/Profile.aspx" CssClass="nav-item flex flex-col items-center py-1 px-2 text-center min-w-0 text-gray-600">
                <i class="fas fa-user text-lg mb-1"></i><span class="text-xs truncate">Tài khoản</span>
            </asp:HyperLink>
        </div>
    </nav>

    <div class="bg-white border-b">
        <div class="container mx-auto px-4 py-3">
            <nav class="flex items-center space-x-2 text-sm">
                <asp:HyperLink ID="lnkBreadcrumbHome" runat="server" NavigateUrl="/Client/Default.aspx" CssClass="text-gray-600 hover:text-primary transition-colors">
                    <i class="fas fa-home"></i> Trang chủ
                </asp:HyperLink>
                <i class="fas fa-chevron-right text-gray-400 text-xs"></i>
                <span class="text-primary font-medium">Giỏ hàng & Thanh toán</span>
            </nav>
        </div>
    </div>

    <div class="bg-white py-6 shadow-sm">
        <div class="container mx-auto px-4">
            <div class="flex items-center justify-center">
                <div class="flex items-center space-x-4 md:space-x-8">
                    <asp:Panel ID="pnlStep1Indicator" runat="server" CssClass="flex items-center">
                        <div id="step1" class="step-indicator w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold">1</div>
                        <span class="ml-2 text-sm font-medium text-gray-700">Giỏ hàng</span>
                    </asp:Panel>
                    <i class="fas fa-chevron-right text-gray-400"></i>
                    <asp:Panel ID="pnlStep2Indicator" runat="server" CssClass="flex items-center">
                        <div id="step2" class="step-indicator w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold">2</div>
                        <span class="ml-2 text-sm font-medium text-gray-700">Thông tin</span>
                    </asp:Panel>
                    <i class="fas fa-chevron-right text-gray-400"></i>
                    <asp:Panel ID="pnlStep3Indicator" runat="server" CssClass="flex items-center">
                        <div id="step3" class="step-indicator w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold">3</div>
                        <span class="ml-2 text-sm font-medium text-gray-700">Thanh toán</span>
                    </asp:Panel>
                </div>
            </div>
        </div>
    </div>

    <div class="container mx-auto px-4 py-6">
        <asp:MultiView ID="mvCheckoutSteps" runat="server" ActiveViewIndex="0">
            <asp:View ID="viewCart" runat="server">
                <div class="flex flex-col lg:flex-row gap-6">
                    <div class="lg:w-2/3">
                        <div class="bg-white rounded-lg shadow-md p-6">
                            <div class="flex justify-between items-center border-b pb-4 mb-6">
                                <h2 class="text-xl font-bold text-dark">Giỏ hàng của bạn</h2>
                                <asp:Label ID="lblCartItemCount" runat="server" CssClass="text-gray-600" Text="0 sản phẩm"></asp:Label>
                            </div>

                            <asp:Repeater ID="rptCartItems" runat="server" OnItemCommand="rptCartItems_ItemCommand">
                                <ItemTemplate>
                                    <div class="cart-item flex items-start <%# Container.ItemIndex < (rptCartItems.Items.Count -1) ? "border-b pb-6 mb-6" : "" %>">
                                        <div class="w-20 h-20 bg-gray-100 rounded-lg overflow-hidden mr-4 flex-shrink-0">
                                            <asp:Image ID="imgProduct" runat="server" ImageUrl='<%# Eval("ImageUrl", "https://api.placeholder.com/300/300?text=Toy") %>' AlternateText='<%# Eval("ProductName") %>' CssClass="w-full h-full object-cover" />
                                        </div>
                                        <div class="flex-grow">
                                            <h3 class="font-medium text-gray-800 mb-1"><%# Eval("ProductName") %></h3>
                                            <p class="text-gray-600 text-sm mb-2">Mã SP: <%# Eval("ProductCode") %></p>
                                            <div class="flex items-center text-sm">
                                                <%-- Rating can be added dynamically here if available --%>
                                            </div>
                                        </div>
                                        <div class="text-right">
                                            <div class="flex items-center mb-2">
                                                <asp:LinkButton ID="btnDecreaseQuantity" runat="server" CommandName="DecreaseQuantity" CommandArgument='<%# Eval("ProductId") %>' CssClass="quantity-btn w-8 h-8 rounded border hover:bg-gray-100 flex items-center justify-center" OnClientClick='<%# "handleQuantityChange(this, " + Eval("ProductId") + ", \"decrease\"); return false;" %>'>
                                                    <i class="fas fa-minus text-xs"></i>
                                                </asp:LinkButton>
                                                <asp:TextBox ID="txtQuantity" runat="server" Text='<%# Eval("Quantity") %>' CssClass="quantity-input w-12 text-center border-t border-b py-1" ReadOnly="true" />
                                                <asp:LinkButton ID="btnIncreaseQuantity" runat="server" CommandName="IncreaseQuantity" CommandArgument='<%# Eval("ProductId") %>' CssClass="quantity-btn w-8 h-8 rounded border hover:bg-gray-100 flex items-center justify-center" OnClientClick='<%# "handleQuantityChange(this, " + Eval("ProductId") + ", \"increase\"); return false;" %>'>
                                                    <i class="fas fa-plus text-xs"></i>
                                                </asp:LinkButton>
                                            </div>
                                            <asp:Label ID="lblPrice" runat="server" Text='<%# Eval("Price", "{0:N0}đ") %>' CssClass="text-primary font-bold text-lg"></asp:Label>
                                            <asp:Label ID="lblOriginalPrice" runat="server" Text='<%# Eval("OriginalPrice", "{0:N0}đ") %>' CssClass="text-gray-500 text-sm line-through" Visible='<%# Convert.ToDecimal(Eval("OriginalPrice")) > 0 && Convert.ToDecimal(Eval("OriginalPrice")) > Convert.ToDecimal(Eval("Price")) %>'></asp:Label>
                                            <asp:LinkButton ID="btnRemoveItem" runat="server" CommandName="RemoveItem" CommandArgument='<%# Eval("ProductId") %>' CssClass="text-red-500 hover:text-red-600 text-sm mt-1" OnClientClick="return confirm('Bạn có chắc chắn muốn xóa sản phẩm này?');">
                                                <i class="fas fa-trash-alt mr-1"></i>Xóa
                                            </asp:LinkButton>
                                        </div>
                                    </div>
                                </ItemTemplate>
                                <FooterTemplate>
                                    <asp:Panel ID="pnlEmptyCart" runat="server" Visible='<%# rptCartItems.Items.Count == 0 %>' CssClass="text-center py-10">
                                        <i class="fas fa-shopping-cart fa-3x text-gray-300 mb-4"></i>
                                        <p class="text-gray-600">Giỏ hàng của bạn đang trống.</p>
                                        <asp:HyperLink ID="lnkShopNowEmpty" runat="server" NavigateUrl="/Client/Default.aspx" CssClass="mt-4 inline-block bg-primary text-white px-6 py-2 rounded-lg hover:bg-opacity-90">
                                            Mua sắm ngay
                                        </asp:HyperLink>
                                    </asp:Panel>
                                </FooterTemplate>
                            </asp:Repeater>
                             <asp:Panel ID="pnlContinueShopping" runat="server" Visible='<%# rptCartItems.Items.Count > 0 %>'>
                                <div class="mt-6 pt-6 border-t">
                                    <asp:HyperLink ID="lnkContinueShopping" runat="server" NavigateUrl="/Client/Default.aspx" CssClass="text-primary hover:underline flex items-center">
                                        <i class="fas fa-arrow-left mr-2"></i> Tiếp tục mua sắm
                                    </asp:HyperLink>
                                </div>
                            </asp:Panel>
                        </div>
                    </div>

                    <asp:Panel ID="pnlOrderSummaryCart" runat="server" CssClass="lg:w-1/3" Visible='<%# rptCartItems.Items.Count > 0 %>'>
                        <div class="bg-white rounded-lg shadow-md p-6 sticky top-4">
                            <h3 class="text-lg font-bold text-dark border-b pb-3 mb-4">Tổng đơn hàng</h3>
                            <div class="space-y-3 mb-4">
                                <div class="flex justify-between">
                                    <span class="text-gray-600">Tạm tính:</span>
                                    <asp:Label ID="lblSubtotal" runat="server" CssClass="font-medium" Text="0đ"></asp:Label>
                                </div>
                                <div class="flex justify-between">
                                    <span class="text-gray-600">Giảm giá:</span>
                                    <asp:Label ID="lblDiscount" runat="server" CssClass="text-green-600 font-medium" Text="0đ"></asp:Label>
                                </div>
                                <div class="flex justify-between">
                                    <span class="text-gray-600">Phí vận chuyển:</span>
                                    <asp:Label ID="lblShippingFeeCart" runat="server" CssClass="text-green-600" Text="Miễn phí"></asp:Label>
                                </div>
                            </div>
                            <div class="border-t pt-3 mb-4">
                                <div class="flex justify-between text-lg font-bold">
                                    <span>Tổng cộng:</span>
                                    <asp:Label ID="lblTotalAmountCart" runat="server" CssClass="text-primary" Text="0đ"></asp:Label>
                                </div>
                                <p class="text-sm text-gray-600 mt-1">Đã bao gồm VAT</p>
                            </div>
                            <div class="mb-4">
                                <label class="block text-sm font-medium text-gray-700 mb-2">Mã giảm giá</label>
                                <div class="flex">
                                    <asp:TextBox ID="txtCouponCode" runat="server" placeholder="Nhập mã giảm giá" CssClass="flex-grow px-3 py-2 border rounded-l-lg focus:outline-none focus:border-primary"></asp:TextBox>
                                    <asp:Button ID="btnApplyCoupon" runat="server" Text="Áp dụng" OnClick="btnApplyCoupon_Click" CssClass="bg-secondary text-white px-4 py-2 rounded-r-lg hover:bg-opacity-90 transition-colors" />
                                </div>
                                <asp:Label ID="lblCouponMessage" runat="server" CssClass="text-xs mt-1"></asp:Label>
                            </div>
                            <asp:Button ID="btnProceedToInfo" runat="server" Text="Tiến hành thanh toán" OnClick="btnProceedToInfo_Click" CssClass="w-full bg-primary text-white py-3 rounded-lg font-medium hover:bg-opacity-90 transition-colors" />
                        </div>
                    </asp:Panel>
                </div>
            </asp:View>

            <asp:View ID="viewInfo" runat="server">
                 <div class="flex flex-col lg:flex-row gap-6">
                    <div class="lg:w-2/3">
                        <div class="bg-white rounded-lg shadow-md p-6">
                            <h2 class="text-xl font-bold text-dark border-b pb-4 mb-6">Thông tin giao hàng</h2>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-2">Họ và tên *</label>
                                    <asp:TextBox ID="txtFullName" runat="server" CssClass="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-primary" placeholder="Nhập họ và tên"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName" ErrorMessage="Vui lòng nhập họ tên." CssClass="text-red-500 text-xs" Display="Dynamic" ValidationGroup="ShippingInfo"></asp:RequiredFieldValidator>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-2">Số điện thoại *</label>
                                    <asp:TextBox ID="txtPhone" runat="server" CssClass="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-primary" placeholder="Nhập số điện thoại" TextMode="Phone"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone" ErrorMessage="Vui lòng nhập số điện thoại." CssClass="text-red-500 text-xs" Display="Dynamic" ValidationGroup="ShippingInfo"></asp:RequiredFieldValidator>
                                    <asp:RegularExpressionValidator ID="revPhone" runat="server" ControlToValidate="txtPhone" ErrorMessage="Số điện thoại không hợp lệ." ValidationExpression="^\+?[0-9]{10,15}$" CssClass="text-red-500 text-xs" Display="Dynamic" ValidationGroup="ShippingInfo"></asp:RegularExpressionValidator>
                                </div>
                            </div>
                            <div class="mb-4">
                                <label class="block text-sm font-medium text-gray-700 mb-2">Email</label>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-primary" placeholder="Nhập email (không bắt buộc)" TextMode="Email"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Email không hợp lệ." ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="text-red-500 text-xs" Display="Dynamic" ValidationGroup="ShippingInfo"></asp:RegularExpressionValidator>
                            </div>
                             <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-2">Tỉnh/Thành phố *</label>
                                    <asp:DropDownList ID="ddlProvince" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlProvince_SelectedIndexChanged" CssClass="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-primary">
                                        <asp:ListItem Value="">Chọn tỉnh/thành phố</asp:ListItem>
                                        <%-- Populate from code-behind --%>
                                    </asp:DropDownList>
                                     <asp:RequiredFieldValidator ID="rfvProvince" runat="server" ControlToValidate="ddlProvince" InitialValue="" ErrorMessage="Vui lòng chọn tỉnh/thành phố." CssClass="text-red-500 text-xs" Display="Dynamic" ValidationGroup="ShippingInfo"></asp:RequiredFieldValidator>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-2">Quận/Huyện *</label>
                                    <asp:DropDownList ID="ddlDistrict" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlDistrict_SelectedIndexChanged" CssClass="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-primary">
                                         <asp:ListItem Value="">Chọn quận/huyện</asp:ListItem>
                                        <%-- Populate from code-behind based on Province --%>
                                    </asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="rfvDistrict" runat="server" ControlToValidate="ddlDistrict" InitialValue="" ErrorMessage="Vui lòng chọn quận/huyện." CssClass="text-red-500 text-xs" Display="Dynamic" ValidationGroup="ShippingInfo"></asp:RequiredFieldValidator>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-2">Phường/Xã *</label>
                                    <asp:DropDownList ID="ddlWard" runat="server" CssClass="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-primary">
                                         <asp:ListItem Value="">Chọn phường/xã</asp:ListItem>
                                        <%-- Populate from code-behind based on District --%>
                                    </asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="rfvWard" runat="server" ControlToValidate="ddlWard" InitialValue="" ErrorMessage="Vui lòng chọn phường/xã." CssClass="text-red-500 text-xs" Display="Dynamic" ValidationGroup="ShippingInfo"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="mb-4">
                                <label class="block text-sm font-medium text-gray-700 mb-2">Địa chỉ cụ thể *</label>
                                <asp:TextBox ID="txtStreetAddress" runat="server" CssClass="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-primary" placeholder="Số nhà, tên đường..."></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvStreetAddress" runat="server" ControlToValidate="txtStreetAddress" ErrorMessage="Vui lòng nhập địa chỉ cụ thể." CssClass="text-red-500 text-xs" Display="Dynamic" ValidationGroup="ShippingInfo"></asp:RequiredFieldValidator>
                            </div>
                            <div class="mb-6">
                                <label class="block text-sm font-medium text-gray-700 mb-2">Ghi chú</label>
                                <asp:TextBox ID="txtOrderNotes" runat="server" TextMode="MultiLine" Rows="3" CssClass="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-primary" placeholder="Ghi chú cho đơn hàng (không bắt buộc)"></asp:TextBox>
                            </div>
                            <div class="mb-6">
                                <h3 class="text-lg font-medium text-gray-900 mb-4">Phương thức giao hàng</h3>
                                <asp:RadioButtonList ID="rblShippingMethods" runat="server" RepeatDirection="Vertical" CssClass="space-y-3" AutoPostBack="true" OnSelectedIndexChanged="rblShippingMethods_SelectedIndexChanged">
                                    <asp:ListItem Value="standard" Selected="True" Text="Giao hàng tiêu chuẩn (3-5 ngày làm việc - <span class='text-green-600 font-medium'>Miễn phí</span>)" data-fee="0"></asp:ListItem>
                                    <asp:ListItem Value="express" Text="Giao hàng nhanh (1-2 ngày làm việc - <span class='text-primary font-medium'>30.000đ</span>)" data-fee="30000"></asp:ListItem>
                                    <asp:ListItem Value="sameday" Text="Giao hàng trong ngày (Trong vòng 4 giờ, nội thành - <span class='text-primary font-medium'>50.000đ</span>)" data-fee="50000"></asp:ListItem>
                                </asp:RadioButtonList>
                            </div>
                             <div class="flex justify-between pt-6 border-t">
                                <asp:Button ID="btnBackToCart" runat="server" Text="Quay lại giỏ hàng" OnClick="btnBackToCart_Click" CssClass="px-6 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors" CausesValidation="false" />
                                <asp:Button ID="btnProceedToPayment" runat="server" Text="Tiếp tục thanh toán" OnClick="btnProceedToPayment_Click" ValidationGroup="ShippingInfo" CssClass="px-6 py-2 bg-primary text-white rounded-lg hover:bg-opacity-90 transition-colors" />
                            </div>
                        </div>
                    </div>
                     <asp:Panel ID="pnlOrderSummaryInfo" runat="server" CssClass="lg:w-1/3">
                         <div class="bg-white rounded-lg shadow-md p-6 sticky top-4">
                            <h3 class="text-lg font-bold text-dark border-b pb-3 mb-4">Tổng đơn hàng</h3>
                            <div class="space-y-3 mb-4">
                                <div class="flex justify-between">
                                    <span class="text-gray-600">Tạm tính:</span>
                                    <asp:Label ID="lblSubtotalInfo" runat="server" CssClass="font-medium" Text="0đ"></asp:Label>
                                </div>
                                <div class="flex justify-between">
                                    <span class="text-gray-600">Giảm giá:</span>
                                    <asp:Label ID="lblDiscountInfo" runat="server" CssClass="text-green-600 font-medium" Text="0đ"></asp:Label>
                                </div>
                                <div class="flex justify-between">
                                    <span class="text-gray-600">Phí vận chuyển:</span>
                                    <asp:Label ID="lblShippingFeeInfo" runat="server" CssClass="font-medium" Text="Miễn phí"></asp:Label>
                                </div>
                            </div>
                            <div class="border-t pt-3 mb-4">
                                <div class="flex justify-between text-lg font-bold">
                                    <span>Tổng cộng:</span>
                                    <asp:Label ID="lblTotalAmountInfo" runat="server" CssClass="text-primary" Text="0đ"></asp:Label>
                                </div>
                                <p class="text-sm text-gray-600 mt-1">Đã bao gồm VAT</p>
                            </div>
                            <div class="border-t pt-4">
                                <h4 class="font-medium text-gray-900 mb-3">
                                    Sản phẩm đã chọn (<asp:Label ID="lblItemCountInfo" runat="server" Text="0"></asp:Label>)
                                </h4>
                                <div class="space-y-2 max-h-48 overflow-y-auto">
                                    <asp:Repeater ID="rptCartSummaryInfo" runat="server">
                                        <ItemTemplate>
                                            <div class="flex justify-between text-sm">
                                                <span class="text-gray-600"><%# Eval("ProductName") %> × <%# Eval("Quantity") %></span>
                                                <span><%# Eval("TotalPrice", "{0:N0}đ") %></span>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </div>
                        </div>
                    </asp:Panel>
                </div>
            </asp:View>

            <asp:View ID="viewPayment" runat="server">
                 <div class="flex flex-col lg:flex-row gap-6">
                    <div class="lg:w-2/3">
                        <div class="bg-white rounded-lg shadow-md p-6">
                            <h2 class="text-xl font-bold text-dark border-b pb-4 mb-6">Phương thức thanh toán</h2>
                            <asp:RadioButtonList ID="rblPaymentMethods" runat="server" CssClass="space-y-4 mb-6" AutoPostBack="true" OnSelectedIndexChanged="rblPaymentMethods_SelectedIndexChanged">
                                <asp:ListItem Value="cod" Selected="True" Text="Thanh toán khi nhận hàng (COD)">
                                     <div class="ml-4 flex-grow">
                                        <div class="flex items-center">
                                            <i class="fas fa-money-bill-wave text-green-600 text-xl mr-3"></i>
                                            <div>
                                                <div class="font-medium">Thanh toán khi nhận hàng (COD)</div>
                                                <div class="text-sm text-gray-600">Thanh toán bằng tiền mặt khi nhận hàng</div>
                                            </div>
                                        </div>
                                    </div>
                                </asp:ListItem>
                                <asp:ListItem Value="bank" Text="Chuyển khoản ngân hàng">
                                     <div class="ml-4 flex-grow">
                                        <div class="flex items-center">
                                            <i class="fas fa-university text-blue-600 text-xl mr-3"></i>
                                            <div>
                                                <div class="font-medium">Chuyển khoản ngân hàng</div>
                                                <div class="text-sm text-gray-600">Chuyển khoản qua Internet Banking hoặc ATM</div>
                                            </div>
                                        </div>
                                    </div>
                                </asp:ListItem>
                                <asp:ListItem Value="card" Text="Thẻ tín dụng/ghi nợ">
                                    <div class="ml-4 flex-grow">
                                        <div class="flex items-center">
                                            <i class="fas fa-credit-card text-purple-600 text-xl mr-3"></i>
                                            <div>
                                                <div class="font-medium">Thẻ tín dụng/ghi nợ</div>
                                                <div class="text-sm text-gray-600">Visa, Mastercard, JCB</div>
                                            </div>
                                        </div>
                                    </div>
                                </asp:ListItem>
                                <asp:ListItem Value="ewallet" Text="Ví điện tử">
                                     <div class="ml-4 flex-grow">
                                        <div class="flex items-center">
                                            <i class="fas fa-mobile-alt text-orange-600 text-xl mr-3"></i>
                                            <div>
                                                <div class="font-medium">Ví điện tử</div>
                                                <div class="text-sm text-gray-600">MoMo, ZaloPay, VNPay</div>
                                            </div>
                                        </div>
                                    </div>
                                </asp:ListItem>
                            </asp:RadioButtonList>

                            <asp:Panel ID="pnlCardDetails" runat="server" Visible="false" CssClass="bg-gray-50 p-4 rounded-lg mb-6">
                                <h4 class="font-medium text-gray-900 mb-4">Thông tin thẻ</h4>
                                <div class="space-y-4">
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 mb-2">Số thẻ</label>
                                        <asp:TextBox ID="txtCardNumber" runat="server" placeholder="1234 5678 9012 3456" CssClass="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-primary"></asp:TextBox>
                                    </div>
                                    <div class="grid grid-cols-2 gap-4">
                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2">Ngày hết hạn</label>
                                            <asp:TextBox ID="txtCardExpiry" runat="server" placeholder="MM/YY" CssClass="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-primary"></asp:TextBox>
                                        </div>
                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2">CVV</label>
                                            <asp:TextBox ID="txtCardCVV" runat="server" placeholder="123" CssClass="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-primary" TextMode="Password" MaxLength="4"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 mb-2">Tên chủ thẻ</label>
                                        <asp:TextBox ID="txtCardHolderName" runat="server" placeholder="NGUYEN VAN A" CssClass="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-primary"></asp:TextBox>
                                    </div>
                                </div>
                            </asp:Panel>
                            <asp:Panel ID="pnlBankDetails" runat="server" Visible="false" CssClass="bg-gray-50 p-4 rounded-lg mb-6">
                                 <h4 class="font-medium text-gray-900 mb-4">Thông tin chuyển khoản</h4>
                                <div class="space-y-3">
                                    <div class="flex justify-between"><span class="text-gray-600">Ngân hàng:</span><span class="font-medium">Vietcombank</span></div>
                                    <div class="flex justify-between"><span class="text-gray-600">Số tài khoản:</span><span class="font-medium">1234567890</span></div>
                                    <div class="flex justify-between"><span class="text-gray-600">Chủ tài khoản:</span><span class="font-medium">TOYLAND COMPANY</span></div>
                                    <div class="flex justify-between"><span class="text-gray-600">Nội dung:</span><span class="font-medium">TOY ORDER <asp:Label ID="lblOrderCodeForBank" runat="server" Text=""></asp:Label></span></div>
                                </div>
                                <div class="mt-3 p-3 bg-yellow-50 border border-yellow-200 rounded"><p class="text-sm text-yellow-800"><i class="fas fa-info-circle mr-1"></i> Vui lòng chuyển khoản với nội dung chính xác để đơn hàng được xử lý nhanh chóng.</p></div>
                            </asp:Panel>
                             <asp:Panel ID="pnlEWalletDetails" runat="server" Visible="false" CssClass="bg-gray-50 p-4 rounded-lg mb-6">
                                <h4 class="font-medium text-gray-900 mb-4">Thanh toán qua Ví điện tử</h4>
                                <p class="text-gray-600">Bạn sẽ được chuyển hướng đến cổng thanh toán của ví điện tử đã chọn để hoàn tất giao dịch.</p>
                                <%-- Add QR codes or specific instructions here --%>
                            </asp:Panel>

                            <div class="mb-6">
                                <asp:CheckBox ID="chkAcceptTerms" runat="server" Text=" Tôi đã đọc và đồng ý với <a href='/Client/Terms.aspx' class='text-primary hover:underline'>điều khoản dịch vụ</a> và <a href='/Client/Privacy.aspx' class='text-primary hover:underline'>chính sách bảo mật</a> của ToyLand." CssClass="text-sm text-gray-600" />
                                <asp:CustomValidator ID="cvAcceptTerms" runat="server" ErrorMessage="Bạn phải đồng ý với điều khoản." ControlToValidate="chkAcceptTerms" ClientValidationFunction="validateTerms" CssClass="text-red-500 text-xs block mt-1" Display="Dynamic" ValidationGroup="Payment"></asp:CustomValidator>
                            </div>
                            <div class="flex justify-between pt-6 border-t">
                                <asp:Button ID="btnBackToInfo" runat="server" Text="Quay lại thông tin" OnClick="btnBackToInfo_Click" CssClass="px-6 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors" CausesValidation="false"/>
                                <asp:Button ID="btnCompleteOrder" runat="server" Text="Hoàn tất đặt hàng" OnClick="btnCompleteOrder_Click" ValidationGroup="Payment" CssClass="px-8 py-3 bg-primary text-white rounded-lg font-medium hover:bg-opacity-90 transition-colors" />
                            </div>
                        </div>
                    </div>
                    <asp:Panel ID="pnlOrderSummaryPayment" runat="server" CssClass="lg:w-1/3">
                         <div class="bg-white rounded-lg shadow-md p-6 sticky top-4">
                            <h3 class="text-lg font-bold text-dark border-b pb-3 mb-4">Xác nhận đơn hàng</h3>
                            <div class="mb-4">
                                <h4 class="font-medium text-gray-900 mb-2">Địa chỉ giao hàng</h4>
                                <div class="text-sm text-gray-600">
                                    <asp:Literal ID="litShippingAddressSummary" runat="server"></asp:Literal>
                                </div>
                            </div>
                            <div class="mb-4">
                                <h4 class="font-medium text-gray-900 mb-2">Phương thức giao hàng</h4>
                                 <div class="text-sm text-gray-600">
                                    <asp:Label ID="lblShippingMethodSummary" runat="server"></asp:Label>
                                </div>
                            </div>
                             <div class="space-y-3 mb-4">
                                <div class="flex justify-between">
                                    <span class="text-gray-600">Tạm tính:</span>
                                    <asp:Label ID="lblSubtotalPayment" runat="server" CssClass="font-medium" Text="0đ"></asp:Label>
                                </div>
                                <div class="flex justify-between">
                                    <span class="text-gray-600">Giảm giá:</span>
                                    <asp:Label ID="lblDiscountPayment" runat="server" CssClass="text-green-600 font-medium" Text="0đ"></asp:Label>
                                </div>
                                <div class="flex justify-between">
                                    <span class="text-gray-600">Phí vận chuyển:</span>
                                    <asp:Label ID="lblShippingFeePayment" runat="server" CssClass="font-medium" Text="Miễn phí"></asp:Label>
                                </div>
                            </div>
                            <div class="border-t pt-3 mb-4">
                                <div class="flex justify-between text-lg font-bold">
                                    <span>Tổng cộng:</span>
                                    <asp:Label ID="lblTotalAmountPayment" runat="server" CssClass="text-primary" Text="0đ"></asp:Label>
                                </div>
                                <p class="text-sm text-gray-600 mt-1">Đã bao gồm VAT</p>
                            </div>
                            <div class="bg-green-50 border border-green-200 p-3 rounded-lg">
                                <div class="flex items-center text-green-700">
                                    <i class="fas fa-shield-alt mr-2"></i><span class="text-sm font-medium">Thanh toán an toàn 100%</span>
                                </div>
                                <p class="text-xs text-green-600 mt-1">Thông tin của bạn được bảo mật với công nghệ SSL</p>
                            </div>
                        </div>
                    </asp:Panel>
                </div>
            </asp:View>
        </asp:MultiView>
    </div>

    <asp:Panel ID="pnlSuccessModal" runat="server" Visible="false" CssClass="fixed inset-0 z-[100] flex items-center justify-center">
        <div class="absolute inset-0 bg-black bg-opacity-50"></div>
        <div class="bg-white rounded-lg shadow-xl z-10 mx-4 max-w-md w-full p-6">
            <div class="text-center">
                <div class="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <i class="fas fa-check text-green-600 text-2xl"></i>
                </div>
                <h3 class="text-xl font-bold text-dark mb-2">Đặt hàng thành công!</h3>
                <p class="text-gray-600 mb-4">Cảm ơn bạn đã đặt hàng tại ToyLand. Chúng tôi sẽ liên hệ với bạn sớm nhất.</p>
                <div class="bg-gray-50 p-3 rounded-lg mb-4">
                    <div class="text-sm">
                        <div class="flex justify-between mb-1">
                            <span class="text-gray-600">Mã đơn hàng:</span>
                            <asp:Label ID="lblSuccessOrderCode" runat="server" CssClass="font-medium"></asp:Label>
                        </div>
                        <div class="flex justify-between">
                            <span class="text-gray-600">Tổng tiền:</span>
                            <asp:Label ID="lblSuccessTotalAmount" runat="server" CssClass="font-medium text-primary"></asp:Label>
                        </div>
                    </div>
                </div>
                <div class="flex space-x-3">
                    <asp:HyperLink ID="lnkContinueShoppingModal" runat="server" NavigateUrl="/Client/Default.aspx" CssClass="flex-1 bg-gray-200 text-gray-800 py-2 rounded-lg hover:bg-gray-300 transition-colors text-center">Tiếp tục mua sắm</asp:HyperLink>
                    <asp:HyperLink ID="lnkTrackOrderModal" runat="server" NavigateUrl="/Client/Profile.aspx#orders" CssClass="flex-1 bg-primary text-white py-2 rounded-lg hover:bg-opacity-90 transition-colors text-center">Theo dõi đơn hàng</asp:HyperLink> <%-- Assuming Profile has an orders tab --%>
                </div>
            </div>
        </div>
    </asp:Panel>

    <asp:LinkButton ID="btnBackToTop" runat="server" CssClass="fixed bottom-20 right-4 bg-primary text-white w-10 h-10 rounded-full flex items-center justify-center shadow-lg z-40 hover:bg-dark transition-colors" Style="display: none;" OnClientClick="window.scrollTo({ top: 0, behavior: 'smooth' }); return false;">
        <i class="fas fa-arrow-up"></i>
    </asp:LinkButton>

    <script type="text/javascript">
        function updateStepIndicators(currentStep) {
            const steps = [
                { el: document.getElementById('step1'), panel: document.getElementById('<%= pnlStep1Indicator.ClientID %>').querySelector('.step-indicator') },
                { el: document.getElementById('step2'), panel: document.getElementById('<%= pnlStep2Indicator.ClientID %>').querySelector('.step-indicator') },
                { el: document.getElementById('step3'), panel: document.getElementById('<%= pnlStep3Indicator.ClientID %>').querySelector('.step-indicator') }
            ];
            steps.forEach((stepObj, index) => {
                const stepNumber = index + 1;
                if (!stepObj.panel) return; // Guard against null panel
                
                if (stepNumber < currentStep) {
                    stepObj.panel.className = "step-indicator w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold step-completed";
                    stepObj.panel.innerHTML = '<i class="fas fa-check"></i>';
                } else if (stepNumber === currentStep) {
                    stepObj.panel.className = "step-indicator w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold step-active";
                    stepObj.panel.textContent = stepNumber;
                } else {
                    stepObj.panel.className = "step-indicator w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold step-inactive";
                    stepObj.panel.textContent = stepNumber;
                }
            });
        }
        
        // Call this from server-side after MultiView's ActiveViewIndex changes, or on initial load
        // Example: ScriptManager.RegisterStartupScript(this, GetType(), "UpdateSteps", "updateStepIndicators(" + (mvCheckoutSteps.ActiveViewIndex + 1) + ");", true);


        // Client-side quantity change for immediate feedback (optional, can trigger postback instead)
        function handleQuantityChange(button, productId, action) {
            const repeaterItem = button.closest('.cart-item');
            const quantityInput = repeaterItem.querySelector('.quantity-input');
            let currentValue = parseInt(quantityInput.value);
            if (action === 'increase') {
                currentValue++;
            } else if (action === 'decrease' && currentValue > 1) {
                currentValue--;
            }
            quantityInput.value = currentValue;
            // Here you might want to trigger a partial postback or AJAX call to update server-side cart
            // For example, using __doPostBack or ASP.NET AJAX UpdatePanel
            // For simplicity, this example focuses on client-side update. Real cart update happens on postback.
            // To trigger full postback for LinkButtons, remove 'return false;' from OnClientClick
            // and let the server handle the quantity update and re-bind.
        }


        // Payment method selection
        const paymentRadios = document.querySelectorAll('input[name$="rblPaymentMethods"]'); // Ends with control ID
        const cardDetailsPanel = document.getElementById('<%= pnlCardDetails.ClientID %>');
        const bankDetailsPanel = document.getElementById('<%= pnlBankDetails.ClientID %>');
        const ewalletPanel = document.getElementById('<%= pnlEWalletDetails.ClientID %>');

        function updatePaymentDetailsVisibility() {
            let selectedPaymentValue = "";
            paymentRadios.forEach(radio => {
                if (radio.checked) selectedPaymentValue = radio.value;
                // Style the parent label
                const label = radio.closest('label') || radio.parentElement.closest('td').parentElement; // Adjust if RadioButtonList renders differently
                 if(label) {
                    if (radio.checked) label.classList.add('selected');
                    else label.classList.remove('selected');
                 }
            });

            if (cardDetailsPanel) cardDetailsPanel.style.display = (selectedPaymentValue === 'card' ? 'block' : 'none');
            if (bankDetailsPanel) bankDetailsPanel.style.display = (selectedPaymentValue === 'bank' ? 'block' : 'none');
            if (ewalletPanel) ewalletPanel.style.display = (selectedPaymentValue === 'ewallet' ? 'block' : 'none');
        }
        
        paymentRadios.forEach(radio => {
            radio.addEventListener('change', updatePaymentDetailsVisibility);
        });
        // Initial call in case of postback
        if(paymentRadios.length > 0) updatePaymentDetailsVisibility();


        // Back to Top Button
        const backToTopButton = document.getElementById('<%= btnBackToTop.ClientID %>');
        if (backToTopButton) {
            window.addEventListener("scroll", () => {
                if (window.scrollY > 300) {
                    backToTopButton.style.display = "flex";
                } else {
                    backToTopButton.style.display = "none";
                }
            });
        }

        // Client-side validation for terms checkbox
        function validateTerms(source, args) {
            const chkTerms = document.getElementById('<%= chkAcceptTerms.ClientID %>');
            args.IsValid = chkTerms.checked;
        }

        // Active state for mobile bottom nav (based on current page URL)
        document.addEventListener('DOMContentLoaded', function () {
            const currentPath = window.location.pathname.toLowerCase();
            const bottomNavLinks = document.querySelectorAll('.bottom-nav .nav-item');
            let cartLinkManuallyActivated = false;

            bottomNavLinks.forEach(link => {
                const linkHref = link.getAttribute('href');
                if (!linkHref) return;

                const linkPath = new URL(linkHref, window.location.origin).pathname.toLowerCase();

                // Specifically activate Cart link on Cart.aspx
                if (currentPath.includes('cart.aspx') && linkPath.includes('cart.aspx')) {
                    link.classList.add('active');
                    link.classList.remove('text-gray-600');
                    cartLinkManuallyActivated = true;
                } else if (!cartLinkManuallyActivated && currentPath === linkPath) {
                    // For other links, if cart wasn't the current page
                    link.classList.add('active');
                    link.classList.remove('text-gray-600');
                }
                else {
                    link.classList.remove('active');
                    link.classList.add('text-gray-600');
                }
            });
        });
    </script>
</asp:Content>