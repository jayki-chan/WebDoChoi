<%@ Page Title="Blog - ToyLand" Language="C#" MasterPageFile="/Site.Master" AutoEventWireup="true" CodeBehind="Blog.aspx.cs" Inherits="WebsiteDoChoi.Client.Blog" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="head" runat="server">
    <%-- Tailwind CSS and Font Awesome are likely in Site.Master. If not, include them. --%>
    <%-- <script src="https://cdn.tailwindcss.com"></script> --%>
    <%-- <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" /> --%>

    <script>
        // Ensure Tailwind config is loaded, preferably from Site.Master.
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

        /* body { font-family: "Baloo 2", cursive; } /* Likely in Site.Master */

        .blog-card:hover {
            transform: translateY(-5px);
            transition: transform 0.3s ease;
        }

        .category-tag:hover {
            transform: scale(1.05);
            transition: transform 0.2s ease;
        }

        /* Bottom Navigation Styles - Likely from Site.Master or global CSS */
        .bottom-nav { position: fixed; bottom: 0; left: 0; right: 0; background: white; border-top: 1px solid #e5e7eb; z-index: 50; box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1); }
        .nav-item { transition: all 0.3s ease; }
        .nav-item.active { color: #FF6B6B; transform: translateY(-2px); }
        .nav-item:not(.active):hover { color: #FF6B6B; }

        @media (max-width: 767px) {
            body { padding-bottom: 80px; } /* For bottom nav */
            .desktop-nav { display: none !important; }
        }
        @media (min-width: 768px) {
            .bottom-nav { display: none !important; }
            /* body { padding-bottom: 0; } */
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

    <div class="bg-gradient-to-r from-primary to-secondary py-12">
        <div class="container mx-auto px-4 text-center">
            <h1 class="text-4xl font-bold text-white mb-4">Blog ToyLand</h1>
            <p class="text-white text-lg">Chia sẻ kiến thức về đồ chơi và phát triển trẻ em</p>
            <nav class="mt-4">
                <ol class="flex justify-center items-center space-x-2 text-white">
                    <li><asp:HyperLink ID="lnkBreadcrumbHome" runat="server" NavigateUrl="/Client/Default.aspx" CssClass="hover:underline">Trang chủ</asp:HyperLink></li>
                    <li><i class="fas fa-chevron-right text-sm"></i></li>
                    <li>Blog</li>
                </ol>
            </nav>
        </div>
    </div>

    <div class="container mx-auto px-4 py-8">
        <div class="flex flex-col lg:flex-row gap-8">
            <div class="lg:w-2/3">
                <asp:Panel ID="pnlFeaturedPost" runat="server" CssClass="bg-white rounded-lg shadow-lg overflow-hidden mb-8">
                    <div class="relative">
                        <asp:Image ID="imgFeaturedPost" runat="server" ImageUrl="https://api.placeholder.com/800/400?text=Featured" AlternateText="Bài viết nổi bật" CssClass="w-full h-64 object-cover" />
                        <div class="absolute top-4 left-4">
                            <span class="bg-primary text-white px-3 py-1 rounded-full text-sm font-medium">Nổi bật</span>
                        </div>
                    </div>
                    <div class="p-6">
                        <div class="flex items-center text-sm text-gray-500 mb-3 flex-wrap">
                            <i class="fas fa-calendar mr-2"></i>
                            <asp:Literal ID="litFeaturedPostDate" runat="server" Text="22/05/2025"></asp:Literal>
                            <i class="fas fa-user ml-4 mr-2"></i>
                            <asp:Literal ID="litFeaturedPostAuthor" runat="server" Text="Admin ToyLand"></asp:Literal>
                            <i class="fas fa-eye ml-4 mr-2"></i>
                            <asp:Literal ID="litFeaturedPostViews" runat="server" Text="1,245 lượt xem"></asp:Literal>
                        </div>
                        <h2 class="text-2xl font-bold text-dark mb-3">
                            <asp:HyperLink ID="hlFeaturedPostTitle" runat="server" NavigateUrl="#" CssClass="hover:text-primary transition-colors">
                                7 Lợi ích tuyệt vời của đồ chơi giáo dục cho sự phát triển của trẻ
                            </asp:HyperLink>
                        </h2>
                        <asp:Literal ID="litFeaturedPostExcerpt" runat="server" Text="Đồ chơi giáo dục không chỉ mang lại niềm vui cho trẻ mà còn có vai trò quan trọng trong việc phát triển trí tuệ, kỹ năng vận động và khả năng sáng tạo. Hãy cùng khám phá những lợi ích tuyệt vời này..."></asp:Literal>
                        <div class="flex items-center justify-between mt-4">
                            <div class="flex space-x-2">
                                <asp:Repeater ID="rptFeaturedPostTags" runat="server">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="hlTag" runat="server" NavigateUrl='<%# Eval("TagUrl") %>' CssClass='<%# Eval("TagCssClass") %>'>
                                            <%# Eval("TagName") %>
                                        </asp:HyperLink>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                            <asp:HyperLink ID="hlFeaturedPostReadMore" runat="server" NavigateUrl="#" CssClass="text-primary hover:underline font-medium">Đọc tiếp →</asp:HyperLink>
                        </div>
                    </div>
                </asp:Panel>

                <div class="grid md:grid-cols-2 gap-6 mb-8">
                    <asp:Repeater ID="rptBlogPosts" runat="server">
                        <ItemTemplate>
                            <article class="blog-card bg-white rounded-lg shadow-md overflow-hidden">
                                <asp:HyperLink ID="hlPostImageLink" runat="server" NavigateUrl='<%# Eval("PostUrl") %>'>
                                    <asp:Image ID="imgPost" runat="server" ImageUrl='<%# Eval("ImageUrl", "https://api.placeholder.com/400/250?text=Blog") %>' AlternateText='<%# Eval("Title") %>' CssClass="w-full h-48 object-cover" />
                                </asp:HyperLink>
                                <div class="p-5">
                                    <div class="flex items-center text-xs text-gray-500 mb-2">
                                        <i class="fas fa-calendar mr-1"></i>
                                        <span><%# Eval("DatePublished", "{0:dd/MM/yyyy}") %></span>
                                        <i class="fas fa-comment ml-3 mr-1"></i>
                                        <span><%# Eval("CommentCount") %> bình luận</span>
                                    </div>
                                    <h3 class="text-lg font-bold text-dark mb-2">
                                        <asp:HyperLink ID="hlPostTitle" runat="server" NavigateUrl='<%# Eval("PostUrl") %>' Text='<%# Eval("Title") %>' CssClass="hover:text-primary transition-colors"></asp:HyperLink>
                                    </h3>
                                    <p class="text-gray-600 text-sm mb-3 line-clamp-3"><%# Eval("Excerpt") %></p>
                                    <div class="flex items-center justify-between">
                                        <asp:Repeater ID="rptPostTags" runat="server" DataSource='<%# Eval("Tags") %>'>
                                            <ItemTemplate>
                                                 <asp:HyperLink ID="hlPostTag" runat="server" NavigateUrl='<%# Eval("TagUrl") %>' Text='<%# Eval("TagName") %>' CssClass='<%# Eval("TagCssClass") + " px-2 py-1 rounded text-xs" %>'></asp:HyperLink>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                        <asp:HyperLink ID="hlReadMore" runat="server" NavigateUrl='<%# Eval("PostUrl") %>' CssClass="text-primary text-sm hover:underline">Xem thêm</asp:HyperLink>
                                    </div>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <asp:Panel ID="pnlNoPosts" runat="server" Visible="false" CssClass="text-center py-10">
                    <p class="text-gray-600">Không tìm thấy bài viết nào phù hợp.</p>
                </asp:Panel>

                <div class="flex justify-center mt-8">
                    <div class="flex space-x-1">
                        <asp:LinkButton ID="lnkPrevPage" runat="server" OnClick="lnkPage_Click" CommandArgument="Prev" CssClass="px-3 py-2 rounded bg-gray-200 text-gray-600 hover:bg-primary hover:text-white transition-colors">
                            <i class="fas fa-chevron-left"></i>
                        </asp:LinkButton>
                        <asp:Repeater ID="rptPagination" runat="server" OnItemCommand="rptPagination_ItemCommand">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkPage" runat="server"
                                    Text='<%# Eval("PageNumber") %>'
                                    CommandName="Page" CommandArgument='<%# Eval("PageNumber") %>'
                                    CssClass='<%# Convert.ToBoolean(Eval("IsCurrentPage")) ? "px-3 py-2 rounded bg-primary text-white" : "px-3 py-2 rounded bg-gray-200 text-gray-600 hover:bg-primary hover:text-white transition-colors" %>'>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:LinkButton ID="lnkNextPage" runat="server" OnClick="lnkPage_Click" CommandArgument="Next" CssClass="px-3 py-2 rounded bg-gray-200 text-gray-600 hover:bg-primary hover:text-white transition-colors">
                             <i class="fas fa-chevron-right"></i>
                        </asp:LinkButton>
                    </div>
                </div>
            </div>

            <aside class="lg:w-1/3">
                <div class="bg-white rounded-lg shadow-md p-6 mb-6">
                    <h3 class="text-lg font-bold text-dark border-b border-gray-200 pb-3 mb-4">Tìm kiếm</h3>
                    <div class="relative flex">
                        <asp:TextBox ID="txtSearchBlog" runat="server" placeholder="Tìm kiếm bài viết..." CssClass="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-l-lg focus:outline-none focus:border-primary"></asp:TextBox>
                        <i class="fas fa-search absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"></i>
                        <asp:Button ID="btnSearchBlog" runat="server" OnClick="btnSearchBlog_Click" Text="Tìm" CssClass="bg-primary text-white px-4 py-2 rounded-r-lg hover:bg-opacity-90 transition-colors" />
                    </div>
                </div>

                <div class="bg-white rounded-lg shadow-md p-6 mb-6">
                    <h3 class="text-lg font-bold text-dark border-b border-gray-200 pb-3 mb-4">Chủ đề</h3>
                    <div class="space-y-2">
                        <asp:Repeater ID="rptCategories" runat="server">
                            <ItemTemplate>
                                <asp:HyperLink ID="hlCategory" runat="server" NavigateUrl='<%# Eval("CategoryUrl") %>' CssClass="category-tag flex items-center justify-between text-gray-700 hover:text-primary transition-colors p-2 rounded hover:bg-gray-50">
                                    <span><i class='<%# Eval("CategoryIconCss") %> mr-2'></i> <%# Eval("CategoryName") %></span>
                                    <span class="text-xs bg-gray-200 text-gray-600 px-2 py-1 rounded-full"><%# Eval("PostCount") %></span>
                                </asp:HyperLink>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>

                <div class="bg-white rounded-lg shadow-md p-6 mb-6">
                    <h3 class="text-lg font-bold text-dark border-b border-gray-200 pb-3 mb-4">Bài viết phổ biến</h3>
                    <div class="space-y-4">
                        <asp:Repeater ID="rptPopularPosts" runat="server">
                            <ItemTemplate>
                                <div class="flex items-start">
                                    <asp:HyperLink ID="hlPopularPostImageLink" runat="server" NavigateUrl='<%# Eval("PostUrl") %>'>
                                        <asp:Image ID="imgPopularPost" runat="server" ImageUrl='<%# Eval("ImageUrl", "https://api.placeholder.com/80/60?text=Popular") %>' AlternateText='<%# Eval("Title") %>' CssClass="w-16 h-12 object-cover rounded mr-3 flex-shrink-0" />
                                    </asp:HyperLink>
                                    <div>
                                        <h4 class="text-sm font-medium text-gray-800 line-clamp-2">
                                             <asp:HyperLink ID="hlPopularPostTitle" runat="server" NavigateUrl='<%# Eval("PostUrl") %>' Text='<%# Eval("Title") %>' CssClass="hover:text-primary transition-colors"></asp:HyperLink>
                                        </h4>
                                        <div class="text-xs text-gray-500 mt-1"><i class="fas fa-eye mr-1"></i><%# Eval("ViewCount") %> lượt xem</div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>

                <div class="bg-gradient-to-br from-primary to-secondary rounded-lg p-6 text-white mb-6">
                    <h3 class="text-lg font-bold mb-3">Đăng ký nhận tin</h3>
                    <p class="text-sm mb-4">Nhận những bài viết mới nhất về đồ chơi và nuôi dạy con</p>
                    <div class="flex">
                        <asp:TextBox ID="txtNewsletterEmail" runat="server" TextMode="Email" placeholder="Email của bạn" CssClass="w-full px-3 py-2 rounded-l text-gray-800 focus:outline-none"></asp:TextBox>
                        <asp:Button ID="btnNewsletterSubscribe" runat="server" OnClick="btnNewsletterSubscribe_Click" Text="Đăng ký" CssClass="bg-white text-primary px-4 py-2 rounded-r font-medium hover:bg-gray-100 transition-colors" />
                    </div>
                     <asp:Label ID="lblNewsletterMessage" runat="server" CssClass="text-xs mt-2 block"></asp:Label>
                </div>

                <div class="bg-white rounded-lg shadow-md p-6">
                    <h3 class="text-lg font-bold text-dark border-b border-gray-200 pb-3 mb-4">Tags phổ biến</h3>
                    <div class="flex flex-wrap gap-2">
                        <asp:Repeater ID="rptTags" runat="server">
                            <ItemTemplate>
                                <asp:HyperLink ID="hlTag" runat="server" NavigateUrl='<%# Eval("TagUrl") %>' Text='<%# Eval("TagName") %>' CssClass='<%# Eval("TagCssClass") + " px-3 py-1 rounded-full text-sm hover:text-white transition-colors cursor-pointer" %>'></asp:HyperLink>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </aside>
        </div>
    </div>

    <asp:LinkButton ID="btnBackToTop" runat="server" CssClass="fixed bottom-20 right-4 bg-primary text-white w-10 h-10 rounded-full flex items-center justify-center shadow-lg z-40 hover:bg-dark transition-colors" Style="display: none;" OnClientClick="window.scrollTo({ top: 0, behavior: 'smooth' }); return false;">
        <i class="fas fa-arrow-up"></i>
    </asp:LinkButton>

     <script type="text/javascript">
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

        // Active state for mobile bottom nav (based on current page URL)
        document.addEventListener('DOMContentLoaded', function () {
            const currentPath = window.location.pathname.toLowerCase();
            const bottomNavLinks = document.querySelectorAll('.bottom-nav .nav-item');
            let blogLinkManuallyActivated = false;

            bottomNavLinks.forEach(link => {
                const linkHref = link.getAttribute('href');
                if (!linkHref) return;
                const linkPath = new URL(linkHref, window.location.origin).pathname.toLowerCase();
                
                if (currentPath.includes('blog.aspx') && linkPath.includes('blog.aspx')) {
                    link.classList.add('active');
                    link.classList.remove('text-gray-600');
                    blogLinkManuallyActivated = true;
                } else if (!blogLinkManuallyActivated && currentPath === linkPath) {
                    link.classList.add('active');
                    link.classList.remove('text-gray-600');
                }
                else {
                    link.classList.remove('active');
                    link.classList.add('text-gray-600');
                }
            });
        });

        // Placeholder for client-side interactions if any (e.g., search input handling before postback)
     </script>
</asp:Content>