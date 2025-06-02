<%@ Page Title="" Language="C#" MasterPageFile="/Site.Master" AutoEventWireup="true" CodeBehind="BlogDetails.aspx.cs" Inherits="WebsiteDoChoi.Client.BlogDetails" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="head" runat="server">
    <%-- Tailwind CSS and Font Awesome are likely in Site.Master. --%>
    <script>
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
        /* body { font-family: "Baloo 2", cursive; } */

        .article-content h2 { @apply text-2xl font-bold text-dark mt-8 mb-4; }
        .article-content h3 { @apply text-xl font-semibold text-dark mt-6 mb-3; }
        .article-content p { @apply text-gray-700 leading-relaxed mb-4; }
        .article-content ul { @apply list-disc list-inside mb-4 pl-4 text-gray-700; }
        .article-content ol { @apply list-decimal list-inside mb-4 pl-4 text-gray-700; }
        .article-content li { @apply mb-2; }
        .article-content blockquote { @apply border-l-4 border-primary bg-primary bg-opacity-5 p-4 italic my-6 text-gray-600; }
        .article-content a { @apply text-primary hover:underline; }
        .article-content img { @apply rounded-lg shadow-md my-6 mx-auto; max-width: 100%; height: auto; }


        .social-share-btn:hover { transform: translateY(-2px); transition: transform 0.2s ease; }
        .comment-item { border-left: 3px solid transparent; transition: border-color 0.3s ease; }
        .comment-item:hover { border-left-color: #FF6B6B; } /* primary color */

        /* Bottom Navigation Styles - Likely from Site.Master or global CSS */
        .bottom-nav { position: fixed; bottom: 0; left: 0; right: 0; background: white; border-top: 1px solid #e5e7eb; z-index: 50; box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1); }
        .nav-item { transition: all 0.3s ease; }
        .nav-item.active { color: #FF6B6B; transform: translateY(-2px); }
        .nav-item:not(.active):hover { color: #FF6B6B; }

        @media (max-width: 767px) {
            body { padding-bottom: 80px; }
            .desktop-nav { display: none !important; }
        }
        @media (min-width: 768px) {
            .bottom-nav { display: none !important; }
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
             <asp:HyperLink ID="lnkBlogBottomNav" runat="server" NavigateUrl="/Client/Blog.aspx" CssClass="nav-item active flex flex-col items-center py-1 px-2 text-center min-w-0"> <%-- Mark Blog as active --%>
                <i class="fas fa-newspaper text-lg mb-1"></i><span class="text-xs truncate">Blog</span>
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
            <nav class="text-sm">
                <ol class="flex items-center space-x-2 text-gray-600 flex-wrap">
                    <li><asp:HyperLink ID="lnkBreadcrumbHome" runat="server" NavigateUrl="/Client/Default.aspx" CssClass="hover:text-primary transition-colors">Trang chủ</asp:HyperLink></li>
                    <li><i class="fas fa-chevron-right text-xs"></i></li>
                    <li><asp:HyperLink ID="lnkBreadcrumbBlog" runat="server" NavigateUrl="/Client/Blog.aspx" CssClass="hover:text-primary transition-colors">Blog</asp:HyperLink></li>
                    <asp:Panel ID="pnlBreadcrumbCategory" runat="server" Visible="false" CssClass="contents">
                        <li><i class="fas fa-chevron-right text-xs"></i></li>
                        <li><asp:HyperLink ID="lnkBreadcrumbCategory" runat="server" CssClass="hover:text-primary transition-colors"></asp:HyperLink></li>
                    </asp:Panel>
                    <li><i class="fas fa-chevron-right text-xs"></i></li>
                    <li class="text-gray-500"><asp:Literal ID="litBreadcrumbPostTitle" runat="server"></asp:Literal></li>
                </ol>
            </nav>
        </div>
    </div>

    <div class="container mx-auto px-4 py-8">
        <asp:Panel ID="pnlPostNotFound" runat="server" Visible="false" CssClass="text-center py-16">
            <i class="fas fa-exclamation-triangle fa-4x text-red-500 mb-4"></i>
            <h2 class="text-2xl font-bold text-dark mb-4">Không tìm thấy bài viết</h2>
            <p class="text-gray-600 mb-6">Bài viết bạn đang tìm kiếm không tồn tại hoặc đã bị xóa.</p>
            <asp:HyperLink ID="lnkGoToBlog" runat="server" NavigateUrl="/Client/Blog.aspx" CssClass="bg-primary text-white px-6 py-3 rounded-lg hover:bg-opacity-90 transition-colors">
                Quay lại trang Blog
            </asp:HyperLink>
        </asp:Panel>

        <asp:Panel ID="pnlPostContentArea" runat="server">
            <div class="flex flex-col lg:flex-row gap-8">
                <div class="lg:w-2/3">
                    <article class="bg-white rounded-lg shadow-lg overflow-hidden">
                        <div class="relative">
                            <asp:Image ID="imgPostHeader" runat="server" AlternateText="Hình ảnh bài viết" CssClass="w-full h-64 md:h-96 object-cover" />
                            <div class="absolute bottom-4 left-4">
                                <asp:HyperLink ID="hlPostCategoryTag" runat="server" CssClass="bg-secondary text-white px-4 py-2 rounded-full font-medium"></asp:HyperLink>
                            </div>
                        </div>
                        <div class="p-6 md:p-8">
                            <div class="flex flex-wrap items-center text-sm text-gray-500 mb-4 gap-x-4 gap-y-2">
                                <div class="flex items-center"><i class="fas fa-calendar mr-2 text-primary"></i><asp:Literal ID="litPostDate" runat="server"></asp:Literal></div>
                                <div class="flex items-center"><i class="fas fa-user mr-2 text-primary"></i><asp:Literal ID="litPostAuthor" runat="server"></asp:Literal></div>
                                <div class="flex items-center"><i class="fas fa-eye mr-2 text-primary"></i><asp:Literal ID="litPostViews" runat="server"></asp:Literal> lượt xem</div>
                                <div class="flex items-center"><i class="fas fa-comment mr-2 text-primary"></i><asp:Literal ID="litPostCommentCount" runat="server"></asp:Literal> bình luận</div>
                                <div class="flex items-center"><i class="fas fa-clock mr-2 text-primary"></i><asp:Literal ID="litPostReadingTime" runat="server"></asp:Literal> phút đọc</div>
                            </div>
                            <h1 class="text-3xl md:text-4xl font-bold text-dark mb-6"><asp:Literal ID="litPostTitle" runat="server"></asp:Literal></h1>
                            <div class="flex items-center justify-between border-b border-gray-200 pb-6 mb-8">
                                <div class="flex items-center space-x-3">
                                    <span class="text-gray-600 font-medium">Chia sẻ:</span>
                                    <asp:HyperLink ID="hlShareFacebook" runat="server" Target="_blank" CssClass="social-share-btn bg-blue-600 text-white w-10 h-10 rounded-full flex items-center justify-center hover:bg-blue-700 transition-colors"><i class="fab fa-facebook-f"></i></asp:HyperLink>
                                    <asp:HyperLink ID="hlShareTwitter" runat="server" Target="_blank" CssClass="social-share-btn bg-blue-400 text-white w-10 h-10 rounded-full flex items-center justify-center hover:bg-blue-500 transition-colors"><i class="fab fa-twitter"></i></asp:HyperLink>
                                    <asp:HyperLink ID="hlShareWhatsapp" runat="server" Target="_blank" CssClass="social-share-btn bg-green-500 text-white w-10 h-10 rounded-full flex items-center justify-center hover:bg-green-600 transition-colors"><i class="fab fa-whatsapp"></i></asp:HyperLink>
                                    <asp:HyperLink ID="hlSharePinterest" runat="server" Target="_blank" CssClass="social-share-btn bg-red-500 text-white w-10 h-10 rounded-full flex items-center justify-center hover:bg-red-600 transition-colors"><i class="fab fa-pinterest"></i></asp:HyperLink>
                                    <asp:LinkButton ID="btnCopyLink" runat="server" OnClientClick="copyLinkToClipboard(); return false;" CssClass="social-share-btn bg-gray-600 text-white w-10 h-10 rounded-full flex items-center justify-center hover:bg-gray-700 transition-colors"><i class="fas fa-link"></i></asp:LinkButton>
                                </div>
                                <div class="flex items-center space-x-3">
                                    <asp:LinkButton ID="btnLikePost" runat="server" OnClick="btnLikePost_Click" CssClass="flex items-center text-gray-600 hover:text-red-500 transition-colors">
                                        <i id="iconLikePost" runat="server" class="far fa-heart mr-1"></i> <%-- fas fa-heart when liked --%>
                                        <asp:Label ID="lblLikeCount" runat="server" Text="0"></asp:Label>
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnSavePost" runat="server" OnClick="btnSavePost_Click" CssClass="flex items-center text-gray-600 hover:text-primary transition-colors">
                                        <i id="iconSavePost" runat="server" class="far fa-bookmark mr-1"></i> <%-- fas fa-bookmark when saved --%>
                                        <span>Lưu</span>
                                    </asp:LinkButton>
                                </div>
                            </div>
                            <div class="article-content">
                                <asp:Literal ID="litPostContent" runat="server" Mode="PassThrough"></asp:Literal>
                            </div>
                            <div class="border-t border-gray-200 pt-6 mt-8">
                                <h3 class="text-lg font-bold text-dark mb-3">Tags:</h3>
                                <div class="flex flex-wrap gap-2">
                                    <asp:Repeater ID="rptPostTags" runat="server">
                                        <ItemTemplate>
                                            <asp:HyperLink ID="hlTag" runat="server" NavigateUrl='<%# Eval("TagUrl") %>' Text='<%# Eval("TagName") %>' CssClass='<%# Eval("TagCssClass") + " px-3 py-1 rounded-full text-sm hover:text-white transition-colors cursor-pointer" %>'></asp:HyperLink>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </div>
                        </div>
                    </article>

                    <asp:Panel ID="pnlAuthorInfo" runat="server" Visible="false" CssClass="bg-white rounded-lg shadow-md p-6 mt-8">
                        <div class="flex items-start">
                            <asp:Image ID="imgAuthorAvatar" runat="server" AlternateText="Tác giả" CssClass="w-16 h-16 rounded-full mr-4 flex-shrink-0" />
                            <div class="flex-grow">
                                <h3 class="text-lg font-bold text-dark mb-1"><asp:Literal ID="litAuthorName" runat="server"></asp:Literal></h3>
                                <p class="text-sm text-gray-600 mb-3"><asp:Literal ID="litAuthorTitle" runat="server"></asp:Literal></p>
                                <p class="text-gray-700 text-sm mb-3"><asp:Literal ID="litAuthorBio" runat="server"></asp:Literal></p>
                                <div class="flex space-x-3">
                                    <asp:HyperLink ID="hlAuthorFacebook" runat="server" Visible="false" Target="_blank" CssClass="text-blue-600 hover:text-blue-700"><i class="fab fa-facebook"></i></asp:HyperLink>
                                    <asp:HyperLink ID="hlAuthorTwitter" runat="server" Visible="false" Target="_blank" CssClass="text-blue-400 hover:text-blue-500"><i class="fab fa-twitter"></i></asp:HyperLink>
                                    <asp:HyperLink ID="hlAuthorInstagram" runat="server" Visible="false" Target="_blank" CssClass="text-pink-600 hover:text-pink-700"><i class="fab fa-instagram"></i></asp:HyperLink>
                                    <asp:HyperLink ID="hlAuthorEmail" runat="server" Visible="false"><i class="fas fa-envelope text-gray-600 hover:text-gray-700"></i></asp:HyperLink>
                                </div>
                            </div>
                        </div>
                    </asp:Panel>

                    <asp:Panel ID="pnlRelatedPosts" runat="server" Visible="false" CssClass="bg-white rounded-lg shadow-md p-6 mt-8">
                        <h3 class="text-xl font-bold text-dark border-b border-gray-200 pb-3 mb-6">Bài viết liên quan</h3>
                        <div class="grid md:grid-cols-2 gap-6">
                            <asp:Repeater ID="rptRelatedPosts" runat="server">
                                <ItemTemplate>
                                    <article class="flex">
                                        <asp:HyperLink ID="hlRelatedPostImageLink" runat="server" NavigateUrl='<%# Eval("PostUrl") %>'>
                                            <asp:Image ID="imgRelatedPost" runat="server" ImageUrl='<%# Eval("ImageUrl", "https://api.placeholder.com/120/80?text=Related") %>' AlternateText='<%# Eval("Title") %>' CssClass="w-24 h-20 object-cover rounded mr-4 flex-shrink-0" />
                                        </asp:HyperLink>
                                        <div>
                                            <h4 class="font-medium text-gray-800 line-clamp-2 mb-1">
                                                <asp:HyperLink ID="hlRelatedPostTitle" runat="server" NavigateUrl='<%# Eval("PostUrl") %>' Text='<%# Eval("Title") %>' CssClass="hover:text-primary transition-colors"></asp:HyperLink>
                                            </h4>
                                            <div class="text-xs text-gray-500"><i class="fas fa-calendar mr-1"></i> <%# Eval("DatePublished", "{0:dd/MM/yyyy}") %></div>
                                        </div>
                                    </article>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </asp:Panel>

                    <div class="bg-white rounded-lg shadow-md p-6 mt-8">
                        <h3 class="text-xl font-bold text-dark border-b border-gray-200 pb-3 mb-6">
                            Bình luận (<asp:Literal ID="litCommentSectionCount" runat="server" Text="0"></asp:Literal>)
                        </h3>
                        <div class="mb-8">
                            <h4 class="text-lg font-semibold text-dark mb-4">Để lại bình luận</h4>
                            <div class="space-y-4">
                                <div class="grid md:grid-cols-2 gap-4">
                                    <asp:TextBox ID="txtCommentName" runat="server" placeholder="Họ và tên *" CssClass="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-primary"></asp:TextBox>
                                    <asp:TextBox ID="txtCommentEmail" runat="server" TextMode="Email" placeholder="Email *" CssClass="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-primary"></asp:TextBox>
                                </div>
                                <asp:TextBox ID="txtCommentContent" runat="server" TextMode="MultiLine" Rows="4" placeholder="Nội dung bình luận *" CssClass="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-primary resize-none"></asp:TextBox>
                                <div class="flex items-center">
                                    <asp:CheckBox ID="chkSaveCommentInfo" runat="server" Text="Lưu thông tin của tôi cho lần bình luận tiếp theo" CssClass="mr-2" />
                                </div>
                                <asp:Button ID="btnSubmitComment" runat="server" Text="Gửi bình luận" OnClick="btnSubmitComment_Click" CssClass="bg-primary text-white px-6 py-3 rounded-lg hover:bg-opacity-90 transition-colors font-medium" ValidationGroup="Comment" />
                                <asp:RequiredFieldValidator ID="rfvCommentName" runat="server" ControlToValidate="txtCommentName" ErrorMessage="Vui lòng nhập họ tên." CssClass="text-red-500 text-xs" Display="Dynamic" ValidationGroup="Comment"></asp:RequiredFieldValidator>
                                <asp:RequiredFieldValidator ID="rfvCommentEmail" runat="server" ControlToValidate="txtCommentEmail" ErrorMessage="Vui lòng nhập email." CssClass="text-red-500 text-xs" Display="Dynamic" ValidationGroup="Comment"></asp:RequiredFieldValidator>
                                <asp:RegularExpressionValidator ID="revCommentEmail" runat="server" ControlToValidate="txtCommentEmail" ErrorMessage="Email không hợp lệ." ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="text-red-500 text-xs" Display="Dynamic" ValidationGroup="Comment"></asp:RegularExpressionValidator>
                                <asp:RequiredFieldValidator ID="rfvCommentContent" runat="server" ControlToValidate="txtCommentContent" ErrorMessage="Vui lòng nhập nội dung bình luận." CssClass="text-red-500 text-xs" Display="Dynamic" ValidationGroup="Comment"></asp:RequiredFieldValidator>
                                <asp:Literal ID="litCommentStatus" runat="server"></asp:Literal>
                            </div>
                        </div>
                        <div class="space-y-6">
                            <asp:Repeater ID="rptComments" runat="server" OnItemCommand="rptComments_ItemCommand">
                                <ItemTemplate>
                                    <div class="comment-item bg-gray-50 rounded-lg p-4">
                                        <div class="flex items-start">
                                            <asp:Image ID="imgCommenterAvatar" runat="server" ImageUrl='<%# Eval("AvatarUrl", "https://api.placeholder.com/50/50?text=User") %>' AlternateText="Avatar" CssClass="w-12 h-12 rounded-full mr-3 flex-shrink-0" />
                                            <div class="flex-grow">
                                                <div class="flex items-center justify-between mb-2">
                                                    <div>
                                                        <h5 class="font-semibold text-dark"><%# Eval("AuthorName") %></h5>
                                                        <div class="text-xs text-gray-500"><span><%# Eval("CommentDate", "{0:dd/MM/yyyy - HH:mm}") %></span>
                                                            <asp:Label ID="lblAuthorBadge" runat="server" Text="Tác giả" CssClass="bg-primary text-white px-2 py-0.5 rounded-full ml-2 text-xs" Visible='<%# Convert.ToBoolean(Eval("IsAuthor")) %>' />
                                                        </div>
                                                    </div>
                                                    <asp:LinkButton ID="btnReplyComment" runat="server" CommandName="Reply" CommandArgument='<%# Eval("CommentId") %>' CssClass="text-gray-400 hover:text-primary transition-colors"><i class="fas fa-reply"></i></asp:LinkButton>
                                                </div>
                                                <p class="text-gray-700 mb-3"><%# Eval("Content") %></p>
                                                <div class="flex items-center space-x-4 text-sm">
                                                    <asp:LinkButton ID="btnLikeComment" runat="server" CommandName="Like" CommandArgument='<%# Eval("CommentId") %>' CssClass="flex items-center text-gray-500 hover:text-primary transition-colors">
                                                        <i class='<%# Convert.ToBoolean(Eval("IsLikedByCurrentUser")) ? "fas" : "far" %> fa-thumbs-up mr-1'></i>
                                                        <span><%# Eval("LikeCount") %></span>
                                                    </asp:LinkButton>
                                                    <%-- Reply form can be a hidden panel toggled by JS/C# --%>
                                                </div>
                                            </div>
                                        </div>
                                        <%-- Placeholder for nested replies, could use another Repeater here --%>
                                        <div class="ml-12 mt-4 space-y-4">
                                             <asp:Repeater ID="rptReplies" runat="server" DataSource='<%# Eval("Replies") %>'>
                                                 <ItemTemplate>
                                                      <div class="comment-item bg-white rounded-lg p-4">
                                                          <div class="flex items-start">
                                                            <asp:Image ID="imgReplyAvatar" runat="server" ImageUrl='<%# Eval("AvatarUrl", "https://api.placeholder.com/40/40?text=Reply") %>' AlternateText="Avatar" CssClass="w-10 h-10 rounded-full mr-3 flex-shrink-0" />
                                                            <div class="flex-grow">
                                                                <div class="flex items-center justify-between mb-1">
                                                                    <div>
                                                                        <h6 class="font-semibold text-dark text-sm"><%# Eval("AuthorName") %></h6>
                                                                        <div class="text-xs text-gray-500"><span><%# Eval("CommentDate", "{0:dd/MM/yyyy - HH:mm}") %></span>
                                                                            <asp:Label ID="lblReplyAuthorBadge" runat="server" Text="Tác giả" CssClass="bg-primary text-white px-1 py-0.5 rounded-full ml-1 text-2xs" Visible='<%# Convert.ToBoolean(Eval("IsAuthor")) %>' />
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <p class="text-gray-700 text-sm"><%# Eval("Content") %></p>
                                                            </div>
                                                          </div>
                                                      </div>
                                                 </ItemTemplate>
                                             </asp:Repeater>
                                         </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                        <asp:Panel ID="pnlNoComments" runat="server" Visible="false" CssClass="text-center py-6">
                            <p class="text-gray-500">Chưa có bình luận nào. Hãy là người đầu tiên bình luận!</p>
                        </asp:Panel>
                        <asp:Button ID="btnLoadMoreComments" runat="server" OnClick="btnLoadMoreComments_Click" Text="Xem thêm bình luận" CssClass="mt-6 bg-gray-200 text-gray-700 px-6 py-2 rounded-lg hover:bg-gray-300 transition-colors w-full md:w-auto" Visible="false" />
                    </div>
                </div>

                <aside class="lg:w-1/3">
                    <asp:Panel ID="pnlTableOfContents" runat="server" CssClass="bg-white rounded-lg shadow-md p-6 mb-6 sticky top-24" Visible="false">
                         <h3 class="text-lg font-bold text-dark border-b border-gray-200 pb-3 mb-4">Mục lục</h3>
                         <ul id="tocList" class="space-y-2 text-sm">
                             <%-- Populated by JavaScript or server-side if simple enough --%>
                         </ul>
                    </asp:Panel>

                    <asp:Panel ID="pnlPopularPostsSidebar" runat="server" CssClass="bg-white rounded-lg shadow-md p-6 mb-6">
                        <h3 class="text-lg font-bold text-dark border-b border-gray-200 pb-3 mb-4">Bài viết phổ biến</h3>
                        <div class="space-y-4">
                            <asp:Repeater ID="rptPopularPostsSidebar" runat="server">
                                <ItemTemplate>
                                    <div class="flex items-start">
                                        <asp:HyperLink ID="hlPopularPostImageLinkSidebar" runat="server" NavigateUrl='<%# Eval("PostUrl") %>'>
                                            <asp:Image ID="imgPopularPostSidebar" runat="server" ImageUrl='<%# Eval("ImageUrl", "https://api.placeholder.com/80/60?text=Popular") %>' AlternateText='<%# Eval("Title") %>' CssClass="w-16 h-12 object-cover rounded mr-3 flex-shrink-0" />
                                        </asp:HyperLink>
                                        <div>
                                            <h4 class="text-sm font-medium text-gray-800 line-clamp-2"><asp:HyperLink ID="hlPopularPostTitleSidebar" runat="server" NavigateUrl='<%# Eval("PostUrl") %>' Text='<%# Eval("Title") %>' CssClass="hover:text-primary transition-colors"></asp:HyperLink></h4>
                                            <div class="text-xs text-gray-500 mt-1"><i class="fas fa-eye mr-1"></i><%# Eval("ViewCount") %> lượt xem</div>
                                        </div>
                                    </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </asp:Panel>
                    
                    <asp:Panel ID="pnlCategoriesSidebar" runat="server" CssClass="bg-white rounded-lg shadow-md p-6 mb-6">
                        <h3 class="text-lg font-bold text-dark border-b border-gray-200 pb-3 mb-4">Chủ đề</h3>
                        <div class="space-y-2">
                             <asp:Repeater ID="rptCategoriesSidebar" runat="server">
                                <ItemTemplate>
                                    <asp:HyperLink ID="hlCategorySidebar" runat="server" NavigateUrl='<%# Eval("CategoryUrl") %>' CssClass="category-tag flex items-center justify-between text-gray-700 hover:text-primary transition-colors p-2 rounded hover:bg-gray-50">
                                        <span><i class='<%# Eval("CategoryIconCss") %> mr-2'></i> <%# Eval("CategoryName") %></span>
                                        <span class="text-xs bg-gray-200 text-gray-600 px-2 py-1 rounded-full"><%# Eval("PostCount") %></span>
                                    </asp:HyperLink>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </asp:Panel>

                     <div class="bg-gradient-to-br from-primary to-secondary rounded-lg p-6 text-white mb-6">
                        <h3 class="text-lg font-bold mb-3">Đăng ký nhận tin</h3>
                        <p class="text-sm mb-4">Nhận những bài viết mới nhất về đồ chơi và nuôi dạy con</p>
                        <div class="flex">
                            <asp:TextBox ID="txtNewsletterEmailSidebar" runat="server" TextMode="Email" placeholder="Email của bạn" CssClass="w-full px-3 py-2 rounded-l text-gray-800 focus:outline-none"></asp:TextBox>
                            <asp:Button ID="btnNewsletterSubscribeSidebar" runat="server" OnClick="btnNewsletterSubscribe_Click" Text="Đăng ký" CssClass="bg-white text-primary px-4 py-2 rounded-r font-medium hover:bg-gray-100 transition-colors" />
                        </div>
                        <asp:Label ID="lblNewsletterMessageSidebar" runat="server" CssClass="text-xs mt-2 block"></asp:Label>
                    </div>

                    <asp:Panel ID="pnlAdSidebar" runat="server" CssClass="bg-white rounded-lg shadow-md overflow-hidden">
                        <asp:HyperLink ID="hlAdLinkSidebar" runat="server" Target="_blank">
                             <asp:Image ID="imgAdSidebar" runat="server" ImageUrl="https://api.placeholder.com/400/600/4ECDC4/FFFFFF?text=Đồ+chơi+giáo+dục+giảm+30%25" AlternateText="Quảng cáo" CssClass="w-full" />
                        </asp:HyperLink>
                    </asp:Panel>
                </aside>
            </div>
        </asp:Panel> <%-- End of pnlPostContentArea --%>
    </div>

    <asp:LinkButton ID="btnBackToTop" runat="server" CssClass="fixed bottom-20 right-4 bg-primary text-white w-10 h-10 rounded-full flex items-center justify-center shadow-lg z-40 hover:bg-dark transition-colors" Style="display: none;" OnClientClick="window.scrollTo({ top: 0, behavior: 'smooth' }); return false;">
        <i class="fas fa-arrow-up"></i>
    </asp:LinkButton>

    <script type="text/javascript">
        function copyLinkToClipboard() {
            navigator.clipboard.writeText(window.location.href)
                .then(() => alert("Đã sao chép link bài viết!"))
                .catch(err => console.error('Không thể sao chép link: ', err));
            return false; // Prevent postback if it's an asp:LinkButton
        }

        function generateTableOfContents() {
            const articleContent = document.querySelector('.article-content');
            const tocList = document.getElementById('tocList'); // Ul element in sidebar
            const tocPanel = document.getElementById('<%= pnlTableOfContents.ClientID %>');

            if (!articleContent || !tocList || !tocPanel) return;
            tocList.innerHTML = ''; // Clear existing items
            
            let hasHeadings = false;
            articleContent.querySelectorAll('h2, h3').forEach((heading, index) => {
                hasHeadings = true;
                const id = 'section-' + (index + 1);
                heading.id = id; // Add id to heading for linking
                
                const listItem = document.createElement('li');
                if (heading.tagName === 'H3') {
                    listItem.classList.add('ml-4'); // Indent H3
                }
                const link = document.createElement('a');
                link.href = '#' + id;
                link.textContent = heading.textContent;
                link.classList.add('text-gray-600', 'hover:text-primary', 'transition-colors', 'block', 'py-1');
                
                link.addEventListener('click', function(e) {
                    e.preventDefault();
                    document.querySelector(this.getAttribute('href')).scrollIntoView({
                        behavior: 'smooth',
                        block: 'start' 
                    });
                });
                
                listItem.appendChild(link);
                tocList.appendChild(listItem);
            });
            if(tocPanel) tocPanel.style.display = hasHeadings ? 'block' : 'none';
        }


        document.addEventListener('DOMContentLoaded', function () {
            // Back to Top
            const backToTopBtn = document.getElementById('<%= btnBackToTop.ClientID %>');
            if (backToTopBtn) {
                window.addEventListener("scroll", () => {
                    if (window.scrollY > 300) backToTopBtn.style.display = "flex";
                    else backToTopBtn.style.display = "none";
                });
            }

            // Active state for mobile bottom nav
            const currentPath = window.location.pathname.toLowerCase();
            const bottomNavLinks = document.querySelectorAll('.bottom-nav .nav-item');
            let blogDetailLinkActivated = false; // To ensure blog link is active on detail page

            bottomNavLinks.forEach(link => {
                const linkHref = link.getAttribute('href');
                if (!linkHref) return;
                const linkPath = new URL(linkHref, window.location.origin).pathname.toLowerCase();
                
                // Prioritize activating "Blog" if on a blog detail page
                if (currentPath.includes('blogdetails.aspx') && linkPath.includes('blog.aspx')) {
                     link.classList.add('active');
                     link.classList.remove('text-gray-600');
                     blogDetailLinkActivated = true;
                } else if (!blogDetailLinkActivated && currentPath === linkPath) {
                    link.classList.add('active');
                    link.classList.remove('text-gray-600');
                } else {
                    link.classList.remove('active');
                    if (!link.classList.contains('active')) { // Don't remove gray if it's already active from blogdetails rule
                        link.classList.add('text-gray-600');
                    }
                }
            });
            
            generateTableOfContents();

            // Client-side comment "like" (visual only, server should handle actual liking)
            document.querySelectorAll('.comment-item .fa-thumbs-up').forEach(button => {
                button.closest('button').addEventListener('click', function(e) {
                    // This is a placeholder. Real like functionality needs server interaction.
                    // e.preventDefault(); 
                    // const countSpan = this.querySelector('span');
                    // let count = parseInt(countSpan.textContent);
                    // if (this.querySelector('i').classList.contains('far')) { // If not liked
                    //     this.querySelector('i').classList.replace('far', 'fas');
                    //     count++;
                    // } else {
                    //     this.querySelector('i').classList.replace('fas', 'far');
                    //     count--;
                    // }
                    // countSpan.textContent = count;
                });
            });
        });
    </script>
</asp:Content>