<%@ Page Title="ToyLand - Shop Đồ Chơi Trẻ Em" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="WebDoChoi.Client.Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <meta name="description" content="ToyLand - Chuyên cung cấp đồ chơi an toàn và giáo dục cho trẻ em mọi lứa tuổi">
    <meta name="keywords" content="đồ chơi trẻ em, đồ chơi giáo dục, đồ chơi an toàn, ToyLand">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta name="format-detection" content="telephone=no">
    <meta name="mobile-web-app-capable" content="yes">

<style>
        /* RESET VÀ BASE STYLES */
        * {
            box-sizing: border-box;
        }
        
        /* MOBILE FIRST - MẶC ĐỊNH CHO MOBILE */
        .responsive-grid {
            display: grid !important;
            grid-template-columns: repeat(2, 1fr) !important;
            gap: 0.5rem !important;
            width: 100% !important;
        }
        
        .container {
            width: 100% !important;
            max-width: 100% !important;
            margin: 0 auto !important;
            padding-left: 0.5rem !important;
            padding-right: 0.5rem !important;
        }
        
        /* BANNER RESPONSIVE */
        .banner-container {
            height: 150px !important;
            width: 100% !important;
            margin: 0.5rem 0 !important;
            position: relative !important;
            overflow: hidden !important;
        }
        
        .banner-slide {
            position: absolute !important;
            top: 0 !important;
            left: 0 !important;
            width: 100% !important;
            height: 100% !important;
            background-size: cover !important;
            background-position: center !important;
            opacity: 0 !important;
            transition: opacity 0.5s ease !important;
        }
        
        .banner-slide:first-child {
            opacity: 1 !important;
        }
        
        /* PRODUCT CARD MOBILE */
        .product-card {
            width: 100% !important;
            min-height: 200px !important;
            background: white !important;
            border-radius: 0.5rem !important;
            overflow: hidden !important;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1) !important;
        }
        
        .product-card img {
            width: 100% !important;
            height: 120px !important;
            object-fit: cover !important;
            display: block !important;
        }
        
        .product-card h3 {
            font-size: 0.75rem !important;
            line-height: 1rem !important;
            padding: 0.25rem !important;
            margin: 0 !important;
            height: 2rem !important;
            overflow: hidden !important;
            display: -webkit-box !important;
            -webkit-line-clamp: 2 !important;
            -webkit-box-orient: vertical !important;
        }
        
        .product-card .price {
            font-size: 0.75rem !important;
            font-weight: bold !important;
            color: #FF6B6B !important;
            padding: 0.25rem !important;
        }
        
        /* MOBILE SIDEBAR HIDDEN */
        @media (max-width: 1023px) {
            .lg\:w-1\/5 {
                display: none !important;
            }
            
            .lg\:w-3\/5 {
                width: 100% !important;
                max-width: 100% !important;
            }
            
            .hidden.lg\:block {
                display: none !important;
            }
            
            /* Banner mobile text */
            .banner-container h1 {
                font-size: 1rem !important;
                margin-bottom: 0.25rem !important;
            }
            
            .banner-container p {
                font-size: 0.75rem !important;
            }
            
            /* Mobile bottom nav space */
            body {
                padding-bottom: 70px !important;
            }
            
            /* Mobile categories overlay */
            #mobileCategoriesOverlay {
                position: fixed !important;
                top: 0 !important;
                left: 0 !important;
                right: 0 !important;
                bottom: 0 !important;
                background: rgba(0,0,0,0.5) !important;
                z-index: 9999 !important;
            }
            
            /* Section spacing mobile */
            .bg-white.rounded-lg.shadow-md {
                margin-bottom: 1rem !important;
                margin-left: 0.5rem !important;
                margin-right: 0.5rem !important;
            }
        }
        
        /* TABLET */
        @media (min-width: 641px) and (max-width: 1023px) {
            .responsive-grid {
                grid-template-columns: repeat(3, 1fr) !important;
                gap: 0.75rem !important;
            }
            
            .banner-container {
                height: 200px !important;
            }
            
            .product-card h3 {
                font-size: 0.875rem !important;
            }
            
            .product-card .price {
                font-size: 0.875rem !important;
            }
        }
        
        /* DESKTOP */
        @media (min-width: 1024px) {
            .responsive-grid {
                grid-template-columns: repeat(4, 1fr) !important;
                gap: 1rem !important;
            }
            
            .banner-container {
                height: 300px !important;
            }
            
            .container {
                padding-left: 1rem !important;
                padding-right: 1rem !important;
            }
            
            body {
                padding-bottom: 0 !important;
            }
        }
        
        /* LOADING SKELETON */
        .skeleton {
            background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%) !important;
            background-size: 200% 100% !important;
            animation: loading 1.5s infinite !important;
        }
        
        @keyframes loading {
            0% { background-position: 200% 0; }
            100% { background-position: -200% 0; }
        }
        
        /* FIX CHO MOBILE NAVIGATION */
        .bottom-nav {
            position: fixed !important;
            bottom: 0 !important;
            left: 0 !important;
            right: 0 !important;
            background: white !important;
            border-top: 1px solid #e5e7eb !important;
            z-index: 50 !important;
            height: 60px !important;
        }
        
        /* ĐẢM BẢO CONTENT HIỂN THỊ */
        .main-content {
            min-height: 200px !important;
            background: #f9fafb !important;
        }
        
        /* FIX FLEX LAYOUT */
        .flex.flex-col.lg\:flex-row {
            display: block !important;
        }
        
        @media (min-width: 1024px) {
            .flex.flex-col.lg\:flex-row {
                display: flex !important;
            }
        }
        
        /* ERROR FALLBACK */
        .error-fallback {
            display: none !important;
            padding: 2rem !important;
            text-align: center !important;
            background: white !important;
            margin: 1rem !important;
            border-radius: 0.5rem !important;
        }
        
        .show-error .error-fallback {
            display: block !important;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <!-- Mobile Detection và Force Layout -->
    <script>
        // Thêm vào đầu file Default.aspx, trong thẻ <script>
        document.addEventListener('DOMContentLoaded', function () {
            // Ensure content is visible regardless of screen size
            const mainContent = document.querySelector('.main-content');
            if (mainContent) {
                mainContent.style.display = 'block';
            }

            // Force layout recalculation on mobile
            function fixMobileLayout() {
                if (window.innerWidth <= 1023) {
                    document.body.style.display = 'none';
                    setTimeout(() => {
                        document.body.style.display = '';
                    }, 0);
                }
            }

            // Handle resize events properly
            let resizeTimer;
            window.addEventListener('resize', function () {
                clearTimeout(resizeTimer);
                resizeTimer = setTimeout(function () {
                    handleResponsiveGrid();
                    fixMobileLayout();
                }, 250);
            });

            // Fix initial mobile layout
            if (window.innerWidth <= 1023) {
                handleResponsiveGrid();
                fixMobileLayout();
            }
        });

        // Thêm fallback display styles
        document.head.insertAdjacentHTML('beforeend', `
    <style>
        @media (max-width: 1023px) {
            .main-content {
                display: block !important;
                min-height: 100vh;
            }
            .container {
                display: block !important;
            }
            .responsive-grid {
                display: grid !important;
            }
        }
    </style>
`);

        // Immediate mobile detection và layout fix
        (function () {
            if (window.innerWidth <= 1023) {
                document.documentElement.style.fontSize = '14px';
                document.body.style.paddingBottom = '70px';

                // Add mobile class to body
                document.body.classList.add('mobile-view');

                // Force show content
                const style = document.createElement('style');
                style.textContent = `
                    .lg\\:w-1\\/5 { display: none !important; }
                    .lg\\:w-3\\/5 { width: 100% !important; }
                    .responsive-grid { display: grid !important; grid-template-columns: repeat(2, 1fr) !important; }
                    .container { padding: 0.5rem !important; }
                `;
                document.head.appendChild(style);
            }
        })();
// Fixed JavaScript for Default.aspx - Replace the entire script section

<!-- THAY THẾ TẤT CẢ JAVASCRIPT BẰNG CODE NÀY -->

<!-- Loading indicator -->
<div id="pageLoader" class="fixed inset-0 bg-white bg-opacity-75 flex items-center justify-center z-50" style="display: none;">
    <div class="text-center">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto mb-2"></div>
        <p class="text-gray-600 text-sm">Đang tải...</p>
    </div>
</div>

<!-- TOÀN BỘ JAVASCRIPT ĐÃ ĐƯỢC CLEAN -->
// THAY THẾ TOÀN BỘ SCRIPT SECTION TRONG Default.aspx BẰNG CODE NÀY

<script>
// CRITICAL: Define all functions first
function handleResponsiveGrid() {
    const containers = document.querySelectorAll('.responsive-grid');
    const width = window.innerWidth;

    containers.forEach(container => {
        if (container) {
            if (width <= 640) {
                container.style.display = 'grid';
                container.style.gridTemplateColumns = 'repeat(2, 1fr)';
                container.style.gap = '0.5rem';
            } else if (width <= 768) {
                container.style.display = 'grid';
                container.style.gridTemplateColumns = 'repeat(3, 1fr)';
                container.style.gap = '1rem';
            } else {
                container.style.display = 'grid';
                container.style.gridTemplateColumns = 'repeat(4, 1fr)';
                container.style.gap = '1rem';
            }
        }
    });

    if (width <= 640) {
        handleMobileLayout();
    }
}

function handleMobileLayout() {
    const grids = document.querySelectorAll('.responsive-grid');
    grids.forEach(grid => {
        if (grid) {
            grid.style.gridTemplateColumns = 'repeat(2, 1fr)';
            grid.style.gap = '0.5rem';
        }
    });

    const sidebars = document.querySelectorAll('.lg\\:w-1\\/5');
    sidebars.forEach(sidebar => {
        if (sidebar) {
            sidebar.style.display = 'none';
        }
    });

    const centerContent = document.querySelector('.lg\\:w-3\\/5');
    if (centerContent) {
        centerContent.style.width = '100%';
    }
}

function initBannerSlideshow() {
    const slides = document.querySelectorAll('.banner-slide');
    const dots = document.querySelectorAll('.banner-dot');
    let currentSlide = 0;

    if (slides.length === 0) return;

    function showSlide(index) {
        slides.forEach((slide, i) => {
            slide.style.opacity = i === index ? '1' : '0';
        });
        dots.forEach((dot, i) => {
            dot.style.opacity = i === index ? '1' : '0.5';
        });
    }

    function nextSlide() {
        currentSlide = (currentSlide + 1) % slides.length;
        showSlide(currentSlide);
    }

    setInterval(nextSlide, 5000);

    dots.forEach((dot, index) => {
        dot.addEventListener('click', () => {
            currentSlide = index;
            showSlide(currentSlide);
        });
    });

    showSlide(0);
}

function initMobileFeatures() {
    window.toggleMobileCategories = function () {
        const overlay = document.getElementById('mobileCategoriesOverlay');
        if (overlay) {
            const isHidden = overlay.classList.contains('hidden');
            if (isHidden) {
                overlay.classList.remove('hidden');
                document.body.style.overflow = 'hidden';
            } else {
                overlay.classList.add('hidden');
                document.body.style.overflow = '';
            }
        }
    };

    document.addEventListener('click', function (e) {
        const overlay = document.getElementById('mobileCategoriesOverlay');
        const menuButton = e.target.closest('[onclick*="toggleMobileCategories"]');

        if (overlay && !overlay.classList.contains('hidden') && !menuButton) {
            const menuContent = overlay.querySelector('.bg-white');
            if (menuContent && !menuContent.contains(e.target)) {
                toggleMobileCategories();
            }
        }
    });
}

function updateCartDisplay(count) {
    const cartCounts = document.querySelectorAll('.cart-count');
    cartCounts.forEach(element => {
        if (element) {
            element.textContent = count;
            element.style.display = count > 0 ? 'flex' : 'none';
        }
    });
    localStorage.setItem('cartCount', count);
}

function updateWishlistDisplay(count) {
    const wishlistCounts = document.querySelectorAll('.wishlist-count');
    wishlistCounts.forEach(element => {
        if (element) {
            element.textContent = count;
            element.style.display = count > 0 ? 'flex' : 'none';
        }
    });
    localStorage.setItem('wishlistCount', count);
}

function showNotification(message, type = 'info') {
    const existing = document.querySelectorAll('.notification');
    existing.forEach(n => n.remove());
    
    const bgColor = {
        'success': 'bg-green-500',
        'error': 'bg-red-500',
        'warning': 'bg-yellow-500',
        'info': 'bg-blue-500'
    }[type] || 'bg-blue-500';
    
    const notification = document.createElement('div');
    notification.className = 'notification fixed top-4 right-4 z-50 p-3 rounded-lg shadow-lg max-w-sm text-white ' + bgColor;
    notification.innerHTML = '<div class="flex items-center justify-between"><span class="text-sm">' + message + '</span><button onclick="this.parentElement.parentElement.remove()" class="ml-2 text-white hover:text-gray-200"><i class="fas fa-times text-xs"></i></button></div>';
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        if (notification.parentNode) {
            notification.remove();
        }
    }, 3000);
}

