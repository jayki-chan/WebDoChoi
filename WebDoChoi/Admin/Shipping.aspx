<%@ Page Title="Quản lý Vận chuyển - ToyLand Admin" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="Shipping.aspx.cs" Inherits="WebsiteDoChoi.Admin.Shipping" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitleContent" runat="server">
    <h1 class="text-xl md:text-2xl font-bold text-gray-800">Quản lý Vận chuyển</h1>
</asp:Content>

<asp:Content ID="AdminHeadShipping" ContentPlaceHolderID="AdminHeadContent" runat="server">
    <%-- Chart.js is in Admin.Master --%>
    <style>
        .shipping-card-admin { transition: all 0.2s ease-out; border-left: 4px solid transparent; }
        .shipping-card-admin:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0,0,0,0.07); }
        .shipping-card-admin.active { border-left-color: #4ECDC4; /* secondary */ }
        .shipping-card-admin.inactive { border-left-color: #FF6B6B; /* primary */ opacity: 0.75; }

        .modal-admin-shipping { backdrop-filter: blur(5px); }
        .chart-container-admin-shipping { position: relative; height: 280px; }
        
        .tab-button-shipping.active { border-bottom-color: #FF6B6B; color: #FF6B6B; font-weight: 600; }
        .tab-button-shipping { border-bottom-width: 2px; border-color: transparent; padding-bottom: 0.75rem; margin-bottom: -2px; /* Align with border bottom */ }
        
        .modal-body-shipping-scrollable { max-height: calc(100vh - 200px); overflow-y: auto; }
        .modal-body-shipping-scrollable::-webkit-scrollbar { width: 6px; }
        .modal-body-shipping-scrollable::-webkit-scrollbar-track { background: #f1f5f9; }
        .modal-body-shipping-scrollable::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius:3px; }

        .tracking-timeline-admin { position: relative; }
        .tracking-timeline-admin::before { content: ''; position: absolute; left: 0.625rem; /* 10px */ top: 0; bottom: 0; width: 2px; background: #e5e7eb; } /* Tailwind gray-200 */
        .tracking-step-admin { position: relative; padding-left: 2rem; /* Increased padding */ margin-bottom: 1rem; }
        .tracking-step-admin::before { content: ''; position: absolute; left: 0.375rem; /* Adjusted for larger dot */ top: 0.375rem; width: 0.75rem; /* 12px */ height: 0.75rem; background: #cbd5e0; /* Tailwind gray-300 */ border-radius: 50%; z-index: 1; border: 2px solid white; }
        .tracking-step-admin.completed::before { background-color: #10B981; /* Tailwind green-600 */ }
        .tracking-step-admin.current::before { background-color: #3B82F6; /* Tailwind blue-500 */ animation: pulseAdminShipping 1.5s infinite; }
         @keyframes pulseAdminShipping { 0%, 100% { box-shadow: 0 0 0 0 rgba(59, 130, 246, 0.4); } 70% { box-shadow: 0 0 0 8px rgba(59, 130, 246, 0); } }

        .partner-logo-admin { width: 48px; height: 48px; object-fit: contain; border-radius: 0.375rem; background: #f8fafc; padding: 4px; border:1px solid #e5e7eb; }

         .print-area-shipping-invoice { display: none; } /* Hidden by default */
         @media print {
            body * { visibility: hidden; }
            .print-area-shipping-invoice, .print-area-shipping-invoice * { visibility: visible; }
            .print-area-shipping-invoice { position: absolute; left: 0; top: 0; width: 100%; padding: 15px; font-size: 11pt; }
            .print-hidden-shipping { display: none !important; }
            .print-area-shipping-invoice table { width: 100%; border-collapse: collapse; margin-bottom: 10px; }
            .print-area-shipping-invoice th, .print-area-shipping-invoice td { border: 1px solid #bbb; padding: 5px; text-align: left; }
            .print-area-shipping-invoice h1, .print-area-shipping-invoice h2 { margin-bottom: 5px; }
         }

    </style>
</asp:Content>

<asp:Content ID="MainAdminContentShipping" ContentPlaceHolderID="AdminMainContent" runat="server">
     <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <asp:UpdatePanel ID="upnlShippingPage" runat="server">
        <ContentTemplate>
            <div class="bg-white shadow-sm px-4 md:px-6 py-3 border-b border-gray-200">
                <div class="flex items-center justify-between">
                    <h2 class="text-lg font-semibold text-gray-700">Cài đặt Vận chuyển</h2>
                    <div class="flex items-center space-x-2">
                        <span class="hidden sm:inline">Tính phí</span>
                        <span class="hidden sm:inline">Thêm PTVC</span>
                    </div>
                </div>
            </div>

            <div class="p-4 md:p-6">
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 md:gap-6 mb-6">
                    <div class="stats-card-primary rounded-xl p-3 md:p-4 text-white"><div class="flex items-center justify-between"><div><p class="text-white text-opacity-80 text-xs">Đơn chờ giao</p><asp:Label ID="lblPendingShipments" runat="server" Text="0" CssClass="text-lg font-bold"></asp:Label></div><div class="w-8 h-8 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-box-open text-base"></i></div></div></div>
                    <div class="stats-card-secondary rounded-xl p-3 md:p-4 text-white"><div class="flex items-center justify-between"><div><p class="text-white text-opacity-80 text-xs">Đang vận chuyển</p><asp:Label ID="lblInTransit" runat="server" Text="0" CssClass="text-lg font-bold"></asp:Label></div><div class="w-8 h-8 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-truck-loading text-base"></i></div></div></div>
                    <div class="stats-card-success rounded-xl p-3 md:p-4 text-white"><div class="flex items-center justify-between"><div><p class="text-white text-opacity-80 text-xs">Đã giao thành công</p><asp:Label ID="lblDeliveredCount" runat="server" Text="0" CssClass="text-lg font-bold"></asp:Label></div><div class="w-8 h-8 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-check-circle text-base"></i></div></div></div>
                    <div class="stats-card-dark rounded-xl p-3 md:p-4 text-white"><div class="flex items-center justify-between"><div><p class="text-white text-opacity-80 text-xs">Tổng phí tháng này</p><asp:Label ID="lblTotalShippingCostMonth" runat="server" Text="0 VNĐ" CssClass="text-lg font-bold"></asp:Label></div><div class="w-8 h-8 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-dollar-sign text-base"></i></div></div></div>
                </div>

                <div class="bg-white rounded-xl shadow-sm mb-6">
                    <div class="border-b border-gray-200">
                        <nav class="flex flex-wrap -mb-px">
                            <asp:LinkButton ID="tabBtnMethods" runat="server" OnClick="ShippingTab_Click" CommandArgument="Methods" Text="Phương thức vận chuyển" CssClass="tab-button-shipping py-3 px-4 text-sm font-medium whitespace-nowrap"></asp:LinkButton>
                            <asp:LinkButton ID="tabBtnZones" runat="server" OnClick="ShippingTab_Click" CommandArgument="Zones" Text="Khu vực giao hàng" CssClass="tab-button-shipping py-3 px-4 text-sm font-medium whitespace-nowrap"></asp:LinkButton>
                            <asp:LinkButton ID="tabBtnPartners" runat="server" OnClick="ShippingTab_Click" CommandArgument="Partners" Text="Đối tác vận chuyển" CssClass="tab-button-shipping py-3 px-4 text-sm font-medium whitespace-nowrap"></asp:LinkButton>
                            <asp:LinkButton ID="tabBtnTracking" runat="server" OnClick="ShippingTab_Click" CommandArgument="Tracking" Text="Theo dõi đơn hàng" CssClass="tab-button-shipping py-3 px-4 text-sm font-medium whitespace-nowrap"></asp:LinkButton>
                        </nav>
                    </div>
                </div>

                <asp:Panel ID="pnlMethodsTab" runat="server" Visible="true">
                     <div class="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-4 md:gap-6">
                         <asp:Repeater ID="rptShippingMethods" runat="server" OnItemCommand="ShippingMethod_Command">
                             <ItemTemplate>
                                 <div class='shipping-card-admin bg-white rounded-xl shadow-sm p-4 <%# Convert.ToBoolean(Eval("IsActive")) ? "active" : "inactive" %>'>
                                     <div class="flex items-start justify-between mb-3">
                                        <div class="flex items-center space-x-3">
                                            <div class='w-10 h-10 <%# Eval("IconBgCss") %> rounded-lg flex items-center justify-center text-white text-lg'><i class='<%# Eval("IconCss") %>'></i></div>
                                            <div>
                                                <h3 class="font-semibold text-gray-800"><%# Eval("MethodName") %></h3>
                                                <p class="text-sm text-gray-600"><%# Eval("EstimatedTime") %></p>
                                            </div>
                                        </div>
                                        <div class="flex items-center space-x-2">
                                            <span class='text-xs px-2 py-1 rounded-full <%# Convert.ToBoolean(Eval("IsActive")) ? "bg-green-100 text-green-800" : "bg-red-100 text-red-800" %>'><%# Convert.ToBoolean(Eval("IsActive")) ? "Hoạt động" : "Tạm dừng" %></span>
                                             <div class="relative">
                                                <asp:LinkButton ID="btnMethodActions" runat="server" CommandName="ToggleDropdown" CommandArgument='<%# Eval("MethodId") %>' OnClientClick='<%# "toggleAdminDropdown(event, \"method-dropdown-" + Eval("MethodId") + "\"); return false;" %>' CssClass="text-gray-400 hover:text-gray-600"><i class="fas fa-ellipsis-v"></i></asp:LinkButton>
                                                <div id='<%# "method-dropdown-" + Eval("MethodId") %>' class="hidden absolute right-0 mt-1 w-44 bg-white rounded-md shadow-lg border z-20">
                                                    <asp:LinkButton ID="btnEditMethod" runat="server" CommandName="EditMethod" CommandArgument='<%# Eval("MethodId") %>' CssClass="w-full text-left block px-3 py-2 text-sm text-gray-700 hover:bg-gray-100"><i class="fas fa-edit w-4 mr-2"></i>Sửa</asp:LinkButton>
                                                    <asp:LinkButton ID="btnViewStatsMethod" runat="server" CommandName="ViewStats" CommandArgument='<%# Eval("MethodId") %>' CssClass="w-full text-left block px-3 py-2 text-sm text-gray-700 hover:bg-gray-100"><i class="fas fa-chart-line w-4 mr-2"></i>Thống kê</asp:LinkButton>
                                                    <asp:LinkButton ID="btnToggleStatusMethod" runat="server" CommandName="ToggleStatus" CommandArgument='<%# Eval("MethodId") + "," + Eval("IsActive") %>' CssClass="w-full text-left block px-3 py-2 text-sm text-gray-700 hover:bg-gray-100"><i class='<%# Convert.ToBoolean(Eval("IsActive")) ? "fas fa-toggle-off" : "fas fa-toggle-on" %> w-4 mr-2'></i><%# Convert.ToBoolean(Eval("IsActive")) ? "Tạm dừng" : "Kích hoạt" %></asp:LinkButton>
                                                    <hr class="my-0.5" />
                                                    <span>Xóa</span>
                                                </div>
                                            </div>
                                        </div>
                                     </div>
                                     <div class="grid grid-cols-2 gap-3 mb-3 text-center">
                                        <div class="p-2 bg-gray-50 rounded-lg"><p class="text-md font-bold text-gray-700"><%# Eval("BaseCost", "{0:N0}đ") %></p><p class="text-2xs text-gray-500">Phí cơ bản</p></div>
                                        <div class="p-2 bg-gray-50 rounded-lg"><p class="text-md font-bold text-blue-600"><%# Eval("CostPerKg", "{0:N0}đ/kg") %></p><p class="text-2xs text-gray-500">Theo KL</p></div>
                                     </div>
                                     <div class="text-xs text-gray-500 flex justify-between"><span>Cập nhật: <%# Eval("LastUpdated", "{0:dd/MM/yy}") %></span> <span><%# Eval("OrderCountThisMonth") %> đơn</span></div>
                                 </div>
                             </ItemTemplate>
                              <FooterTemplate><asp:Panel ID="pnlNoMethods" runat="server" Visible='<%# rptShippingMethods.Items.Count == 0 %>' CssClass="col-span-full text-center py-10 text-gray-500">Chưa có phương thức vận chuyển nào.</asp:Panel></FooterTemplate>
                         </asp:Repeater>
                     </div>
                </asp:Panel>
                
                <asp:Panel ID="pnlZonesTab" runat="server" Visible="false">
                     <div class="bg-white rounded-xl shadow-sm p-4 md:p-6 mb-6">
                         <div class="flex items-center justify-between mb-4">
                            <h3 class="text-lg font-bold text-gray-800">Khu vực giao hàng đã cấu hình</h3>
                            <span>Thêm khu vực</span>
                         </div>
                         <asp:Repeater ID="rptShippingZones" runat="server" OnItemCommand="ShippingZone_Command">
                             <ItemTemplate>
                                 <div class="zone-card border border-gray-200 rounded-lg p-3 mb-3 hover:shadow-md">
                                     <div class="flex items-center justify-between">
                                         <div class="flex items-center space-x-3">
                                            <div class="w-8 h-8 bg-blue-100 rounded-lg flex items-center justify-center"><i class="fas fa-map-marked-alt text-blue-600"></i></div>
                                            <div>
                                                <h4 class="font-semibold text-gray-700"><%# Eval("ZoneName") %></h4>
                                                <p class="text-xs text-gray-500"><%# Eval("RegionsDescription") %></p>
                                            </div>
                                         </div>
                                         <div class="flex items-center space-x-2">
                                            <span class='text-2xs px-2 py-0.5 rounded-full <%# Convert.ToBoolean(Eval("IsActive")) ? "bg-green-100 text-green-700" : "bg-red-100 text-red-700" %>'><%# Convert.ToBoolean(Eval("IsActive")) ? "Hoạt động" : "Tạm dừng" %></span>
                                            <asp:LinkButton ID="btnEditZone" runat="server" CommandName="EditZone" CommandArgument='<%# Eval("ZoneId") %>' CssClass="text-gray-400 hover:text-primary" ToolTip="Sửa"><i class="fas fa-edit"></i></asp:LinkButton>
                                            <span>Xóa</span>
                                         </div>
                                     </div>
                                      <div class="mt-2 pl-11 text-xs text-gray-600">Phí: <%# Eval("BaseFee", "{0:N0}đ") %> + <%# Eval("FeePerUnit", "{0:N0}đ") %>/<%# Eval("UnitName") %> | TG: <%# Eval("EstimatedDeliveryTime") %></div>
                                 </div>
                             </ItemTemplate>
                             <FooterTemplate><asp:Panel runat="server" Visible='<%# rptShippingZones.Items.Count == 0 %>'><p class="text-sm text-gray-500 py-4 text-center">Chưa có khu vực nào được cấu hình.</p></asp:Panel></FooterTemplate>
                         </asp:Repeater>
                     </div>
                     <div class="bg-white rounded-xl shadow-sm p-4 md:p-6"><h3 class="text-lg font-bold text-gray-800 mb-4">Thống kê giao hàng theo Khu vực</h3><div class="chart-container-admin h-[250px]"><canvas id="adminZoneChart"></canvas></div></div>
                </asp:Panel>

                <asp:Panel ID="pnlPartnersTab" runat="server" Visible="false">
                     <div class="bg-white rounded-xl shadow-sm p-4 md:p-6 mb-6">
                         <div class="flex items-center justify-between mb-4">
                            <h3 class="text-lg font-bold text-gray-800">Đối tác vận chuyển</h3>
                            <span>Thêm đối tác</span>
                         </div>
                         <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <asp:Repeater ID="rptShippingPartners" runat="server" OnItemCommand="ShippingPartner_Command">
                                <ItemTemplate>
                                    <div class="bg-gray-50 rounded-lg p-4 border hover:shadow-md">
                                        <div class="flex items-center justify-between">
                                            <div class="flex items-center space-x-3">
                                                <asp:Image ID="imgPartnerLogo" runat="server" ImageUrl='<%# Eval("LogoUrl") %>' AlternateText='<%# Eval("PartnerName") %>' CssClass="partner-logo-admin" />
                                                <div><h4 class="font-semibold text-gray-700"><%# Eval("PartnerName") %></h4><p class="text-xs text-gray-500"><%# Eval("IntegrationType") %></p></div>
                                            </div>
                                            <span class='text-2xs px-2 py-0.5 rounded-full <%# Convert.ToBoolean(Eval("IsConnected")) ? "bg-green-100 text-green-700" : "bg-red-100 text-red-700" %>'><%# Convert.ToBoolean(Eval("IsConnected")) ? "Đã kết nối" : "Chưa kết nối" %></span>
                                        </div>
                                        <div class="grid grid-cols-2 gap-2 mt-3 text-center text-xs">
                                            <div class="bg-white p-2 rounded"><p class="font-medium text-gray-700"><%# Eval("OrdersThisMonth") %></p><p class="text-gray-500">Đơn tháng</p></div>
                                            <div class="bg-white p-2 rounded"><p class="font-medium text-green-600"><%# Eval("SuccessRate", "{0:F1}%") %></p><p class="text-gray-500">Thành công</p></div>
                                        </div>
                                         <div class="text-xs text-gray-500 mt-2">Phí TB: <%# Eval("AverageCost", "{0:N0}đ") %> | TG Giao TB: <%# Eval("AverageTimeDays", "{0:F1} ngày") %></div>
                                        <div class="mt-3 pt-2 border-t flex justify-end space-x-2">
                                            <asp:LinkButton ID="btnConfigurePartner" runat="server" CommandName="Configure" CommandArgument='<%# Eval("PartnerId") %>' CssClass="text-primary hover:underline text-xs"><i class="fas fa-cog"></i> Cấu hình</asp:LinkButton>
                                            <span>Xóa</span>
                                        </div>
                                    </div>
                                </ItemTemplate>
                                 <FooterTemplate><asp:Panel runat="server" Visible='<%# rptShippingPartners.Items.Count == 0 %>'><p class="text-sm text-gray-500 py-4 text-center">Chưa có đối tác vận chuyển nào.</p></asp:Panel></FooterTemplate>
                            </asp:Repeater>
                         </div>
                     </div>
                     <div class="bg-white rounded-xl shadow-sm p-4 md:p-6"><h3 class="text-lg font-bold text-gray-800 mb-4">So sánh hiệu suất đối tác</h3><div class="chart-container-admin h-[250px]"><canvas id="adminPartnerChart"></canvas></div></div>
                </asp:Panel>
                
                <asp:Panel ID="pnlTrackingTab" runat="server" Visible="false">
                     <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                        <div class="lg:col-span-1 bg-white rounded-xl shadow-sm p-4 md:p-6">
                             <h3 class="text-lg font-bold text-gray-800 mb-4">Tra cứu đơn hàng</h3>
                             <div class="space-y-3">
                                <div><label class="block text-sm font-medium text-gray-700 mb-1">Mã đơn hàng</label><asp:TextBox ID="txtTrackingOrderCode" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary" placeholder="VD: TL202500001"></asp:TextBox></div>
                                <div><label class="block text-sm font-medium text-gray-700 mb-1">Số điện thoại (tùy chọn)</label><asp:TextBox ID="txtTrackingPhone" runat="server" TextMode="Phone" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary"></asp:TextBox></div>
                                <asp:Button ID="btnTrackOrder" runat="server" OnClick="btnTrackOrder_Click" Text="Tra cứu" CssClass="w-full bg-primary hover:bg-opacity-90 text-white py-2 px-4 rounded-lg" />
                             </div>
                             <div class="mt-4">
                                 <h4 class="font-semibold text-gray-700 mb-2 text-sm">Lọc nhanh:</h4>
                                 <div class="space-y-1">
                                    <asp:LinkButton ID="btnFilterShippingPending" runat="server" OnClick="btnFilterTrackingStatus_Click" CommandArgument="pending" CssClass="block w-full text-left text-sm text-gray-600 hover:bg-gray-100 p-2 rounded-md"><i class="fas fa-clock text-yellow-500 w-5 mr-2"></i>Chờ xử lý (<asp:Literal ID="litTrackPendingCount" runat="server">0</asp:Literal>)</asp:LinkButton>
                                    <asp:LinkButton ID="btnFilterShippingInTransit" runat="server" OnClick="btnFilterTrackingStatus_Click" CommandArgument="shipped" CssClass="block w-full text-left text-sm text-gray-600 hover:bg-gray-100 p-2 rounded-md"><i class="fas fa-truck text-blue-500 w-5 mr-2"></i>Đang giao (<asp:Literal ID="litTrackInTransitCount" runat="server">0</asp:Literal>)</asp:LinkButton>
                                     <asp:LinkButton ID="btnFilterShippingProblem" runat="server" OnClick="btnFilterTrackingStatus_Click" CommandArgument="problem" CssClass="block w-full text-left text-sm text-gray-600 hover:bg-gray-100 p-2 rounded-md"><i class="fas fa-exclamation-triangle text-red-500 w-5 mr-2"></i>Có vấn đề (<asp:Literal ID="litTrackProblemCount" runat="server">0</asp:Literal>)</asp:LinkButton>
                                 </div>
                             </div>
                        </div>
                        <div class="lg:col-span-2 bg-white rounded-xl shadow-sm p-4 md:p-6">
                             <asp:Panel ID="pnlTrackingResult" runat="server" Visible="false">
                                 <div class="flex items-center justify-between mb-4">
                                     <h3 class="text-lg font-bold text-gray-800">Kết quả tra cứu: <asp:Label ID="lblTrackedOrderCode" runat="server" CssClass="text-primary"></asp:Label></h3>
                                     <asp:HyperLink ID="hlTrackedOrderDetails" runat="server" CssClass="text-primary text-sm hover:underline">Xem chi tiết đơn</asp:HyperLink>
                                 </div>
                                  <div class="mb-4 p-3 bg-gray-50 rounded-lg text-sm">
                                    <p><strong>Khách hàng:</strong> <asp:Literal ID="litTrackCustomer" runat="server"></asp:Literal></p>
                                    <p><strong>Đối tác VC:</strong> <asp:Literal ID="litTrackPartner" runat="server"></asp:Literal> - Mã VC: <asp:Literal ID="litTrackPartnerCode" runat="server"></asp:Literal></p>
                                    <p><strong>Trạng thái hiện tại:</strong> <asp:Literal ID="litTrackCurrentStatus" runat="server"></asp:Literal></p>
                                </div>
                                 <div class="tracking-timeline-admin max-h-80 overflow-y-auto custom-scrollbar">
                                     <asp:Repeater ID="rptTrackingTimeline" runat="server">
                                         <ItemTemplate>
                                             <div class='tracking-step-admin mb-4 <%# Eval("CssClass") %>'>
                                                 <h4 class="font-medium text-gray-700 text-sm"><%# Eval("StatusName") %></h4>
                                                 <p class="text-xs text-gray-500"><%# Eval("StatusDate", "{0:dd/MM/yyyy - HH:mm}") %></p>
                                                 <p class="text-xs text-gray-600 mt-0.5"><%# Eval("Location") %></p>
                                                  <asp:Literal ID="litTrackNotes" runat="server" Text='<%# Eval("Notes") %>' Visible='<%# !string.IsNullOrEmpty(Eval("Notes")?.ToString()) %>'></asp:Literal>
                                             </div>
                                         </ItemTemplate>
                                     </asp:Repeater>
                                 </div>
                             </asp:Panel>
                             <asp:Panel ID="pnlNoTrackingResult" runat="server" Visible="true" CssClass="text-center py-10 text-gray-500">
                                 <i class="fas fa-search fa-3x mb-3"></i>
                                 <p>Nhập mã đơn hàng hoặc SĐT để tra cứu.</p>
                             </asp:Panel>
                        </div>
                     </div>
                </asp:Panel>
                
                 <asp:Panel ID="pnlRecentOrdersTracking" runat="server" Visible="false" CssClass="mt-6 bg-white rounded-xl shadow-sm">
                     <div class="p-4 md:p-6 border-b border-gray-200"><h3 class="text-lg font-bold text-gray-800">Danh sách đơn hàng (theo bộ lọc)</h3></div>
                     <div class="overflow-x-auto"><asp:GridView ID="gvTrackingOrders" runat="server" AutoGenerateColumns="False" CssClass="w-full table-admin-reports" EmptyDataText="Không có đơn hàng nào." OnRowCommand="gvTrackingOrders_RowCommand"><Columns>
                         <asp:BoundField DataField="OrderCode" HeaderText="Mã ĐH" />
                         <asp:BoundField DataField="CustomerName" HeaderText="Khách hàng" />
                         <asp:BoundField DataField="ShippingPartner" HeaderText="Đối tác VC" />
                         <asp:TemplateField HeaderText="Trạng thái VC"><ItemTemplate><span class='px-2 py-1 text-xs leading-5 font-semibold rounded-full'><%# Eval("ShippingStatusText") %></span></ItemTemplate></asp:TemplateField>
                         <asp:BoundField DataField="LastUpdate" HeaderText="Cập nhật cuối" DataFormatString="{0:dd/MM HH:mm}" />
                         <asp:TemplateField HeaderText="Hành động"><ItemTemplate><asp:LinkButton ID="btnTrackThisOrder" runat="server" CommandName="Track" CommandArgument='<%# Eval("OrderCode") %>' CssClass="text-primary hover:underline text-sm">Tra cứu</asp:LinkButton></ItemTemplate></asp:TemplateField>
                         </Columns></asp:GridView></div>
                 </asp:Panel>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

     <asp:Panel ID="pnlShippingMethodModal" runat="server" Visible="false" CssClass="modal-admin-shipping fixed inset-0 bg-black bg-opacity-60 z-[70] flex items-center justify-center p-4">
        <div class="bg-white rounded-xl w-full max-w-xl shadow-xl flex flex-col">
             <div class="p-4 border-b flex justify-between items-center"><h2 class="text-lg font-bold text-gray-800"><asp:Label ID="lblMethodModalTitle" runat="server"></asp:Label></h2><asp:LinkButton ID="btnCloseMethodModal" runat="server" OnClick="btnCloseMethodModal_Click" CssClass="text-gray-400 hover:text-red-500" CausesValidation="false"><i class="fas fa-times text-xl"></i></asp:LinkButton></div>
             <div class="p-5 space-y-4 modal-body-shipping-scrollable">
                 <asp:HiddenField ID="hfShippingMethodId" runat="server" Value="0" />
                 <div><label class="block text-sm font-medium text-gray-700 mb-1">Tên phương thức *</label><asp:TextBox ID="txtMethodName" runat="server" CssClass="w-full border-gray-300 rounded-md shadow-sm" placeholder="VD: Giao hàng nhanh"></asp:TextBox><asp:RequiredFieldValidator ID="rfvMethodName" runat="server" ControlToValidate="txtMethodName" ErrorMessage="Tên không được trống." Display="Dynamic" CssClass="text-red-500 text-xs mt-1" ValidationGroup="MethodValidation" /></div>
                 <div><label class="block text-sm font-medium text-gray-700 mb-1">Mô tả</label><asp:TextBox ID="txtMethodDescription" runat="server" TextMode="MultiLine" Rows="2" CssClass="w-full border-gray-300 rounded-md shadow-sm"></asp:TextBox></div>
                 <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div><label class="block text-sm font-medium text-gray-700 mb-1">TG Giao hàng ước tính (ngày) *</label><asp:TextBox ID="txtEstimatedDays" runat="server" TextMode="Number" CssClass="w-full border-gray-300 rounded-md shadow-sm" placeholder="3-5"></asp:TextBox><asp:RequiredFieldValidator ID="rfvEstimatedDays" runat="server" ControlToValidate="txtEstimatedDays" ErrorMessage="TG không trống." Display="Dynamic" CssClass="text-red-500 text-xs mt-1" ValidationGroup="MethodValidation" /></div>
                    <div><label class="block text-sm font-medium text-gray-700 mb-1">Icon CSS (FontAwesome)</label><asp:TextBox ID="txtMethodIconCss" runat="server" CssClass="w-full border-gray-300 rounded-md shadow-sm" placeholder="fas fa-shipping-fast"></asp:TextBox></div>
                 </div>
                  <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div><label class="block text-sm font-medium text-gray-700 mb-1">Phí cơ bản (VNĐ) *</label><asp:TextBox ID="txtBaseCost" runat="server" TextMode="Number" step="1000" CssClass="w-full border-gray-300 rounded-md shadow-sm" placeholder="0"></asp:TextBox><asp:RequiredFieldValidator ID="rfvBaseCost" runat="server" ControlToValidate="txtBaseCost" ErrorMessage="Phí không trống." Display="Dynamic" CssClass="text-red-500 text-xs mt-1" ValidationGroup="MethodValidation" /></div>
                    <div><label class="block text-sm font-medium text-gray-700 mb-1">Phí/kg (VNĐ)</label><asp:TextBox ID="txtCostPerKg" runat="server" TextMode="Number" step="500" CssClass="w-full border-gray-300 rounded-md shadow-sm" placeholder="0"></asp:TextBox></div>
                  </div>
                 <div class="mt-3"><asp:CheckBox ID="chkMethodIsActive" runat="server" Text=" Kích hoạt phương thức này" Checked="true" CssClass="text-sm" /></div>
             </div>
             <div class="p-4 bg-gray-50 border-t flex justify-end space-x-2"><asp:Button ID="btnCancelMethodModal" runat="server" Text="Hủy" OnClick="btnCloseMethodModal_Click" CssClass="px-4 py-2 border rounded-md text-sm" CausesValidation="false" /><asp:Button ID="btnSaveShippingMethod" runat="server" Text="Lưu" OnClick="btnSaveShippingMethod_Click" ValidationGroup="MethodValidation" CssClass="px-4 py-2 bg-primary text-white rounded-md text-sm hover:bg-opacity-90" /></div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlRateCalculatorModal" runat="server" Visible="false" CssClass="modal-admin-shipping fixed inset-0 bg-black bg-opacity-60 z-[70] flex items-center justify-center p-4">
         <div class="bg-white rounded-xl w-full max-w-md shadow-xl">
            <div class="rate-calculator p-5 text-white rounded-t-xl flex justify-between items-center">
                <h2 class="text-lg font-semibold">Tính phí vận chuyển</h2>
                <asp:LinkButton ID="btnCloseRateCalculator" runat="server" OnClick="btnCloseRateCalculator_Click" CssClass="text-white opacity-70 hover:opacity-100" CausesValidation="false"><i class="fas fa-times text-xl"></i></asp:LinkButton>
            </div>
            <div class="p-5 space-y-3">
                <div><label class="block text-sm font-medium text-gray-700 mb-1">Trọng lượng (kg)</label><asp:TextBox ID="txtCalcWeight" runat="server" TextMode="Number" step="0.1" CssClass="w-full border-gray-300 rounded-md" placeholder="1.5"></asp:TextBox></div>
                <div><label class="block text-sm font-medium text-gray-700 mb-1">Khu vực</label><asp:DropDownList ID="ddlCalcZone" runat="server" CssClass="w-full border-gray-300 rounded-md"><asp:ListItem Value="">Chọn khu vực</asp:ListItem></asp:DropDownList></div>
                <div><label class="block text-sm font-medium text-gray-700 mb-1">Phương thức</label><asp:DropDownList ID="ddlCalcMethod" runat="server" CssClass="w-full border-gray-300 rounded-md"><asp:ListItem Value="">Chọn PTVC</asp:ListItem></asp:DropDownList></div>
                <asp:Button ID="btnCalculateRate" runat="server" Text="Tính phí" OnClick="btnCalculateRate_Click" CssClass="w-full bg-primary text-white py-2.5 rounded-md hover:bg-opacity-90 font-medium" />
                <asp:Panel ID="pnlRateResult" runat="server" Visible="false" CssClass="mt-3 p-3 bg-gray-100 rounded-md text-center">
                    <p class="text-sm text-gray-600">Phí vận chuyển ước tính</p>
                    <p class="text-xl font-bold text-primary"><asp:Label ID="lblCalculatedRateResult" runat="server"></asp:Label></p>
                    <p class="text-xs text-gray-500 mt-0.5"><asp:Label ID="lblRateBreakdownResult" runat="server"></asp:Label></p>
                </asp:Panel>
            </div>
        </div>
    </asp:Panel>
    
    <asp:Panel ID="pnlDeleteConfirmationModal" runat="server" Visible="false" CssClass="modal-admin-shipping fixed inset-0 bg-black bg-opacity-75 z-[80] flex items-center justify-center p-4">
        <div class="bg-white rounded-xl w-full max-w-sm p-5 shadow-xl text-center">
            <div class="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-3"><i class="fas fa-exclamation-triangle text-red-500 text-xl"></i></div>
            <h3 class="text-md font-semibold text-gray-800 mb-2">Xác nhận xóa</h3>
            <p class="text-sm text-gray-600 mb-5">Bạn có chắc muốn xóa <asp:Literal ID="litDeleteItemName" runat="server"></asp:Literal>? Hành động này không thể hoàn tác.</p>
            <div class="flex space-x-3">
                <asp:Button ID="btnModalCancelDelete" runat="server" Text="Hủy" OnClick="btnModalCancelDelete_Click" CssClass="flex-1 px-4 py-2 border rounded-md text-sm" CausesValidation="false" />
                <asp:Button ID="btnModalConfirmDelete" runat="server" Text="Xóa" OnClick="btnModalConfirmDelete_Click" CssClass="flex-1 px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded-md text-sm" />
                <asp:HiddenField ID="hfDeleteItemId" runat="server" />
                <asp:HiddenField ID="hfDeleteItemType" runat="server" /> <%-- To know what to delete (method, zone, partner) --%>
            </div>
        </div>
    </asp:Panel>
</asp:Content>

<asp:Content ID="AdminScriptsShipping" ContentPlaceHolderID="AdminScriptsContent" runat="server">
     <script type="text/javascript">
        let currentAdminShippingTab = 'methods';
        let adminZoneChartInstance = null;
        let adminPartnerChartInstance = null;
        // Modal visibility is primarily server-controlled via Panel.Visible

        function switchAdminShippingTab(tabName, buttonElement) {
            // Client-side class updates for immediate feedback
            document.querySelectorAll('.tab-button-shipping').forEach(btn => btn.classList.remove('active', 'text-primary', 'border-primary'));
            buttonElement.classList.add('active', 'text-primary', 'border-primary');
        }
        
        function openAdminDeleteConfirmation(itemId, itemName, itemType) {
             document.getElementById('<%= hfDeleteItemId.ClientID %>').value = itemId;
             document.getElementById('<%= hfDeleteItemType.ClientID %>').value = itemType;
             document.getElementById('<%= litDeleteItemName.ClientID %>').innerText = itemName;
             const modal = document.getElementById('<%= pnlDeleteConfirmationModal.ClientID %>');
             if(modal) modal.style.display = 'flex';
             document.body.style.overflow = 'hidden';
             setupModalClose(); // Re-attach close handlers
             return false; // Prevent default linkbutton behavior
         }

        function setupModalClose() { // Generic modal close setup
            document.querySelectorAll('.modal-admin-shipping').forEach(modal => {
                modal.addEventListener('click', function(e) {
                    if (e.target === this) { // Clicked on overlay
                        const closeButton = this.querySelector('button[onclick*="close"]'); // Find a close button
                        if (closeButton && typeof closeButton.click === 'function') closeButton.click(); // Simulate click if it's an ASP button or has JS onclick
                        else this.style.display = 'none'; // Fallback hide
                        document.body.style.overflow = 'auto';
                    }
                });
            });
        }

        document.addEventListener('DOMContentLoaded', function () {
            setupModalClose();
            const initialActiveTabButton = document.getElementById('<%= tabBtnMethods.ClientID %>'); // Default active tab
            if(initialActiveTabButton) switchAdminShippingTab('methods', initialActiveTabButton);

             // Active state for mobile bottom nav
            const currentPath = window.location.pathname.toLowerCase();
            const bottomNavLinks = document.querySelectorAll('.bottom-nav .nav-item');
            let shippingLinkManuallyActivated = false;

            bottomNavLinks.forEach(link => {
                const linkHref = link.getAttribute('href');
                if (!linkHref) return;
                const linkPath = new URL(linkHref, window.location.origin).pathname.toLowerCase();
                
                if (currentPath.includes('shipping.aspx') && linkPath.includes('shipping.aspx')) { 
                    link.classList.add('active');
                    link.classList.remove('text-gray-600');
                    shippingLinkManuallyActivated = true;
                } else if (!shippingLinkManuallyActivated && currentPath === linkPath) {
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

        // ASP.NET AJAX Page Load (for UpdatePanel)
        if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function(sender, args) {
                setupModalClose(); // Re-attach close handlers after UpdatePanel partial postback
                // Re-initialize charts if they are inside the UpdatePanel and need new data
                const activeTab = document.querySelector('.tab-button-shipping.active');
                if(activeTab){
                    if(activeTab.id.includes('Zones') && window.zoneChartData) { // Check if data is available
                         if (adminZoneChartInstance) adminZoneChartInstance.destroy();
                         initAdminZoneChart(window.zoneChartData.labels, window.zoneChartData.data);
                    } else if (activeTab.id.includes('Partners') && window.partnerChartData) {
                         if (adminPartnerChartInstance) adminPartnerChartInstance.destroy();
                         initAdminPartnerChart(window.partnerChartData.labels, window.partnerChartData.datasets);
                    }
                }
            });
        }
        
        // Chart initializations (data passed from server)
        function initAdminZoneChart(labels, data) {
            const ctx = document.getElementById('adminZoneChart');
            if (!ctx) return;
            if (adminZoneChartInstance) adminZoneChartInstance.destroy();
            adminZoneChartInstance = new Chart(ctx.getContext('2d'), {
                type: 'doughnut', data: { labels: labels, datasets: [{ data: data, backgroundColor: ['#3b82f6', '#eab308', '#ef4444', '#10b981', '#8b5cf6'], borderWidth:0 }] },
                options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom', labels: {padding:15, usePointStyle:true, font:{size:11}} } } }
            });
        }
        function initAdminPartnerChart(labels, datasets) {
            const ctx = document.getElementById('adminPartnerChart');
            if (!ctx) return;
            if (adminPartnerChartInstance) adminPartnerChartInstance.destroy();
            adminPartnerChartInstance = new Chart(ctx.getContext('2d'), {
                type: 'bar', data: { labels: labels, datasets: datasets /* [{label:'', data:[], backgroundColor:''}, ...] */ },
                options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'top', labels:{font:{size:11}} } }, scales:{y:{beginAtZero:true, title:{display:true, text:'Số đơn hàng', font:{size:10}}, ticks:{font:{size:10}}}, x:{ticks:{font:{size:10}}}} }
            });
        }
     </script>
</asp:Content>