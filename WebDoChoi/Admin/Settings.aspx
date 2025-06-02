<%@ Page Title="Cài đặt Website - ToyLand Admin" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="Settings.aspx.cs" Inherits="WebsiteDoChoi.Admin.Settings" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitleContent" runat="server">
    <h1 class="text-xl md:text-2xl font-bold text-gray-800">Cài đặt Website</h1>
</asp:Content>

<asp:Content ID="AdminHeadSettings" ContentPlaceHolderID="AdminHeadContent" runat="server">
    <%-- Chart.js and date-fns might not be strictly needed for this page, but kept from template --%>
    <style>
        .tab-button-settings.active { color: #FF6B6B; border-bottom-color: #FF6B6B; background-color: rgba(255, 107, 107, 0.03); }
        .tab-button-settings { transition: all 0.2s ease-out; border-bottom-width: 3px; border-color: transparent; padding-bottom: 0.5rem; margin-bottom:-3px; }
        .tab-button-settings:hover { background-color: rgba(255, 107, 107, 0.07); }
        
        .tab-content-settings { display: none; }
        .tab-content-settings.active { display: block; animation: fadeInSettings 0.3s ease-in-out; }
        @keyframes fadeInSettings { from { opacity: 0; transform: translateY(5px); } to { opacity: 1; transform: translateY(0); } }

        .form-label-settings { display: block; font-weight: 500; color: #374151; margin-bottom: 0.375rem; font-size:0.875rem; } /* text-sm */
        .form-input-settings, .form-textarea-settings, .form-select-settings { 
            width: 100%; padding: 0.625rem 0.75rem; /* py-2.5 px-3 */ border: 1px solid #d1d5db; /* gray-300 */ 
            border-radius: 0.375rem; /* rounded-md */ transition: border-color 0.2s ease; font-size:0.875rem;
        }
        .form-input-settings:focus, .form-textarea-settings:focus, .form-select-settings:focus { 
            outline: none; border-color: #FF6B6B; /* primary */ box-shadow: 0 0 0 2px rgba(255, 107, 107, 0.2);
        }
        .form-textarea-settings { resize: vertical; min-height: 90px; }

        .toggle-switch-settings { position: relative; width: 2.75rem; /* w-11 */ height: 1.5rem; /* h-6 */ background-color: #d1d5db; border-radius: 0.75rem; cursor: pointer; transition: background-color 0.2s ease; flex-shrink:0; }
        .toggle-switch-settings.active { background-color: #FF6B6B; /* primary */ }
        .toggle-switch-settings::after { content: ''; position: absolute; top: 2px; left: 2px; width: 1.25rem; /* w-5 */ height: 1.25rem; background-color: white; border-radius: 50%; transition: transform 0.2s ease; box-shadow: 0 1px 2px rgba(0,0,0,0.1); }
        .toggle-switch-settings.active::after { transform: translateX(1.25rem); /* translate-x-5 */ }
        
        .color-picker-settings { width: 2.5rem; height: 2.5rem; border: 1px solid #e5e7eb; border-radius: 0.375rem; cursor: pointer; overflow: hidden; padding:0.125rem; }
        .color-picker-settings input[type="color"] { width: 100%; height: 100%; border: none; cursor: pointer; -webkit-appearance: none; -moz-appearance: none; appearance: none; background: none; }
        .color-picker-settings input[type="color"]::-webkit-color-swatch-wrapper { padding: 0; }
        .color-picker-settings input[type="color"]::-webkit-color-swatch { border: none; border-radius: 0.25rem; }
        .color-picker-settings input[type="color"]::-moz-color-swatch { border: none; border-radius: 0.25rem; }


        .file-upload-area-settings { border: 2px dashed #d1d5db; border-radius: 0.5rem; padding: 1rem; text-align: center; transition: all 0.2s ease; cursor: pointer; }
        .file-upload-area-settings:hover, .file-upload-area-settings.dragover { border-color: #FF6B6B; background-color: rgba(255, 107, 107, 0.03); }
        
        .status-indicator-settings { display: inline-block; width: 0.625rem; height: 0.625rem; border-radius: 50%; margin-right: 0.375rem; }
        .status-healthy-settings { background-color: #10b981; box-shadow: 0 0 0 2px rgba(16, 185, 129, 0.2); }
        .status-warning-settings { background-color: #f59e0b; box-shadow: 0 0 0 2px rgba(245, 158, 11, 0.2); }
        .status-error-settings { background-color: #ef4444; box-shadow: 0 0 0 2px rgba(239, 68, 68, 0.2); }

        .api-key-field-settings { position: relative; }
        .api-key-field-settings .form-input-settings { padding-right: 3rem; } /* Space for the eye icon */
        .api-key-actions-settings { position: absolute; right: 0.5rem; top: 50%; transform: translateY(-50%); }
        
        .notification-settings { /* Re-using general admin notification styling */ }
        .modal-admin-settings { backdrop-filter: blur(4px); }
    </style>
</asp:Content>

<asp:Content ID="MainAdminContentSettings" ContentPlaceHolderID="AdminMainContent" runat="server">
     <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <asp:UpdatePanel ID="upnlSettingsPage" runat="server">
        <ContentTemplate>
            <div class="bg-white shadow-sm px-4 md:px-6 py-3 border-b border-gray-200 sticky top-0 z-30 md:relative">
                <div class="flex items-center justify-between">
                    <h2 class="text-lg font-semibold text-gray-700">Cài đặt chung Website</h2>
                    <div class="flex items-center space-x-2">
                        <span class="hidden sm:inline">Xuất</span>
                        <span class="hidden sm:inline">Nhập</span>
                        <span class="hidden sm:inline">Lưu</span>
                    </div>
                </div>
            </div>

            <div class="p-4 md:p-6">
                 <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 md:gap-6 mb-6">
                    <div class="stats-card-primary rounded-xl p-3 text-white"><div class="flex items-center justify-between"><div><p class="text-white text-opacity-80 text-xs">Hệ thống</p><div class="text-lg font-bold flex items-center"><span class="status-indicator-settings status-healthy-settings"></span><asp:Label ID="lblSystemStatus" runat="server" Text="Hoạt động"></asp:Label></div><asp:Label ID="lblSystemUptime" runat="server" Text="Uptime: 99.9%" CssClass="text-white text-opacity-80 text-2xs"></asp:Label></div><div class="w-8 h-8 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-server text-base"></i></div></div></div>
                    <div class="stats-card-secondary rounded-xl p-3 text-white"><div class="flex items-center justify-between"><div><p class="text-white text-opacity-80 text-xs">Database</p><div class="text-lg font-bold flex items-center"><span class="status-indicator-settings status-healthy-settings"></span><asp:Label ID="lblDbStatus" runat="server" Text="Kết nối tốt"></asp:Label></div><asp:Label ID="lblDbPing" runat="server" Text="Ping: 12ms" CssClass="text-white text-opacity-80 text-2xs"></asp:Label></div><div class="w-8 h-8 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-database text-base"></i></div></div></div>
                    <div class="stats-card-accent rounded-xl p-3 text-dark"><div class="flex items-center justify-between"><div><p class="text-dark text-opacity-80 text-xs">Cache</p><div class="text-lg font-bold flex items-center"><span class="status-indicator-settings status-warning-settings"></span><asp:Label ID="lblCacheStatus" runat="server" Text="Cần tối ưu"></asp:Label></div><asp:Label ID="lblCacheHitRate" runat="server" Text="Hit: 78%" CssClass="text-dark text-opacity-80 text-2xs"></asp:Label></div><div class="w-8 h-8 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-memory text-base text-dark"></i></div></div></div>
                    <div class="stats-card rounded-xl p-3 text-white"><div class="flex items-center justify-between"><div><p class="text-white text-opacity-80 text-xs">Bảo mật (SSL)</p><div class="text-lg font-bold flex items-center"><span class="status-indicator-settings status-healthy-settings"></span><asp:Label ID="lblSslStatus" runat="server" Text="Active"></asp:Label></div><asp:Label ID="lblSslExpiry" runat="server" Text="Còn 89 ngày" CssClass="text-white text-opacity-80 text-2xs"></asp:Label></div><div class="w-8 h-8 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-shield-alt text-base"></i></div></div></div>
                </div>

                <div class="bg-white rounded-xl shadow-sm mb-6">
                    <div class="border-b border-gray-200">
                        <nav class="flex flex-wrap -mb-px" aria-label="Tabs">
                            <asp:LinkButton ID="tabBtnGeneral" runat="server" OnClick="SettingsTab_Click" CommandArgument="General" CssClass="tab-button-settings px-3 py-3 text-xs sm:text-sm font-medium whitespace-nowrap"><i class="fas fa-info-circle mr-1 sm:mr-2"></i><span class="hidden sm:inline">Chung</span><span class="sm:hidden">Chung</span></asp:LinkButton>
                            <asp:LinkButton ID="tabBtnSales" runat="server" OnClick="SettingsTab_Click" CommandArgument="Sales" CssClass="tab-button-settings px-3 py-3 text-xs sm:text-sm font-medium whitespace-nowrap"><i class="fas fa-store mr-1 sm:mr-2"></i><span class="hidden sm:inline">Bán hàng</span><span class="sm:hidden">Bán hàng</span></asp:LinkButton>
                            <asp:LinkButton ID="tabBtnPayment" runat="server" OnClick="SettingsTab_Click" CommandArgument="Payment" CssClass="tab-button-settings px-3 py-3 text-xs sm:text-sm font-medium whitespace-nowrap"><i class="fas fa-credit-card mr-1 sm:mr-2"></i><span class="hidden sm:inline">Thanh toán</span><span class="sm:hidden">TT</span></asp:LinkButton>
                            <asp:LinkButton ID="tabBtnEmail" runat="server" OnClick="SettingsTab_Click" CommandArgument="Email" CssClass="tab-button-settings px-3 py-3 text-xs sm:text-sm font-medium whitespace-nowrap"><i class="fas fa-envelope mr-1 sm:mr-2"></i><span class="hidden sm:inline">Email & SMS</span><span class="sm:hidden">Email</span></asp:LinkButton>
                            <asp:LinkButton ID="tabBtnSeo" runat="server" OnClick="SettingsTab_Click" CommandArgument="Seo" CssClass="tab-button-settings px-3 py-3 text-xs sm:text-sm font-medium whitespace-nowrap"><i class="fas fa-search-dollar mr-1 sm:mr-2"></i><span class="hidden sm:inline">SEO</span><span class="sm:hidden">SEO</span></asp:LinkButton>
                            <asp:LinkButton ID="tabBtnSecurity" runat="server" OnClick="SettingsTab_Click" CommandArgument="Security" CssClass="tab-button-settings px-3 py-3 text-xs sm:text-sm font-medium whitespace-nowrap"><i class="fas fa-shield-alt mr-1 sm:mr-2"></i><span class="hidden sm:inline">Bảo mật</span><span class="sm:hidden">Bảo mật</span></asp:LinkButton>
                            <asp:LinkButton ID="tabBtnPerformance" runat="server" OnClick="SettingsTab_Click" CommandArgument="Performance" CssClass="tab-button-settings px-3 py-3 text-xs sm:text-sm font-medium whitespace-nowrap"><i class="fas fa-tachometer-alt mr-1 sm:mr-2"></i><span class="hidden sm:inline">Hiệu suất</span><span class="sm:hidden">Hiệu suất</span></asp:LinkButton>
                            <asp:LinkButton ID="tabBtnSocial" runat="server" OnClick="SettingsTab_Click" CommandArgument="Social" CssClass="tab-button-settings px-3 py-3 text-xs sm:text-sm font-medium whitespace-nowrap"><i class="fas fa-share-alt mr-1 sm:mr-2"></i><span class="hidden sm:inline">MXH</span><span class="sm:hidden">MXH</span></asp:LinkButton>
                        </nav>
                    </div>
                    <div class="p-4 md:p-6">
                        <asp:Panel ID="pnlGeneralSettings" runat="server" CssClass="tab-content-settings">
                            <h3 class="text-lg font-semibold text-gray-700 mb-4 border-b pb-2">Thông tin chung Website</h3>
                            <div class="grid grid-cols-1 lg:grid-cols-2 gap-x-6 gap-y-4">
                                <div class="space-y-4">
                                    <div><label class="form-label-settings">Tên website *</label><asp:TextBox ID="txtSiteName" runat="server" CssClass="form-input-settings"></asp:TextBox><asp:RequiredFieldValidator ID="rfvSiteName" ValidationGroup="GeneralSettings" ControlToValidate="txtSiteName" ErrorMessage="Không trống" CssClass="text-red-500 text-xs" Display="Dynamic" runat="server"/></div>
                                    <div><label class="form-label-settings">Tagline</label><asp:TextBox ID="txtSiteTagline" runat="server" CssClass="form-input-settings"></asp:TextBox></div>
                                    <div><label class="form-label-settings">Mô tả website</label><asp:TextBox ID="txtSiteDescription" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-textarea-settings"></asp:TextBox></div>
                                    <div><label class="form-label-settings">Địa chỉ cửa hàng</label><asp:TextBox ID="txtStoreAddress" runat="server" TextMode="MultiLine" Rows="2" CssClass="form-textarea-settings"></asp:TextBox></div>
                                </div>
                                <div class="space-y-4">
                                    <div><label class="form-label-settings">Logo (khuyến nghị 200x80px)</label><asp:FileUpload ID="fuLogo" runat="server" CssClass="block w-full text-sm text-gray-500 file:mr-4 file:py-1.5 file:px-3 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-primary file:text-white hover:file:bg-opacity-90" /><asp:Image ID="imgLogoPreview" runat="server" CssClass="mt-2 h-16 object-contain border p-1 rounded bg-gray-50" Visible="false" /></div>
                                    <div><label class="form-label-settings">Favicon (khuyến nghị 32x32px, .ico hoặc .png)</label><asp:FileUpload ID="fuFavicon" runat="server" CssClass="block w-full text-sm text-gray-500 file:mr-4 file:py-1.5 file:px-3 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-primary file:text-white hover:file:bg-opacity-90" /><asp:Image ID="imgFaviconPreview" runat="server" CssClass="mt-2 h-8 w-8 object-contain border p-1 rounded bg-gray-50" Visible="false" /></div>
                                    <div class="form-group-settings"><label class="form-label-settings">Màu sắc chủ đạo</label><div class="flex space-x-3 items-center">
                                        <div><label class="text-xs">Primary:</label><div class="color-picker-settings inline-block"><asp:TextBox ID="txtPrimaryColor" runat="server" TextMode="Color" DefaultValue="#FF6B6B" CssClass="w-full h-full p-0 border-0"></asp:TextBox></div></div>
                                        <div><label class="text-xs">Secondary:</label><div class="color-picker-settings inline-block"><asp:TextBox ID="txtSecondaryColor" runat="server" TextMode="Color" DefaultValue="#4ECDC4" CssClass="w-full h-full p-0 border-0"></asp:TextBox></div></div>
                                        <div><label class="text-xs">Accent:</label><div class="color-picker-settings inline-block"><asp:TextBox ID="txtAccentColor" runat="server" TextMode="Color" DefaultValue="#FFE66D" CssClass="w-full h-full p-0 border-0"></asp:TextBox></div></div>
                                    </div></div>
                                     <div><label class="form-label-settings">Email liên hệ</label><asp:TextBox ID="txtContactEmail" runat="server" TextMode="Email" CssClass="form-input-settings"></asp:TextBox></div>
                                     <div><label class="form-label-settings">Số điện thoại</label><asp:TextBox ID="txtContactPhone" runat="server" TextMode="Phone" CssClass="form-input-settings"></asp:TextBox></div>
                                     <div><label class="form-label-settings">Giờ làm việc</label><asp:TextBox ID="txtWorkingHours" runat="server" CssClass="form-input-settings"></asp:TextBox></div>
                                </div>
                            </div>
                        </asp:Panel>
                        
                        <asp:Panel ID="pnlSalesSettings" runat="server" CssClass="tab-content-settings" Visible="false">
                             <h3 class="text-lg font-semibold text-gray-700 mb-4 border-b pb-2">Cài đặt Bán hàng</h3>
                             <div class="grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-4">
                                 <div><label class="form-label-settings">Tiền tệ chính</label><asp:DropDownList ID="ddlCurrency" runat="server" CssClass="form-select-settings"><asp:ListItem Value="VND" Text="Việt Nam Đồng (VNĐ)" Selected="True" /><asp:ListItem Value="USD" Text="US Dollar (USD)" /></asp:DropDownList></div>
                                 <div><label class="form-label-settings">Ký hiệu tiền tệ</label><asp:TextBox ID="txtCurrencySymbol" runat="server" Text="đ" CssClass="form-input-settings"></asp:TextBox></div>
                                 <div><label class="form-label-settings">Thuế VAT mặc định (%)</label><asp:TextBox ID="txtDefaultTaxRate" runat="server" TextMode="Number" step="0.1" CssClass="form-input-settings" Text="10"></asp:TextBox></div>
                                 <div><label class="form-label-settings">Miễn phí vận chuyển từ (VNĐ)</label><asp:TextBox ID="txtFreeShippingThreshold" runat="server" TextMode="Number" step="1000" CssClass="form-input-settings" Text="500000"></asp:TextBox></div>
                                 <div><label class="form-label-settings">Số sản phẩm/trang (cửa hàng)</label><asp:DropDownList ID="ddlProductsPerPage" runat="server" CssClass="form-select-settings"><asp:ListItem Text="12" Value="12" Selected="True" /><asp:ListItem Text="24" Value="24" /><asp:ListItem Text="36" Value="36" /></asp:DropDownList></div>
                                 <div class="md:col-span-2 grid grid-cols-1 sm:grid-cols-2 gap-4">
                                     <div class="flex items-center justify-between p-3 border rounded-md"><label class="form-label-settings mb-0 mr-auto">Tự động trừ kho</label><asp:CheckBox ID="chkAutoUpdateStock" runat="server" Checked="true" CssClass="toggle-switch-settings-aspnet" /></div>
                                     <div class="flex items-center justify-between p-3 border rounded-md"><label class="form-label-settings mb-0 mr-auto">Đặt hàng khi hết hàng</label><asp:CheckBox ID="chkAllowOrderOutOfStock" runat="server" CssClass="toggle-switch-settings-aspnet" /></div>
                                     <div class="flex items-center justify-between p-3 border rounded-md"><label class="form-label-settings mb-0 mr-auto">Hiện số lượng tồn</label><asp:CheckBox ID="chkShowStockQuantity" runat="server" Checked="true" CssClass="toggle-switch-settings-aspnet" /></div>
                                     <div class="flex items-center justify-between p-3 border rounded-md"><label class="form-label-settings mb-0 mr-auto">Cho phép đánh giá SP</label><asp:CheckBox ID="chkAllowReviews" runat="server" Checked="true" CssClass="toggle-switch-settings-aspnet" /></div>
                                 </div>
                             </div>
                        </asp:Panel>

                        <asp:Panel ID="pnlPaymentSettings" runat="server" CssClass="tab-content-settings" Visible="false">
                             <h3 class="text-lg font-semibold text-gray-700 mb-4 border-b pb-2">Cài đặt Thanh toán</h3>
                              <div class="space-y-5">
                                  <div class="border rounded-lg p-4"><div class="flex items-center justify-between mb-2"><div class="flex items-center space-x-2"><i class="fas fa-money-bill-wave text-green-600 text-xl"></i><h4 class="font-medium">Thanh toán khi nhận hàng (COD)</h4></div><asp:CheckBox ID="chkEnableCOD" runat="server" Checked="true" CssClass="toggle-switch-settings-aspnet"/></div><div class="grid grid-cols-2 gap-3"><asp:TextBox ID="txtCODFeePercent" placeholder="Phí xử lý (%)" TextMode="Number" CssClass="form-input-settings text-xs" runat="server" /><asp:TextBox ID="txtCODMinOrder" placeholder="Đơn tối thiểu COD" TextMode="Number" CssClass="form-input-settings text-xs" runat="server" /></div></div>
                                  <div class="border rounded-lg p-4"><div class="flex items-center justify-between mb-2"><div class="flex items-center space-x-2"><i class="fas fa-university text-blue-600 text-xl"></i><h4 class="font-medium">Chuyển khoản ngân hàng</h4></div><asp:CheckBox ID="chkEnableBankTransfer" runat="server" Checked="true" CssClass="toggle-switch-settings-aspnet"/></div><asp:TextBox ID="txtBankTransferInfo" TextMode="MultiLine" Rows="3" placeholder="Thông tin tài khoản ngân hàng..." CssClass="form-textarea-settings text-xs" runat="server" /></div>
                                  <div class="border rounded-lg p-4"><div class="flex items-center justify-between mb-2"><div class="flex items-center space-x-2"><i class="fas fa-mobile-alt text-pink-600 text-xl"></i><h4 class="font-medium">Ví MoMo</h4></div><asp:CheckBox ID="chkEnableMoMo" runat="server" CssClass="toggle-switch-settings-aspnet"/></div><div class="grid grid-cols-2 gap-3"><asp:TextBox ID="txtMoMoPartnerCode" placeholder="Partner Code" CssClass="form-input-settings text-xs" runat="server" /><asp:TextBox ID="txtMoMoAccessKey" placeholder="Access Key" TextMode="Password" CssClass="form-input-settings text-xs" runat="server" /></div></div>
                                  <div class="border rounded-lg p-4"><div class="flex items-center justify-between mb-2"><div class="flex items-center space-x-2"><i class="fas fa-wallet text-blue-500 text-xl"></i><h4 class="font-medium">Ví ZaloPay</h4></div><asp:CheckBox ID="chkEnableZaloPay" runat="server" CssClass="toggle-switch-settings-aspnet"/></div><div class="grid grid-cols-2 gap-3"><asp:TextBox ID="txtZaloPayAppId" placeholder="App ID" CssClass="form-input-settings text-xs" runat="server" /><asp:TextBox ID="txtZaloPayKey1" placeholder="Key1" TextMode="Password" CssClass="form-input-settings text-xs" runat="server" /></div></div>
                              </div>
                        </asp:Panel>
                         
                        <asp:Panel ID="pnlEmailSettings" runat="server" CssClass="tab-content-settings" Visible="false">
                            <%-- Nội dung tab Email & SMS --%>
                             <h3 class="text-lg font-semibold text-gray-700 mb-4 border-b pb-2">Cài đặt Email & SMS</h3>
                             <p>Nội dung cho Email & SMS sẽ ở đây...</p>
                        </asp:Panel>
                        <asp:Panel ID="pnlSeoSettings" runat="server" CssClass="tab-content-settings" Visible="false">
                            <%-- Nội dung tab SEO --%>
                             <h3 class="text-lg font-semibold text-gray-700 mb-4 border-b pb-2">Cài đặt SEO & Analytics</h3>
                             <p>Nội dung cho SEO & Analytics sẽ ở đây...</p>
                        </asp:Panel>
                         <asp:Panel ID="pnlSecuritySettings" runat="server" CssClass="tab-content-settings" Visible="false">
                             <%-- Nội dung tab Bảo mật --%>
                             <h3 class="text-lg font-semibold text-gray-700 mb-4 border-b pb-2">Cài đặt Bảo mật</h3>
                             <p>Nội dung cho Bảo mật sẽ ở đây...</p>
                         </asp:Panel>
                         <asp:Panel ID="pnlPerformanceSettings" runat="server" CssClass="tab-content-settings" Visible="false">
                             <%-- Nội dung tab Hiệu suất --%>
                            <h3 class="text-lg font-semibold text-gray-700 mb-4 border-b pb-2">Cài đặt Hiệu suất</h3>
                             <p>Nội dung cho Hiệu suất sẽ ở đây...</p>
                         </asp:Panel>
                         <asp:Panel ID="pnlSocialSettings" runat="server" CssClass="tab-content-settings" Visible="false">
                             <%-- Nội dung tab Mạng xã hội --%>
                             <h3 class="text-lg font-semibold text-gray-700 mb-4 border-b pb-2">Cài đặt Mạng xã hội</h3>
                             <p>Nội dung cho Mạng xã hội sẽ ở đây...</p>
                         </asp:Panel>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

     <asp:Panel ID="pnlImportModal" runat="server" Visible="false" CssClass="modal-admin-settings fixed inset-0 bg-black bg-opacity-50 z-[70] flex items-center justify-center p-4">
        <div class="bg-white rounded-xl w-full max-w-md shadow-xl">
             <div class="p-5 border-b flex justify-between items-center">
                 <h3 class="text-lg font-semibold">Nhập cấu hình từ File</h3>
                 <asp:LinkButton ID="btnCloseImportModal" runat="server" OnClick="btnCloseImportModal_Click" CssClass="text-gray-400 hover:text-red-500" CausesValidation="false"><i class="fas fa-times text-lg"></i></asp:LinkButton>
             </div>
             <div class="p-5 space-y-4">
                 <asp:FileUpload ID="fuImportSettingsFile" runat="server" CssClass="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100" accept=".json,.xml" />
                 <asp:Label ID="lblImportError" runat="server" CssClass="text-red-500 text-xs" Visible="false"></asp:Label>
                 <div class="flex space-x-3 justify-end">
                    <asp:Button ID="btnCancelImport" runat="server" Text="Hủy" OnClick="btnCloseImportModal_Click" CssClass="px-4 py-2 border rounded-md text-sm" CausesValidation="false" />
                    <asp:Button ID="btnConfirmImport" runat="server" Text="Nhập File" OnClick="btnConfirmImport_Click" CssClass="px-4 py-2 bg-primary text-white rounded-md text-sm hover:bg-opacity-90" />
                </div>
             </div>
        </div>
    </asp:Panel>
    
    <%-- Notification Panel (can be reused from MasterPage or specific here) --%>
    <asp:Panel ID="pnlAdminNotification" runat="server" Visible="false" CssClass="notification-settings fixed bottom-5 right-5 bg-white shadow-lg rounded-lg border-l-4 p-4 min-w-[280px] z-[100]">
        <div class="flex items-start">
            <asp:Literal ID="litNotificationIcon" runat="server"></asp:Literal> <%-- <i class="fas fa-check-circle text-green-500 text-xl"></i> --%>
            <div class="ml-3 flex-1">
                <asp:Label ID="lblNotificationTitle" runat="server" CssClass="text-sm font-medium text-gray-800"></asp:Label>
                <asp:Label ID="lblNotificationMessage" runat="server" CssClass="text-sm text-gray-600"></asp:Label>
            </div>
            <asp:LinkButton ID="btnCloseNotification" runat="server" OnClick="btnCloseNotification_Click" CssClass="ml-4 text-gray-400 hover:text-gray-600"><i class="fas fa-times"></i></asp:LinkButton>
        </div>
    </asp:Panel>
</asp:Content>

<asp:Content ID="AdminScriptsSettings" ContentPlaceHolderID="AdminScriptsContent" runat="server">
     <script type="text/javascript">
        let currentAdminSettingsTab = 'general';

        function switchAdminSettingsTab(tabName, buttonElement) {
            document.querySelectorAll('.tab-button-settings').forEach(btn => btn.classList.remove('active', 'text-primary', 'border-primary'));
            buttonElement.classList.add('active', 'text-primary', 'border-primary');
            
            // ASP.NET Panels will handle visibility, this is just for client-side specific logic if any for showing/hiding
            // If not using UpdatePanel for tabs, this would be direct DOM manipulation like:
            // document.querySelectorAll('.tab-content-settings').forEach(content => content.style.display = 'none');
            // document.getElementById('content-' + tabName).style.display = 'block';
        }
        
        function toggleAdminSwitch(checkboxId) {
            const checkbox = document.getElementById(checkboxId);
            const visualSwitch = checkbox.nextElementSibling; // Assuming the visual div is next
            if (checkbox && visualSwitch) {
                visualSwitch.classList.toggle('active', checkbox.checked);
            }
        }
        
        // Client-side preview for FileUpload
        function previewAdminImage(fileUploadClientId, previewImageClientId) {
            const input = document.getElementById(fileUploadClientId);
            const preview = document.getElementById(previewImageClientId);
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function (e) {
                    preview.src = e.target.result;
                    preview.style.display = 'block';
                }
                reader.readAsDataURL(input.files[0]);
            } else {
                preview.style.display = 'none';
                preview.src = '#';
            }
        }
        
        // Hook up image previews
        document.addEventListener('DOMContentLoaded', function () {
            const fuLogoCtrl = document.getElementById('<%= fuLogo.ClientID %>');
            if(fuLogoCtrl) fuLogoCtrl.addEventListener('change', function() { previewAdminImage(this.id, '<%= imgLogoPreview.ClientID %>'); });
            
            const fuFaviconCtrl = document.getElementById('<%= fuFavicon.ClientID %>');
            if(fuFaviconCtrl) fuFaviconCtrl.addEventListener('change', function() { previewAdminImage(this.id, '<%= imgFaviconPreview.ClientID %>'); });
            
            // Initialize default tab
            const defaultTabButton = document.getElementById('<%= tabBtnGeneral.ClientID %>');
            if(defaultTabButton) switchAdminSettingsTab('general', defaultTabButton);
            
            // Initialize toggle switches based on CheckBox state (if not handled by server-side rendering of class)
            document.querySelectorAll('.toggle-switch-settings-aspnet').forEach(cb => {
                 toggleAdminSwitch(cb.id); // Initial state
                 cb.addEventListener('change', function() { toggleAdminSwitch(this.id); });
            });

             // Active state for mobile bottom nav
            const currentPath = window.location.pathname.toLowerCase();
            const bottomNavLinks = document.querySelectorAll('.bottom-nav .nav-item');
            let settingsLinkManuallyActivated = false;

            bottomNavLinks.forEach(link => {
                const linkHref = link.getAttribute('href');
                if (!linkHref) return;
                const linkPath = new URL(linkHref, window.location.origin).pathname.toLowerCase();
                
                if (currentPath.includes('settings.aspx') && linkPath.includes('settings.aspx')) { 
                    link.classList.add('active');
                    link.classList.remove('text-gray-600');
                    settingsLinkManuallyActivated = true;
                } else if (!settingsLinkManuallyActivated && currentPath === linkPath) {
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

        // For modals controlled by server-side visibility
        function setupSettingsModalClose() {
            const modals = document.querySelectorAll('.modal-admin-settings');
            modals.forEach(modal => {
                modal.addEventListener('click', function(e) {
                    if (e.target === this) { // Clicked on overlay
                        const closeButtonId = modal.id === '<%= pnlImportModal.ClientID %>' ? '<%= btnCloseImportModal.ClientID %>' : null;
                        if(closeButtonId) {
                             const closeButton = document.getElementById(closeButtonId);
                             if(closeButton) closeButton.click(); 
                        } else {
                             this.style.display = 'none'; 
                        }
                         document.body.style.overflow = 'auto';
                    }
                });
            });
        }
        
        if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function() { 
                setupSettingsModalClose(); 
                document.querySelectorAll('.toggle-switch-settings-aspnet').forEach(cb => toggleAdminSwitch(cb.id));
            });
        }
        // Notification JS - can be reused or part of master
        function showAdminNotification(title, message, type) {
            const notifPanel = document.getElementById('<%= pnlAdminNotification.ClientID %>');
            const titleEl = document.getElementById('<%= lblNotificationTitle.ClientID %>');
            const msgEl = document.getElementById('<%= lblNotificationMessage.ClientID %>');
            const iconEl = document.getElementById('<%= litNotificationIcon.ClientID %>'); // Will be span
            
            if (!notifPanel || !titleEl || !msgEl || !iconEl) return;

            titleEl.innerText = title;
            msgEl.innerText = message;
            
            notifPanel.className = 'notification-settings fixed bottom-5 right-5 bg-white shadow-lg rounded-lg border-l-4 p-4 min-w-[280px] z-[100] transform transition-transform duration-300'; // Reset classes
            iconEl.innerHTML = ''; // Clear previous icon
            let iconHTML = '';

            switch(type) {
                case 'success': notifPanel.classList.add('border-green-500'); iconHTML = '<i class="fas fa-check-circle text-green-500 text-xl mr-3"></i>'; break;
                case 'error': notifPanel.classList.add('border-red-500'); iconHTML = '<i class="fas fa-times-circle text-red-500 text-xl mr-3"></i>'; break;
                case 'warning': notifPanel.classList.add('border-yellow-500'); iconHTML = '<i class="fas fa-exclamation-triangle text-yellow-500 text-xl mr-3"></i>'; break;
                default: notifPanel.classList.add('border-blue-500'); iconHTML = '<i class="fas fa-info-circle text-blue-500 text-xl mr-3"></i>'; break;
            }
            iconEl.innerHTML = iconHTML;
            notifPanel.style.transform = 'translateX(0)';
            notifPanel.style.display = 'flex'; // if it was hidden

            setTimeout(() => {
                notifPanel.style.transform = 'translateX(110%)';
                setTimeout(() => { notifPanel.style.display = 'none';}, 300);
            }, 5000);
        }
        function closeAdminNotification() {
            const notifPanel = document.getElementById('<%= pnlAdminNotification.ClientID %>');
            if(notifPanel) {
                 notifPanel.style.transform = 'translateX(110%)';
                 setTimeout(() => { notifPanel.style.display = 'none';}, 300);
            }
        }
     </script>
</asp:Content>