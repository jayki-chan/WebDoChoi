<%@ Page Title="Dashboard - ToyLand Admin" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="WebsiteDoChoi.Admin.Default" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitleContent" runat="server">
    <h1 class="text-xl md:text-2xl font-bold text-gray-800">Dashboard</h1>
</asp:Content>

<asp:Content ID="MainAdminContent" ContentPlaceHolderID="AdminMainContent" runat="server">
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 md:gap-6 mb-6 md:mb-8">
        <div class="stat-card-primary rounded-xl p-4 md:p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-white text-opacity-80 text-sm">Tổng doanh thu</p>
                    <asp:Label ID="lblTotalRevenue" runat="server" Text="0 VNĐ" CssClass="text-xl md:text-2xl font-bold"></asp:Label>
                    <asp:Label ID="lblRevenueChange" runat="server" Text="+0% so với tháng trước" CssClass="text-white text-opacity-80 text-xs md:text-sm"></asp:Label>
                </div>
                <div class="w-10 h-10 md:w-12 md:h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                    <i class="fas fa-chart-line text-xl md:text-2xl"></i>
                </div>
            </div>
        </div>
        <div class="stat-card-secondary rounded-xl p-4 md:p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-white text-opacity-80 text-sm">Đơn hàng mới</p>
                    <asp:Label ID="lblNewOrders" runat="server" Text="0" CssClass="text-xl md:text-2xl font-bold"></asp:Label>
                    <asp:Label ID="lblNewOrdersChange" runat="server" Text="+0% so với tuần trước" CssClass="text-white text-opacity-80 text-xs md:text-sm"></asp:Label>
                </div>
                <div class="w-10 h-10 md:w-12 md:h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                    <i class="fas fa-shopping-cart text-xl md:text-2xl"></i>
                </div>
            </div>
        </div>
        <div class="stat-card-accent rounded-xl p-4 md:p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-white text-opacity-80 text-sm">Khách hàng mới</p>
                    <asp:Label ID="lblNewCustomers" runat="server" Text="0" CssClass="text-xl md:text-2xl font-bold"></asp:Label>
                    <asp:Label ID="lblNewCustomersChange" runat="server" Text="+0% so với tháng trước" CssClass="text-white text-opacity-80 text-xs md:text-sm"></asp:Label>
                </div>
                <div class="w-10 h-10 md:w-12 md:h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                    <i class="fas fa-users text-xl md:text-2xl"></i>
                </div>
            </div>
        </div>
        <div class="stat-card-dark rounded-xl p-4 md:p-6 text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-white text-opacity-80 text-sm">Sản phẩm bán chạy</p>
                    <asp:Label ID="lblBestSellingProductCount" runat="server" Text="0" CssClass="text-xl md:text-2xl font-bold"></asp:Label>
                    <asp:Label ID="lblBestSellingProductName" runat="server" Text="N/A" CssClass="text-white text-opacity-80 text-xs md:text-sm truncate block max-w-[150px]"></asp:Label>
                </div>
                <div class="w-10 h-10 md:w-12 md:h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center">
                    <i class="fas fa-crown text-xl md:text-2xl"></i>
                </div>
            </div>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 md:gap-6 mb-6 md:mb-8">
        <div class="bg-white rounded-xl shadow-sm p-4 md:p-6">
            <div class="flex items-center justify-between mb-4 md:mb-6">
                <h3 class="text-base md:text-lg font-bold text-gray-800">Doanh thu theo tháng</h3>
                <asp:DropDownList ID="ddlSalesYear" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSalesYear_SelectedIndexChanged" CssClass="border border-gray-300 rounded-lg px-2 md:px-3 py-1 text-sm focus:outline-none focus:border-primary">
                    <%-- Populate with years from code-behind --%>
                </asp:DropDownList>
            </div>
            <div class="relative h-[300px] md:h-[350px]">
                <canvas id="salesChart"></canvas>
            </div>
        </div>
        <div class="bg-white rounded-xl shadow-sm p-4 md:p-6">
             <div class="flex items-center justify-between mb-4 md:mb-6">
                <h3 class="text-base md:text-lg font-bold text-gray-800">Danh mục bán chạy</h3>
                 <asp:HyperLink ID="hlViewCategoryReport" runat="server" NavigateUrl="~/Admin/Reports.aspx?type=categories" CssClass="text-primary hover:text-primary-dark text-sm">Xem chi tiết</asp:HyperLink>
            </div>
            <div class="relative h-[300px] md:h-[350px]">
                <canvas id="categoryChart"></canvas>
            </div>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-4 md:gap-6">
        <div class="lg:col-span-2 bg-white rounded-xl shadow-sm">
            <div class="p-4 md:p-6 border-b border-gray-200">
                <div class="flex items-center justify-between">
                    <h3 class="text-base md:text-lg font-bold text-gray-800">Đơn hàng gần đây</h3>
                    <asp:HyperLink ID="hlViewAllOrders" runat="server" NavigateUrl="~/Admin/Orders.aspx" CssClass="text-primary hover:text-primary-dark text-sm">Xem tất cả</asp:HyperLink>
                </div>
            </div>
            <div class="overflow-x-auto">
                <asp:GridView ID="gvRecentOrders" runat="server" AutoGenerateColumns="False" CssClass="w-full"
                    HeaderStyle-CssClass="bg-gray-50" RowStyle-CssClass="table-row"
                    EmptyDataText="Không có đơn hàng gần đây." GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="OrderCode" HeaderText="Mã đơn" ItemStyle-CssClass="px-4 md:px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900" HeaderStyle-CssClass="px-4 md:px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" />
                        <asp:BoundField DataField="CustomerName" HeaderText="Khách hàng" ItemStyle-CssClass="px-4 md:px-6 py-4 whitespace-nowrap text-sm text-gray-500" HeaderStyle-CssClass="px-4 md:px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" />
                        <asp:BoundField DataField="TotalAmount" HeaderText="Tổng tiền" DataFormatString="{0:N0}đ" ItemStyle-CssClass="px-4 md:px-6 py-4 whitespace-nowrap text-sm text-gray-900" HeaderStyle-CssClass="px-4 md:px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" />
                        <asp:TemplateField HeaderText="Trạng thái" HeaderStyle-CssClass="px-4 md:px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" ItemStyle-CssClass="px-4 md:px-6 py-4 whitespace-nowrap">
                            <ItemTemplate>
                                <span class='<%# GetStatusCssClass(Eval("Status")) %>'><%# Eval("StatusText") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Thao tác" HeaderStyle-CssClass="px-4 md:px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" ItemStyle-CssClass="px-4 md:px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            <ItemTemplate>
                                <asp:HyperLink ID="hlViewOrder" runat="server" NavigateUrl='<%# Eval("OrderId", "~/Admin/OrderDetails.aspx?id={0}") %>' CssClass="text-primary hover:text-primary-dark mr-2" ToolTip="Xem chi tiết"><i class="fas fa-eye"></i></asp:HyperLink>
                                <asp:HyperLink ID="hlEditOrder" runat="server" NavigateUrl='<%# Eval("OrderId", "~/Admin/OrderEdit.aspx?id={0}") %>' CssClass="text-secondary hover:text-secondary-dark" ToolTip="Chỉnh sửa"><i class="fas fa-edit"></i></asp:HyperLink>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <HeaderStyle CssClass="bg-gray-50"></HeaderStyle>
                    <RowStyle CssClass="table-row"></RowStyle>
                </asp:GridView>
            </div>
        </div>
        <div class="space-y-4 md:space-y-6">
            <div class="bg-white rounded-xl shadow-sm p-4 md:p-6">
                <h3 class="text-base md:text-lg font-bold text-gray-800 mb-4">Thao tác nhanh</h3>
                <div class="space-y-3">
                    <asp:HyperLink ID="hlAddProduct" runat="server" NavigateUrl="~/Admin/ProductEdit.aspx" CssClass="w-full bg-primary hover:bg-opacity-90 text-white py-2 md:py-3 px-4 rounded-lg transition-colors flex items-center text-sm md:text-base"><i class="fas fa-plus mr-2"></i> Thêm sản phẩm mới</asp:HyperLink>
                    <asp:HyperLink ID="hlCreatePromotion" runat="server" NavigateUrl="~/Admin/PromotionEdit.aspx" CssClass="w-full bg-secondary hover:bg-opacity-90 text-white py-2 md:py-3 px-4 rounded-lg transition-colors flex items-center text-sm md:text-base"><i class="fas fa-tags mr-2"></i> Tạo khuyến mãi</asp:HyperLink>
                    <asp:HyperLink ID="hlExportReport" runat="server" NavigateUrl="~/Admin/Reports.aspx?action=export" CssClass="w-full bg-accent hover:bg-opacity-90 text-dark py-2 md:py-3 px-4 rounded-lg transition-colors flex items-center text-sm md:text-base"><i class="fas fa-file-export mr-2"></i> Xuất báo cáo</asp:HyperLink>
                </div>
            </div>
            <div class="bg-white rounded-xl shadow-sm p-4 md:p-6">
                <h3 class="text-base md:text-lg font-bold text-gray-800 mb-4">Thông báo Admin</h3>
                 <asp:Repeater ID="rptAdminNotifications" runat="server">
                    <ItemTemplate>
                        <div class="flex items-start space-x-3 <%# Container.ItemIndex > 0 ? "mt-4 pt-4 border-t border-gray-100" : "" %>">
                            <div class='<%# Eval("IconBgCss") %> w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0'>
                                <i class='<%# Eval("IconCss") %>'></i>
                            </div>
                            <div class="flex-1">
                                <p class="text-sm text-gray-800"><%# Eval("Message") %></p>
                                <p class="text-xs text-gray-500"><%# Eval("TimeAgo") %></p>
                            </div>
                        </div>
                    </ItemTemplate>
                     <FooterTemplate>
                         <asp:Panel ID="pnlNoAdminNotifications" runat="server" Visible='<%# rptAdminNotifications.Items.Count == 0 %>'>
                             <p class="text-sm text-gray-500">Không có thông báo mới.</p>
                         </asp:Panel>
                     </FooterTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="ScriptsContent" ContentPlaceHolderID="AdminScriptsContent" runat="server">
    <script type="text/javascript">
        let salesChartInstance = null;
        let categoryChartInstance = null;

        function renderSalesChart(labels, data) {
            const salesCtx = document.getElementById('salesChart');
            if (!salesCtx) return;
            if (salesChartInstance) {
                salesChartInstance.destroy();
            }
            salesChartInstance = new Chart(salesCtx.getContext('2d'), {
                type: 'line',
                data: {
                    labels: labels, // ['T1', 'T2', ...]
                    datasets: [{
                        label: 'Doanh thu (triệu VNĐ)',
                        data: data, // [85, 92, ...]
                        borderColor: '#FF6B6B',
                        backgroundColor: 'rgba(255, 107, 107, 0.1)',
                        tension: 0.4,
                        fill: true
                    }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        y: { beginAtZero: true, grid: { color: 'rgba(0,0,0,0.05)' }, ticks: { font: { size: window.innerWidth < 768 ? 9 : 11 } } },
                        x: { grid: { display: false }, ticks: { font: { size: window.innerWidth < 768 ? 9 : 11 } } }
                    }
                }
            });
        }

        function renderCategoryChart(labels, data) {
            const categoryCtx = document.getElementById('categoryChart');
            if (!categoryCtx) return;
            if (categoryChartInstance) {
                categoryChartInstance.destroy();
            }
            categoryChartInstance = new Chart(categoryCtx.getContext('2d'), {
                type: 'doughnut',
                data: {
                    labels: labels, // ['Giáo dục', 'Robot', ...]
                    datasets: [{
                        data: data, // [35, 25, ...]
                        backgroundColor: ['#FF6B6B', '#4ECDC4', '#FFE66D', '#1A535C', '#95A5A6', '#F39C12', '#3498DB'], // Add more colors if needed
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { position: 'bottom', labels: { padding: window.innerWidth < 768 ? 8 : 15, usePointStyle: true, font: { size: window.innerWidth < 768 ? 9 : 11 } } } }
                }
            });
        }

        // Will be called by server-side script registration
        // function initializeCharts(salesLabels, salesData, categoryLabels, categoryData) {
        //     renderSalesChart(salesLabels, salesData);
        //     renderCategoryChart(categoryLabels, categoryData);
        // }

        window.addEventListener('resize', function () {
            if (salesChartInstance) salesChartInstance.resize();
            if (categoryChartInstance) categoryChartInstance.resize();
        });

        // You might want to call a function to fetch and render chart data on initial load
        // or after a DDL change, triggered from server-side.
        // For example, after ddlSalesYear changes, a server-side event will re-register the script
        // to call renderSalesChart with new data.
    </script>
</asp:Content>