function showPageLoader() {
    const loader = document.getElementById('pageLoader');
    if (loader) {
        loader.style.display = 'flex';
    }
}

function hidePageLoader() {
    const loader = document.getElementById('pageLoader');
    if (loader) {
        loader.style.display = 'none';
    }
}

// Touch gestures for mobile slideshow
let touchStartX = 0;
let touchEndX = 0;

function handleTouchStart(e) {
    touchStartX = e.changedTouches[0].screenX;
}

function handleTouchEnd(e) {
    touchEndX = e.changedTouches[0].screenX;
    handleSwipe();
}

function handleSwipe() {
    const swipeThreshold = 50;
    const diff = touchStartX - touchEndX;

    if (Math.abs(diff) > swipeThreshold) {
        const slides = document.querySelectorAll('.banner-slide');
        const dots = document.querySelectorAll('.banner-dot');
        let currentSlide = Array.from(slides).findIndex(slide => slide.style.opacity === '1');

        if (diff > 0) {
            currentSlide = (currentSlide + 1) % slides.length;
        } else {
            currentSlide = currentSlide === 0 ? slides.length - 1 : currentSlide - 1;
        }

        slides.forEach((slide, i) => {
            slide.style.opacity = i === currentSlide ? '1' : '0';
        });
        dots.forEach((dot, i) => {
            dot.style.opacity = i === currentSlide ? '1' : '0.5';
        });
    }
}

