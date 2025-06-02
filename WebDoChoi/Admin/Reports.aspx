<%@ Page Title="Báo cáo & Thống kê - ToyLand Admin" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="Reports.aspx.cs" Inherits="WebsiteDoChoi.Admin.Reports" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitleContent" runat="server">
    <h1 class="text-xl md:text-2xl font-bold text-gray-800">Báo cáo & Thống kê</h1>
</asp:Content>

<asp:Content ID="AdminHeadReports" ContentPlaceHolderID="AdminHeadContent" runat="server">
    <%-- Chart.js is already in Admin.Master --%>
    <%-- <script src="https://cdn.jsdelivr.net/npm/date-fns@2.29.3/index.min.js"></script> --%> <%-- date-fns for date manipulation in JS if needed --%>
    <style>
        .chart-container-admin { position: relative; height: 300px; }
        .chart-container-large-admin { position: relative; height: 380px; }
        .report-card-admin:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0,0,0,0.07); }
        .report-card-admin { transition: all 0.2s ease-out; }
        
        .stat-card-gradient-primary { background: linear-gradient(135deg, #FF6B6B 0%, #FF8E53 100%); }
        .stat-card-gradient-secondary { background: linear-gradient(135deg, #4ECDC4 0%, #66D9EF 100%); }
        .stat-card-gradient-accent { background: linear-gradient(135deg, #FFE66D 0%, #FFC371 100%); }
        .stat-card-gradient-dark { background: linear-gradient(135deg, #1A535C 0%, #4C6E7A 100%); }
        .stat-card-gradient-success { background: linear-gradient(135deg, #56ab2f 0%, #a8e063 100%); }
        .stat-card-gradient-warning { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }

        .metric-trend-admin { font-size: 0.75rem; font-weight: 500; }
        .metric-trend-admin.up { color: #10B981; } /* Tailwind green-600 */
        .metric-trend-admin.down { color: #EF4444; } /* Tailwind red-500 */
        .metric-trend-admin.neutral { color: #6B7280; } /* Tailwind gray-500 */

        .export-button-admin:hover { transform: scale(1.03); }
        .export-button-admin { transition: transform 0.15s ease-out; }
        .loading-spinner-admin { animation: spin 1s linear infinite; }
        @keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }

        .table-admin-reports th { background-color: #f9fafb; } /* gray-50 */
        .table-admin-reports td, .table-admin-reports th { padding: 0.75rem 1rem; border-bottom: 1px solid #e5e7eb; } /* gray-200 */
        .table-admin-reports tr:hover td { background-color: #f3f4f6; } /* gray-100 */
    </style>
</asp:Content>

<asp:Content ID="MainAdminContentReports" ContentPlaceHolderID="AdminMainContent" runat="server">
     <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <asp:UpdatePanel ID="upnlReports" runat="server">
        <ContentTemplate>
            <div class="bg-white shadow-sm px-4 md:px-6 py-3 border-b border-gray-200">
                <div class="flex flex-col sm:flex-row items-center justify-between gap-3">
                    <h2 class="text-lg font-semibold text-gray-700">Tổng quan Báo cáo</h2>
                    <div class="flex flex-wrap items-center justify-center sm:justify-end gap-2">
                        <div class="flex items-center space-x-2">
                            <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" CssClass="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:border-primary w-full sm:w-auto"></asp:TextBox>
                            <span class="text-gray-500 text-sm">đến</span>
                            <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" CssClass="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:border-primary w-full sm:w-auto"></asp:TextBox>
                            <asp:Button ID="btnUpdateReports" runat="server" OnClick="btnUpdateReports_Click" Text="Cập nhật" CssClass="bg-secondary hover:bg-opacity-90 text-white px-4 py-2 rounded-lg transition-colors text-sm" />
                        </div>
                        <div class="flex items-center space-x-2">
                            <span class="hidden sm:inline">Excel</span>
                            <span class="hidden sm:inline">PDF</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="p-4 md:p-6">
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 md:gap-6 mb-6">
                    <div class="stat-card-gradient-primary rounded-xl p-4 text-white report-card-admin">
                        <div class="flex items-center justify-between"><div><p class="text-white text-opacity-80 text-sm">Doanh thu</p><asp:Label ID="lblTotalRevenue" runat="server" Text="0 VNĐ" CssClass="text-xl font-bold"></asp:Label><div class="flex items-center mt-1"><asp:Label ID="lblRevenueTrend" runat="server" CssClass="metric-trend-admin"></asp:Label></div></div><div class="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-chart-line text-lg"></i></div></div>
                    </div>
                    <div class="stat-card-gradient-secondary rounded-xl p-4 text-white report-card-admin">
                        <div class="flex items-center justify-between"><div><p class="text-white text-opacity-80 text-sm">Đơn hoàn thành</p><asp:Label ID="lblCompletedOrders" runat="server" Text="0" CssClass="text-xl font-bold"></asp:Label><div class="flex items-center mt-1"><asp:Label ID="lblCompletedOrdersTrend" runat="server" CssClass="metric-trend-admin"></asp:Label></div></div><div class="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-check-circle text-lg"></i></div></div>
                    </div>
                    <div class="stat-card-gradient-accent rounded-xl p-4 text-dark report-card-admin">
                        <div class="flex items-center justify-between"><div><p class="text-dark text-opacity-80 text-sm">Khách hàng mới</p><asp:Label ID="lblNewCustomersReport" runat="server" Text="0" CssClass="text-xl font-bold"></asp:Label><div class="flex items-center mt-1"><asp:Label ID="lblNewCustomersTrend" runat="server" CssClass="metric-trend-admin up"></asp:Label></div></div><div class="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-users text-lg text-dark"></i></div></div>
                    </div>
                    <div class="stat-card-gradient-dark rounded-xl p-4 text-white report-card-admin">
                        <div class="flex items-center justify-between"><div><p class="text-white text-opacity-80 text-sm">Tỷ lệ chuyển đổi</p><asp:Label ID="lblConversionRate" runat="server" Text="0%" CssClass="text-xl font-bold"></asp:Label><div class="flex items-center mt-1"><asp:Label ID="lblConversionRateTrend" runat="server" CssClass="metric-trend-admin"></asp:Label></div></div><div class="w-10 h-10 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-percentage text-lg"></i></div></div>
                    </div>
                </div>

                <div class="grid grid-cols-1 xl:grid-cols-3 gap-4 md:gap-6 mb-6">
                    <div class="xl:col-span-2 bg-white rounded-xl shadow-sm report-card-admin">
                        <div class="p-4 md:p-6 border-b border-gray-200 flex items-center justify-between">
                            <h3 class="text-base font-bold text-gray-800">Xu hướng doanh thu</h3>
                            <asp:DropDownList ID="ddlRevenueTimeframe" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlRevenueTimeframe_SelectedIndexChanged" CssClass="border border-gray-300 rounded-lg px-3 py-1 text-sm focus:outline-none focus:border-primary">
                                <asp:ListItem Value="7days">7 ngày qua</asp:ListItem>
                                <asp:ListItem Value="30days" Selected="True">30 ngày qua</asp:ListItem>
                                <asp:ListItem Value="3months">3 tháng qua</asp:ListItem>
                                <asp:ListItem Value="12months">12 tháng qua</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="p-4 md:p-6"><div class="chart-container-large-admin"><canvas id="adminRevenueChart"></canvas></div></div>
                    </div>
                    <div class="bg-white rounded-xl shadow-sm report-card-admin">
                        <div class="p-4 md:p-6 border-b border-gray-200"><h3 class="text-base font-bold text-gray-800">Phân tích doanh thu</h3></div>
                        <div class="p-4 md:p-6 space-y-3">
                             <asp:Repeater ID="rptRevenueBreakdown" runat="server">
                                 <ItemTemplate>
                                     <div class="mb-2">
                                         <div class="flex items-center justify-between text-sm">
                                             <span class="text-gray-600"><%# Eval("SourceName") %></span>
                                             <span class="font-semibold text-gray-800"><%# Eval("Amount", "{0:N0} VNĐ") %></span>
                                         </div>
                                         <div class="mt-1 w-full bg-gray-200 rounded-full h-2.5">
                                            <div class='<%# Eval("ProgressBarCss") %> h-2.5 rounded-full' style='width: <%# Eval("Percentage") %>%'></div>
                                        </div>
                                     </div>
                                 </ItemTemplate>
                             </asp:Repeater>
                             <div class="mt-4 pt-3 border-t border-gray-200">
                                <div class="flex items-center justify-between"><span class="text-sm font-medium text-gray-800">Tổng DT đã chọn</span><asp:Label ID="lblTotalRevenueBreakdown" runat="server" Text="0 VNĐ" CssClass="text-lg font-bold text-primary"></asp:Label></div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 md:gap-6 mb-6">
                     <div class="bg-white rounded-xl shadow-sm report-card-admin">
                        <div class="p-4 md:p-6 border-b border-gray-200"><h3 class="text-base font-bold text-gray-800">Trạng thái đơn hàng (tháng này)</h3></div>
                        <div class="p-4 md:p-6"><div class="chart-container-admin"><canvas id="adminOrderStatusChart"></canvas></div></div>
                    </div>
                    <div class="bg-white rounded-xl shadow-sm report-card-admin">
                        <div class="p-4 md:p-6 border-b border-gray-200"><h3 class="text-base font-bold text-gray-800">Top 5 Sản phẩm bán chạy (tháng này)</h3></div>
                        <div class="p-4 md:p-6">
                            <div class="space-y-3">
                                <asp:Repeater ID="rptTopProducts" runat="server">
                                    <ItemTemplate>
                                        <div class="flex items-center space-x-3">
                                            <div class='w-10 h-10 <%# Eval("RankCssClass") %> rounded-lg flex items-center justify-center text-white font-bold text-sm'> <%# Container.ItemIndex + 1 %></div>
                                            <div class="flex-1">
                                                <h4 class="font-medium text-gray-800 text-sm truncate" title='<%# Eval("ProductName") %>'><%# Eval("ProductName") %></h4>
                                                <p class="text-xs text-gray-600"><%# Eval("UnitsSold") %> SP đã bán</p>
                                            </div>
                                            <div class="text-right">
                                                <p class="font-semibold text-gray-800 text-sm"><%# Eval("TotalRevenue", "{0:N0} VNĐ") %></p>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="grid grid-cols-1 xl:grid-cols-2 gap-4 md:gap-6">
                    <div class="bg-white rounded-xl shadow-sm report-card-admin">
                        <div class="p-4 md:p-6 border-b border-gray-200 flex justify-between items-center">
                            <h3 class="text-base font-bold text-gray-800">Đơn hàng gần đây</h3>
                            <asp:HyperLink ID="hlViewAllOrdersReport" runat="server" NavigateUrl="~/Admin/Orders.aspx" CssClass="text-primary hover:underline text-sm font-medium">Xem tất cả</asp:HyperLink>
                        </div>
                        <div class="overflow-x-auto custom-scrollbar max-h-96">
                            <asp:GridView ID="gvRecentOrdersReport" runat="server" AutoGenerateColumns="False" CssClass="w-full table-admin-reports" EmptyDataText="Không có đơn hàng gần đây.">
                                <Columns>
                                    <asp:BoundField DataField="OrderCode" HeaderText="Mã ĐH" />
                                    <asp:BoundField DataField="CustomerName" HeaderText="Khách hàng" />
                                    <asp:BoundField DataField="TotalAmount" HeaderText="Tổng tiền" DataFormatString="{0:N0}đ" />
                                    <asp:TemplateField HeaderText="Trạng thái"><ItemTemplate><span class='px-2 py-1 text-xs leading-5 font-semibold rounded-full'><%# Eval("StatusText") %></span></ItemTemplate></asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                     <div class="bg-white rounded-xl shadow-sm report-card-admin">
                        <div class="p-4 md:p-6 border-b border-gray-200 flex justify-between items-center">
                            <h3 class="text-base font-bold text-gray-800">Báo cáo tồn kho</h3>
                             <asp:HyperLink ID="hlViewAllProductsReport" runat="server" NavigateUrl="~/Admin/Products.aspx" CssClass="text-primary hover:underline text-sm font-medium">Xem tất cả SP</asp:HyperLink>
                        </div>
                         <div class="overflow-x-auto custom-scrollbar max-h-96">
                            <asp:GridView ID="gvInventoryReport" runat="server" AutoGenerateColumns="False" CssClass="w-full table-admin-reports" EmptyDataText="Không có dữ liệu tồn kho.">
                                 <Columns>
                                    <asp:TemplateField HeaderText="Sản phẩm">
                                        <ItemTemplate><div class="font-medium text-gray-900"><%# Eval("ProductName") %></div><div class="text-xs text-gray-500">SKU: <%# Eval("SKU") %></div></ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="StockQuantity" HeaderText="Tồn kho" ItemStyle-CssClass="text-center" />
                                    <asp:TemplateField HeaderText="Trạng thái kho"><ItemTemplate><span class='px-2 py-1 text-xs leading-5 font-semibold rounded-full'></span></ItemTemplate></asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

<asp:Content ID="AdminScriptsReports" ContentPlaceHolderID="AdminScriptsContent" runat="server">
    <script type="text/javascript">
        let adminRevenueChartInstance = null;
        let adminOrderStatusChartInstance = null;
        let adminCustomerChartInstance = null; // For the customer demographics on this page

        function renderAdminRevenueChart(labels, revenueData, orderData) { // Combined revenue and order count
            const ctx = document.getElementById('adminRevenueChart');
            if (!ctx) return;
            if (adminRevenueChartInstance) adminRevenueChartInstance.destroy();
            adminRevenueChartInstance = new Chart(ctx.getContext('2d'), {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [
                        { label: 'Doanh thu (triệu VNĐ)', data: revenueData, borderColor: '#FF6B6B', backgroundColor: 'rgba(255, 107, 107, 0.1)', tension: 0.3, fill: true, yAxisID: 'yRevenue', pointBackgroundColor: '#FF6B6B', pointRadius: 4 },
                        { label: 'Số đơn hàng', data: orderData, borderColor: '#4ECDC4', backgroundColor: 'rgba(78, 205, 196, 0.1)', tension: 0.3, fill: false, yAxisID: 'yOrders', pointBackgroundColor: '#4ECDC4', pointRadius: 4 }
                    ]
                },
                options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'top', labels:{font:{size:10}, usePointStyle:true, padding:15} } }, 
                    scales: { 
                        yRevenue: { type:'linear', display:true, position:'left', beginAtZero: true, title:{display:true, text:'Doanh thu (triệu)', font:{size:10}}, ticks:{font:{size:10}} },
                        yOrders: { type:'linear', display:true, position:'right', beginAtZero: true, title:{display:true, text:'Số đơn hàng', font:{size:10}}, grid:{drawOnChartArea:false}, ticks:{font:{size:10}} },
                        x: { ticks:{font:{size:10}}} 
                    },
                    interaction: { mode: 'index', intersect: false }
                }
            });
        }

        function renderAdminOrderStatusChart(labels, data) {
            const ctx = document.getElementById('adminOrderStatusChart');
            if(!ctx) return;
            if(adminOrderStatusChartInstance) adminOrderStatusChartInstance.destroy();
            adminOrderStatusChartInstance = new Chart(ctx.getContext('2d'), {
                type: 'doughnut',
                data: {
                    labels: labels, // ['Hoàn thành', 'Đang xử lý', ...]
                    datasets: [{ data: data, backgroundColor: ['#10B981', '#F59E0B', '#3B82F6', '#8B5CF6', '#EF4444', '#6B7280'], borderWidth: 0, hoverBorderWidth:2, hoverBorderColor:'#fff' }]
                },
                options: { responsive: true, maintainAspectRatio: false, cutout: '65%', plugins: { legend: { position: 'bottom', labels:{font:{size:10}, usePointStyle:true, padding:10} }, tooltip: {callbacks: {label: function(c){return `${c.label}: ${c.parsed}% (${c.dataset.data[c.dataIndex]} đơn)`;}}} } }
            });
        }
        
        function renderAdminCustomerDemographicsChart(labels, data) {
            const ctx = document.getElementById('customerChart'); // The ID from HTML
            if(!ctx) return;
            if(adminCustomerChartInstance) adminCustomerChartInstance.destroy();
            adminCustomerChartInstance = new Chart(ctx.getContext('2d'), {
                type: 'pie',
                data: {
                    labels: labels, // ['18-25', '26-35', ...]
                    datasets: [{ data: data, backgroundColor: ['#FF6B6B', '#4ECDC4', '#FFE66D', '#1A535C', '#A569BD'], borderWidth:0, hoverBorderWidth:2, hoverBorderColor:'#fff' }]
                },
                options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom', labels:{font:{size:10}, usePointStyle:true, padding:10} }, tooltip: {callbacks: {label: function(c){return `${c.label}: ${c.parsed}%`;}}} } }
            });
        }

        // Function to be called by ASP.NET ScriptManager to initialize charts with data
        // function initializeAllAdminReportCharts(revenueChartData, orderStatusChartData, customerDemographicsChartData) {
        //     if(revenueChartData) renderAdminRevenueChart(revenueChartData.labels, revenueChartData.revenue, revenueChartData.orders);
        //     if(orderStatusChartData) renderAdminOrderStatusChart(orderStatusChartData.labels, orderStatusChartData.data);
        //     if(customerDemographicsChartData) renderAdminCustomerDemographicsChart(customerDemographicsChartData.labels, customerDemographicsChartData.data);
        // }
        
        window.addEventListener('resize', function() {
            if (adminRevenueChartInstance) adminRevenueChartInstance.resize();
            if (adminOrderStatusChartInstance) adminOrderStatusChartInstance.resize();
            if (adminCustomerChartInstance) adminCustomerChartInstance.resize();
        });

        document.addEventListener('DOMContentLoaded', function () {
            const today = new Date();
            const firstDayCurrentMonth = new Date(today.getFullYear(), today.getMonth(), 1);
            
            const startDateInput = document.getElementById(getClientIdCS('<%= txtStartDate.ClientID %>'));
            const endDateInput = document.getElementById(getClientIdCS('<%= txtEndDate.ClientID %>'));

            if(startDateInput && !startDateInput.value) startDateInput.value = firstDayCurrentMonth.toISOString().split('T')[0];
            if(endDateInput && !endDateInput.value) endDateInput.value = today.toISOString().split('T')[0];

            // Active state for mobile bottom nav
            const currentPath = window.location.pathname.toLowerCase();
            const bottomNavLinks = document.querySelectorAll('.bottom-nav .nav-item');
            let reportLinkManuallyActivated = false;

            bottomNavLinks.forEach(link => {
                const linkHref = link.getAttribute('href');
                if (!linkHref) return;
                const linkPath = new URL(linkHref, window.location.origin).pathname.toLowerCase();
                
                if (currentPath.includes('reports.aspx') && linkPath.includes('reports.aspx')) { 
                    link.classList.add('active');
                    link.classList.remove('text-gray-600');
                    reportLinkManuallyActivated = true;
                } else if (!reportLinkManuallyActivated && currentPath === linkPath) {
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
        
        // ClientID helper for scripts within UpdatePanel ContentTemplate
        function getClientIdCS(serverID) {
            return serverID; // In ContentTemplate, ASP.NET usually renders ClientID directly.
                            // If it's inside a naming container like Repeater, you might need more complex logic.
        }

        function showAdminReportNotification(message, type) {
            // Implement a more robust notification system if available from Admin.Master
            // For now, using a simple one
            const notificationContainer = document.getElementById('adminReportNotificationArea'); // Add this div to your ASPX if you want a dedicated area
            if (notificationContainer) {
                // ... create and append notification element ...
            } else {
                alert(message); // Fallback
            }
        }
    </script>
</asp:Content>