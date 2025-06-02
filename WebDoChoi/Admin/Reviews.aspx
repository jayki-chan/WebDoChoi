<%@ Page Title="Quản lý Đánh giá - ToyLand Admin" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="Reviews.aspx.cs" Inherits="WebsiteDoChoi.Admin.Reviews" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitleContent" runat="server">
    <h1 class="text-xl md:text-2xl font-bold text-gray-800">Quản lý Đánh giá</h1>
</asp:Content>

<asp:Content ID="AdminHeadReviews" ContentPlaceHolderID="AdminHeadContent" runat="server">
    <%-- Chart.js is in Admin.Master --%>
    <style>
        .review-card-admin { transition: all 0.2s ease-out; border-left-width: 4px; border-left-style: solid; }
        .review-card-admin:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0,0,0,0.07); }
        
        .review-card-admin.status-pending { border-left-color: #FFE66D; /* accent */ }
        .review-card-admin.status-approved { border-left-color: #4ECDC4; /* secondary */ }
        .review-card-admin.status-rejected { border-left-color: #FF6B6B; /* primary */ opacity:0.8; }
        .review-card-admin.status-reported { border-left-color: #EF4444; /* Tailwind red-500 */ background-color: rgba(239,68,68,0.05); }


        .star-rating-admin .star-filled { color: #fbbf24; /* Tailwind yellow-500 */ }
        .star-rating-admin .star-empty { color: #d1d5db; /* Tailwind gray-300 */ }

        .modal-admin-review { backdrop-filter: blur(5px); }
        .chart-container-admin-review { position: relative; height: 280px; }
        
        .review-images-admin { display: grid; grid-template-columns: repeat(auto-fill, minmax(50px, 1fr)); gap: 0.5rem; max-width: 250px; }
        .review-images-admin img { aspect-ratio: 1; object-fit: cover; border-radius: 0.375rem; cursor: pointer; border: 1px solid #e5e7eb; }
        .review-images-admin img:hover { transform: scale(1.05); border-color: #FF6B6B; }

        .review-content-admin { max-height: 6em; /* Approx 4 lines */ overflow: hidden; position: relative; line-height:1.5em; }
        .review-content-admin.expanded { max-height: none; }
        .read-more-btn-admin { color: #FF6B6B; cursor: pointer; font-weight: 500; }
        .read-more-btn-admin:hover { text-decoration: underline; }
        
        .action-dropdown-review { opacity: 0; visibility:hidden; transform: translateY(-10px); transition: opacity 0.2s ease, visibility 0s 0.2s linear, transform 0.2s ease; }
        .action-dropdown-review.show { opacity: 1; visibility:visible; transform: translateY(0); transition: opacity 0.2s ease, visibility 0s 0s linear, transform 0.2s ease; }
        
        .filter-badge-admin { background: rgba(255, 107, 107, 0.1); color: #FF6B6B; border: 1px solid rgba(255, 107, 107, 0.2); }

        .lightbox-review { position: fixed; inset: 0; background: rgba(0,0,0,0.85); z-index: 9999; display: flex; align-items: center; justify-content: center; opacity: 0; visibility: hidden; transition: all 0.3s ease; }
        .lightbox-review.show { opacity: 1; visibility: visible; }
        .lightbox-review img { max-width: 90vw; max-height: 85vh; object-fit: contain; border-radius: 4px; }
        .lightbox-review .close-lightbox { position: absolute; top: 1rem; right: 1rem; color: white; font-size: 1.5rem; cursor: pointer; }
        
        .response-area-admin { max-height: 0; overflow: hidden; transition: max-height 0.3s ease-out, padding 0.3s ease-out, margin 0.3s ease-out; padding-top:0; padding-bottom:0; margin-top:0;}
        .response-area-admin.show { max-height: 300px; padding-top:1rem; padding-bottom:1rem; margin-top:1rem;}

        .bulk-actions-bar { transform: translateY(-100%); opacity: 0; transition: all 0.3s ease-out; position:sticky; top: 0; z-index:45; /* Below sidebar overlay, above content */ }
        .bulk-actions-bar.show { transform: translateY(0); opacity: 1; }
        
        .modal-body-reviews-scrollable { max-height: calc(100vh - 200px); overflow-y: auto; }
        .modal-body-reviews-scrollable::-webkit-scrollbar { width: 6px; }
        .modal-body-reviews-scrollable::-webkit-scrollbar-track { background: #f1f5f9; }
        .modal-body-reviews-scrollable::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius:3px; }

    </style>
</asp:Content>

<asp:Content ID="MainAdminContentReviews" ContentPlaceHolderID="AdminMainContent" runat="server">
     <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <asp:UpdatePanel ID="upnlReviewsPage" runat="server">
        <ContentTemplate>
            <div class="bg-white shadow-sm px-4 md:px-6 py-3 border-b border-gray-200 sticky top-0 z-30 md:relative"> {/* md:relative to allow bulk bar to slide under on desktop */}
                <div class="flex items-center justify-between">
                    <h2 class="text-lg font-semibold text-gray-700">Quản lý Đánh giá</h2>
                    <div class="flex items-center space-x-2">
                       <span class="hidden sm:inline">Xuất</span>
                      <span class="hidden sm:inline">Thao tác</span>
                    </div>
                </div>
            </div>

             <asp:Panel ID="pnlBulkActionsBar" runat="server" Visible="false" CssClass="bulk-actions-bar bg-gradient-to-r from-blue-500 to-purple-600 text-white px-4 md:px-6 py-3 shadow-md">
                <div class="flex items-center justify-between">
                    <div class="flex items-center space-x-4">
                        <div class="flex items-center">
                            <asp:CheckBox ID="chkSelectAll" runat="server" AutoPostBack="false" onchange="toggleSelectAllReviews(this.checked);" CssClass="rounded border-white text-blue-600 focus:ring-blue-500" />
                            <label for="<%= chkSelectAll.ClientID %>" class="ml-2 text-sm">Chọn tất cả</label>
                        </div>
                        <asp:Label ID="lblSelectedReviewsCount" runat="server" Text="0 đánh giá được chọn" CssClass="text-sm"></asp:Label>
                    </div>
                    <div class="flex items-center space-x-2">
                        <asp:Button ID="btnBulkApprove" runat="server" OnClick="btnBulkApprove_Click" Text="Duyệt" CssClass="bg-white bg-opacity-20 hover:bg-opacity-30 px-3 py-1 rounded text-sm transition-colors" />
                        <asp:Button ID="btnBulkReject" runat="server" OnClick="btnBulkReject_Click" Text="Từ chối" CssClass="bg-white bg-opacity-20 hover:bg-opacity-30 px-3 py-1 rounded text-sm transition-colors" />
                        <asp:Button ID="btnBulkDelete" runat="server" OnClick="btnBulkDelete_Click" Text="Xóa" CssClass="bg-red-500 hover:bg-red-600 px-3 py-1 rounded text-sm transition-colors" OnClientClick="return confirm('Xác nhận xóa các đánh giá đã chọn?');" />
                        <asp:LinkButton ID="btnCloseBulkBar" runat="server" OnClick="btnCloseBulkBar_Click" CssClass="text-white hover:text-gray-200 p-1"><i class="fas fa-times"></i></asp:LinkButton>
                    </div>
                </div>
            </asp:Panel>

            <div class="p-4 md:p-6">
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4 md:gap-6 mb-6">
                    <div class="stats-card-primary rounded-xl p-3 text-white"><div class="flex items-center justify-between"><div><p class="text-white text-opacity-80 text-xs">Tổng đánh giá</p><asp:Label ID="lblTotalReviews" runat="server" Text="0" CssClass="text-lg font-bold"></asp:Label></div><div class="w-8 h-8 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-comments text-base"></i></div></div></div>
                    <div class="stats-card-accent rounded-xl p-3 text-dark"><div class="flex items-center justify-between"><div><p class="text-dark text-opacity-80 text-xs">Chờ duyệt</p><asp:Label ID="lblPendingReviews" runat="server" Text="0" CssClass="text-lg font-bold"></asp:Label></div><div class="w-8 h-8 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-clock text-base text-dark"></i></div></div></div>
                    <div class="stats-card-secondary rounded-xl p-3 text-white"><div class="flex items-center justify-between"><div><p class="text-white text-opacity-80 text-xs">Đã duyệt</p><asp:Label ID="lblApprovedReviews" runat="server" Text="0" CssClass="text-lg font-bold"></asp:Label></div><div class="w-8 h-8 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-check-double text-base"></i></div></div></div>
                    <div class="stats-card rounded-xl p-3 text-white"><div class="flex items-center justify-between"><div><p class="text-white text-opacity-80 text-xs">Rating TB</p><asp:Label ID="lblAverageRating" runat="server" Text="0.0" CssClass="text-lg font-bold"></asp:Label></div><div class="w-8 h-8 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-star-half-alt text-base"></i></div></div></div>
                    <div class="stats-card-dark rounded-xl p-3 text-white"><div class="flex items-center justify-between"><div><p class="text-white text-opacity-80 text-xs">Báo cáo</p><asp:Label ID="lblReportedReviews" runat="server" Text="0" CssClass="text-lg font-bold"></asp:Label></div><div class="w-8 h-8 bg-white bg-opacity-20 rounded-lg flex items-center justify-center"><i class="fas fa-flag text-base"></i></div></div></div>
                </div>

                 <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 md:gap-6 mb-6">
                    <div class="bg-white rounded-xl shadow-sm p-4 md:p-6"><div class="flex items-center justify-between mb-4"><h3 class="text-base font-bold text-gray-800">Phân bố đánh giá</h3></div><div class="chart-container-admin-review"><canvas id="adminRatingChart"></canvas></div></div>
                    <div class="bg-white rounded-xl shadow-sm p-4 md:p-6"><div class="flex items-center justify-between mb-4"><h3 class="text-base font-bold text-gray-800">Đánh giá theo thời gian</h3><asp:DropDownList ID="ddlTimelinePeriod" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlTimelinePeriod_SelectedIndexChanged" CssClass="border border-gray-300 rounded-lg px-2 py-1 text-xs focus:outline-none focus:border-primary"><asp:ListItem Value="7days">7 ngày</asp:ListItem><asp:ListItem Value="30days" Selected="True">30 ngày</asp:ListItem><asp:ListItem Value="90days">90 ngày</asp:ListItem></asp:DropDownList></div><div class="chart-container-admin-review"><canvas id="adminTimelineChart"></canvas></div></div>
                </div>

                <div class="bg-white rounded-xl shadow-sm p-4 md:p-6 mb-6">
                     <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4 items-end">
                        <div class="relative lg:col-span-2"><label class="block text-sm font-medium text-gray-700 mb-1">Tìm kiếm</label><asp:TextBox ID="txtSearchReviews" runat="server" placeholder="Nội dung, sản phẩm, KH..." CssClass="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-primary w-full"></asp:TextBox><i class="fas fa-search absolute left-3 bottom-2.5 text-gray-400"></i></div>
                        <div><label class="block text-sm font-medium text-gray-700 mb-1">Trạng thái</label><asp:DropDownList ID="ddlReviewStatusFilter" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary"><asp:ListItem Value="">Tất cả</asp:ListItem><asp:ListItem Value="pending">Chờ duyệt</asp:ListItem><asp:ListItem Value="approved">Đã duyệt</asp:ListItem><asp:ListItem Value="rejected">Từ chối</asp:ListItem><asp:ListItem Value="reported">Báo cáo</asp:ListItem></asp:DropDownList></div>
                        <div><label class="block text-sm font-medium text-gray-700 mb-1">Rating</label><asp:DropDownList ID="ddlRatingFilter" runat="server" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary"><asp:ListItem Value="">Tất cả</asp:ListItem><asp:ListItem Value="5">5 sao</asp:ListItem><asp:ListItem Value="4">4 sao</asp:ListItem><asp:ListItem Value="3">3 sao</asp:ListItem><asp:ListItem Value="2">2 sao</asp:ListItem><asp:ListItem Value="1">1 sao</asp:ListItem></asp:DropDownList></div>
                         <div><label class="block text-sm font-medium text-gray-700 mb-1">Sản phẩm</label><asp:DropDownList ID="ddlProductFilter" runat="server" DataTextField="ProductName" DataValueField="ProductId" CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:border-primary"><asp:ListItem Value="">Tất cả SP</asp:ListItem></asp:DropDownList></div>
                        <div class="flex space-x-2">
                            <asp:Button ID="btnApplyReviewFilters" runat="server" Text="Lọc" OnClick="btnApplyReviewFilters_Click" CssClass="w-full sm:w-auto px-4 py-2 bg-secondary text-white rounded-lg hover:bg-opacity-90" />
                            <asp:Button ID="btnResetReviewFilters" runat="server" Text="Reset" OnClick="btnResetReviewFilters_Click" CssClass="w-full sm:w-auto px-4 py-2 bg-gray-500 hover:bg-gray-600 text-white rounded-lg" CausesValidation="false"/>
                        </div>
                    </div>
                     <asp:Panel ID="pnlActiveFilters" runat="server" Visible="false" CssClass="mt-3">
                         <div class="flex flex-wrap gap-2 items-center">
                             <span class="text-sm text-gray-600">Đang lọc theo:</span>
                             <asp:Repeater ID="rptActiveFilters" runat="server" OnItemCommand="rptActiveFilters_ItemCommand">
                                 <ItemTemplate>
                                     <span class="filter-badge-admin px-2 py-1 rounded-full text-xs flex items-center">
                                         <%# Eval("FilterText") %>
                                         <asp:LinkButton ID="btnRemoveFilter" runat="server" CommandName='<%# Eval("FilterType") %>' CommandArgument='<%# Eval("FilterValue") %>' CssClass="ml-1.5 text-primary hover:text-red-700"><i class="fas fa-times-circle text-xs"></i></asp:LinkButton>
                                     </span>
                                 </ItemTemplate>
                             </asp:Repeater>
                         </div>
                     </asp:Panel>
                </div>

                <div class="space-y-4 md:space-y-5" id="reviewsListContainer">
                    <asp:Repeater ID="rptReviews" runat="server" OnItemCommand="rptReviews_ItemCommand">
                        <ItemTemplate>
                            <div class='review-card-admin bg-white rounded-xl shadow-sm p-4 <%# Eval("CardCssClass") %>' data-review-id='<%# Eval("ReviewId") %>' data-status='<%# Eval("Status") %>' data-rating='<%# Eval("Rating") %>' data-product-id='<%# Eval("ProductId") %>'>
                                <div class="flex items-start space-x-3">
                                    <asp:CheckBox ID="chkReviewSelect" runat="server" CssClass="review-checkbox mt-1.5 rounded border-gray-300 text-primary focus:ring-primary" data-reviewid='<%# Eval("ReviewId") %>' onchange="updateBulkSelection();" />
                                    <asp:Image ID="imgReviewProduct" runat="server" ImageUrl='<%# Eval("ProductImageUrl", "https://api.placeholder.com/80/80?text=Toy") %>' AlternateText='<%# Eval("ProductName") %>' CssClass="w-16 h-16 md:w-20 md:h-20 object-cover rounded-lg flex-shrink-0" />
                                    <div class="flex-1 min-w-0">
                                        <div class="flex flex-col sm:flex-row sm:items-start sm:justify-between mb-2">
                                            <div>
                                                <h4 class="font-semibold text-gray-800 text-sm md:text-base"><%# Eval("ProductName") %></h4>
                                                <div class="flex items-center flex-wrap gap-x-3 gap-y-1 text-xs text-gray-500">
                                                    <span><%# Eval("CustomerName") %></span> <span class="hidden sm:inline">•</span> <span><%# Eval("ReviewDate", "{0:dd/MM/yyyy HH:mm}") %></span>
                                                    <asp:Label ID="lblVerifiedPurchase" runat="server" Visible='<%# Convert.ToBoolean(Eval("IsVerifiedPurchase")) %>' CssClass="flex items-center text-green-600"><i class="fas fa-check-circle mr-1"></i>Đã mua hàng</asp:Label>
                                                </div>
                                            </div>
                                            <div class="flex items-center space-x-2 mt-2 sm:mt-0">
                                                <asp:Label ID="lblReviewStatusBadge" runat="server" Text='<%# Eval("StatusText") %>' CssClass='<%# Eval("StatusBadgeCss") + " px-2 py-0.5 rounded-full text-2xs font-medium whitespace-nowrap" %>' />
                                                <div class="relative">
                                                    <asp:LinkButton ID="btnReviewActions" runat="server" CommandName="ToggleDropdown" CommandArgument='<%# Eval("ReviewId") %>' OnClientClick='<%# "toggleAdminDropdown(event, \"reviewActionDropdown-" + Eval("ReviewId") + "\"); return false;" %>' CssClass="text-gray-400 hover:text-gray-600 p-1"><i class="fas fa-ellipsis-v"></i></asp:LinkButton>
                                                    <div id='<%# "reviewActionDropdown-" + Eval("ReviewId") %>' class="action-dropdown-review hidden absolute right-0 mt-1 w-40 bg-white rounded-md shadow-lg border z-20">
                                                        <asp:LinkButton ID="btnApproveReview" runat="server" CommandName="Approve" CommandArgument='<%# Eval("ReviewId") %>' Visible='<%# Eval("Status").ToString() != "approved" %>' CssClass="w-full text-left block px-3 py-1.5 text-xs text-green-600 hover:bg-gray-50"><i class="fas fa-check w-4 mr-1.5"></i>Duyệt</asp:LinkButton>
                                                        <asp:LinkButton ID="btnRejectReview" runat="server" CommandName="Reject" CommandArgument='<%# Eval("ReviewId") %>' Visible='<%# Eval("Status").ToString() != "rejected" %>' CssClass="w-full text-left block px-3 py-1.5 text-xs text-red-600 hover:bg-gray-50"><i class="fas fa-times w-4 mr-1.5"></i>Từ chối</asp:LinkButton>
                                                        <asp:LinkButton ID="btnRespondReview" runat="server" CommandName="Respond" CommandArgument='<%# Eval("ReviewId") %>' CssClass="w-full text-left block px-3 py-1.5 text-xs text-blue-600 hover:bg-gray-50"><i class="fas fa-reply w-4 mr-1.5"></i>Phản hồi</asp:LinkButton>
                                                        <asp:LinkButton ID="btnViewReviewDetail" runat="server" CommandName="ViewDetail" CommandArgument='<%# Eval("ReviewId") %>' CssClass="w-full text-left block px-3 py-1.5 text-xs text-gray-700 hover:bg-gray-50"><i class="fas fa-eye w-4 mr-1.5"></i>Xem chi tiết</asp:LinkButton>
                                                        <hr class="my-0.5" />
                                                        <span>Xóa</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="flex items-center space-x-1 mb-2 mt-1 star-rating-admin">
                                            <span class="text-xs text-gray-500">(<%# Eval("Rating", "{0:F1}") %>)</span>
                                            <span class="text-sm font-medium text-gray-800 ml-2"><%# Eval("ReviewTitle") %></span>
                                        </div>
                                        <div class='review-content-admin text-sm text-gray-700 mb-2' id='<%# "reviewContent-" + Eval("ReviewId") %>'><p><%# Eval("ReviewText") %></p></div>
                                        <asp:LinkButton ID="btnReadMore" runat="server" Text="Xem thêm" OnClientClick='<%# "toggleReviewContent(this, \"reviewContent-" + Eval("ReviewId") + "\"); return false;" %>' CssClass="read-more-btn-admin text-xs" Visible='<%# Eval("ReviewText").ToString().Length > 150 %>'></asp:LinkButton> <%-- Approximate length --%>
                                        
                                        <asp:Panel ID="pnlReviewImages" runat="server" Visible='<%# ((List<string>)Eval("ImageUrls")).Any() %>' CssClass="review-images-admin my-2">
                                            <asp:Repeater ID="rptReviewImages" runat="server" DataSource='<%# Eval("ImageUrls") %>'>
                                                <ItemTemplate>
                                                    <asp:ImageButton ID="imgReview" runat="server" ImageUrl='<%# Container.DataItem.ToString() %>' AlternateText="Ảnh đánh giá" OnClientClick='<%# "openAdminLightbox(\"" + Container.DataItem.ToString() + "\"); return false;" %>' CssClass="w-full h-full" />
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </asp:Panel>
                                        
                                        <div class="review-stats-mini text-xs">
                                            <div class="flex items-center text-gray-500"><i class="far fa-thumbs-up mr-1"></i> <%# Eval("HelpfulCount") %> hữu ích</div>
                                            <div class="flex items-center text-gray-500"><i class="fas fa-eye mr-1"></i> <%# Eval("ViewCount") %> xem</div>
                                            <asp:HyperLink ID="hlOrderLink" runat="server" NavigateUrl='<%# Eval("OrderId", "~/Admin/Orders.aspx?view={0}") %>' Target="_blank" CssClass="flex items-center text-blue-600 hover:underline"><i class="fas fa-shopping-bag mr-1"></i>Đơn #<%# Eval("OrderCode") %></asp:HyperLink>
                                        </asp:Panel>
                                        
                                        <asp:Panel ID="pnlAdminResponse" runat="server" Visible='<%# !string.IsNullOrEmpty(Eval("AdminResponseText")?.ToString()) %>' CssClass="mt-3 bg-blue-50 border-l-4 border-blue-400 p-3 rounded-r-md">
                                            <div class="flex items-start space-x-2">
                                                <div class="w-6 h-6 bg-blue-500 rounded-full flex items-center justify-center text-white text-2xs font-medium flex-shrink-0">A</div>
                                                <div class="flex-1"><p class="text-blue-800 text-xs font-medium">Phản hồi từ ToyLand</p><p class="text-blue-700 text-xs"><%# Eval("AdminResponseText") %></p><p class="text-2xs text-gray-400 mt-0.5">Ngày: <%# Eval("AdminResponseDate", "{0:dd/MM/yy}") %></p></div>
                                            </div>
                                        </asp:Panel>

                                        <asp:Panel ID="pnlResponseArea" runat="server" CssClass="response-area-admin mt-3 bg-gray-50 rounded-lg p-3" Visible="false">
                                            <asp:TextBox ID="txtAdminReply" runat="server" TextMode="MultiLine" Rows="2" CssClass="w-full border border-gray-300 rounded-md p-2 text-sm focus:outline-none focus:border-primary" placeholder="Nhập phản hồi của bạn..."></asp:TextBox>
                                            <div class="flex items-center justify-between mt-2">
                                                <asp:CheckBox ID="chkMakePublic" runat="server" Text="Hiện công khai" Checked="true" CssClass="text-xs text-gray-600" />
                                                <div class="flex space-x-2">
                                                    <asp:LinkButton ID="btnCancelReply" runat="server" CommandName="CancelReply" CommandArgument='<%# Eval("ReviewId") %>' Text="Hủy" CssClass="px-3 py-1 border rounded-md text-xs hover:bg-gray-100" CausesValidation="false"/>
                                                    <asp:LinkButton ID="btnSubmitReply" runat="server" CommandName="SubmitReply" CommandArgument='<%# Eval("ReviewId") %>' Text="Gửi" CssClass="px-3 py-1 bg-primary text-white rounded-md text-xs hover:bg-opacity-90"/>
                                                </div>
                                            </div>
                                        </asp:Panel>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                         <FooterTemplate><asp:Panel ID="pnlNoReviews" runat="server" Visible='<%# rptReviews.Items.Count == 0 %>'><p class="text-center py-10 text-gray-500">Không có đánh giá nào.</p></asp:Panel></FooterTemplate>
                    </asp:Repeater>
                </div>

                <div class="flex flex-col sm:flex-row items-center justify-between mt-8 space-y-4 sm:space-y-0">
                    <asp:Label ID="lblReviewPageInfo" runat="server" CssClass="text-sm text-gray-500"></asp:Label>
                    <div class="flex items-center space-x-1">
                        <asp:LinkButton ID="lnkReviewPrevPage" runat="server" OnClick="ReviewPage_Changed" CommandArgument="Prev" CssClass="px-3 py-2 border border-gray-300 rounded-lg text-sm hover:bg-gray-50"><i class="fas fa-chevron-left"></i></asp:LinkButton>
                        <asp:Repeater ID="rptReviewPager" runat="server" OnItemCommand="ReviewPage_Changed">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkReviewPageNumber" runat="server" Text='<%# Eval("Text") %>' CommandName="Page" CommandArgument='<%# Eval("Value") %>' CssClass='<%# Convert.ToBoolean(Eval("IsCurrent")) ? "px-3 py-2 bg-primary text-white rounded-lg text-sm" : "px-3 py-2 border border-gray-300 rounded-lg text-sm hover:bg-gray-50" %>'></asp:LinkButton>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:LinkButton ID="lnkReviewNextPage" runat="server" OnClick="ReviewPage_Changed" CommandArgument="Next" CssClass="px-3 py-2 border border-gray-300 rounded-lg text-sm hover:bg-gray-50"><i class="fas fa-chevron-right"></i></asp:LinkButton>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

    <div id="adminImageLightbox" class="lightbox-review" onclick="closeAdminLightbox(event)">
        <button class="close-lightbox" type="button" onclick="closeAdminLightbox(event, true)"><i class="fas fa-times"></i></button>
        <img id="adminLightboxImage" src="" alt="Ảnh đánh giá phóng to">
    </div>
    
    <asp:Panel ID="pnlDeleteReviewModal" runat="server" Visible="false" CssClass="modal-admin-review fixed inset-0 bg-black bg-opacity-75 z-[70] flex items-center justify-center p-4">
         <div class="bg-white rounded-xl w-full max-w-sm p-5 shadow-xl text-center">
            <div class="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-3"><i class="fas fa-exclamation-triangle text-red-500 text-xl"></i></div>
            <h3 class="text-md font-semibold text-gray-800 mb-2">Xác nhận xóa</h3>
            <p class="text-sm text-gray-600 mb-5">Bạn có chắc muốn xóa đánh giá "<asp:Literal ID="litDeleteReviewTitle" runat="server"></asp:Literal>"?</p>
            <div class="flex space-x-3">
                <asp:Button ID="btnCancelDeleteReview" runat="server" Text="Hủy" OnClick="btnCancelDeleteReview_Click" CssClass="flex-1 px-4 py-2 border rounded-md text-sm" CausesValidation="false" />
                <asp:Button ID="btnConfirmDeleteReview" runat="server" Text="Xóa" OnClick="btnConfirmDeleteReview_Click" CssClass="flex-1 px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded-md text-sm" />
                <asp:HiddenField ID="hfDeleteReviewId" runat="server" />
            </div>
        </div>
    </asp:Panel>
</asp:Content>

<asp:Content ID="AdminScriptsReviews" ContentPlaceHolderID="AdminScriptsContent" runat="server">
    <script type="text/javascript">
        let adminRatingChartInstance = null;
        let adminTimelineChartInstance = null;
        let currentBulkActionType = '';
        let selectedReviewIdsForBulk = [];

        function toggleAdminDropdown(event, dropdownIdSuffix) { /* ... same as previous pages ... */ }
        function getClientIdPrefixReviews() { /* ... same as previous pages, adjust for rptReviews ... */ }
        document.addEventListener('click', function(event) { /* ... same as previous pages ... */ });

        function toggleBulkActionsBar() {
            const bulkBar = document.getElementById('<%= pnlBulkActionsBar.ClientID %>');
            if(bulkBar) bulkBar.classList.toggle('show');
        }
        
        function toggleSelectAllReviews(isChecked) {
            document.querySelectorAll('.review-checkbox').forEach(cb => cb.checked = isChecked);
            updateSelectedReviewsCount();
        }
        function updateSelectedReviewsCount() {
            selectedReviewIdsForBulk = [];
            document.querySelectorAll('.review-checkbox:checked').forEach(cb => selectedReviewIdsForBulk.push(cb.dataset.reviewid));
            document.getElementById('<%= lblSelectedReviewsCount.ClientID %>').textContent = `${selectedReviewIdsForBulk.length} đánh giá được chọn`;
            
            const selectAllCheckbox = document.getElementById('<%= chkSelectAll.ClientID %>');
            const allCheckboxes = document.querySelectorAll('.review-checkbox');
            if(selectAllCheckbox && allCheckboxes.length > 0){
                selectAllCheckbox.checked = selectedReviewIdsForBulk.length === allCheckboxes.length;
                selectAllCheckbox.indeterminate = selectedReviewIdsForBulk.length > 0 && selectedReviewIdsForBulk.length < allCheckboxes.length;
            } else if (selectAllCheckbox) {
                 selectAllCheckbox.checked = false;
                 selectAllCheckbox.indeterminate = false;
            }
        }
        
        function openAdminLightbox(imageSrc) {
            const lightbox = document.getElementById('adminImageLightbox');
            const img = document.getElementById('adminLightboxImage');
            if (lightbox && img) { img.src = imageSrc; lightbox.classList.add('show'); document.body.style.overflow = 'hidden';}
        }
        function closeAdminLightbox(event, forceClose = false) {
            const lightbox = document.getElementById('adminImageLightbox');
            if (lightbox && (event.target === lightbox || forceClose)) { lightbox.classList.remove('show'); document.body.style.overflow = 'auto';}
        }
        
        function toggleReviewContent(button, contentIdSuffix) {
            const contentDiv = document.getElementById(getClientIdPrefixReviews() + contentIdSuffix);
            if (contentDiv) {
                contentDiv.classList.toggle('expanded');
                button.textContent = contentDiv.classList.contains('expanded') ? 'Thu gọn' : 'Xem thêm';
            }
        }
        
        function toggleReviewResponseArea(reviewId) { // Called by server-side or direct JS if needed
            const responseArea = document.getElementById(getClientIdPrefixReviews() + `pnlResponseArea_Review${reviewId}`); // Example IDing for repeater items
            if (responseArea) responseArea.style.display = responseArea.style.display === 'none' ? 'block' : 'none'; // Simple toggle
        }

        // Chart initializations (data from server)
        function initializeAdminReviewCharts(ratingData, timelineLabels, timelineNewData, timelineApprovedData) {
            const ratingCtx = document.getElementById('adminRatingChart');
            if (ratingCtx) {
                 if (adminRatingChartInstance) adminRatingChartInstance.destroy();
                adminRatingChartInstance = new Chart(ratingCtx.getContext('2d'), {
                    type: 'doughnut', data: { labels: ['5 sao', '4 sao', '3 sao', '2 sao', '1 sao'], datasets: [{ data: ratingData, backgroundColor: ['#10B981', '#6EE7B7', '#FDE047', '#FB923C', '#EF4444'], borderWidth:0 }] },
                    options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom', labels:{font:{size:10}, usePointStyle:true, padding:10} } } }
                });
            }
            const timelineCtx = document.getElementById('adminTimelineChart');
            if(timelineCtx) {
                 if (adminTimelineChartInstance) adminTimelineChartInstance.destroy();
                adminTimelineChartInstance = new Chart(timelineCtx.getContext('2d'), {
                    type: 'line', data: { labels: timelineLabels, datasets: [ { label: 'Đánh giá mới', data: timelineNewData, borderColor: '#FF6B6B', backgroundColor: 'rgba(255,107,107,0.1)', tension: 0.3, fill: true }, { label: 'Đã duyệt', data: timelineApprovedData, borderColor: '#4ECDC4', backgroundColor: 'rgba(78,205,196,0.1)', tension: 0.3, fill: true } ] },
                    options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'top', labels:{font:{size:10}} } }, scales: { y: { beginAtZero: true, ticks:{font:{size:10}} }, x:{ticks:{font:{size:10}}} } }
                });
            }
        }
        
         function openAdminDeleteConfirmation(itemId, itemName, itemType) {
             document.getElementById('<%= hfDeleteReviewId.ClientID %>').value = itemId; // Use review-specific hidden field
             document.getElementById('<%= litDeleteReviewTitle.ClientID %>').innerText = itemName; // Use review-specific literal
             const modal = document.getElementById('<%= pnlDeleteReviewModal.ClientID %>'); // Use review-specific modal panel
             if(modal) modal.style.display = 'flex';
             document.body.style.overflow = 'hidden';
             setupAdminReviewModalClose();
             return false;
         }
         function setupAdminReviewModalClose() { // More specific setup
            const modals = document.querySelectorAll('.modal-admin-review'); // Target review modals
            modals.forEach(modal => {
                modal.addEventListener('click', function(e) {
                    if (e.target === this) {
                        const closeButtonId = modal.id === '<%= pnlDeleteReviewModal.ClientID %>' ? '<%= btnCancelDeleteReview.ClientID %>' : null;
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

        // ASP.NET AJAX Page Load
        if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function(sender, args) {
                setupAdminReviewModalClose();
                // Re-initialize charts if they are inside the UpdatePanel (upnlReviewsPage)
                 if (window.adminReviewChartData) { // Check if server has prepared new data
                    initializeAdminReviewCharts(
                        window.adminReviewChartData.ratingData,
                        window.adminReviewChartData.timelineLabels,
                        window.adminReviewChartData.timelineNewData,
                        window.adminReviewChartData.timelineApprovedData
                    );
                 }
                 // Ensure bulk action checkboxes are reset if items changed
                 updateSelectedReviewsCount(); 
            });
        }
        document.addEventListener('DOMContentLoaded', function() {
            setupAdminReviewModalClose();
            const currentPath = window.location.pathname.toLowerCase();
            const bottomNavLinks = document.querySelectorAll('.bottom-nav .nav-item');
            let reviewLinkManuallyActivated = false;

            bottomNavLinks.forEach(link => {
                const linkHref = link.getAttribute('href');
                if (!linkHref) return;
                const linkPath = new URL(linkHref, window.location.origin).pathname.toLowerCase();
                
                if (currentPath.includes('reviews.aspx') && linkPath.includes('reviews.aspx')) { 
                    link.classList.add('active');
                    link.classList.remove('text-gray-600');
                    reviewLinkManuallyActivated = true;
                } else if (!reviewLinkManuallyActivated && currentPath === linkPath) {
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
    </script>
</asp:Content>