// Performance optimization - debounce resize events
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Immediate mobile detection and layout fix
(function () {
    if (window.innerWidth <= 1023) {
        document.documentElement.style.fontSize = '14px';
        document.body.style.paddingBottom = '70px';
        document.body.classList.add('mobile-view');

        const style = document.createElement('style');
        style.textContent = '.lg\\:w-1\\/5 { display: none !important; } .lg\\:w-3\\/5 { width: 100% !important; } .responsive-grid { display: grid !important; grid-template-columns: repeat(2, 1fr) !important; } .container { padding: 0.5rem !important; }';
        document.head.appendChild(style);
    }
})();

// DOMContentLoaded event listener
document.addEventListener('DOMContentLoaded', function () {
    console.log('DOM loaded, initializing...');
    
    const mainContent = document.querySelector('.main-content');
    if (mainContent) {
        mainContent.style.display = 'block';
    }

    function fixMobileLayout() {
        if (window.innerWidth <= 1023) {
            document.body.style.display = 'none';
            setTimeout(() => {
                document.body.style.display = '';
            }, 0);
        }
    }

    let resizeTimer;
    window.addEventListener('resize', function () {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(function () {
            handleResponsiveGrid();
            fixMobileLayout();
        }, 250);
    });

    if (window.innerWidth <= 1023) {
        handleResponsiveGrid();
        fixMobileLayout();
    }

    try {
        initBannerSlideshow();
        initMobileFeatures();
        updateCartDisplay(parseInt(localStorage.getItem('cartCount') || '0'));
    } catch (e) {
        console.log('Initialization error:', e);
    }
});

// Add touch event listeners to banner
window.addEventListener('load', function() {
    const bannerContainer = document.querySelector('.banner-container');
    if (bannerContainer) {
        bannerContainer.addEventListener('touchstart', handleTouchStart, false);
        bannerContainer.addEventListener('touchend', handleTouchEnd, false);
    }

    setTimeout(hidePageLoader, 1000);
    
    document.body.style.visibility = 'visible';
    
    const grids = document.querySelectorAll('.responsive-grid');
    grids.forEach(grid => {
        if (window.innerWidth <= 640) {
            grid.style.gridTemplateColumns = 'repeat(2, 1fr)';
        } else if (window.innerWidth <= 1023) {
            grid.style.gridTemplateColumns = 'repeat(3, 1fr)';
        } else {
            grid.style.gridTemplateColumns = 'repeat(4, 1fr)';
        }
    });
});

// Apply debounce to resize handler
window.addEventListener('resize', debounce(handleResponsiveGrid, 250));

