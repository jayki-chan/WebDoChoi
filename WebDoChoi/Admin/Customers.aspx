<%@ Page Title="Quản lý Khách hàng - ToyLand Admin" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="Customers.aspx.cs" Inherits="WebsiteDoChoi.Admin.Customers" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitleContent" runat="server">
    <h1 class="text-xl md:text-2xl font-bold text-gray-800">Quản lý Khách hàng</h1>
</asp:Content>

<asp:Content ID="AdminHeadCustomers" ContentPlaceHolderID="AdminHeadContent" runat="server">
    <style>
        .customer-card-admin { transition: all 0.3s ease; }
        .customer-card-admin:hover { transform: translateY(-2px); box-shadow: 0 6px 18px rgba(0,0,0,0.07); }

        .badge-customer { color: white; text-transform: uppercase; font-size: 0.7rem; padding: 0.2rem 0.6rem; border-radius: 9999px; font-weight: 600; }
        .badge-vip { background: linear-gradient(45deg, #FFD700, #FFA500); color: #4A3B00; } /* Gold to Orange, dark text */
        .badge-regular { background: linear-gradient(45deg, #4ECDC4, #44A08D); }
        .badge-new { background: linear-gradient(45deg, #FF6B6B, #ee5a6f); }
        .badge-active { background-color: #DEF7EC; color: #03543F; } /* Green light */
        .badge-inactive { background-color: #FEE2E2; color: #9A3412; } /* Red light */
        .badge-blocked { background-color: #E5E7EB; color: #4B5563; } /* Gray light */


        .modal-admin-customer { backdrop-filter: blur(5px); }
        .chart-container-admin { position: relative; height: 280px; } /* Slightly smaller for modal */
        .modal-body-customer-scrollable::-webkit-scrollbar { width: 6px; }
        .modal-body-customer-scrollable::-webkit-scrollbar-track { background: #f1f5f9; border-radius: 3px; }
        .modal-body-customer-scrollable::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 3px; }
        .modal-body-customer-scrollable { scrollbar-width: thin; scrollbar-color: #cbd5e1 #f1f5f9; max-height: calc(100vh - 200px); overflow-y: auto; }
    </style>
</asp:Content>

<asp:Content ID="MainAdminContentCustomers" ContentPlaceHolderID="AdminMainContent" runat="server">
    <div class="bg-white shadow-sm px-4 md:px-6 py-3 border-b border-gray-200">
        <div class="flex items-center justify-between">
            <h2 class="text-lg font-semibold text-gray-700">Danh sách Khách hàng</h2>
                <span class="hidden sm:inline">Xuất Excel</span>
                <span class="sm:hidden">Xuất</span>
        </div>
    </div>

    <div class="p-4 md:p-6">
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 md:gap-6 mb-6 md:mb-8">
            <div class="bg-white rounded-xl p-4 md:p-6 shadow-sm">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-600 text-sm">Tổng khách hàng</p>
                        <asp:Label ID="lblTotalCustomers" runat="server" Text="0" CssClass="text-xl md:text-2xl font-bold text-gray-800"></asp:Label>
                        <asp:Label ID="lblTotalCustomersChange" runat="server" Text="+0%" CssClass="text-green-500 text-xs md:text-sm"></asp:Label>
                    </div>
                    <div class="w-10 h-10 md:w-12 md:h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                        <i class="fas fa-users text-blue-600 text-xl md:text-2xl"></i>
                    </div>
                </div>
            </div>
            <div class="bg-white rounded-xl p-4 md:p-6 shadow-sm">
                 <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-600 text-sm">Khách hàng mới (Tháng)</p>
                        <asp:Label ID="lblNewCustomersMonthly" runat="server" Text="0" CssClass="text-xl md:text-2xl font-bold text-green-600"></asp:Label>
                        <asp:Label ID="lblNewCustomersInfo" runat="server" Text="Trong tháng này" CssClass="text-green-500 text-xs md:text-sm"></asp:Label>
                    </div>
                    <div class="w-10 h-10 md:w-12 md:h-12 bg-green-100 rounded-lg flex items-center justify-center">
                        <i class="fas fa-user-plus text-green-600 text-xl md:text-2xl"></i>
                    </div>
                </div>
            </div>
             <div class="bg-white rounded-xl p-4 md:p-6 shadow-sm">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-600 text-sm">Khách hàng VIP</p>
                        <asp:Label ID="lblVipCustomers" runat="server" Text="0" CssClass="text-xl md:text-2xl font-bold text-yellow-600"></asp:Label>
                        <asp:Label ID="lblVipCustomersPercentage" runat="server" Text="0%" CssClass="text-yellow-500 text-xs md:text-sm"></asp:Label>
                    </div>
                    <div class="w-10 h-10 md:w-12 md:h-12 bg-yellow-100 rounded-lg flex items-center justify-center">
                        <i class="fas fa-crown text-yellow-600 text-xl md:text-2xl"></i>
                    </div>
                </div>
            </div>
             <div class="bg-white rounded-xl p-4 md:p-6 shadow-sm">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-600 text-sm">Tỷ lệ quay lại</p>
                        <asp:Label ID="lblReturnRate" runat="server" Text="0%" CssClass="text-xl md:text-2xl font-bold text-purple-600"></asp:Label>
                        <asp:Label ID="lblReturnRateChange" runat="server" Text="+0%" CssClass="text-purple-500 text-xs md:text-sm"></asp:Label>
                    </div>
                    <div class="w-10 h-10 md:w-12 md:h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                        <i class="fas fa-sync-alt text-purple-600 text-xl md:text-2xl"></i>
                    </div>
                </div>
            </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 md:gap-6 mb-6 md:mb-8">
            <div class="bg-white rounded-xl shadow-sm p-4 md:p-6">
                <div class="flex items-center justify-between mb-4 md:mb-6">
                    <h3 class="text-base md:text-lg font-bold text-gray-800">Tăng trưởng khách hàng</h3>
                    <asp:DropDownList ID="ddlCustomerGrowthPeriod" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlCustomerGrowthPeriod_SelectedIndexChanged" CssClass="border border-gray-300 rounded-lg px-2 md:px-3 py-1 text-sm focus:outline-none focus:border-primary">
                        <asp:ListItem Value="6m">6 tháng</asp:ListItem>
                        <asp:ListItem Value="12m" Selected="True">12 tháng</asp:ListItem>
                        <asp:ListItem Value="all">Tất cả</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="chart-container-admin">
                    <canvas id="customerGrowthChartAdmin"></canvas>
                </div>
            </div>
            <div class="bg-white rounded-xl shadow-sm p-4 md:p-6">
                <h3 class="text-base md:text-lg font-bold text-gray-800 mb-4 md:mb-6">Phân khúc khách hàng</h3>
                <div class="chart-container-admin">
                    <canvas id="customerSegmentChartAdmin"></canvas>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm p-4 md:p-6 mb-6">
            <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4 items-end">
                <div class="relative">
                    <label for="txtSearchCustomers" class="block text-sm font-medium text-gray-700 mb-1">Tìm kiếm</label>
                    <asp:TextBox ID="txtSearchCustomers" runat="server" placeholder="Tên, Email, SĐT..." CssClass="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-primary w-full"></asp:TextBox>
                    <i class="fas fa-search absolute left-3 bottom-2.5 text-gray-400"></i>
                </div>
                 <div>
                    <label for="ddlSegmentFilter" class="block text-sm font-medium text-gray-700 mb-1">Phân khúc</label>
                    <asp:DropDownList ID="ddlSegmentFilter" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary">
                        <asp:ListItem Value="">Tất cả phân khúc</asp:ListItem>
                        <asp:ListItem Value="vip">VIP</asp:ListItem>
                        <asp:ListItem Value="regular">Thường</asp:ListItem>
                        <asp:ListItem Value="new">Mới</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div>
                    <label for="ddlCustomerStatusFilter" class="block text-sm font-medium text-gray-700 mb-1">Trạng thái TK</label>
                    <asp:DropDownList ID="ddlCustomerStatusFilter" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary">
                        <asp:ListItem Value="">Tất cả trạng thái</asp:ListItem>
                        <asp:ListItem Value="active">Hoạt động</asp:ListItem>
                        <asp:ListItem Value="inactive">Không hoạt động</asp:ListItem>
                        <asp:ListItem Value="blocked">Đã chặn</asp:ListItem>
                    </asp:DropDownList>
                </div>
                 <div>
                    <label for="txtJoinedDateFilter" class="block text-sm font-medium text-gray-700 mb-1">Ngày tham gia</label>
                    <asp:TextBox ID="txtJoinedDateFilter" runat="server" TextMode="Date" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary"></asp:TextBox>
                </div>
                <div class="flex space-x-2">
                    <asp:Button ID="btnApplyCustomerFilters" runat="server" Text="Lọc" OnClick="btnApplyCustomerFilters_Click" CssClass="w-full sm:w-auto px-4 py-2 bg-secondary text-white rounded-lg hover:bg-opacity-90" />
                    <asp:Button ID="btnResetCustomerFilters" runat="server" Text="Reset" OnClick="btnResetCustomerFilters_Click" CssClass="w-full sm:w-auto px-4 py-2 bg-gray-500 hover:bg-gray-600 text-white rounded-lg" CausesValidation="false"/>
                </div>
            </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-4 md:gap-6" id="customersListContainer">
             <asp:Repeater ID="rptCustomers" runat="server" OnItemCommand="rptCustomers_ItemCommand">
                 <ItemTemplate>
                     <div class="customer-card-admin bg-white rounded-xl shadow-sm p-4 md:p-6">
                        <div class="flex items-start justify-between mb-3">
                            <div class="flex items-center space-x-3">
                                <div class='w-12 h-12 rounded-full flex items-center justify-center text-white font-bold text-lg'>
                                    <%# Eval("CustomerName").ToString() %>
                                </div>
                                <div>
                                    <h3 class="font-semibold text-gray-800"><%# Eval("CustomerName") %></h3>
                                    <p class="text-sm text-gray-600"><%# Eval("Email") %></p>
                                    <p class="text-sm text-gray-500"><%# Eval("PhoneNumber") %></p>
                                </div>
                            </div>
                            <span class='badge-customer <%# Eval("SegmentCssClass") %>'><%# Eval("SegmentText") %></span>
                        </div>
                        <div class="grid grid-cols-3 gap-4 mb-3 text-center">
                            <div>
                                <p class="text-lg font-bold text-gray-800"><%# Eval("TotalOrders") %></p>
                                <p class="text-xs text-gray-500">Đơn hàng</p>
                            </div>
                            <div>
                                <p class="text-lg font-bold text-green-600"><%# Eval("TotalSpent", "{0:N0}K") %></p>
                                <p class="text-xs text-gray-500">Chi tiêu</p>
                            </div>
                            <div>
                                <p class="text-lg font-bold text-blue-600"><%# Eval("AverageRating", "{0:F1}") %></p>
                                <p class="text-xs text-gray-500">Đánh giá TB</p>
                            </div>
                        </div>
                        <div class="flex items-center justify-between text-sm text-gray-500 mb-3">
                            <span>Tham gia: <%# Eval("JoinedDate", "{0:dd/MM/yyyy}") %></span>
                            <span class='px-2 py-0.5 rounded-full text-xs'><%# Eval("AccountStatusText") %></span>
                        </div>
                        <div class="flex items-center space-x-2">
                            <asp:LinkButton ID="btnViewCustomerDetails" runat="server" CommandName="ViewDetails" CommandArgument='<%# Eval("CustomerId") %>' CssClass="flex-1 bg-primary hover:bg-opacity-90 text-white py-2 px-3 rounded-lg text-sm transition-colors text-center"><i class="fas fa-eye mr-1"></i> Xem chi tiết</asp:LinkButton>
                            <asp:HyperLink ID="hlEmailCustomer" runat="server" NavigateUrl='<%# "mailto:" + Eval("Email") %>' CssClass="px-3 py-2 text-gray-600 hover:text-primary transition-colors" ToolTip="Gửi Email"><i class="fas fa-envelope"></i></asp:HyperLink>
                            <asp:LinkButton ID="btnToggleBlockCustomer" runat="server" CommandName="ToggleBlock" CommandArgument='<%# Eval("CustomerId") + "," + Eval("AccountStatus") %>' CssClass="px-3 py-2 text-gray-600 transition-colors" ToolTip='<%# Eval("AccountStatus").ToString() == "blocked" ? "Bỏ chặn" : "Chặn" %>'>
                                <i class='<%# Eval("AccountStatus").ToString() == "blocked" ? "fas fa-unlock text-green-500 hover:text-green-700" : "fas fa-ban text-red-500 hover:text-red-700" %>'></i>
                            </asp:LinkButton>
                        </div>
                    </div>
                 </ItemTemplate>
                  <FooterTemplate>
                    <asp:Panel ID="pnlNoCustomers" runat="server" Visible='<%# rptCustomers.Items.Count == 0 %>' CssClass="col-span-full text-center py-10">
                        <p class="text-gray-500">Không tìm thấy khách hàng nào.</p>
                    </asp:Panel>
                </FooterTemplate>
             </asp:Repeater>
        </div>

        <div class="flex flex-col sm:flex-row items-center justify-between mt-6 space-y-4 sm:space-y-0">
            <asp:Label ID="lblCustomerPageInfo" runat="server" CssClass="text-sm text-gray-500"></asp:Label>
            <div class="flex items-center space-x-1">
                <asp:LinkButton ID="lnkCustomerPrevPage" runat="server" OnClick="CustomerPage_Changed" CommandArgument="Prev" CssClass="px-3 py-2 border border-gray-300 rounded-lg text-sm hover:bg-gray-50"><i class="fas fa-chevron-left"></i></asp:LinkButton>
                <asp:Repeater ID="rptCustomerPager" runat="server" OnItemCommand="CustomerPage_Changed">
                    <ItemTemplate>
                        <asp:LinkButton ID="lnkCustomerPageNumber" runat="server" Text='<%# Eval("Text") %>' CommandName="Page" CommandArgument='<%# Eval("Value") %>' CssClass='<%# Convert.ToBoolean(Eval("IsCurrent")) ? "px-3 py-2 bg-primary text-white rounded-lg text-sm" : "px-3 py-2 border border-gray-300 rounded-lg text-sm hover:bg-gray-50" %>'></asp:LinkButton>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:LinkButton ID="lnkCustomerNextPage" runat="server" OnClick="CustomerPage_Changed" CommandArgument="Next" CssClass="px-3 py-2 border border-gray-300 rounded-lg text-sm hover:bg-gray-50"><i class="fas fa-chevron-right"></i></asp:LinkButton>
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlCustomerDetailModal" runat="server" Visible="false" CssClass="modal-admin-customer fixed inset-0 bg-black bg-opacity-50 z-[60] flex items-center justify-center p-4">
        <div class="bg-white rounded-xl w-full max-w-6xl shadow-xl flex flex-col">
             <div class="p-4 md:p-6 border-b border-gray-200 flex items-center justify-between">
                <h2 class="text-lg md:text-xl font-bold text-gray-800">Chi tiết khách hàng - <asp:Label ID="lblModalCustomerName" runat="server"></asp:Label></h2>
                <asp:LinkButton ID="btnCloseCustomerModal" runat="server" OnClick="btnCloseCustomerModal_Click" CssClass="text-gray-400 hover:text-gray-600" CausesValidation="false"><i class="fas fa-times text-xl"></i></asp:LinkButton>
            </div>
            <div class="p-4 md:p-6 modal-body-customer-scrollable">
                 <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    <div class="lg:col-span-1 space-y-6">
                        <div class="bg-gray-50 rounded-lg p-4">
                            <h3 class="text-base font-semibold text-gray-800 mb-3">Thông tin cá nhân</h3>
                            <div class="flex items-center space-x-4 mb-3">
                                 <div class="w-16 h-16 rounded-full flex items-center justify-center text-white font-bold text-2xl" id="modalAvatarContainer">
                                    <asp:Label ID="lblModalAvatarInitial" runat="server" Text="K"></asp:Label>
                                 </div>
                                <div>
                                    <h4 class="font-semibold text-gray-800"><asp:Label ID="lblModalCustomerFullName" runat="server"></asp:Label></h4>
                                    <asp:Label ID="lblModalCustomerSegment" runat="server" CssClass="badge-customer text-white text-xs px-2 py-1 rounded-full font-medium"></asp:Label>
                                </div>
                            </div>
                             <div class="space-y-1 text-sm">
                                <p><strong class="text-gray-600">Email:</strong> <asp:Label ID="lblModalEmail" runat="server"></asp:Label></p>
                                <p><strong class="text-gray-600">Điện thoại:</strong> <asp:Label ID="lblModalPhone" runat="server"></asp:Label></p>
                                <p><strong class="text-gray-600">Giới tính:</strong> <asp:Label ID="lblModalGender" runat="server"></asp:Label></p>
                                <p><strong class="text-gray-600">Ngày sinh:</strong> <asp:Label ID="lblModalDob" runat="server"></asp:Label></p>
                                <p><strong class="text-gray-600">Tham gia:</strong> <asp:Label ID="lblModalJoinedDate" runat="server"></asp:Label></p>
                                <p><strong class="text-gray-600">Trạng thái:</strong> <asp:Label ID="lblModalAccountStatus" runat="server" CssClass="px-2 py-0.5 rounded-full text-xs"></asp:Label></p>
                            </div>
                        </div>
                         <div class="bg-gray-50 rounded-lg p-4">
                            <h3 class="text-base font-semibold text-gray-800 mb-3">Thống kê</h3>
                            <div class="grid grid-cols-2 gap-3 text-center">
                                <div><p class="text-xl font-bold text-gray-800"><asp:Label ID="lblModalTotalOrders" runat="server"></asp:Label></p><p class="text-xs text-gray-500">Đơn hàng</p></div>
                                <div><p class="text-xl font-bold text-green-600"><asp:Label ID="lblModalTotalSpent" runat="server"></asp:Label></p><p class="text-xs text-gray-500">Chi tiêu</p></div>
                                <div><p class="text-xl font-bold text-blue-600"><asp:Label ID="lblModalAvgRating" runat="server"></asp:Label></p><p class="text-xs text-gray-500">Đánh giá TB</p></div>
                                <div><p class="text-xl font-bold text-purple-600"><asp:Label ID="lblModalCompletionRate" runat="server"></asp:Label>%</p><p class="text-xs text-gray-500">Hoàn thành</p></div>
                            </div>
                        </div>
                        <asp:Panel ID="pnlModalAddresses" runat="server" CssClass="bg-gray-50 rounded-lg p-4">
                            <h3 class="text-base font-semibold text-gray-800 mb-3">Địa chỉ (<asp:Label ID="lblModalAddressCount" runat="server" Text="0"></asp:Label>)</h3>
                            <div class="space-y-2 max-h-40 overflow-y-auto">
                               <asp:Repeater ID="rptModalAddresses" runat="server">
                                   <ItemTemplate>
                                       <div class="border border-gray-200 rounded-md p-2 bg-white text-xs">
                                           <div class="flex justify-between items-center">
                                               <span class="font-medium"><%# Eval("AddressType") %></span>
                                               <asp:Label ID="lblIsDefaultAddress" runat="server" Text="Mặc định" Visible='<%# Convert.ToBoolean(Eval("IsDefault")) %>' CssClass="text-2xs bg-green-100 text-green-700 px-1.5 py-0.5 rounded-full"></asp:Label>
                                           </div>
                                           <p class="text-gray-600"><%# Eval("FullAddress") %></p>
                                       </div>
                                   </ItemTemplate>
                                   <FooterTemplate>
                                       <asp:Panel ID="pnlNoAddressesModal" runat="server" Visible='<%# rptModalAddresses.Items.Count == 0 %>'>
                                           <p class="text-xs text-gray-500">Chưa có địa chỉ nào.</p>
                                       </asp:Panel>
                                   </FooterTemplate>
                               </asp:Repeater>
                            </div>
                        </asp:Panel>
                    </div>
                     <div class="lg:col-span-2 space-y-6">
                        <div>
                            <h3 class="text-base font-semibold text-gray-800 mb-3">Đơn hàng gần đây (<asp:Label ID="lblModalRecentOrderCount" runat="server" Text="0"></asp:Label>)</h3>
                             <div class="bg-white border border-gray-200 rounded-lg overflow-hidden">
                                <div class="overflow-x-auto max-h-60">
                                     <asp:GridView ID="gvModalRecentOrders" runat="server" AutoGenerateColumns="False" CssClass="w-full min-w-full text-xs" GridLines="None" EmptyDataText="Không có đơn hàng nào.">
                                         <Columns>
                                             <asp:BoundField DataField="OrderCode" HeaderText="Mã ĐH" />
                                             <asp:BoundField DataField="OrderDate" HeaderText="Ngày" DataFormatString="{0:dd/MM/yy}" />
                                             <asp:BoundField DataField="TotalAmount" HeaderText="Tổng" DataFormatString="{0:N0}K" />
                                             <asp:TemplateField HeaderText="TT">
                                                 <ItemTemplate><span class=''><%# Eval("StatusText") %></span></ItemTemplate>
                                             </asp:TemplateField>
                                             <asp:HyperLinkField DataNavigateUrlFields="OrderId" DataNavigateUrlFormatString="~/Admin/Orders.aspx?view={0}" Text="<i class='fas fa-eye'></i>" ControlStyle-CssClass="text-primary hover:text-primary-dark" />
                                         </Columns>
                                     </asp:GridView>
                                </div>
                            </div>
                        </div>
                        <div>
                            <h3 class="text-base font-semibold text-gray-800 mb-3">Lịch sử mua hàng (6 tháng)</h3>
                            <div class="bg-white border border-gray-200 rounded-lg p-3">
                                <div class="chart-container-admin h-[200px]">
                                    <canvas id="customerPurchaseChartModal"></canvas>
                                </div>
                            </div>
                        </div>
                         <div>
                            <h3 class="text-base font-semibold text-gray-800 mb-3">Hoạt động gần đây</h3>
                            <div class="bg-white border border-gray-200 rounded-lg p-3 max-h-48 overflow-y-auto">
                                <div class="space-y-3">
                                    <asp:Repeater ID="rptModalActivityLog" runat="server">
                                        <ItemTemplate>
                                            <div class="flex items-start space-x-2">
                                                <div class='w-6 h-6 <%# Eval("IconBgCss") %> rounded-full flex items-center justify-center flex-shrink-0 mt-0.5'>
                                                    <i class='<%# Eval("IconCss") %> text-xs'></i>
                                                </div>
                                                <div class="flex-1">
                                                    <p class="text-xs text-gray-700"><%# Eval("Activity") %></p>
                                                    <p class="text-3xs text-gray-400"><%# Eval("Timestamp", "{0:dd/MM/yy HH:mm}") %></p>
                                                </div>
                                            </div>
                                        </ItemTemplate>
                                         <FooterTemplate>
                                            <asp:Panel ID="pnlNoActivityModal" runat="server" Visible='<%# rptModalActivityLog.Items.Count == 0 %>'>
                                                <p class="text-xs text-gray-500">Không có hoạt động nào gần đây.</p>
                                            </asp:Panel>
                                        </FooterTemplate>
                                    </asp:Repeater>
                                </div>
                            </div>
                        </div>
                    </div>
                 </div>
            </div>
            <div class="p-4 md:p-6 border-t border-gray-200 bg-gray-50 flex flex-col sm:flex-row justify-end space-y-2 sm:space-y-0 sm:space-x-3">
                <asp:Button ID="btnModalCloseCustomer" runat="server" Text="Đóng" OnClick="btnCloseCustomerModal_Click" CssClass="w-full sm:w-auto px-6 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50" CausesValidation="false" />
                <asp:HyperLink ID="hlModalEmailCustomer" runat="server" Text="Gửi Email" CssClass="w-full sm:w-auto px-6 py-2 bg-blue-500 hover:bg-blue-600 text-white rounded-lg text-center inline-flex items-center justify-center"><i class="fas fa-envelope mr-2"></i>Gửi email</asp:HyperLink>
                <asp:HyperLink ID="hlModalEditCustomer" runat="server" Text="Chỉnh sửa" CssClass="w-full sm:w-auto px-6 py-2 bg-secondary hover:bg-opacity-90 text-white rounded-lg text-center inline-flex items-center justify-center"><i class="fas fa-edit mr-2"></i>Chỉnh sửa</asp:HyperLink>
                <asp:LinkButton ID="btnModalToggleBlockCustomer" runat="server" OnClick="btnToggleBlockCustomer_Click" CssClass="w-full sm:w-auto px-6 py-2 text-white rounded-lg">
                     <%-- Text and Icon set in code-behind --%>
                </asp:LinkButton>
            </div>
        </div>
    </asp:Panel>
</asp:Content>

<asp:Content ID="AdminScriptsCustomers" ContentPlaceHolderID="AdminScriptsContent" runat="server">
    <script type="text/javascript">
        let customerGrowthChartAdminInstance = null;
        let customerSegmentChartAdminInstance = null;
        let customerPurchaseChartModalInstance = null;

        function renderCustomerGrowthChart(labels, newData, totalData) {
            const ctx = document.getElementById('customerGrowthChartAdmin');
            if (!ctx) return;
            if (customerGrowthChartAdminInstance) customerGrowthChartAdminInstance.destroy();
            customerGrowthChartAdminInstance = new Chart(ctx.getContext('2d'), {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [
                        { label: 'Khách hàng mới', data: newData, borderColor: '#FF6B6B', backgroundColor: 'rgba(255, 107, 107, 0.1)', tension: 0.3, fill: true },
                        { label: 'Tổng khách hàng', data: totalData, borderColor: '#4ECDC4', backgroundColor: 'rgba(78, 205, 196, 0.1)', tension: 0.3, fill: false }
                    ]
                },
                options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom', labels:{ padding: 10, usePointStyle: true, font: {size: 10}} } }, scales: { y: { beginAtZero: true, ticks:{font:{size:10}} }, x:{ticks:{font:{size:10}}} } }
            });
        }

        function renderCustomerSegmentChart(labels, data) {
            const ctx = document.getElementById('customerSegmentChartAdmin');
            if(!ctx) return;
            if(customerSegmentChartAdminInstance) customerSegmentChartAdminInstance.destroy();
            customerSegmentChartAdminInstance = new Chart(ctx.getContext('2d'), {
                type: 'doughnut',
                data: {
                    labels: labels, // ['VIP', 'Thường', 'Mới', 'Không hoạt động']
                    datasets: [{ data: data, backgroundColor: ['#FFD700', '#4ECDC4', '#FF6B6B', '#95A5A6'], borderWidth: 0 }]
                },
                options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom', labels:{ padding: 10, usePointStyle: true, font:{size:10} } } } }
            });
        }
        
        function renderCustomerPurchaseChartModal(labels, orderData, revenueData) {
            const ctx = document.getElementById('customerPurchaseChartModal');
            if (!ctx) { console.error('customerPurchaseChartModal canvas not found'); return; }
            if (customerPurchaseChartModalInstance) customerPurchaseChartModalInstance.destroy();
            customerPurchaseChartModalInstance = new Chart(ctx.getContext('2d'), {
                type: 'bar',
                data: {
                    labels: labels, // Monthly labels
                    datasets: [
                        { label: 'Số đơn hàng', data: orderData, backgroundColor: 'rgba(255, 107, 107, 0.7)', borderColor: '#FF6B6B', yAxisID: 'yOrders' },
                        { label: 'Chi tiêu (K VNĐ)', data: revenueData, backgroundColor: 'rgba(78, 205, 196, 0.7)', borderColor: '#4ECDC4', yAxisID: 'yRevenue' }
                    ]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { position: 'top', labels:{font:{size:10}} } },
                    scales: {
                        x: { ticks:{font:{size:9}}},
                        yOrders: { type: 'linear', display: true, position: 'left', beginAtZero: true, title: { display: true, text: 'Số đơn hàng', font:{size:10}}, ticks:{font:{size:9}} },
                        yRevenue: { type: 'linear', display: true, position: 'right', beginAtZero: true, title: { display: true, text: 'Chi tiêu (K VNĐ)', font:{size:10}}, grid: { drawOnChartArea: false }, ticks:{font:{size:9}} }
                    }
                }
            });
        }
        
        // Call from server-side script registration
        // function initializeAdminCustomerCharts(growthLabels, growthNewData, growthTotalData, segmentLabels, segmentData) {
        //     renderCustomerGrowthChart(growthLabels, growthNewData, growthTotalData);
        //     renderCustomerSegmentChart(segmentLabels, segmentData);
        // }
        // function initializeModalPurchaseChart(purchaseLabels, purchaseOrderData, purchaseRevenueData){
        //     renderCustomerPurchaseChartModal(purchaseLabels, purchaseOrderData, purchaseRevenueData);
        // }


        window.addEventListener('resize', function() {
            if (customerGrowthChartAdminInstance) customerGrowthChartAdminInstance.resize();
            if (customerSegmentChartAdminInstance) customerSegmentChartAdminInstance.resize();
            if (customerPurchaseChartModalInstance) customerPurchaseChartModalInstance.resize();
        });

         // Function to be called by server-side LinkButton in Repeater/GridView
        function viewCustomerDetailsOnClient(customerId) {
            // This JS function is a helper if you need to do something on client before/after modal is shown by server
            // For this setup, the server will set pnlCustomerDetailModal.Visible = true and rebind.
            // However, for the chart inside modal, we need to ensure it renders after modal is visible.
            // Server can register a startup script to call initializeModalPurchaseChart with correct data.
        }
        
        // Close modal when clicking outside
        // Make sure this ID matches your modal Panel ID
        const customerModalElement = document.getElementById('<%= pnlCustomerDetailModal.ClientID %>');
        if(customerModalElement){
            customerModalElement.addEventListener('click', (e) => {
                if (e.target === e.currentTarget) {
                     const closeButton = document.getElementById('<%= btnCloseCustomerModal.ClientID %>');
                     if(closeButton) closeButton.click(); // Trigger server-side close
                     else customerModalElement.style.display = 'none'; // Fallback
                     document.body.style.overflow = 'auto';
                }
            });
        }
    </script>
</asp:Content>