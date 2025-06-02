<%@ Page Title="Quản lý Đơn hàng - ToyLand Admin" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="Orders.aspx.cs" Inherits="WebsiteDoChoi.Admin.Orders" %>

<asp:Content ID="PageTitleContent" ContentPlaceHolderID="PageTitleContent" runat="server">
    <h1 class="text-xl md:text-2xl font-bold text-gray-800">Quản lý Đơn hàng</h1>
</asp:Content>

<asp:Content ID="AdminHeadOrders" ContentPlaceHolderID="AdminHeadContent" runat="server">
    <style>
        .order-card-admin { transition: all 0.3s ease; }
        .order-card-admin:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.08); }

        /* Status Badge Colors - Tailwind doesn't have these exact gradient classes by default */
        .status-badge { color: white; text-xs: ; padding: 0.25rem 0.75rem; border-radius: 9999px; font-weight: 500; }
        .status-pending { background-color: #FFA500; } /* Orange */
        .status-confirmed { background-color: #1E90FF; } /* DodgerBlue */
        .status-processing { background-color: #32CD32; } /* LimeGreen */
        .status-shipped { background-color: #9370DB; } /* MediumPurple */
        .status-delivered { background-color: #008000; } /* Green */
        .status-cancelled { background-color: #FF0000; } /* Red */
        .status-returned { background-color: #800080; } /* Purple */
        .status-default { background-color: #A0AEC0; } /* Cool Gray 500 */


        .timeline-admin { position: relative; }
        .timeline-admin::before { content: ''; position: absolute; left: 10px; /* Adjusted for smaller dot */ top: 0; bottom: 0; width: 2px; background: linear-gradient(to bottom, #4ECDC4, #FF6B6B); }
        .timeline-item-admin { position: relative; padding-left: 30px; margin-bottom: 16px; }
        .timeline-item-admin::before { content: ''; position: absolute; left: 5px; /* Adjusted for smaller dot */ top: 5px; width: 10px; height: 10px; border-radius: 50%; background: #4ECDC4; border: 2px solid white; box-shadow: 0 1px 2px rgba(0,0,0,0.1); }
        .timeline-item-admin.completed::before { background: #008000; }
        .timeline-item-admin.current::before { background: #FF6B6B; animation: pulseAdmin 2s infinite; }

        @keyframes pulseAdmin {
            0% { box-shadow: 0 0 0 0 rgba(255, 107, 107, 0.7); }
            70% { box-shadow: 0 0 0 8px rgba(255, 107, 107, 0); }
            100% { box-shadow: 0 0 0 0 rgba(255, 107, 107, 0); }
        }
        .modal-admin-fixed { backdrop-filter: blur(5px); }
        
        .modal-body-orders-scrollable::-webkit-scrollbar { width: 6px; }
        .modal-body-orders-scrollable::-webkit-scrollbar-track { background: #f1f5f9; border-radius: 3px; }
        .modal-body-orders-scrollable::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 3px; }
        .modal-body-orders-scrollable { scrollbar-width: thin; scrollbar-color: #cbd5e1 #f1f5f9; max-height: calc(100vh - 220px); overflow-y: auto; }


        @media print {
            body * { visibility: hidden; }
            .print-area-order, .print-area-order * { visibility: visible; }
            .print-area-order { position: absolute; left: 0; top: 0; width: 100%; padding: 20px; font-size: 12px; }
            .print-hidden-order { display: none !important; }
            .print-area-order table { width: 100%; border-collapse: collapse; }
            .print-area-order th, .print-area-order td { border: 1px solid #ccc; padding: 4px; text-align: left; }
            .print-area-order h1, .print-area-order h2, .print-area-order h3 { margin-bottom: 8px; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainAdminContentOrders" ContentPlaceHolderID="AdminMainContent" runat="server">
     <div class="bg-white shadow-sm px-4 md:px-6 py-3 border-b border-gray-200">
        <div class="flex items-center justify-between">
            <h2 class="text-lg font-semibold text-gray-700">Danh sách Đơn hàng</h2>
                <span class="hidden sm:inline">Xuất Excel</span>
                <span class="sm:hidden">Xuất</span>
        </div>
    </div>

    <div class="p-4 md:p-6">
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 md:gap-6 mb-6 md:mb-8">
            <div class="bg-white rounded-xl p-4 md:p-6 shadow-sm">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-600 text-sm">Tổng đơn hàng</p>
                        <asp:Label ID="lblTotalOrders" runat="server" Text="0" CssClass="text-xl md:text-2xl font-bold text-gray-800"></asp:Label>
                        <asp:Label ID="lblTotalOrdersChange" runat="server" Text="+0%" CssClass="text-green-500 text-xs md:text-sm"></asp:Label>
                    </div>
                    <div class="w-10 h-10 md:w-12 md:h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                        <i class="fas fa-shopping-cart text-blue-600 text-xl md:text-2xl"></i>
                    </div>
                </div>
            </div>
            <div class="bg-white rounded-xl p-4 md:p-6 shadow-sm">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-600 text-sm">Chờ xử lý</p>
                        <asp:Label ID="lblPendingOrders" runat="server" Text="0" CssClass="text-xl md:text-2xl font-bold text-orange-600"></asp:Label>
                        <asp:Label ID="lblPendingOrdersInfo" runat="server" Text="Cần xử lý" CssClass="text-orange-500 text-xs md:text-sm"></asp:Label>
                    </div>
                    <div class="w-10 h-10 md:w-12 md:h-12 bg-orange-100 rounded-lg flex items-center justify-center">
                        <i class="fas fa-clock text-orange-600 text-xl md:text-2xl"></i>
                    </div>
                </div>
            </div>
             <div class="bg-white rounded-xl p-4 md:p-6 shadow-sm">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-600 text-sm">Đang giao</p>
                        <asp:Label ID="lblShippedOrders" runat="server" Text="0" CssClass="text-xl md:text-2xl font-bold text-purple-600"></asp:Label>
                        <asp:Label ID="lblShippedOrdersInfo" runat="server" Text="Vận chuyển" CssClass="text-purple-500 text-xs md:text-sm"></asp:Label>
                    </div>
                    <div class="w-10 h-10 md:w-12 md:h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                        <i class="fas fa-truck text-purple-600 text-xl md:text-2xl"></i>
                    </div>
                </div>
            </div>
            <div class="bg-white rounded-xl p-4 md:p-6 shadow-sm">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-600 text-sm">Doanh thu hôm nay</p>
                        <asp:Label ID="lblTodayRevenue" runat="server" Text="0 VNĐ" CssClass="text-xl md:text-2xl font-bold text-green-600"></asp:Label>
                         <asp:Label ID="lblTodayRevenueChange" runat="server" Text="+0%" CssClass="text-green-500 text-xs md:text-sm"></asp:Label>
                    </div>
                    <div class="w-10 h-10 md:w-12 md:h-12 bg-green-100 rounded-lg flex items-center justify-center">
                        <i class="fas fa-chart-line text-green-600 text-xl md:text-2xl"></i>
                    </div>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-xl shadow-sm p-4 md:p-6 mb-6">
            <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4 items-end">
                <div class="relative">
                    <label for="txtSearchOrders" class="block text-sm font-medium text-gray-700 mb-1">Tìm kiếm</label>
                    <asp:TextBox ID="txtSearchOrders" runat="server" placeholder="Mã ĐH, Tên KH..." CssClass="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-primary w-full"></asp:TextBox>
                    <i class="fas fa-search absolute left-3 bottom-2.5 text-gray-400"></i>
                </div>
                <div>
                    <label for="ddlStatusFilter" class="block text-sm font-medium text-gray-700 mb-1">Trạng thái</label>
                    <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary">
                        <asp:ListItem Value="">Tất cả trạng thái</asp:ListItem>
                        <%-- Add status items from code-behind or statically --%>
                    </asp:DropDownList>
                </div>
                <div>
                     <label for="ddlPaymentFilter" class="block text-sm font-medium text-gray-700 mb-1">Thanh toán</label>
                    <asp:DropDownList ID="ddlPaymentFilter" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary">
                        <asp:ListItem Value="">PT Thanh toán</asp:ListItem>
                        <%-- Add payment method items --%>
                    </asp:DropDownList>
                </div>
                 <div>
                    <label for="txtDateFilter" class="block text-sm font-medium text-gray-700 mb-1">Ngày đặt</label>
                    <asp:TextBox ID="txtDateFilter" runat="server" TextMode="Date" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary"></asp:TextBox>
                </div>
                <div class="flex space-x-2">
                    <asp:Button ID="btnApplyOrderFilters" runat="server" Text="Lọc" OnClick="btnApplyOrderFilters_Click" CssClass="w-full sm:w-auto px-4 py-2 bg-secondary text-white rounded-lg hover:bg-opacity-90" />
                    <asp:Button ID="btnResetOrderFilters" runat="server" Text="Reset" OnClick="btnResetOrderFilters_Click" CssClass="w-full sm:w-auto px-4 py-2 bg-gray-500 hover:bg-gray-600 text-white rounded-lg" CausesValidation="false" />
                </div>
            </div>
        </div>

        <div class="space-y-4" id="ordersListContainer">
            <asp:Repeater ID="rptOrders" runat="server" OnItemCommand="rptOrders_ItemCommand">
                <ItemTemplate>
                    <div class="order-card-admin bg-white rounded-xl shadow-sm overflow-hidden">
                        <div class="p-4 md:p-6">
                            <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between space-y-4 lg:space-y-0">
                                <div class="flex-1">
                                    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-3">
                                        <div>
                                            <h3 class="text-base md:text-lg font-bold text-gray-800"><%# Eval("OrderCode") %></h3>
                                            <p class="text-gray-600 text-xs md:text-sm"><%# Eval("OrderDate", "{0:dd/MM/yyyy - HH:mm}") %></p>
                                        </div>
                                        <span class='status-badge self-start sm:self-center mt-2 sm:mt-0'><%# Eval("StatusText") %></span>
                                    </div>
                                    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-3 text-xs md:text-sm">
                                        <div>
                                            <p class="text-gray-500 uppercase tracking-wide text-2xs">Khách hàng</p>
                                            <p class="font-medium"><%# Eval("CustomerName") %></p>
                                            <p class="text-gray-500"><%# Eval("CustomerPhone") %></p>
                                        </div>
                                        <div>
                                            <p class="text-gray-500 uppercase tracking-wide text-2xs">Sản phẩm</p>
                                            <p class="font-medium truncate" title='<%# Eval("ProductSummary") %>'><%# Eval("ProductSummary") %></p>
                                            <p class="text-gray-500"><%# Eval("TotalItems") %> sản phẩm</p>
                                        </div>
                                        <div>
                                            <p class="text-gray-500 uppercase tracking-wide text-2xs">Tổng tiền</p>
                                            <p class="font-bold text-green-600"><%# Eval("TotalAmount", "{0:N0}đ") %></p>
                                            <p class='text-gray-500 <%# (Eval("PaymentStatus")?.ToString() == "Đã thanh toán" ? "text-green-600" : "text-orange-500") %>'><%# Eval("PaymentStatus") %></p>
                                        </div>
                                        <div>
                                            <p class="text-gray-500 uppercase tracking-wide text-2xs">Thanh toán</p>
                                            <p class="font-medium"><%# Eval("PaymentMethod") %></p>
                                        </div>
                                    </div>
                                </div>
                                <div class="flex flex-col sm:flex-row items-stretch sm:items-center space-y-2 sm:space-y-0 sm:space-x-2 lg:ml-6 pt-3 lg:pt-0 border-t lg:border-t-0">
                                    <asp:LinkButton ID="btnViewDetails" runat="server" CommandName="ViewDetails" CommandArgument='<%# Eval("OrderId") %>' CssClass="bg-primary hover:bg-opacity-90 text-white px-3 py-2 rounded-lg text-sm transition-colors flex items-center justify-center"><i class="fas fa-eye mr-1"></i>Chi tiết</asp:LinkButton>
                                    <asp:LinkButton ID="btnPrintOrderCard" runat="server" CommandName="PrintOrder" CommandArgument='<%# Eval("OrderId") %>' CssClass="bg-blue-500 hover:bg-blue-600 text-white px-3 py-2 rounded-lg text-sm transition-colors flex items-center justify-center"><i class="fas fa-print mr-1"></i>In</asp:LinkButton>
                                    <%-- Update Status Dropdown or Button leading to modal section --%>
                                     <div class="relative">
                                         <asp:DropDownList ID="ddlUpdateStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlUpdateStatus_SelectedIndexChanged" CommandArgument='<%# Eval("OrderId") %>' CssClass="w-full sm:w-auto bg-gray-200 text-gray-700 px-3 py-2 rounded-lg text-sm appearance-none focus:outline-none focus:border-primary">
                                             <asp:ListItem Value="" Text="-- Cập nhật TT --" Selected="True"></asp:ListItem>
                                              <%-- Populate from code-behind or static --%>
                                         </asp:DropDownList>
                                     </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
                 <FooterTemplate>
                    <asp:Panel ID="pnlNoOrders" runat="server" Visible='<%# rptOrders.Items.Count == 0 %>' CssClass="text-center py-10">
                        <p class="text-gray-500">Không có đơn hàng nào phù hợp với bộ lọc.</p>
                    </asp:Panel>
                </FooterTemplate>
            </asp:Repeater>
        </div>

        <div class="flex flex-col sm:flex-row items-center justify-between mt-6 space-y-4 sm:space-y-0">
            <asp:Label ID="lblOrderPageInfo" runat="server" CssClass="text-sm text-gray-500"></asp:Label>
            <div class="flex items-center space-x-1">
                <asp:LinkButton ID="lnkOrderPrevPage" runat="server" OnClick="OrderPage_Changed" CommandArgument="Prev" CssClass="px-3 py-2 border border-gray-300 rounded-lg text-sm hover:bg-gray-50"><i class="fas fa-chevron-left"></i></asp:LinkButton>
                <asp:Repeater ID="rptOrderPager" runat="server" OnItemCommand="OrderPage_Changed">
                    <ItemTemplate>
                        <asp:LinkButton ID="lnkOrderPageNumber" runat="server" Text='<%# Eval("Text") %>' CommandName="Page" CommandArgument='<%# Eval("Value") %>' CssClass='<%# Convert.ToBoolean(Eval("IsCurrent")) ? "px-3 py-2 bg-primary text-white rounded-lg text-sm" : "px-3 py-2 border border-gray-300 rounded-lg text-sm hover:bg-gray-50" %>'></asp:LinkButton>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:LinkButton ID="lnkOrderNextPage" runat="server" OnClick="OrderPage_Changed" CommandArgument="Next" CssClass="px-3 py-2 border border-gray-300 rounded-lg text-sm hover:bg-gray-50"><i class="fas fa-chevron-right"></i></asp:LinkButton>
            </div>
        </div>
    </div>
    
    <asp:Panel ID="pnlOrderDetailModal" runat="server" Visible="false" CssClass="modal-admin-fixed fixed inset-0 bg-black bg-opacity-50 z-[60] flex items-center justify-center p-4">
        <div class="bg-white rounded-xl w-full max-w-6xl shadow-xl flex flex-col">
            <div class="p-4 md:p-6 border-b border-gray-200 flex items-center justify-between print-hidden-order">
                <h2 class="text-lg md:text-xl font-bold text-gray-800">Chi tiết đơn hàng <asp:Label ID="lblModalOrderId" runat="server"></asp:Label></h2>
                <asp:LinkButton ID="btnCloseOrderDetailModal" runat="server" OnClick="btnCloseOrderDetailModal_Click" CssClass="text-gray-400 hover:text-gray-600" CausesValidation="false"><i class="fas fa-times text-xl"></i></asp:LinkButton>
            </div>
            <div class="p-4 md:p-6 modal-body-orders-scrollable print-area-order">
                <%-- Invoice Header for Print --%>
                <div class="print-only mb-6 text-center" style="display:none;"> <%-- Hidden by default, shown by print CSS --%>
                    <h1 class="text-3xl font-bold text-primary">ToyLand</h1>
                    <p class="text-gray-600">Shop Đồ Chơi Trẻ Em</p>
                    <p class="text-sm text-gray-500">123 Đường ABC, Quận 1, TP.HCM | ĐT: 0987 654 321</p>
                    <hr class="my-4"/>
                    <h2 class="text-2xl font-bold mb-2">HÓA ĐƠN BÁN HÀNG</h2>
                </div>

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    <div class="lg:col-span-1">
                        <h3 class="text-base md:text-lg font-semibold text-gray-800 mb-4">Trạng thái đơn hàng</h3>
                        <div class="timeline-admin">
                           <asp:Repeater ID="rptOrderStatusTimeline" runat="server">
                               <ItemTemplate>
                                   <div class='timeline-item-admin <%# Eval("CssClass") %>'>
                                       <h4 class="font-medium text-gray-800 text-sm md:text-base"><%# Eval("StatusName") %></h4>
                                       <p class="text-xs md:text-sm text-gray-500"><%# Eval("StatusDate", "{0:dd/MM/yyyy - HH:mm}") %></p>
                                       <asp:Literal ID="litStatusNotes" runat="server" Text='<%# Eval("Notes") %>' Visible='<%# !string.IsNullOrEmpty(Eval("Notes")?.ToString()) %>'></asp:Literal>
                                   </div>
                               </ItemTemplate>
                           </asp:Repeater>
                        </div>
                    </div>
                    <div class="lg:col-span-2">
                        <div class="space-y-6">
                            <div class="bg-gray-50 rounded-lg p-4">
                                <h3 class="text-base md:text-lg font-semibold text-gray-800 mb-3">Thông tin khách hàng</h3>
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                                    <div><p class="text-gray-500">Họ tên:</p><asp:Label ID="lblModalCustomerName" runat="server" CssClass="font-medium"></asp:Label></div>
                                    <div><p class="text-gray-500">Điện thoại:</p><asp:Label ID="lblModalCustomerPhone" runat="server" CssClass="font-medium"></asp:Label></div>
                                    <div class="md:col-span-2"><p class="text-gray-500">Email:</p><asp:Label ID="lblModalCustomerEmail" runat="server" CssClass="font-medium"></asp:Label></div>
                                    <div class="md:col-span-2"><p class="text-gray-500">Địa chỉ giao hàng:</p><asp:Label ID="lblModalShippingAddress" runat="server" CssClass="font-medium"></asp:Label></div>
                                     <div class="md:col-span-2"><p class="text-gray-500">Ghi chú đơn hàng:</p><asp:Label ID="lblModalOrderNotes" runat="server" CssClass="font-medium italic"></asp:Label></div>
                                </div>
                            </div>
                            <div>
                                <h3 class="text-base md:text-lg font-semibold text-gray-800 mb-3">Sản phẩm đã đặt</h3>
                                <div class="space-y-3">
                                    <asp:Repeater ID="rptModalOrderItems" runat="server">
                                        <ItemTemplate>
                                            <div class="flex items-center space-x-3 p-3 border border-gray-200 rounded-lg">
                                                <asp:Image ID="imgModalItem" runat="server" ImageUrl='<%# Eval("ImageUrl", "https://api.placeholder.com/80/80?text=Toy") %>' AlternateText='<%# Eval("ProductName") %>' CssClass="w-16 h-16 rounded-lg object-cover print-hidden-order" />
                                                <div class="flex-1">
                                                    <h4 class="font-medium text-gray-800 text-sm"><%# Eval("ProductName") %></h4>
                                                    <p class="text-xs text-gray-500">SKU: <%# Eval("SKU") %></p>
                                                    <p class="text-xs text-gray-500">SL: <%# Eval("Quantity") %></p>
                                                </div>
                                                <div class="text-right">
                                                    <p class="font-semibold text-gray-800 text-sm"><%# Eval("TotalPrice", "{0:N0}đ") %></p>
                                                    <p class="text-xs text-gray-500">(<%# Eval("UnitPrice", "{0:N0}đ") %> x <%# Eval("Quantity") %>)</p>
                                                </div>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </div>
                            <div class="bg-gray-50 rounded-lg p-4">
                                <h3 class="text-base md:text-lg font-semibold text-gray-800 mb-3">Thông tin thanh toán</h3>
                                 <div class="space-y-1 text-sm">
                                    <div class="flex justify-between"><span class="text-gray-600">Tạm tính:</span><asp:Label ID="lblModalSubtotal" runat="server" CssClass="font-medium"></asp:Label></div>
                                    <div class="flex justify-between"><span class="text-gray-600">Phí vận chuyển:</span><asp:Label ID="lblModalShippingFee" runat="server" CssClass="font-medium"></asp:Label></div>
                                    <div class="flex justify-between"><span class="text-gray-600">Giảm giá:</span><asp:Label ID="lblModalDiscount" runat="server" CssClass="font-medium text-red-500"></asp:Label></div>
                                    <hr class="my-2">
                                    <div class="flex justify-between text-base font-bold"><span >Tổng cộng:</span><asp:Label ID="lblModalTotalAmount" runat="server" CssClass="text-green-600"></asp:Label></div>
                                    <div class="flex justify-between items-center mt-2"><span class="text-gray-600">Phương thức:</span><asp:Label ID="lblModalPaymentMethod" runat="server" CssClass="px-2 py-1 rounded-full text-xs"></asp:Label></div>
                                    <div class="flex justify-between items-center"><span class="text-gray-600">Trạng thái TT:</span><asp:Label ID="lblModalPaymentStatus" runat="server" CssClass="px-2 py-1 rounded-full text-xs"></asp:Label></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="p-4 md:p-6 border-t border-gray-200 bg-gray-50 flex flex-col sm:flex-row justify-end space-y-2 sm:space-y-0 sm:space-x-3 print-hidden-order">
                <asp:Button ID="btnModalClose" runat="server" Text="Đóng" OnClick="btnCloseOrderDetailModal_Click" CssClass="w-full sm:w-auto px-6 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50" CausesValidation="false" />
                <asp:Button ID="btnModalPrint" runat="server" Text="In hóa đơn" OnClientClick="printOrderDetailFromModal(); return false;" CssClass="w-full sm:w-auto px-6 py-2 bg-blue-500 hover:bg-blue-600 text-white rounded-lg" />
                <asp:HyperLink ID="lnkModalTracking" runat="server" Text="Tracking" Target="_blank" CssClass="w-full sm:w-auto px-6 py-2 bg-green-500 hover:bg-green-600 text-white rounded-lg text-center inline-flex items-center justify-center"><i class="fas fa-truck mr-2"></i>Tracking</asp:HyperLink>
                 <div class="relative w-full sm:w-auto">
                     <asp:DropDownList ID="ddlModalUpdateStatus" runat="server" CssClass="w-full bg-gray-200 text-gray-700 px-3 py-2 rounded-lg text-sm appearance-none focus:outline-none focus:border-primary">
                         <asp:ListItem Value="" Text="-- Cập nhật TT --"></asp:ListItem>
                         <%-- Options populated from code-behind --%>
                     </asp:DropDownList>
                 </div>
                <asp:Button ID="btnModalUpdateStatus" runat="server" Text="Lưu TT" OnClick="btnModalUpdateStatus_Click" CssClass="w-full sm:w-auto px-4 py-2 bg-secondary text-white rounded-lg hover:bg-opacity-90" />
            </div>
        </div>
    </asp:Panel>
</asp:Content>

<asp:Content ID="AdminScriptsOrders" ContentPlaceHolderID="AdminScriptsContent" runat="server">
    <script type="text/javascript">
        function toggleStatusMenu(orderId) {
            // This function might not be needed if using DropDownList for status update per card
            const menu = document.getElementById(`statusMenu${orderId}`);
            if (menu) menu.classList.toggle('hidden');
        }

        function printOrderDetailFromModal() {
            const modalContent = document.getElementById('<%= pnlOrderDetailModal.ClientID %>').querySelector('.print-area-order');
            if (modalContent) {
                // Temporarily make only the print area visible
                document.querySelectorAll('body > *:not(.print-area-order)').forEach(el => el.classList.add('print-hidden-order-temp'));
                modalContent.style.visibility = 'visible'; // Ensure it is visible
                modalContent.querySelectorAll('.print-hidden-order').forEach(el => el.style.display = 'none');
                
                window.print();
                
                // Restore visibility
                modalContent.querySelectorAll('.print-hidden-order').forEach(el => el.style.display = '');
                document.querySelectorAll('.print-hidden-order-temp').forEach(el => el.classList.remove('print-hidden-order-temp'));
            }
        }
        
        document.addEventListener('DOMContentLoaded', function () {
            // Active state for mobile bottom nav
            const currentPath = window.location.pathname.toLowerCase();
            const bottomNavLinks = document.querySelectorAll('.bottom-nav .nav-item');
            let orderLinkManuallyActivated = false;

            bottomNavLinks.forEach(link => {
                const linkHref = link.getAttribute('href');
                if (!linkHref) return;
                const linkPath = new URL(linkHref, window.location.origin).pathname.toLowerCase();
                
                if (currentPath.includes('orders.aspx') && linkPath.includes('orders.aspx')) { // Assuming Orders.aspx is the target
                    link.classList.add('active');
                    link.classList.remove('text-gray-600');
                    orderLinkManuallyActivated = true;
                } else if (!orderLinkManuallyActivated && currentPath === linkPath) {
                    link.classList.add('active');
                    link.classList.remove('text-gray-600');
                } else {
                    link.classList.remove('active');
                     if (!link.classList.contains('active')) {
                        link.classList.add('text-gray-600');
                    }
                }
            });

            // Close dropdowns for status update when clicking outside
            document.addEventListener('click', function(event) {
                const openMenus = document.querySelectorAll('[id^="statusMenu"]:not(.hidden)');
                openMenus.forEach(menu => {
                    const button = menu.previousElementSibling; // Assuming button is just before menu
                    if (button && !button.contains(event.target) && !menu.contains(event.target)) {
                        menu.classList.add('hidden');
                    }
                });
            });
        });
    </script>
</asp:Content>