// Emergency fallback
window.addEventListener('error', function(e) {
    console.error('JavaScript error:', e.error);
    if (document.body.innerHTML === '') {
        location.reload();
    }
});

console.log('Default.aspx JavaScript loaded successfully');
    </script>
<!-- Add padding bottom for mobile navigation -->


    <!-- Banner Slideshow -->
    <div class="container mx-auto px-2 sm:px-4 py-4">
        <div class="banner-container rounded-lg overflow-hidden relative shadow-lg bg-gray-200">
            <div class="banner-slide absolute inset-0 bg-cover bg-center" 
                 style="background-image: url('https://cdn.tgdd.vn/News/Thumb/1527248/dai-le-sale-to-do-choi-giam-den-50-mua-ngay-cho-be-thumb-1200x628.png')">
                <div class="absolute inset-0 bg-black bg-opacity-20 flex items-center justify-center">
                    <div class="text-center text-white">
                        <h1 class="text-2xl md:text-4xl font-bold mb-2">Khuyến mãi mùa hè - Giảm 50%</h1>
                        <p class="text-sm md:text-lg">Giảm giá lên đến 50% cho tất cả đồ chơi giáo dục</p>
                    </div>
                </div>
            </div>
            <div class="banner-slide absolute inset-0 bg-cover bg-center opacity-0" 
                 style="background-image: url('https://www.mykingdom.com.vn/cdn/shop/articles/mykingdom-do-choi-cong-nghe-thong-minh-cho-tre-em-image.jpg?v=1686020840')">
                <div class="absolute inset-0 bg-black bg-opacity-20 flex items-center justify-center">
                    <div class="text-center text-white">
                        <h1 class="text-2xl md:text-4xl font-bold mb-2">Đồ chơi thông minh mới nhất</h1>
                        <p class="text-sm md:text-lg">Khám phá bộ sưu tập đồ chơi công nghệ cao</p>
                    </div>
                </div>
            </div>
            <div class="banner-slide absolute inset-0 bg-cover bg-center opacity-0" 
                 style="background-image: url('https://cdn.tgdd.vn/News/1561562/mien-phi-giao-hang-tan-noi-cho-don-tu-500-000d-9-845x442.png')">
                <div class="absolute inset-0 bg-black bg-opacity-20 flex items-center justify-center">
                    <div class="text-center text-white">
                        <h1 class="text-2xl md:text-4xl font-bold mb-2">Miễn phí vận chuyển</h1>
                        <p class="text-sm md:text-lg">Miễn phí giao hàng cho đơn hàng từ 500.000đ</p>
                    </div>
                </div>
            </div>
            
            <!-- Banner controls -->
            <div class="absolute bottom-4 left-0 right-0 flex justify-center space-x-2">
                <button class="banner-dot w-3 h-3 rounded-full bg-white opacity-50 hover:opacity-100 transition-opacity" data-slide="0"></button>
                <button class="banner-dot w-3 h-3 rounded-full bg-white opacity-50 hover:opacity-100 transition-opacity" data-slide="1"></button>
                <button class="banner-dot w-3 h-3 rounded-full bg-white opacity-50 hover:opacity-100 transition-opacity" data-slide="2"></button>
            </div>
        </div>
    </div>

    <!-- Main Content Area -->
    <div class="container mx-auto px-2 sm:px-4 py-4">
        <div class="flex flex-col lg:flex-row gap-4">
            <!-- Left Sidebar - Hidden on mobile, shown on desktop -->
            <div class="hidden lg:block lg:w-1/5">
                <div class="bg-white rounded-lg shadow-md p-4 mb-4">
                    <h3 class="text-lg font-bold text-dark border-b border-gray-200 pb-2 mb-3">
                        <i class="fas fa-list mr-2"></i>Danh mục đồ chơi
                    </h3>
                    <asp:Repeater ID="rptCategories" runat="server">
                        <HeaderTemplate>
                            <ul class="space-y-2">
                        </HeaderTemplate>
                        <ItemTemplate>
                            <li>
                                <a href='<%# "/Client/ProductList.aspx?categoryId=" + Eval("Id") %>' 
                                   class="flex items-center text-gray-700 hover:text-primary transition-colors p-2 rounded hover:bg-gray-50">
                                    <i class='<%# Eval("Icon") %> w-5 mr-3 text-secondary'></i>
                                    <span class="flex-1"><%# Eval("Name") %></span>
                                    <span class="text-xs text-gray-500 bg-gray-100 px-2 py-1 rounded"><%# Eval("ProductCount") %></span>
                                </a>
                            </li>
                        </ItemTemplate>
                        <FooterTemplate>
                            </ul>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
                
                <!-- Statistics - Desktop only -->
                <div class="bg-white rounded-lg shadow-md p-4">
                    <h3 class="text-lg font-bold text-dark border-b border-gray-200 pb-2 mb-3">
                        <i class="fas fa-chart-bar mr-2"></i>Thống kê
                    </h3>
                    <div class="space-y-3">
                        <div class="flex items-center justify-between text-sm">
                            <span class="flex items-center text-gray-700">
                                <i class="fas fa-users text-secondary mr-2"></i>
                                Đang online
                            </span>
                            <span class="font-bold text-primary">
                                <asp:Label ID="lblOnlineUsers" runat="server" Text="257"></asp:Label>
                            </span>
                        </div>
                        <div class="flex items-center justify-between text-sm">
                            <span class="flex items-center text-gray-700">
                                <i class="fas fa-cube text-secondary mr-2"></i>
                                Sản phẩm
                            </span>
                            <span class="font-bold text-primary">
                                <asp:Label ID="lblTotalProducts" runat="server" Text="2,548"></asp:Label>
                            </span>
                        </div>
                        <div class="flex items-center justify-between text-sm">
                            <span class="flex items-center text-gray-700">
                                <i class="fas fa-shopping-cart text-secondary mr-2"></i>
                                Đơn hôm nay
                            </span>
                            <span class="font-bold text-primary">
                                <asp:Label ID="lblTodayOrders" runat="server" Text="36"></asp:Label>
                            </span>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Center Content -->
            <div class="w-full lg:w-3/5">
                <!-- Best Selling Section -->
                <div class="bg-white rounded-lg shadow-md p-3 sm:p-4 mb-4">
                    <div class="flex justify-between items-center border-b border-gray-200 pb-2 mb-4">
                        <h2 class="text-lg sm:text-xl font-bold text-dark flex items-center">
                            <i class="fas fa-fire text-orange-500 mr-2"></i>
                            <span class="hidden sm:inline">Đồ chơi bán chạy</span>
                            <span class="sm:hidden">Bán chạy</span>
                        </h2>
                        <a href="/Client/ProductList.aspx?filter=bestseller" 
                           class="text-primary hover:underline flex items-center text-sm">
                            <span>Xem tất cả</span>
                            <i class="fas fa-chevron-right ml-1 text-xs"></i>
                        </a>
                    </div>
                   
                    <div class="responsive-grid" id="bestSellingContainer">
                        <asp:Repeater ID="rptBestSellingProducts" runat="server" OnItemCommand="rptBestSellingProducts_ItemCommand">
                            <ItemTemplate>
                                <div class="product-card bg-gray-50 rounded-lg overflow-hidden shadow-sm hover:shadow-md transition-shadow">
                                    <div class="relative group">
                                        <asp:Image ID="imgProduct" runat="server" 
                                            ImageUrl='<%# Eval("ImageUrl") %>' 
                                            AlternateText='<%# Eval("Name") %>' 
                                            CssClass="w-full h-32 sm:h-40 object-cover transition-transform group-hover:scale-105" 
                                            onerror="this.src='https://via.placeholder.com/300x300?text=No+Image'" />
                    
                                        <!-- Product actions overlay - SỬA CHÍNH TẠI ĐÂY -->
                                        <div class="product-actions absolute inset-0 bg-black bg-opacity-20 flex items-center justify-center space-x-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                            <!-- Thay thế button bằng LinkButton để có server-side event -->
                                            <asp:LinkButton ID="btnAddToCartBest" runat="server" 
                                                CommandName="AddToCart" 
                                                CommandArgument='<%# Eval("Id") %>'
                                                CssClass="bg-white text-primary p-2 rounded-full hover:bg-primary hover:text-white transition-colors"
                                                ToolTip="Thêm vào giỏ hàng"
                                                OnClientClick="showPageLoader(); return true;">
                                                <i class="fas fa-shopping-cart"></i>
                                            </asp:LinkButton>
                        
                                            <asp:LinkButton ID="btnAddToWishlistBest" runat="server" 
                                                CommandName="AddToWishlist" 
                                                CommandArgument='<%# Eval("Id") %>'
                                                CssClass="bg-white text-primary p-2 rounded-full hover:bg-primary hover:text-white transition-colors"
                                                ToolTip="Thêm vào yêu thích"
                                                OnClientClick="showPageLoader(); return true;">
                                                <i class="fas fa-heart"></i>
                                            </asp:LinkButton>
                        
                                            <asp:HyperLink ID="lnkViewDetails" runat="server" 
                                                NavigateUrl='<%# "/Client/ProductDetails.aspx?id=" + Eval("Id") %>'
                                                CssClass="bg-white text-primary p-2 rounded-full hover:bg-primary hover:text-white transition-colors"
                                                ToolTip="Xem chi tiết">
                                                <i class="fas fa-eye"></i>
                                            </asp:HyperLink>
                                        </div>
                    
                                        <!-- Badges -->
                                        <div class="absolute top-2 left-2 space-y-1">
                                            <asp:Panel ID="pnlDiscountBadge" runat="server" Visible='<%# Convert.ToInt32(Eval("DiscountPercent")) > 0 %>'>
                                                <span class="bg-red-500 text-white text-xs px-2 py-1 rounded">-<%# Eval("DiscountPercent") %>%</span>
                                            </asp:Panel>
                                            <asp:Panel ID="pnlNewBadge" runat="server" Visible='<%# Convert.ToBoolean(Eval("IsNew")) %>'>
                                                <span class="bg-green-500 text-white text-xs px-2 py-1 rounded">Mới</span>
                                            </asp:Panel>
                                        </div>
                                    </div>
                
                                    <div class="p-2 sm:p-3">
                                        <h3 class="font-medium text-gray-800 line-clamp-2 mb-2 text-sm sm:text-base" title="<%# Eval("Name") %>">
                                            <%# Eval("Name") %>
                                        </h3>
                    
                                        <!-- Rating -->
                                        <div class="flex items-center mb-2">
                                            <div class="flex text-yellow-400 text-xs">
                                                <%# GenerateStars(Convert.ToDouble(Eval("Rating") ?? 0)) %>
                                            </div>
                                            <span class="text-gray-500 ml-1 text-xs">(<%# Eval("ReviewCount") %>)</span>
                                        </div>
                    
                                        <!-- Price -->
                                        <div class="flex justify-between items-center">
                                            <div class="price">
                                                <span class="text-primary font-bold text-sm sm:text-base"><%# Convert.ToDecimal(Eval("Price")).ToString("N0") %>đ</span>
                                                <asp:Panel ID="pnlOriginalPrice" runat="server" Visible='<%# Convert.ToDecimal(Eval("OriginalPrice") ?? 0) > Convert.ToDecimal(Eval("Price")) %>'>
                                                    <span class="text-gray-500 text-xs line-through ml-1"><%# Convert.ToDecimal(Eval("OriginalPrice")).ToString("N0") %>đ</span>
                                                </asp:Panel>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>

                <!-- Advertisement Banner 1 -->
                <div class="rounded-lg overflow-hidden mb-4 shadow-md">
                    <asp:Image ID="imgAdBanner1" runat="server" 
                        ImageUrl="https://cdn.tgdd.vn//News/1491638//30-11-11-12-san-sale-do-choi-giam-soc-den-50-1-845x442.jpg" 
                        AlternateText="Khuyến mãi" 
                        CssClass="w-full h-20 sm:h-24 md:h-32 object-cover" />
                </div>

                <!-- Featured Products Section -->
                <div class="bg-white rounded-lg shadow-md p-3 sm:p-4">
                    <div class="flex justify-between items-center border-b border-gray-200 pb-2 mb-4">
                        <h2 class="text-lg sm:text-xl font-bold text-dark flex items-center">
                            <i class="fas fa-star text-yellow-500 mr-2"></i>
                            <span class="hidden sm:inline">Đồ chơi nổi bật</span>
                            <span class="sm:hidden">Nổi bật</span>
                        </h2>
                        <div class="flex space-x-2">
                            <asp:LinkButton ID="btnGridView" runat="server" 
                                CssClass="text-gray-600 hover:text-primary transition-colors p-1"
                                OnClick="btnGridView_Click"
                                ToolTip="Xem dạng lưới">
                                <i class="fas fa-th-large"></i>
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnListView" runat="server" 
                                CssClass="text-gray-600 hover:text-primary transition-colors p-1"
                                OnClick="btnListView_Click"
                                ToolTip="Xem dạng danh sách">
                                <i class="fas fa-list"></i>
                            </asp:LinkButton>
                        </div>
                    </div>

                    <div class="responsive-grid" id="featuredContainer">
                        <asp:Repeater ID="rptFeaturedProducts" runat="server" OnItemCommand="rptFeaturedProducts_ItemCommand">
                            <ItemTemplate>
                                <div class="product-card bg-gray-50 rounded-lg overflow-hidden shadow-sm hover:shadow-md transition-shadow">
                                    <div class="relative group">
                                        <asp:Image ID="imgFeaturedProduct" runat="server" 
                                            ImageUrl='<%# Eval("ImageUrl") %>' 
                                            AlternateText='<%# Eval("Name") %>' 
                                            CssClass="w-full h-32 sm:h-40 object-cover transition-transform group-hover:scale-105"
                                            onerror="this.src=''" /> <!-- CHưa có ảnh --->
                                        
                                        <div class="product-actions absolute inset-0 bg-black bg-opacity-20 flex items-center justify-center space-x-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                            <asp:LinkButton ID="btnAddToCartFeatured" runat="server" 
                                                CommandName="AddToCart" 
                                                CommandArgument='<%# Eval("Id") %>'
                                                CssClass="bg-white text-primary p-2 rounded-full hover:bg-primary hover:text-white transition-colors">
                                                <i class="fas fa-shopping-cart"></i>
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnAddToWishlistFeatured" runat="server" 
                                                CommandName="AddToWishlist" 
                                                CommandArgument='<%# Eval("Id") %>'
                                                CssClass="bg-white text-primary p-2 rounded-full hover:bg-primary hover:text-white transition-colors">
                                                <i class="fas fa-heart"></i>
                                            </asp:LinkButton>
                                            <asp:HyperLink ID="lnkViewDetailsFeatured" runat="server" 
                                                NavigateUrl='<%# "/Client/ProductDetails.aspx?id=" + Eval("Id") %>'
                                                CssClass="bg-white text-primary p-2 rounded-full hover:bg-primary hover:text-white transition-colors">
                                                <i class="fas fa-eye"></i>
                                            </asp:HyperLink>
                                        </div>
                                        
                                        <div class="absolute top-2 right-2">
                                            <asp:Panel ID="pnlFeaturedBadge" runat="server" Visible='<%# Convert.ToBoolean(Eval("IsHot") ?? false) %>'>
                                                <span class="bg-blue-500 text-white text-xs px-2 py-1 rounded">Hot</span>
                                            </asp:Panel>
                                        </div>
                                    </div>
                                    
                                    <div class="p-2 sm:p-3">
                                        <h3 class="font-medium text-gray-800 line-clamp-2 mb-2 text-sm sm:text-base">
                                            <%# Eval("Name") %>
                                        </h3>
                                        <div class="flex items-center mb-2">
                                            <div class="flex text-yellow-400 text-xs">
                                                <%# GenerateStars(Convert.ToDouble(Eval("Rating") ?? 0)) %>
                                            </div>
                                            <span class="text-gray-500 ml-1 text-xs">(<%# Eval("ReviewCount") %>)</span>
                                        </div>
                                        <div class="flex justify-between items-center">
                                            <span class="text-primary font-bold text-sm sm:text-base"><%# Convert.ToDecimal(Eval("Price")).ToString("N0") %>đ</span>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <!-- Pagination -->
                    <div class="flex justify-center mt-6">
                        <div class="flex space-x-1">
                            <asp:LinkButton ID="btnPrevPage" runat="server" 
                                CssClass="px-3 py-1 rounded bg-gray-200 text-gray-600 hover:bg-primary hover:text-white transition-colors"
                                OnClick="btnPrevPage_Click">
                                <i class="fas fa-chevron-left"></i>
                            </asp:LinkButton>
                            
                            <asp:Repeater ID="rptPagination" runat="server">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnPage" runat="server" 
                                        Text='<%# Eval("PageNumber") %>'
                                        CommandArgument='<%# Eval("PageNumber") %>'
                                        CssClass='<%# Convert.ToBoolean(Eval("IsCurrentPage")) ? "px-3 py-1 rounded bg-primary text-white" : "px-3 py-1 rounded bg-gray-200 text-gray-600 hover:bg-primary hover:text-white transition-colors" %>'
                                        OnClick="btnPage_Click" />
                                </ItemTemplate>
                            </asp:Repeater>
                            
                            <asp:LinkButton ID="btnNextPage" runat="server" 
                                CssClass="px-3 py-1 rounded bg-gray-200 text-gray-600 hover:bg-primary hover:text-white transition-colors"
                                OnClick="btnNextPage_Click">
                                <i class="fas fa-chevron-right"></i>
                            </asp:LinkButton>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Right Sidebar - Hidden on mobile -->
            <div class="hidden lg:block lg:w-1/5">
                <!-- Shopping Cart Info -->
                <div class="bg-white rounded-lg shadow-md p-4 mb-4">
                    <h3 class="text-lg font-bold text-dark border-b border-gray-200 pb-2 mb-3">
                        <i class="fas fa-shopping-cart mr-2"></i>Giỏ hàng
                    </h3>
                    <asp:Panel ID="pnlCartEmpty" runat="server" Visible="true">
                        <div class="text-center py-8 text-gray-500">
                            <i class="fas fa-shopping-cart text-4xl mb-2 opacity-50"></i>
                            <p>Giỏ hàng trống</p>
                            <a href="/Client/ProductList.aspx" class="text-primary hover:underline text-sm mt-2 inline-block">
                                Mua sắm ngay
                            </a>
                        </div>
                    </asp:Panel>
                    
                    <asp:Panel ID="pnlCartItems" runat="server" Visible="false">
                        <div class="space-y-3" id="cartItemsContainer">
                            <asp:Repeater ID="rptCartItems" runat="server" OnItemCommand="rptCartItems_ItemCommand">
                                <ItemTemplate>
                                    <div class="flex items-start border-b border-gray-100 pb-2">
                                        <div class="bg-gray-100 rounded w-12 h-12 overflow-hidden mr-2 flex-shrink-0">
                                            <asp:Image ID="imgCartProduct" runat="server" 
                                                ImageUrl='<%# Eval("ImageUrl") %>' 
                                                AlternateText='<%# Eval("Name") %>' 
                                                CssClass="w-full h-full object-cover" />
                                        </div>
                                        <div class="flex-grow min-w-0">
                                            <h4 class="text-sm font-medium line-clamp-1 mb-1" title="<%# Eval("Name") %>"><%# Eval("Name") %></h4>
    
                                            <!-- SỬA QUANTITY CONTROLS -->
                                            <div class="flex items-center justify-between text-xs mb-1">
                                                <div class="flex items-center space-x-1">
                                                    <!-- Nút giảm số lượng -->
                                                    <asp:LinkButton ID="btnDecreaseQty" runat="server" 
                                                        CommandName="UpdateQuantity" 
                                                        CommandArgument='<%# Eval("Id") + "|" + (Convert.ToInt32(Eval("Quantity")) - 1) %>'
                                                        CssClass="w-5 h-5 flex items-center justify-center bg-gray-200 rounded text-xs hover:bg-gray-300"
                                                        OnClientClick="showPageLoader(); return true;">
                                                        <i class="fas fa-minus"></i>
                                                    </asp:LinkButton>
                                
                                                    <!-- Hiển thị số lượng hiện tại -->
                                                    <span class="w-8 text-center text-xs font-medium"><%# Eval("Quantity") %></span>
                                
                                                    <!-- Nút tăng số lượng -->
                                                    <asp:LinkButton ID="btnIncreaseQty" runat="server" 
                                                        CommandName="UpdateQuantity" 
                                                        CommandArgument='<%# Eval("Id") + "|" + (Convert.ToInt32(Eval("Quantity")) + 1) %>'
                                                        CssClass="w-5 h-5 flex items-center justify-center bg-gray-200 rounded text-xs hover:bg-gray-300"
                                                        OnClientClick="showPageLoader(); return true;">
                                                        <i class="fas fa-plus"></i>
                                                    </asp:LinkButton>
                                                </div>
        
                                                <!-- Nút xóa sản phẩm -->
                                                <asp:LinkButton ID="btnRemoveFromCart" runat="server" 
                                                    CommandName="RemoveFromCart" 
                                                    CommandArgument='<%# Eval("Id") %>'
                                                    CssClass="text-red-500 hover:text-red-600 ml-2"
                                                    OnClientClick="return confirm('Xóa sản phẩm này khỏi giỏ hàng?');"
                                                    ToolTip="Xóa sản phẩm">
                                                    <i class="fas fa-trash-alt"></i>
                                                </asp:LinkButton>
                                            </div>
    
                                            <!-- Price info -->
                                            <div class="text-xs">
                                                <span class="text-primary font-medium"><%# Convert.ToDecimal(Eval("Price")).ToString("N0") %>đ</span>
                                                <span class="text-gray-500 ml-1">x <%# Eval("Quantity") %></span>
                                            </div>
    
                                            <!-- Stock status -->
                                            <asp:Panel ID="pnlStockStatus" runat="server" Visible='<%# !Convert.ToBoolean(Eval("IsAvailable")) %>'>
                                                <span class="text-red-500 text-xs">Hết hàng</span>
                                            </asp:Panel>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>

                        <!-- Cart actions - KHÔNG THAY ĐỔI -->
                        <div class="border-t border-gray-200 mt-3 pt-3">
                            <div class="flex justify-between font-medium mb-3">
                                <span>Tổng cộng:</span>
                                <span class="text-primary">
                                    <asp:Label ID="lblCartTotal" runat="server" Text="0"></asp:Label>đ
                                </span>
                            </div>
                            <div class="space-y-2">
                                <asp:HyperLink ID="lnkViewCart" runat="server" 
                                    NavigateUrl="/Client/Cart.aspx"
                                    CssClass="block bg-gray-100 text-gray-700 text-center py-2 rounded hover:bg-gray-200 transition-colors text-sm">
                                    Xem giỏ hàng
                                </asp:HyperLink>
                                <asp:HyperLink ID="lnkCheckout" runat="server" 
                                    NavigateUrl="/Client/Checkout.aspx"
                                    CssClass="block bg-primary text-white text-center py-2 rounded hover:bg-primary/90 transition-colors">
                                    Thanh toán
                                </asp:HyperLink>
                            </div>
                        </div>
                    </asp:Panel>
                </div>
                
                <!-- Advertisement Banner 2 -->
                <div class="mb-4">
                    <div class="bg-white rounded-lg shadow-md overflow-hidden">
                        <asp:Image ID="imgAdBanner2" runat="server" 
                            ImageUrl="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTZYoAjF4hbjzMiUbcCSYDUMh-NHR1tGJtYMw&s" 
                            AlternateText="Quảng cáo" 
                            CssClass="w-full h-48 object-cover" />
                    </div>
                </div>
                
                <!-- New Products -->
                <div class="bg-white rounded-lg shadow-md p-4">
                    <h3 class="text-lg font-bold text-dark border-b border-gray-200 pb-2 mb-3">
                        <i class="fas fa-sparkles mr-2"></i>Đồ chơi mới
                    </h3>
                    <div class="space-y-3">
                        <asp:Repeater ID="rptNewProducts" runat="server">
                            <ItemTemplate>
                                <div class="flex items-start">
                                    <div class="bg-gray-100 rounded w-12 h-12 overflow-hidden mr-2 flex-shrink-0">
                                        <asp:Image ID="imgNewProduct" runat="server" 
                                            ImageUrl='<%# Eval("ImageUrl") %>' 
                                            AlternateText='<%# Eval("Name") %>' 
                                            CssClass="w-full h-full object-cover" />
                                    </div>
                                    <div class="flex-grow min-w-0">
                                        <asp:HyperLink ID="lnkNewProduct" runat="server" 
                                            NavigateUrl='<%# "/Client/ProductDetails.aspx?id=" + Eval("Id") %>'
                                            CssClass="text-sm font-medium hover:text-primary transition-colors line-clamp-2 block">
                                            <%# Eval("Name") %>
                                        </asp:HyperLink>
                                        <div class="flex text-yellow-400 text-xs mt-1">
                                            <%# GenerateStars(Convert.ToDouble(Eval("Rating") ?? 0)) %>
                                        </div>
                                        <span class="text-primary text-sm font-medium"><%# Convert.ToDecimal(Eval("Price")).ToString("N0") %>đ</span>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Mobile Category Menu - Sticky bottom on mobile -->
    <div class="lg:hidden fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 z-40">
        <div class="grid grid-cols-5 gap-1 p-2">
            <a href="/Client/Default.aspx" class="flex flex-col items-center py-2 text-primary">
                <i class="fas fa-home text-lg"></i>
                <span class="text-xs mt-1">Trang chủ</span>
            </a>
            <a href="/Client/ProductList.aspx" class="flex flex-col items-center py-2 text-gray-600">
                <i class="fas fa-cube text-lg"></i>
                <span class="text-xs mt-1">Sản phẩm</span>
            </a>
            <button onclick="toggleMobileCategories()" class="flex flex-col items-center py-2 text-gray-600">
                <i class="fas fa-list text-lg"></i>
                <span class="text-xs mt-1">Danh mục</span>
            </button>
            <a href="/Client/Cart.aspx" class="flex flex-col items-center py-2 text-gray-600 relative">
                <i class="fas fa-shopping-cart text-lg"></i>
                <span class="text-xs mt-1">Giỏ hàng</span>
                <span class="cart-count absolute -top-1 -right-1 bg-primary text-white text-xs rounded-full h-4 w-4 flex items-center justify-center" style="display: none;">0</span>
            </a>
            <a href="/Client/Login.aspx" class="flex flex-col items-center py-2 text-gray-600 relative">
                <i class="fas fa-user text-lg"></i>
                <span class="text-xs mt-1">Tài khoản</span>
                <span class="wishlist-count absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full h-4 w-4 flex items-center justify-center" style="display: none;">0</span>
            </a>
        </div>
    </div>

    <!-- Mobile Categories Overlay -->
    <div id="mobileCategoriesOverlay" class="lg:hidden fixed inset-0 bg-black bg-opacity-50 z-50 hidden">
        <div class="absolute bottom-0 left-0 right-0 bg-white rounded-t-2xl max-h-96 overflow-y-auto">
            <div class="p-4 border-b border-gray-200 flex justify-between items-center">
                <h3 class="text-lg font-bold">Danh mục sản phẩm</h3>
                <button onclick="toggleMobileCategories()" class="text-gray-500">
                    <i class="fas fa-times text-xl"></i>
                </button>
            </div>
            <div class="p-4">
                <asp:Repeater ID="rptMobileCategories" runat="server">
                    <ItemTemplate>
                        <a href='<%# "/Client/ProductList.aspx?categoryId=" + Eval("Id") %>' 
                           class="flex items-center py-3 border-b border-gray-100 last:border-b-0"
                           onclick="toggleMobileCategories()">
                            <i class='<%# Eval("Icon") %> w-8 mr-3 text-secondary'></i>
                            <div class="flex-1">
                                <span class="font-medium"><%# Eval("Name") %></span>
                                <span class="text-gray-500 text-sm block"><%# Eval("ProductCount") %> sản phẩm</span>
                            </div>
                            <i class="fas fa-chevron-right text-gray-400"></i>
                        </a>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>

</asp:Content>