<%@ Page Title="Quản lý Khuyến mãi - ToyLand Admin" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="Promotions.aspx.cs" Inherits="WebsiteDoChoi.Admin.Promotions" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitleContent" runat="server">
    <h1 class="text-xl md:text-2xl font-bold text-gray-800">Quản lý Khuyến mãi</h1>
</asp:Content>

<asp:Content ID="AdminHeadPromotions" ContentPlaceHolderID="AdminHeadContent" runat="server">
    <%-- Chart.js is in Admin.Master --%>
    <style>
        .promo-card-admin { transition: all 0.2s ease-out; border-left: 4px solid transparent; }
        .promo-card-admin:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0,0,0,0.07); }
        .promo-card-admin.active { border-left-color: #4ECDC4; /* secondary */ }
        .promo-card-admin.expired { border-left-color: #FF6B6B; /* primary */ opacity: 0.75; }
        .promo-card-admin.scheduled { border-left-color: #FFE66D; /* accent */ }

        .modal-admin-promo { backdrop-filter: blur(5px); }
        .chart-container-admin-promo { position: relative; height: 280px; }
        
        .tab-button-main.active { border-bottom-color: #FF6B6B; color: #FF6B6B; font-weight: 600; }
        .tab-button-main { border-bottom-width: 2px; border-color: transparent; }
        
        .promo-type-tab-modal.active { background-color: #FF6B6B; color: white; }
        .promo-type-tab-modal { border: 1px solid #e5e7eb; }

        .condition-row-admin { border: 1px solid #e5e7eb; border-radius: 0.5rem; background: #f9fafb; padding: 0.75rem; }
        
        .modal-body-promotions-scrollable { max-height: calc(100vh - 220px); overflow-y: auto; }
        .modal-body-promotions-scrollable::-webkit-scrollbar { width: 6px; }
        .modal-body-promotions-scrollable::-webkit-scrollbar-track { background: #f1f5f9; }
        .modal-body-promotions-scrollable::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius:3px; }

        .coupon-code-display { font-family: 'Courier New', monospace; color: #FF6B6B; font-weight: bold; }
        .usage-progress-bar { transition: width 0.3s ease; background-color: #4ECDC4; }
    </style>
</asp:Content>

<asp:Content ID="MainAdminContentPromotions" ContentPlaceHolderID="AdminMainContent" runat="server">
     <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <asp:UpdatePanel ID="upnlPromotionsPage" runat="server">
        <ContentTemplate>
            <div class="bg-white shadow-sm px-4 md:px-6 py-3 border-b border-gray-200">
                <div class="flex items-center justify-between">
                    <h2 class="text-lg font-semibold text-gray-700">Chương trình Khuyến mãi & Mã giảm giá</h2>
                    <div class="flex items-center space-x-2">
                            <span class="hidden sm:inline">Xuất</span>
                            <span class="hidden sm:inline">Tạo mới</span>
                    </div>
                </div>
            </div>

            <div class="p-4 md:p-6">
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4 md:gap-6 mb-6">
                    <div class="stats-card-primary rounded-xl p-3 md:p-4 text-white"><div class="flex items-center justify-between"><div><p class="text-white text-opacity-80 text-xs">Tổng KM</p><asp:Label ID="lblTotalPromotions" runat="server" Text="0" CssClass="text-lg font-bold"></asp:Label></div><div class="w-8 h-8 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-tags text-base"></i></div></div></div>
                    <div class="stats-card-secondary rounded-xl p-3 md:p-4 text-white"><div class="flex items-center justify-between"><div><p class="text-white text-opacity-80 text-xs">Đang chạy</p><asp:Label ID="lblActivePromotions" runat="server" Text="0" CssClass="text-lg font-bold"></asp:Label></div><div class="w-8 h-8 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-play-circle text-base"></i></div></div></div>
                    <div class="stats-card-accent rounded-xl p-3 md:p-4 text-dark"><div class="flex items-center justify-between"><div><p class="text-dark text-opacity-80 text-xs">Sắp hết hạn</p><asp:Label ID="lblExpiringSoon" runat="server" Text="0" CssClass="text-lg font-bold"></asp:Label></div><div class="w-8 h-8 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-clock text-base text-dark"></i></div></div></div>
                    <div class="stats-card-dark rounded-xl p-3 md:p-4 text-white"><div class="flex items-center justify-between"><div><p class="text-white text-opacity-80 text-xs">Tổng tiết kiệm</p><asp:Label ID="lblTotalSavings" runat="server" Text="0 VNĐ" CssClass="text-lg font-bold"></asp:Label></div><div class="w-8 h-8 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-piggy-bank text-base"></i></div></div></div>
                    <div class="stats-card rounded-xl p-3 md:p-4 text-white"><div class="flex items-center justify-between"><div><p class="text-white text-opacity-80 text-xs">Lượt sử dụng</p><asp:Label ID="lblTotalUsage" runat="server" Text="0" CssClass="text-lg font-bold"></asp:Label></div><div class="w-8 h-8 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-users text-base"></i></div></div></div>
                </div>

                <div class="bg-white rounded-xl shadow-sm mb-6">
                    <div class="border-b border-gray-200">
                        <nav class="flex space-x-1 p-1" aria-label="Tabs">
                            <asp:LinkButton ID="tabBtnCoupons" runat="server" OnClick="Tab_Click" CommandArgument="Coupons" Text="Mã giảm giá" CssClass="tab-button-main flex-1 py-3 px-4 rounded-t-lg text-sm font-medium transition-colors"></asp:LinkButton>
                            <asp:LinkButton ID="tabBtnProductPromos" runat="server" OnClick="Tab_Click" CommandArgument="ProductPromos" Text="KM Sản phẩm" CssClass="tab-button-main flex-1 py-3 px-4 rounded-t-lg text-sm font-medium transition-colors"></asp:LinkButton>
                            <asp:LinkButton ID="tabBtnAnalytics" runat="server" OnClick="Tab_Click" CommandArgument="Analytics" Text="Thống kê" CssClass="tab-button-main flex-1 py-3 px-4 rounded-t-lg text-sm font-medium transition-colors"></asp:LinkButton>
                        </nav>
                    </div>
                    <div class="p-4 md:p-6">
                         <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4 items-end">
                            <div class="relative"><label class="block text-sm font-medium text-gray-700 mb-1">Tìm kiếm</label><asp:TextBox ID="txtSearchPromotions" runat="server" placeholder="Tên, mã KM..." CssClass="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-primary w-full"></asp:TextBox><i class="fas fa-search absolute left-3 bottom-2.5 text-gray-400"></i></div>
                            <div><label class="block text-sm font-medium text-gray-700 mb-1">Trạng thái</label><asp:DropDownList ID="ddlPromotionStatusFilter" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary"><asp:ListItem Value="">Tất cả</asp:ListItem><asp:ListItem Value="active">Đang hoạt động</asp:ListItem><asp:ListItem Value="scheduled">Chờ kích hoạt</asp:ListItem><asp:ListItem Value="expired">Hết hạn</asp:ListItem><asp:ListItem Value="disabled">Đã tắt</asp:ListItem></asp:DropDownList></div>
                            <div><label class="block text-sm font-medium text-gray-700 mb-1">Loại KM</label><asp:DropDownList ID="ddlPromotionTypeFilter" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary"><asp:ListItem Value="">Tất cả</asp:ListItem><asp:ListItem Value="percentage">Giảm theo %</asp:ListItem><asp:ListItem Value="fixed_amount">Giảm cố định</asp:ListItem><asp:ListItem Value="free_shipping">Miễn phí ship</asp:ListItem><asp:ListItem Value="bogo">Mua X tặng Y</asp:ListItem></asp:DropDownList></div>
                            <div><label class="block text-sm font-medium text-gray-700 mb-1">Sắp xếp</label><asp:DropDownList ID="ddlPromotionSortFilter" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary"><asp:ListItem Value="created_desc">Mới nhất</asp:ListItem><asp:ListItem Value="name_asc">Tên A-Z</asp:ListItem><asp:ListItem Value="usage_desc">Lượt dùng</asp:ListItem><asp:ListItem Value="expiry_asc">Sắp hết hạn</asp:ListItem></asp:DropDownList></div>
                            <div class="flex space-x-2">
                                <asp:Button ID="btnApplyPromotionFilters" runat="server" Text="Lọc" OnClick="btnApplyPromotionFilters_Click" CssClass="w-full sm:w-auto px-4 py-2 bg-secondary text-white rounded-lg hover:bg-opacity-90" />
                                <asp:Button ID="btnResetPromotionFilters" runat="server" Text="Reset" OnClick="btnResetPromotionFilters_Click" CssClass="w-full sm:w-auto px-4 py-2 bg-gray-500 hover:bg-gray-600 text-white rounded-lg" CausesValidation="false"/>
                            </div>
                        </div>
                    </div>
                </div>

                <asp:Panel ID="pnlCouponsContent" runat="server" Visible="true">
                    <div class="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-4 md:gap-6">
                        <asp:Repeater ID="rptCoupons" runat="server" OnItemCommand="Promotion_ItemCommand">
                            <ItemTemplate>
                                <div class='promo-card-admin bg-white rounded-xl shadow-sm p-4 <%# Eval("StatusCssClass") %>'>
                                    <div class="flex items-start justify-between mb-3">
                                        <div class="flex-1">
                                            <div class="flex items-center space-x-2 mb-1">
                                                <span class="coupon-code-display text-lg"><%# Eval("Code") %></span>
                                                <asp:LinkButton ID="btnCopyCode" runat="server" CommandName="CopyCode" CommandArgument='<%# Eval("Code") %>' OnClientClick='<%# "copyCouponCodeClientSide(\"" + Eval("Code") + "\"); return false;" %>' CssClass="text-gray-400 hover:text-gray-600" ToolTip="Sao chép mã"><i class="fas fa-copy"></i></asp:LinkButton>
                                            </div>
                                            <h3 class="font-semibold text-gray-800 text-base mb-1 line-clamp-1" title='<%# Eval("Name") %>'><%# Eval("Name") %></h3>
                                            <p class="text-sm text-gray-600 line-clamp-2" title='<%# Eval("Description") %>'><%# Eval("Description") %></p>
                                        </div>
                                        <div class="flex items-center space-x-2">
                                            <span class='text-xs px-2 py-1 rounded-full <%# Eval("StatusBadgeCss") %>'><%# Eval("StatusText") %></span>
                                            <div class="relative">
                                                <asp:LinkButton ID="btnCouponActions" runat="server" CommandName="ToggleDropdown" CommandArgument='<%# Eval("PromotionId") %>' OnClientClick='<%# "toggleAdminDropdown(event, \"coupon-dropdown-" + Eval("PromotionId") + "\"); return false;" %>' CssClass="text-gray-400 hover:text-gray-600"><i class="fas fa-ellipsis-v"></i></asp:LinkButton>
                                                <div id='<%# "coupon-dropdown-" + Eval("PromotionId") %>' class="hidden absolute right-0 mt-1 w-48 bg-white rounded-md shadow-lg border z-20">
                                                    <asp:LinkButton ID="btnEditCoupon" runat="server" CommandName="Edit" CommandArgument='<%# Eval("PromotionId") %>' CssClass="w-full text-left block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"><i class="fas fa-edit mr-2"></i>Chỉnh sửa</asp:LinkButton>
                                                    <asp:LinkButton ID="btnDuplicateCoupon" runat="server" CommandName="Duplicate" CommandArgument='<%# Eval("PromotionId") %>' CssClass="w-full text-left block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"><i class="fas fa-copy mr-2"></i>Nhân bản</asp:LinkButton>
                                                    <asp:LinkButton ID="btnToggleCouponStatus" runat="server" CommandName="ToggleStatus" CommandArgument='<%# Eval("PromotionId") + "," + Eval("IsActive") %>' CssClass="w-full text-left block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"><i class='<%# Convert.ToBoolean(Eval("IsActive")) ? "fas fa-pause" : "fas fa-play" %> mr-2'></i><%# Convert.ToBoolean(Eval("IsActive")) ? "Tạm dừng" : "Kích hoạt" %></asp:LinkButton>
                                                    <hr class="my-1" />
                                                    <span>Xóa</span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="grid grid-cols-2 gap-3 mb-3 text-center">
                                        <div class="p-2 bg-gray-50 rounded-lg"><div class='text-md font-bold'><%# Eval("DiscountDisplayValue") %></div><p class="text-2xs text-gray-500">Giảm giá</p></div>
                                        <div class="p-2 bg-gray-50 rounded-lg"><p class="text-md font-bold text-gray-800"><%# Eval("UsageCount") %></p><p class="text-2xs text-gray-500">Đã dùng</p></div>
                                    </div>
                                    <div class="mb-3">
                                        <div class="flex justify-between text-xs text-gray-600 mb-1"><span>Giới hạn:</span><span><%# Eval("UsageCount") %>/<%# Convert.ToInt32(Eval("UsageLimit")) == 0 ? "&infin;" : Eval("UsageLimit").ToString() %></span></div>
                                        <div class="w-full bg-gray-200 rounded-full h-1.5"><div class="usage-progress-bar h-1.5 rounded-full" style='width: <%# Eval("UsagePercentage") %>%'></div></div>
                                    </div>
                                    <div class="space-y-1 text-xs text-gray-500">
                                        <div class="flex justify-between"><span>Đơn tối thiểu:</span><span class="font-medium"><%# Eval("MinimumOrderValue", "{0:N0}đ") %></span></div>
                                        <div class="flex justify-between"><span>Hiệu lực:</span><span class="font-medium"><%# Eval("StartDate", "{0:dd/MM/yy}") %> - <%# Eval("EndDate", "{0:dd/MM/yy}") %></span></div>
                                        <div class="flex justify-between"><span>Còn lại:</span><span class='font-medium <%# Eval("TimeRemainingCssClass") %>'><%# Eval("TimeRemainingText") %></span></div>
                                    </div>
                                    <div class="mt-3 pt-3 border-t border-gray-200 flex items-center justify-between">
                                        <asp:LinkButton ID="btnViewCouponStats" runat="server" CommandName="ViewStats" CommandArgument='<%# Eval("PromotionId") %>' CssClass="text-primary hover:underline text-sm"><i class="fas fa-chart-line mr-1"></i>Xem thống kê</asp:LinkButton>
                                        <asp:LinkButton ID="btnEditCouponCard" runat="server" CommandName="Edit" CommandArgument='<%# Eval("PromotionId") %>' CssClass="text-secondary hover:underline text-sm"><i class="fas fa-edit mr-1"></i>Chỉnh sửa</asp:LinkButton>
                                    </div>
                                </div>
                            </ItemTemplate>
                             <FooterTemplate>
                                <asp:Panel ID="pnlNoCoupons" runat="server" Visible='<%# rptCoupons.Items.Count == 0 %>' CssClass="col-span-full text-center py-10">
                                    <p class="text-gray-500">Không có mã giảm giá nào.</p>
                                </asp:Panel>
                            </FooterTemplate>
                        </asp:Repeater>
                    </div>
                </asp:Panel>
                
                <asp:Panel ID="pnlProductPromosContent" runat="server" Visible="false">
                    <%-- Repeater for Product Promotions similar to rptCoupons, adjust fields accordingly --%>
                    <div class="text-center py-10"><p class="text-gray-500">Chức năng Khuyến mãi Sản phẩm đang được phát triển.</p></div>
                </asp:Panel>

                <asp:Panel ID="pnlAnalyticsContent" runat="server" Visible="false">
                     <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
                        <div class="bg-white rounded-xl shadow-sm p-4 md:p-6"><div class="flex items-center justify-between mb-4"><h3 class="text-base font-bold text-gray-800">Tác động doanh thu (30 ngày)</h3></div><div class="chart-container-admin"><canvas id="adminPromoRevenueChart"></canvas></div></div>
                        <div class="bg-white rounded-xl shadow-sm p-4 md:p-6"><div class="flex items-center justify-between mb-4"><h3 class="text-base font-bold text-gray-800">Tỷ lệ sử dụng các loại KM</h3></div><div class="chart-container-admin"><canvas id="adminPromoUsageChart"></canvas></div></div>
                    </div>
                     <div class="bg-white rounded-xl shadow-sm p-4 md:p-6">
                         <h3 class="text-base font-bold text-gray-800 mb-4">Top khuyến mãi hiệu quả</h3>
                         <div class="overflow-x-auto">
                             <asp:GridView ID="gvTopPromotions" runat="server" AutoGenerateColumns="False" CssClass="w-full table-admin-reports" EmptyDataText="Chưa có dữ liệu.">
                                 <Columns>
                                     <asp:BoundField DataField="PromotionName" HeaderText="Khuyến mãi" />
                                     <asp:BoundField DataField="Type" HeaderText="Loại" />
                                     <asp:BoundField DataField="UsageCount" HeaderText="Lượt dùng" />
                                     <asp:BoundField DataField="RevenueGenerated" HeaderText="Doanh thu" DataFormatString="{0:N0}đ" />
                                     <asp:BoundField DataField="SavingsProvided" HeaderText="Tiết kiệm" DataFormatString="{0:N0}đ" />
                                     <asp:BoundField DataField="ROI" HeaderText="ROI (%)" DataFormatString="{0:F1}%" />
                                     <asp:TemplateField HeaderText="Trạng thái"><ItemTemplate><span class='px-2 py-1 text-xs leading-5 font-semibold rounded-full'><%# Eval("StatusText") %></span></ItemTemplate></asp:TemplateField>
                                 </Columns>
                             </asp:GridView>
                         </div>
                     </div>
                </asp:Panel>

                 <div class="flex flex-col sm:flex-row items-center justify-between mt-6 space-y-4 sm:space-y-0">
                    <asp:Label ID="lblPromotionPageInfo" runat="server" CssClass="text-sm text-gray-500"></asp:Label>
                    <div class="flex items-center space-x-1">
                        <asp:LinkButton ID="lnkPromotionPrevPage" runat="server" OnClick="PromotionPage_Changed" CommandArgument="Prev" CssClass="px-3 py-2 border border-gray-300 rounded-lg text-sm hover:bg-gray-50"><i class="fas fa-chevron-left"></i></asp:LinkButton>
                        <asp:Repeater ID="rptPromotionPager" runat="server" OnItemCommand="PromotionPage_Changed">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkPromotionPageNumber" runat="server" Text='<%# Eval("Text") %>' CommandName="Page" CommandArgument='<%# Eval("Value") %>' CssClass='<%# Convert.ToBoolean(Eval("IsCurrent")) ? "px-3 py-2 bg-primary text-white rounded-lg text-sm" : "px-3 py-2 border border-gray-300 rounded-lg text-sm hover:bg-gray-50" %>'></asp:LinkButton>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:LinkButton ID="lnkPromotionNextPage" runat="server" OnClick="PromotionPage_Changed" CommandArgument="Next" CssClass="px-3 py-2 border border-gray-300 rounded-lg text-sm hover:bg-gray-50"><i class="fas fa-chevron-right"></i></asp:LinkButton>
                    </div>
                </div>
            </div> <%-- End of p-4 md:p-6 for main content area --%>
        </ContentTemplate>
    </asp:UpdatePanel>

     <asp:Panel ID="pnlPromotionModal" runat="server" Visible="false" CssClass="modal-admin-promo fixed inset-0 bg-black bg-opacity-75 z-[60] flex items-center justify-center p-4">
         <div class="bg-white rounded-xl w-full max-w-3xl shadow-xl flex flex-col">
            <div class="p-4 md:p-5 border-b border-gray-200">
                <div class="flex items-center justify-between">
                    <h2 class="text-lg font-bold text-gray-800"><asp:Label ID="lblPromotionModalTitle" runat="server">Tạo khuyến mãi</asp:Label></h2>
                    <asp:LinkButton ID="btnClosePromotionModal" runat="server" OnClick="btnClosePromotionModal_Click" CssClass="text-gray-400 hover:text-gray-600" CausesValidation="false"><i class="fas fa-times text-xl"></i></asp:LinkButton>
                </div>
            </div>
            <div class="p-4 md:p-5 space-y-5 modal-body-promotions-scrollable">
                <asp:HiddenField ID="hfPromotionId" runat="server" Value="0" />
                <asp:HiddenField ID="hfCurrentPromoType" runat="server" Value="coupon" />

                <div class="border-b border-gray-200 mb-4">
                    <nav class="flex space-x-2">
                        <asp:LinkButton ID="btnTabCouponModal" runat="server" OnClick="PromoTypeTab_Click" CommandArgument="coupon" Text="Mã giảm giá" CssClass="promo-type-tab-modal py-2 px-4 rounded-t-lg text-sm font-medium"></asp:LinkButton>
                        <asp:LinkButton ID="btnTabProductPromoModal" runat="server" OnClick="PromoTypeTab_Click" CommandArgument="product" Text="KM Sản phẩm" CssClass="promo-type-tab-modal py-2 px-4 rounded-t-lg text-sm font-medium"></asp:LinkButton>
                    </nav>
                </div>

                <asp:Panel ID="pnlCouponFormModal" runat="server" CssClass="space-y-4">
                    <h4 class="text-base font-semibold text-gray-700">Thông tin mã giảm giá</h4>
                     <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div><label class="block text-sm font-medium text-gray-700 mb-1">Mã coupon *</label><div class="flex"><asp:TextBox ID="txtCouponCodeModal" runat="server" CssClass="flex-1 border border-gray-300 rounded-l-lg px-3 py-2 focus:outline-none focus:border-primary uppercase" placeholder="VD: SUMMER25"></asp:TextBox><asp:Button ID="btnGenerateCodeModal" runat="server" Text="Tạo mã" OnClick="btnGenerateCodeModal_Click" CssClass="px-3 py-2 bg-secondary text-white rounded-r-lg hover:bg-opacity-90 text-xs" CausesValidation="false" /></div><asp:RequiredFieldValidator ID="rfvCouponCode" runat="server" ControlToValidate="txtCouponCodeModal" ErrorMessage="Mã coupon không được trống." Display="Dynamic" CssClass="text-red-500 text-xs mt-1" ValidationGroup="CouponValidation"></asp:RequiredFieldValidator></div>
                        <div><label class="block text-sm font-medium text-gray-700 mb-1">Tên khuyến mãi *</label><asp:TextBox ID="txtCouponNameModal" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary" placeholder="VD: Chào hè rực rỡ"></asp:TextBox><asp:RequiredFieldValidator ID="rfvCouponName" runat="server" ControlToValidate="txtCouponNameModal" ErrorMessage="Tên KM không được trống." Display="Dynamic" CssClass="text-red-500 text-xs mt-1" ValidationGroup="CouponValidation"></asp:RequiredFieldValidator></div>
                    </div>
                    <div><label class="block text-sm font-medium text-gray-700 mb-1">Mô tả</label><asp:TextBox ID="txtCouponDescriptionModal" runat="server" TextMode="MultiLine" Rows="2" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary"></asp:TextBox></div>
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                        <div><label class="block text-sm font-medium text-gray-700 mb-1">Loại giảm giá *</label><asp:DropDownList ID="ddlDiscountTypeModal" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlDiscountTypeModal_SelectedIndexChanged" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary"><asp:ListItem Value="percentage">Phần trăm (%)</asp:ListItem><asp:ListItem Value="fixed_amount">Số tiền cố định (VNĐ)</asp:ListItem><asp:ListItem Value="free_shipping">Miễn phí vận chuyển</asp:ListItem></asp:DropDownList></div>
                        <asp:Panel ID="pnlDiscountValueModal" runat="server" CssClass="contents"><div class="md:col-span-1"><label class="block text-sm font-medium text-gray-700 mb-1">Giá trị giảm *</label><div class="relative"><asp:TextBox ID="txtDiscountValueModal" runat="server" TextMode="Number" step="any" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 pr-10 focus:outline-none focus:border-primary" placeholder="10"></asp:TextBox><asp:Label ID="lblDiscountUnitModal" runat="server" Text="%" CssClass="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-500"></asp:Label></div><asp:RequiredFieldValidator ID="rfvDiscountValue" runat="server" ControlToValidate="txtDiscountValueModal" ErrorMessage="Giá trị không trống." Display="Dynamic" CssClass="text-red-500 text-xs mt-1" ValidationGroup="CouponValidation"></asp:RequiredFieldValidator></div></asp:Panel>
                        <asp:Panel ID="pnlMaxDiscountModal" runat="server" CssClass="contents"><div class="md:col-span-1"><label class="block text-sm font-medium text-gray-700 mb-1">Giảm tối đa (VNĐ)</label><asp:TextBox ID="txtMaxDiscountModal" runat="server" TextMode="Number" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary" placeholder="Để trống=Không giới hạn"></asp:TextBox></div></asp:Panel>
                    </div>
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                         <div><label class="block text-sm font-medium text-gray-700 mb-1">Đơn hàng tối thiểu (VNĐ)</label><asp:TextBox ID="txtMinOrderModal" runat="server" TextMode="Number" step="1000" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary" placeholder="0"></asp:TextBox></div>
                         <div><label class="block text-sm font-medium text-gray-700 mb-1">Giới hạn sử dụng (Tổng)</label><asp:TextBox ID="txtUsageLimitTotalModal" runat="server" TextMode="Number" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary" placeholder="Để trống=Không giới hạn"></asp:TextBox></div>
                         <div><label class="block text-sm font-medium text-gray-700 mb-1">Giới hạn/Khách hàng</label><asp:TextBox ID="txtUsageLimitUserModal" runat="server" TextMode="Number" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary" Text="1"></asp:TextBox></div>
                    </div>
                </asp:Panel> <%-- End Coupon Form --%>

                <asp:Panel ID="pnlProductPromoFormModal" runat="server" Visible="false" CssClass="space-y-4">
                    <h4 class="text-base font-semibold text-gray-700">Thông tin khuyến mãi sản phẩm</h4>
                    <%-- Fields for product-specific promotions: Name, Description, Discount Type (%, fixed), Discount Value --%>
                    <%-- Target selection: All Products, Specific Categories, Specific Products --%>
                    <%-- This form would be similar to coupon but target products/categories instead of a code --%>
                    <p class="text-center text-gray-500 p-8 border-2 border-dashed rounded-lg">Form tạo khuyến mãi sản phẩm sẽ được thiết kế ở đây.<br/> (Ví dụ: Giảm giá % cho danh mục, Mua X tặng Y cho sản phẩm cụ thể)</p>
                </asp:Panel> <%-- End Product Promo Form --%>

                <div class="space-y-4 border-t border-gray-200 pt-4">
                     <h4 class="text-base font-semibold text-gray-700">Thời gian & Trạng thái</h4>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div><label class="block text-sm font-medium text-gray-700 mb-1">Ngày bắt đầu *</label><asp:TextBox ID="txtStartDateModal" runat="server" TextMode="DateTimeLocal" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary"></asp:TextBox><asp:RequiredFieldValidator ID="rfvStartDate" runat="server" ControlToValidate="txtStartDateModal" ErrorMessage="Ngày bắt đầu không trống." Display="Dynamic" CssClass="text-red-500 text-xs mt-1" ValidationGroup="CouponValidation"></asp:RequiredFieldValidator></div>
                        <div><label class="block text-sm font-medium text-gray-700 mb-1">Ngày kết thúc *</label><asp:TextBox ID="txtEndDateModal" runat="server" TextMode="DateTimeLocal" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary"></asp:TextBox><asp:RequiredFieldValidator ID="rfvEndDate" runat="server" ControlToValidate="txtEndDateModal" ErrorMessage="Ngày kết thúc không trống." Display="Dynamic" CssClass="text-red-500 text-xs mt-1" ValidationGroup="CouponValidation"></asp:RequiredFieldValidator><asp:CompareValidator ID="cvEndDate" ControlToValidate="txtEndDateModal" ControlToCompare="txtStartDateModal" Operator="GreaterThanEqual" Type="Date" ErrorMessage="Ngày kết thúc phải sau ngày bắt đầu." Display="Dynamic" CssClass="text-red-500 text-xs mt-1" ValidationGroup="CouponValidation" runat="server" /></div>
                    </div>
                    <div class="flex items-center space-x-4">
                        <asp:CheckBox ID="chkIsActivePromoModal" runat="server" Text=" Kích hoạt khuyến mãi" Checked="true" CssClass="text-sm text-gray-700"/>
                        <asp:CheckBox ID="chkSendNotificationModal" runat="server" Text=" Gửi thông báo cho khách hàng" CssClass="text-sm text-gray-700"/>
                    </div>
                </div>
            </div>
            <div class="p-4 md:p-5 border-t border-gray-200 bg-gray-50 flex flex-col sm:flex-row justify-end space-y-2 sm:space-y-0 sm:space-x-3">
                <asp:Button ID="btnCancelPromotionModal" runat="server" Text="Hủy" OnClick="btnClosePromotionModal_Click" CssClass="w-full sm:w-auto px-6 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50" CausesValidation="false" />
                <asp:Button ID="btnPreviewPromotionModal" runat="server" Text="Xem trước" OnClientClick="previewPromotionClientSide(); return false;" CssClass="w-full sm:w-auto px-6 py-2 bg-gray-400 hover:bg-gray-500 text-white rounded-lg" />
                <asp:Button ID="btnSavePromotionModal" runat="server" Text="Lưu khuyến mãi" OnClick="btnSavePromotion_Click" CssClass="w-full sm:w-auto px-6 py-2 bg-primary hover:bg-opacity-90 text-white rounded-lg" ValidationGroup="CouponValidation" /> <%-- Change ValidationGroup if product promo form is active --%>
            </div>
        </div>
    </asp:Panel>
    
    <asp:Panel ID="pnlCouponStatsModal" runat="server" Visible="false" CssClass="modal-admin-promo fixed inset-0 bg-black bg-opacity-75 z-[70] flex items-center justify-center p-4">
         <div class="bg-white rounded-xl w-full max-w-3xl shadow-xl flex flex-col">
            <div class="p-4 md:p-5 border-b border-gray-200 flex items-center justify-between">
                <h2 class="text-lg font-bold text-gray-800">Thống kê mã: <asp:Label ID="lblStatsCouponCode" runat="server"></asp:Label></h2>
                <asp:LinkButton ID="btnCloseCouponStatsModal" runat="server" OnClick="btnCloseCouponStatsModal_Click" CssClass="text-gray-400 hover:text-gray-600"><i class="fas fa-times text-xl"></i></asp:LinkButton>
            </div>
            <div class="p-4 md:p-5 modal-body-promotions-scrollable">
                <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-5">
                    <div class="bg-primary bg-opacity-10 rounded-lg p-3 text-center"><div class="text-xl font-bold text-primary"><asp:Label ID="lblStatsUsageCountModal" runat="server">0</asp:Label></div><div class="text-xs text-gray-600">Lượt sử dụng</div></div>
                    <div class="bg-secondary bg-opacity-10 rounded-lg p-3 text-center"><div class="text-xl font-bold text-secondary"><asp:Label ID="lblStatsRevenueModal" runat="server">0đ</asp:Label></div><div class="text-xs text-gray-600">Doanh thu</div></div>
                    <div class="bg-accent bg-opacity-10 rounded-lg p-3 text-center"><div class="text-xl font-bold text-yellow-700"><asp:Label ID="lblStatsSavingModal" runat="server">0đ</asp:Label></div><div class="text-xs text-gray-600">Tiết kiệm</div></div>
                    <div class="bg-green-100 rounded-lg p-3 text-center"><div class="text-xl font-bold text-green-700"><asp:Label ID="lblStatsConversionModal" runat="server">0%</asp:Label></div><div class="text-xs text-gray-600">Chuyển đổi</div></div>
                </div>
                <div class="bg-gray-50 rounded-lg p-4 mb-5">
                    <h4 class="text-base font-semibold text-gray-700 mb-3">Lượt sử dụng theo thời gian</h4>
                    <div class="chart-container-admin h-[250px]"><canvas id="adminCouponUsageChartModal"></canvas></div>
                </div>
                 <div class="overflow-x-auto">
                     <h4 class="text-base font-semibold text-gray-700 mb-3">Chi tiết sử dụng</h4>
                     <asp:GridView ID="gvCouponUsageDetails" runat="server" AutoGenerateColumns="False" CssClass="w-full table-admin-reports text-xs" EmptyDataText="Chưa có lượt sử dụng nào." GridLines="None">
                        <Columns>
                            <asp:BoundField DataField="OrderCode" HeaderText="Đơn hàng" />
                            <asp:BoundField DataField="CustomerName" HeaderText="Khách hàng" />
                            <asp:BoundField DataField="UsageDate" HeaderText="Ngày SD" DataFormatString="{0:dd/MM/yy HH:mm}" />
                            <asp:BoundField DataField="OrderValue" HeaderText="Giá trị ĐH" DataFormatString="{0:N0}đ" />
                            <asp:BoundField DataField="DiscountApplied" HeaderText="Giảm giá" DataFormatString="{0:N0}đ" />
                        </Columns>
                     </asp:GridView>
                 </div>
            </div>
             <div class="p-4 md:p-5 border-t border-gray-200 bg-gray-50 text-right">
                 <asp:Button ID="btnModalCloseStats" runat="server" Text="Đóng" OnClick="btnCloseCouponStatsModal_Click" CssClass="px-6 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50" />
             </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlDeletePromotionModal" runat="server" Visible="false" CssClass="modal-admin-promo fixed inset-0 bg-black bg-opacity-75 z-[70] flex items-center justify-center p-4">
        <div class="bg-white rounded-xl w-full max-w-md p-6 shadow-xl">
            <div class="text-center">
                <div class="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4"><i class="fas fa-exclamation-triangle text-red-600 text-2xl"></i></div>
                <h3 class="text-lg font-semibold text-gray-800 mb-2">Xác nhận xóa</h3>
                <p class="text-gray-600 mb-6">Bạn có chắc muốn xóa khuyến mãi "<asp:Literal ID="litDeletePromotionName" runat="server"></asp:Literal>"? Hành động này không thể hoàn tác.</p>
                <div class="flex space-x-4">
                    <asp:Button ID="btnCancelDeletePromotion" runat="server" Text="Hủy" OnClick="btnCancelDeletePromotion_Click" CssClass="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50" />
                    <asp:Button ID="btnConfirmDeletePromotion" runat="server" Text="Xóa" OnClick="btnConfirmDeletePromotion_Click" CssClass="flex-1 px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded-lg" />
                    <asp:HiddenField ID="hfDeletePromotionId" runat="server" />
                </div>
            </div>
        </div>
    </asp:Panel>
</asp:Content>

<asp:Content ID="AdminScriptsPromotions" ContentPlaceHolderID="AdminScriptsContent" runat="server">
    <script type="text/javascript">
        let currentAdminPromoTab = 'coupons';
        let currentEditingPromoId = null;
        let currentPromoTypeInModal = 'coupon';
        let adminCouponUsageChartModalInstance = null;
        let adminPromoRevenueChartInstance = null;
        let adminPromoUsageTypeChartInstance = null;


        function switchAdminMainTab(tabName, buttonElement) {
            document.querySelectorAll('.tab-button-main').forEach(btn => btn.classList.remove('active'));
            buttonElement.classList.add('active');

            document.getElementById('<%= pnlCouponsContent.ClientID %>').style.display = (tabName === 'coupons' ? 'block' : 'none');
            document.getElementById('<%= pnlProductPromosContent.ClientID %>').style.display = (tabName === 'productPromos' ? 'block' : 'none');
            document.getElementById('<%= pnlAnalyticsContent.ClientID %>').style.display = (tabName === 'analytics' ? 'block' : 'none');
            
            currentAdminPromoTab = tabName;
            if (tabName === 'analytics' && !adminPromoRevenueChartInstance) { // Initialize charts if analytics tab is shown
                 setTimeout(initializeAdminAnalyticsCharts, 100); // Give DOM time to render
            }
        }
        
        function switchPromoTypeInModal(type, buttonElement) {
            document.querySelectorAll('.promo-type-tab-modal').forEach(tab => {
                tab.classList.remove('active', 'bg-primary', 'text-white');
                tab.classList.add('border-gray-300', 'text-gray-500', 'hover:bg-gray-50');
            });
             buttonElement.classList.add('active', 'bg-primary', 'text-white');
             buttonElement.classList.remove('border-gray-300', 'text-gray-500', 'hover:bg-gray-50');


            document.getElementById('<%= pnlCouponFormModal.ClientID %>').style.display = (type === 'coupon' ? 'block' : 'none');
            document.getElementById('<%= pnlProductPromoFormModal.ClientID %>').style.display = (type === 'product' ? 'block' : 'none');
            document.getElementById('<%= hfCurrentPromoType.ClientID %>').value = type;
            
            // Update validation group for save button based on active form
            const saveButton = document.getElementById('<%= btnSavePromotionModal.ClientID %>');
            if (saveButton) {
                saveButton.setAttribute('onclick', saveButton.getAttribute('onclick').replace(/ValidationGroup='[^']*'/, `ValidationGroup='${type === 'coupon' ? 'CouponValidation' : 'ProductPromoValidation'}'`));
            }
        }
        
        // Simplified ClientID getter for this page context
        function getClientId(serverID) { return serverID; }

        function toggleAdminDropdown(event, dropdownIdSuffix) {
            event.stopPropagation();
            const dropdown = document.getElementById(getClientIdPrefixPromotions() + dropdownIdSuffix);
            document.querySelectorAll('[id^="' + getClientIdPrefixPromotions() + 'coupon-dropdown-"], [id^="' + getClientIdPrefixPromotions() + 'promo-dropdown-"]').forEach(d => {
                if (d !== dropdown && !d.classList.contains('hidden')) d.classList.add('hidden');
            });
            if(dropdown) dropdown.classList.toggle('hidden');
        }
        function getClientIdPrefixPromotions() { // Adjust if using complex naming containers
             const firstBtn = document.querySelector('[id*="rptCoupons_btnCouponActions_0"]');
             return firstBtn ? firstBtn.id.substring(0, firstBtn.id.lastIndexOf('_') + 1) : '';
        }


        document.addEventListener('click', function(event) { // Close dropdowns on outside click
            if (!event.target.closest('.relative')) { // If click is not on a relative positioned parent of a dropdown
                 document.querySelectorAll('[id^="' + getClientIdPrefixPromotions() + 'coupon-dropdown-"], [id^="' + getClientIdPrefixPromotions() + 'promo-dropdown-"]').forEach(d => d.classList.add('hidden'));
            }
        });
        
        function copyCouponCodeClientSide(code) {
            navigator.clipboard.writeText(code).then(() => showAdminNotification(`Đã sao chép mã: ${code}`, 'success'));
        }
        
        // Modal visibility is mostly handled by server with pnl.Visible=true/false
        // JS primarily for client-side enhancements or if non-postback modal opening is needed.

        function initializeAdminAnalyticsCharts(revenueData, usageData) {
            const revenueCtx = document.getElementById('adminPromoRevenueChart');
            if (revenueCtx) {
                 if (adminPromoRevenueChartInstance) adminPromoRevenueChartInstance.destroy();
                adminPromoRevenueChartInstance = new Chart(revenueCtx.getContext('2d'), { /* ... config from HTML ... */ 
                    type: 'line', data: revenueData, // revenueData = { labels: [], datasets: [{label:'', data:[]}, ...] }
                    options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'top' } }, scales: { y: { beginAtZero: true }, x: {} } }
                });
            }
            const usageCtx = document.getElementById('adminPromoUsageChart');
            if(usageCtx) {
                if(adminPromoUsageTypeChartInstance) adminPromoUsageTypeChartInstance.destroy();
                adminPromoUsageTypeChartInstance = new Chart(usageCtx.getContext('2d'), { /* ... config from HTML ... */ 
                    type: 'doughnut', data: usageData, // usageData = { labels:[], datasets:[{data:[]}] }
                    options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom' } } }
                });
            }
        }
        
        function initializeCouponStatsChartModal(labels, data) {
             const ctx = document.getElementById('adminCouponUsageChartModal');
             if(!ctx) return;
             if(adminCouponUsageChartModalInstance) adminCouponUsageChartModalInstance.destroy();
             adminCouponUsageChartModalInstance = new Chart(ctx.getContext('2d'), {
                 type: 'bar', data: { labels: labels, datasets: [{ label: 'Lượt sử dụng', data: data, backgroundColor: 'rgba(255, 107, 107, 0.7)' }] },
                 options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true } } }
             });
        }
        
        function ddlDiscountTypeModal_ClientChanged(ddl) {
            const discountValueFieldPanel = document.getElementById('<%= pnlDiscountValueModal.ClientID %>');
            const maxDiscountFieldPanel = document.getElementById('<%= pnlMaxDiscountModal.ClientID %>');
            const discountUnitLabel = document.getElementById('<%= lblDiscountUnitModal.ClientID %>');

            if (ddl.value === 'free_shipping') {
                if(discountValueFieldPanel) discountValueFieldPanel.style.display = 'none';
                if(maxDiscountFieldPanel) maxDiscountFieldPanel.style.display = 'none';
            } else {
                if(discountValueFieldPanel) discountValueFieldPanel.style.display = 'block'; // Or 'grid' if it's a grid item
                if(maxDiscountFieldPanel) maxDiscountFieldPanel.style.display = 'block';
                if(discountUnitLabel) discountUnitLabel.textContent = (ddl.value === 'percentage' ? '%' : 'VNĐ');
            }
        }
        
        function handleApplicableToChangeModal(ddl) {
            const targetSelectionPanel = document.getElementById('targetSelectionModal'); // Assuming you add an ID to this panel in ASPX
            const targetDropdown = document.getElementById(''); // Assuming ddlTargetIdModal is your target DropDownList
            if(!targetSelectionPanel || !targetDropdown) return;

            if (ddl.value === 'all') {
                targetSelectionPanel.style.display = 'none';
            } else {
                targetSelectionPanel.style.display = 'block'; // Or 'grid'
            }
        }
        
        function setupPromoModalClose() {
            const modal = document.getElementById('<%= pnlPromotionModal.ClientID %>');
            if (modal) {
                modal.addEventListener('click', (e) => {
                    if (e.target === e.currentTarget) {
                        document.getElementById('<%= btnClosePromotionModal.ClientID %>').click();
                    }
                });
            }
            const statsModal = document.getElementById('<%= pnlCouponStatsModal.ClientID %>');
             if (statsModal) {
                statsModal.addEventListener('click', (e) => {
                    if (e.target === e.currentTarget) {
                        document.getElementById('<%= btnCloseCouponStatsModal.ClientID %>').click();
                    }
                });
            }
            const deleteModal = document.getElementById('<%= pnlDeletePromotionModal.ClientID %>');
            if(deleteModal) {
                 deleteModal.addEventListener('click', (e) => {
                    if (e.target === e.currentTarget) {
                        document.getElementById('<%= btnCancelDeletePromotion.ClientID %>').click();
                    }
                });
            }
        }
        if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function() { setupPromoModalClose(); });
        }
        document.addEventListener('DOMContentLoaded', function() {
            setupPromoModalClose(); 
             // Ensure default tab is visually selected in modal
            const defaultPromoTypeButton = document.querySelector('.promo-type-tab-modal[data-type="coupon"]');
            if(defaultPromoTypeButton) switchPromoTypeInModal('coupon', defaultPromoTypeButton);
            
            // Set active for main content tab
            const defaultMainTabButton = document.getElementById('<%= tabBtnCoupons.ClientID %>');
            if(defaultMainTabButton) switchAdminMainTab('coupons', defaultMainTabButton);

             // Active state for mobile bottom nav
            const currentPath = window.location.pathname.toLowerCase();
            const bottomNavLinks = document.querySelectorAll('.bottom-nav .nav-item');
            let promoLinkManuallyActivated = false;

            bottomNavLinks.forEach(link => {
                const linkHref = link.getAttribute('href');
                if (!linkHref) return;
                const linkPath = new URL(linkHref, window.location.origin).pathname.toLowerCase();
                
                if (currentPath.includes('promotions.aspx') && linkPath.includes('promotions.aspx')) { 
                    link.classList.add('active');
                    link.classList.remove('text-gray-600');
                    promoLinkManuallyActivated = true;
                } else if (!promoLinkManuallyActivated && currentPath === linkPath) {
                    link.classList.add('active');
                    link.classList.remove('text-gray-600');
                } else {
                    link.classList.remove('active');
                     if (!link.classList.contains('active')) { // Do not remove gray if it's already active
                        link.classList.add('text-gray-600');
                    }
                }
            });
        });
    </script>
</asp:Content>