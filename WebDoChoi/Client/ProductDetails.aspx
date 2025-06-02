<%@ Page Title="Chi tiết sản phẩm - ToyLand" Language="C#" MasterPageFile="/Site.Master" AutoEventWireup="true" CodeBehind="ProductDetails.aspx.cs" Inherits="WebsiteDoChoi.Client.ProductDetails" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: '#FF6B6B',
                        secondary: '#4ECDC4',
                        accent: '#FFE66D',
                        dark: '#1A535C',
                        light: '#F7FFF7',
                    }
                }
            }
        }
    </script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Baloo+2:wght@400;500;600;700&display=swap');
        
        body {
            font-family: 'Baloo 2', cursive;
            padding-bottom: 80px;
        }
        
        .thumbnail:hover {
            border-color: #FF6B6B;
        }
        
        .thumbnail.active {
            border-color: #FF6B6B;
            border-width: 2px;
        }
        
        .zoom-container {
            overflow: hidden;
            cursor: zoom-in;
        }
        
        .zoom-container img {
            transition: transform 0.3s ease;
        }
        
        .zoom-container:hover img {
            transform: scale(1.2);
        }
        
        .tabs-container .tab-button.active {
            border-bottom: 2px solid #FF6B6B;
            color: #FF6B6B;
        }
        
        .review-stars {
            color: #fbbf24;
        }
        
        .progress-bar {
            background: linear-gradient(90deg, #fbbf24 var(--width), #e5e7eb var(--width));
        }

        /* Bottom Navigation Styles */
        .bottom-nav {
            position: fixed;
            bottom: 0;
            left: 0;
            right: 0;
            background: white;
            border-top: 1px solid #e5e7eb;
            z-index: 50;
            box-shadow: 0 -2px 10px rgba(0,0,0,0.1);
        }

        .nav-item {
            transition: all 0.3s ease;
        }

        .nav-item.active {
            color: #FF6B6B;
            transform: translateY(-2px);
        }

        .nav-item:not(.active):hover {
            color: #FF6B6B;
        }

        /* Hide desktop navigation on mobile */
        @media (max-width: 767px) {
            .desktop-nav {
                display: none !important;
            }
        }

        /* Show desktop navigation on desktop */
        @media (min-width: 768px) {
            .bottom-nav {
                display: none !important;
            }
            body {
                padding-bottom: 0;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Breadcrumb -->
    <div class="container mx-auto px-4 py-3">
        <nav class="text-sm">
            <ol class="flex items-center space-x-2 text-gray-600">
                <li>
                    <asp:HyperLink ID="lnkBreadcrumbHome" runat="server" NavigateUrl="/Client/Default.aspx" 
                        CssClass="hover:text-primary transition-colors">Trang chủ</asp:HyperLink>
                </li>
                <li><i class="fas fa-chevron-right text-xs"></i></li>
                <li>
                    <asp:HyperLink ID="lnkBreadcrumbCategory" runat="server" NavigateUrl="#" 
                        CssClass="hover:text-primary transition-colors">
                        <asp:Label ID="lblBreadcrumbCategory" runat="server"></asp:Label>
                    </asp:HyperLink>
                </li>
                <li><i class="fas fa-chevron-right text-xs"></i></li>
                <li class="text-gray-800">
                    <asp:Label ID="lblBreadcrumbProduct" runat="server"></asp:Label>
                </li>
            </ol>
        </nav>
    </div>

    <!-- Product Detail Content -->
    <div class="container mx-auto px-4 py-4">
        <div class="flex flex-col lg:flex-row gap-6">
            <!-- Left Side - Product Images -->
            <div class="w-full lg:w-1/2">
                <div class="bg-white rounded-lg shadow-md p-4">
                    <!-- Main Image -->
                    <div class="zoom-container rounded-lg overflow-hidden mb-4 bg-gray-100">
                        <asp:Image ID="imgMainProduct" runat="server" 
                            CssClass="w-full h-96 object-cover" 
                            AlternateText="Hình ảnh sản phẩm" />
                    </div>
                    
                    <!-- Thumbnail Images -->
                    <div class="flex space-x-2 overflow-x-auto">
                        <asp:Repeater ID="rptProductImages" runat="server">
                            <ItemTemplate>
                                <asp:Image ID="imgThumbnail" runat="server" 
                                    ImageUrl='<%# Eval("ImageUrl") %>' 
                                    AlternateText='<%# Eval("AltText") %>'
                                    CssClass='<%# Container.ItemIndex == 0 ? "thumbnail w-20 h-20 object-cover rounded-lg border-2 border-gray-200 cursor-pointer active" : "thumbnail w-20 h-20 object-cover rounded-lg border-2 border-gray-200 cursor-pointer" %>'
                                    onclick='<%# "changeMainImage(\"" + Eval("ImageUrl") + "\", this)" %>' />
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>

            <!-- Right Side - Product Info -->
            <div class="w-full lg:w-1/2">
                <div class="bg-white rounded-lg shadow-md p-6">
                    <!-- Product Title -->
                    <h1 class="text-2xl md:text-3xl font-bold text-dark mb-3">
                        <asp:Label ID="lblProductName" runat="server"></asp:Label>
                    </h1>
                    
                    <!-- Rating and Reviews -->
                    <div class="flex items-center mb-4">
                        <div class="flex text-yellow-400 text-lg">
                            <asp:Literal ID="litRatingStars" runat="server"></asp:Literal>
                        </div>
                        <span class="text-gray-600 ml-2">
                            (<asp:Label ID="lblRating" runat="server"></asp:Label>/5)
                        </span>
                        <span class="text-gray-400 mx-2">|</span>
                        <a href="#reviews" class="text-primary hover:underline">
                            <asp:Label ID="lblReviewCount" runat="server"></asp:Label> đánh giá
                        </a>
                        <span class="text-gray-400 mx-2">|</span>
                        <span='<%# Convert.ToBoolean(Eval("InStock")) ? "text-green-600" : "text-red-600" %>'>
                            <asp:Label ID="lblStockStatus" runat="server"></asp:Label>
                        </span>
                    </div>

                    <!-- Price -->
                    <div class="flex items-center mb-6">
                        <span class="text-3xl font-bold text-primary">
                            <asp:Label ID="lblPrice" runat="server"></asp:Label>đ
                        </span>
                        <asp:Panel ID="pnlOriginalPrice" runat="server" Visible="false">
                            <span class="text-gray-500 text-xl line-through ml-3">
                                <asp:Label ID="lblOriginalPrice" runat="server"></asp:Label>đ
                            </span>
                            <span class="bg-red-100 text-red-600 text-sm px-2 py-1 rounded ml-3">
                                -<asp:Label ID="lblDiscountPercent" runat="server"></asp:Label>%
                            </span>
                        </asp:Panel>
                    </div>

                    <!-- Product Features -->
                    <div class="mb-6">
                        <h3 class="font-bold text-dark mb-3">Tính năng nổi bật:</h3>
                        <ul class="space-y-2">
                            <asp:Repeater ID="rptProductFeatures" runat="server">
                                <ItemTemplate>
                                    <li class="flex items-center">
                                        <i class="fas fa-check-circle text-green-500 mr-2"></i>
                                        <span><%# Eval("FeatureName") %></span>
                                    </li>
                                </ItemTemplate>
                            </asp:Repeater>
                        </ul>
                    </div>

                    <!-- Age Group -->
                    <div class="flex items-center mb-6">
                        <span class="text-gray-700 font-medium mr-3">Độ tuổi phù hợp:</span>
                        <span class="bg-accent text-dark px-3 py-1 rounded-full font-medium">
                            <asp:Label ID="lblAgeGroup" runat="server"></asp:Label>
                        </span>
                    </div>

                    <!-- Quantity and Add to Cart -->
                    <div class="flex items-center space-x-4 mb-6">
                        <div class="flex items-center">
                            <label class="text-gray-700 font-medium mr-3">Số lượng:</label>
                            <div class="flex items-center border rounded-lg">
                                <asp:LinkButton ID="btnDecreaseQty" runat="server" 
                                    CssClass="px-3 py-2 hover:bg-gray-100" 
                                    OnClientClick="decreaseQuantity(); return false;">
                                    <i class="fas fa-minus"></i>
                                </asp:LinkButton>
                                <asp:TextBox ID="txtQuantity" runat="server" 
                                    Text="1" 
                                    TextMode="Number" 
                                    CssClass="w-16 text-center py-2 border-none focus:outline-none" 
                                    min="1" 
                                    max="99" />
                                <asp:LinkButton ID="btnIncreaseQty" runat="server" 
                                    CssClass="px-3 py-2 hover:bg-gray-100" 
                                    OnClientClick="increaseQuantity(); return false;">
                                    <i class="fas fa-plus"></i>
                                </asp:LinkButton>
                            </div>
                        </div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="space-y-3">
                        <asp:Button ID="btnAddToCart" runat="server" 
                            Text="Thêm vào giỏ hàng" 
                            CssClass="w-full bg-primary text-white py-3 rounded-lg font-bold hover:bg-red-600 transition-colors"
                            OnClick="btnAddToCart_Click" />
                        <div class="flex space-x-3">
                            <asp:LinkButton ID="btnAddToWishlist" runat="server" 
                                CssClass="flex-1 bg-secondary text-white py-3 rounded-lg font-bold hover:bg-teal-600 transition-colors text-center"
                                OnClick="btnAddToWishlist_Click">
                                <i class="fas fa-heart mr-2"></i>
                                Yêu thích
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnShare" runat="server" 
                                CssClass="flex-1 bg-dark text-white py-3 rounded-lg font-bold hover:bg-gray-800 transition-colors text-center"
                                OnClientClick="shareProduct(); return false;">
                                <i class="fas fa-share-alt mr-2"></i>
                                Chia sẻ
                            </asp:LinkButton>
                        </div>
                    </div>

                    <!-- Shipping Info -->
                    <div class="mt-6 p-4 bg-gray-50 rounded-lg">
                        <div class="space-y-2">
                            <div class="flex items-center">
                                <i class="fas fa-truck text-primary mr-2"></i>
                                <span class="text-sm">Miễn phí vận chuyển cho đơn hàng từ 500.000đ</span>
                            </div>
                            <div class="flex items-center">
                                <i class="fas fa-undo text-primary mr-2"></i>
                                <span class="text-sm">Đổi trả miễn phí trong 7 ngày</span>
                            </div>
                            <div class="flex items-center">
                                <i class="fas fa-shield-alt text-primary mr-2"></i>
                                <span class="text-sm">Bảo hành chính hãng 12 tháng</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Product Details Tabs -->
        <div class="mt-8 bg-white rounded-lg shadow-md">
            <div class="tabs-container border-b">
                <div class="flex overflow-x-auto">
                    <asp:LinkButton ID="btnTabDescription" runat="server" 
                        CssClass="tab-button px-6 py-4 font-medium text-gray-600 hover:text-primary active"
                        OnClientClick="showTab('description'); return false;">
                        Mô tả sản phẩm
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnTabSpecifications" runat="server" 
                        CssClass="tab-button px-6 py-4 font-medium text-gray-600 hover:text-primary"
                        OnClientClick="showTab('specifications'); return false;">
                        Thông số kỹ thuật
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnTabReviews" runat="server" 
                        CssClass="tab-button px-6 py-4 font-medium text-gray-600 hover:text-primary"
                        OnClientClick="showTab('reviews'); return false;">
                        Đánh giá (<asp:Label ID="lblTabReviewCount" runat="server"></asp:Label>)
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnTabShipping" runat="server" 
                        CssClass="tab-button px-6 py-4 font-medium text-gray-600 hover:text-primary"
                        OnClientClick="showTab('shipping'); return false;">
                        Vận chuyển
                    </asp:LinkButton>
                </div>
            </div>

            <!-- Tab Content -->
            <div class="p-6">
                <!-- Description Tab -->
                <div id="description" class="tab-content">
                    <h3 class="text-xl font-bold text-dark mb-4">Mô tả chi tiết sản phẩm</h3>
                    <div class="prose max-w-none">
                        <asp:Literal ID="litProductDescription" runat="server"></asp:Literal>
                    </div>
                </div>

                <!-- Specifications Tab -->
                <div id="specifications" class="tab-content hidden">
                    <h3 class="text-xl font-bold text-dark mb-4">Thông số kỹ thuật</h3>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div class="space-y-3">
                            <asp:Repeater ID="rptSpecificationsLeft" runat="server">
                                <ItemTemplate>
                                    <div class="flex justify-between border-b pb-2">
                                        <span class="font-medium"><%# Eval("SpecName") %>:</span>
                                        <span><%# Eval("SpecValue") %></span>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                        <div class="space-y-3">
                            <asp:Repeater ID="rptSpecificationsRight" runat="server">
                                <ItemTemplate>
                                    <div class="flex justify-between border-b pb-2">
                                        <span class="font-medium"><%# Eval("SpecName") %>:</span>
                                        <span><%# Eval("SpecValue") %></span>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                </div>

                <!-- Reviews Tab -->
                <div id="reviews" class="tab-content hidden">
                    <h3 class="text-xl font-bold text-dark mb-4">Đánh giá từ khách hàng</h3>
                    
                    <!-- Rating Summary -->
                    <div class="bg-gray-50 rounded-lg p-6 mb-6">
                        <div class="flex flex-col md:flex-row items-start md:items-center gap-6">
                            <div class="text-center">
                                <div class="text-4xl font-bold text-primary mb-2">
                                    <asp:Label ID="lblAverageRating" runat="server"></asp:Label>
                                </div>
                                <div class="flex text-yellow-400 mb-2">
                                    <asp:Literal ID="litAverageRatingStars" runat="server"></asp:Literal>
                                </div>
                                <div class="text-gray-600">
                                    <asp:Label ID="lblTotalReviews" runat="server"></asp:Label> đánh giá
                                </div>
                            </div>
                            <div class="flex-1">
                                <div class="space-y-2">
                                    <asp:Repeater ID="rptRatingSummary" runat="server">
                                        <ItemTemplate>
                                            <div class="flex items-center">
                                                <span class="w-8"><%# Eval("Rating") %>★</span>
                                                <div class="flex-1 mx-3 h-2 bg-gray-200 rounded">
                                                    <div class="h-full bg-yellow-400 rounded" style="width: <%# Eval("Percentage") %>%"></div>
                                                </div>
                                                <span class="text-sm text-gray-600"><%# Eval("Count") %></span>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Individual Reviews -->
                    <div class="space-y-6">
                        <asp:Repeater ID="rptReviews" runat="server">
                            <ItemTemplate>
                                <div class="border-b pb-6">
                                    <div class="flex items-start gap-4">
                                        <div class="w-10 h-10 rounded-full flex items-center justify-center text-white font-bold">
                                           NGUYEN VAN A
                                        </div>
                                        <div class="flex-1">
                                            <div class="flex items-center mb-2">
                                                <span class="font-medium text-dark"><%# Eval("CustomerName") %></span>
                                                <div class="flex text-yellow-400 ml-3">
                                                    #4.5
                                                </div>
                                                <span class="text-gray-500 text-sm ml-3"><%# Eval("ReviewDate", "{0:dd/MM/yyyy}") %></span>
                                            </div>
                                            <p class="text-gray-700 mb-2"><%# Eval("ReviewContent") %></p>
                                            <div class="flex items-center text-sm text-gray-500">
                                                <asp:LinkButton ID="btnLikeReview" runat="server" 
                                                    CommandName="LikeReview" 
                                                    CommandArgument='<%# Eval("Id") %>'
                                                    CssClass="text-primary hover:underline mr-4"
                                                    OnCommand="btnLikeReview_Command">
                                                    <i class="fas fa-thumbs-up mr-1"></i>Hữu ích (<%# Eval("LikeCount") %>)
                                                </asp:LinkButton>
                                                <button class="text-gray-400 hover:text-gray-600">Trả lời</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <!-- Load More Reviews -->
                    <div class="text-center mt-6">
                        <asp:Button ID="btnLoadMoreReviews" runat="server" 
                            Text="Xem thêm đánh giá" 
                            CssClass="px-6 py-2 border border-primary text-primary rounded-lg hover:bg-primary hover:text-white transition-colors"
                            OnClick="btnLoadMoreReviews_Click" />
                    </div>
                </div>

                <!-- Shipping Tab -->
                <div id="shipping" class="tab-content hidden">
                    <h3 class="text-xl font-bold text-dark mb-4">Thông tin vận chuyển</h3>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <h4 class="font-bold text-dark mb-3">Phí vận chuyển</h4>
                            <div class="space-y-3">
                                <asp:Repeater ID="rptShippingOptions" runat="server">
                                    <ItemTemplate>
                                        <div class="flex justify-between items-center p-3 bg-gray-50 rounded">
                                            <div>
                                                <div class="font-medium text-gray-800"><%# Eval("Name") %></div>
                                                <div class="text-sm text-gray-600">Thời gian giao hàng: <%# Eval("EstimatedDays") %> ngày</div>
                                            </div>
                                            <span class="font-bold text-primary">
                                                <%# Eval("BaseCost", "{0:N0}") %>đ
                                            </span>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </div>
                        <div>
                            <h4 class="font-bold text-dark mb-3">Chính sách đổi trả</h4>
                            <div class="space-y-3">
                                <asp:Repeater ID="rptReturnPolicies" runat="server">
                                    <ItemTemplate>
                                        <div class="flex items-start">
                                            <i class="fas fa-check-circle text-green-500 mr-3 mt-1"></i>
                                            <div>
                                                <%--<div class="font-medium"><%# Eval("PolicyTitle") %></div>--%>
                                                <%--<div class="text-sm text-gray-600"><%# Eval("PolicyDescription") %></div>--%>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Related Products -->
        <div class="mt-8 bg-white rounded-lg shadow-md p-6">
            <h3 class="text-2xl font-bold text-dark mb-6">Sản phẩm liên quan</h3>
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                <asp:Repeater ID="rptRelatedProducts" runat="server">
                    <ItemTemplate>
                        <div class="group cursor-pointer" onclick="location.href='/Client/ProductDetails.aspx?id=<%# Eval("Id") %>'">
                            <div class="bg-gray-100 rounded-lg overflow-hidden mb-3">
                                <asp:Image ID="imgRelatedProduct" runat="server" 
                                    ImageUrl='<%# Eval("PrimaryImage") %>' 
                                    AlternateText='<%# Eval("Name") %>' 
                                    CssClass="w-full h-40 object-cover transition-transform group-hover:scale-105" />
                            </div>
                            <h4 class="font-medium text-gray-800 line-clamp-2 h-12 mb-2"><%# Eval("Name") %></h4>
                            <div class="flex items-center text-xs mb-2">
                                <div class="flex text-yellow-400">
                                    <%# Eval("RatingAverage") %>
                                </div>
                                <span class="text-gray-500 ml-1">(<%# Eval("RatingCount") %>)</span>
                            </div>
                            <div class="flex justify-between items-center">
                                <span class="text-primary font-bold"><%# Eval("CurrentPrice", "{0:N0}") %>đ</span>
                                <asp:Panel ID="pnlRelatedBadge" runat="server" Visible='<%# Eval("SalePrice") != null %>'>
                                    <span class="text-xs px-2 py-1 rounded bg-red-100 text-red-600">
                                        -<%# Eval("DiscountPercent") %>%
                                    </span>
                                </asp:Panel>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>


    <!-- Back to top button -->
    <asp:Button ID="btnBackToTop" runat="server" 
        CssClass="fixed bottom-20 right-4 bg-primary text-white w-10 h-10 rounded-full flex items-center justify-center shadow-lg z-40 hover:bg-dark transition-colors" 
        Style="display: none;" 
        OnClientClick="window.scrollTo({ top: 0, behavior: 'smooth' }); return false;">
    </asp:Button>

    <script>
        // Image Gallery Functions
        function changeMainImage(src, thumbnail) {
            document.getElementById('<%= imgMainProduct.ClientID %>').src = src;
            
            // Update active thumbnail
            document.querySelectorAll('.thumbnail').forEach(thumb => {
                thumb.classList.remove('active');
            });
            thumbnail.classList.add('active');
        }

        // Quantity Functions
        function increaseQuantity() {
            const quantityInput = document.getElementById('<%= txtQuantity.ClientID %>');
            const currentValue = parseInt(quantityInput.value);
            if (currentValue < 99) {
                quantityInput.value = currentValue + 1;
            }
        }

        function decreaseQuantity() {
            const quantityInput = document.getElementById('<%= txtQuantity.ClientID %>');
            const currentValue = parseInt(quantityInput.value);
            if (currentValue > 1) {
                quantityInput.value = currentValue - 1;
            }
        }

        // Tab Functions
        function showTab(tabName) {
            // Hide all tab contents
            document.querySelectorAll('.tab-content').forEach(content => {
                content.classList.add('hidden');
            });
            
            // Remove active class from all tab buttons
            document.querySelectorAll('.tab-button').forEach(button => {
                button.classList.remove('active');
            });
            
            // Show selected tab content
            document.getElementById(tabName).classList.remove('hidden');
            
            // Add active class to clicked tab button
            event.target.classList.add('active');
        }

        // Back to Top Button
        const backToTopButton = document.getElementById('<%= btnBackToTop.ClientID %>');
        window.addEventListener('scroll', () => {
            if (window.scrollY > 300) {
                backToTopButton.style.display = 'flex';
            } else {
                backToTopButton.style.display = 'none';
            }
        });

        // Bottom Navigation Active State
        const navItems = document.querySelectorAll('.nav-item');
        navItems.forEach(item => {
            item.addEventListener('click', (e) => {
                // Remove active class from all items
                navItems.forEach(nav => {
                    nav.classList.remove('active');
                    nav.classList.add('text-gray-600');
                });
                // Add active class to clicked item
                item.classList.add('active');
                item.classList.remove('text-gray-600');
            });
        });

        // Add to Cart Animation
        function animateAddToCart() {
            const addToCartBtn = document.getElementById('<%= btnAddToCart.ClientID %>');
            const originalText = addToCartBtn.value;
            addToCartBtn.value = '✓ Đã thêm vào giỏ!';
            addToCartBtn.classList.add('bg-green-500');
            addToCartBtn.classList.remove('bg-primary');
            
            setTimeout(() => {
                addToCartBtn.value = originalText;
                addToCartBtn.classList.remove('bg-green-500');
                addToCartBtn.classList.add('bg-primary');
            }, 2000);
        }

        // Share Product Function
        function shareProduct() {
            if (navigator.share) {
                navigator.share({
                    title: document.title,
                    url: window.location.href
                });
            } else {
                // Fallback - copy to clipboard
                navigator.clipboard.writeText(window.location.href).then(() => {
                    alert('Đã sao chép link sản phẩm!');
                });
            }
        }

        // Smooth scroll for navigation links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth'
                    });
                }
            });
        });

        // Product image zoom effect
        document.addEventListener('DOMContentLoaded', function() {
            const mainImage = document.getElementById('<%= imgMainProduct.ClientID %>');
            if (mainImage) {
                mainImage.addEventListener('click', function() {
                    // Open image in modal or lightbox (implement as needed)
                    window.open(this.src, '_blank');
                });
            }
        });

        // Quantity input validation
        document.addEventListener('DOMContentLoaded', function() {
            const quantityInput = document.getElementById('<%= txtQuantity.ClientID %>');
            if (quantityInput) {
                quantityInput.addEventListener('change', function() {
                    const value = parseInt(this.value);
                    if (value < 1) this.value = 1;
                    if (value > 99) this.value = 99;
                });
            }
        });
    </script>
</asp:Content>