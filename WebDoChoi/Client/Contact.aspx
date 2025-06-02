<%@ Page Title="Về chúng tôi - ToyLand" Language="C#" MasterPageFile="/Site.Master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="WebsiteDoChoi.Client.About" %>

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
        
        .parallax-bg {
            background-attachment: fixed;
            background-position: center;
            background-repeat: no-repeat;
            background-size: cover;
        }
        
        .counter-animation {
            animation: countUp 2s ease-in-out;
        }
        
        @keyframes countUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .team-card:hover .team-overlay {
            opacity: 1;
        }
        
        .timeline-item:nth-child(odd) .timeline-content {
            margin-left: auto;
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
    <div class="bg-white border-b">
        <div class="container mx-auto px-4 py-3">
            <nav class="flex" aria-label="Breadcrumb">
                <ol class="inline-flex items-center space-x-1 md:space-x-3">
                    <li class="inline-flex items-center">
                        <asp:HyperLink ID="lnkBreadcrumbHome" runat="server" NavigateUrl="/Client/Default.aspx"
                            CssClass="inline-flex items-center text-sm font-medium text-gray-700 hover:text-primary">
                            <i class="fas fa-home w-4 h-4 mr-2"></i>
                            Trang chủ
                        </asp:HyperLink>
                    </li>
                    <li>
                        <div class="flex items-center">
                            <i class="fas fa-chevron-right text-gray-400 w-4 h-4"></i>
                            <span class="ml-1 text-sm font-medium text-primary md:ml-2">Về chúng tôi</span>
                        </div>
                    </li>
                </ol>
            </nav>
        </div>
    </div>

    <!-- Hero Section -->
    <section class="relative h-96 bg-gradient-to-r from-primary to-secondary flex items-center">
        <div class="absolute inset-0 bg-black bg-opacity-20"></div>
        <div class="container mx-auto px-4 relative z-10">
            <div class="text-center text-white">
                <h1 class="text-4xl md:text-6xl font-bold mb-4">Về ToyLand</h1>
                <p class="text-xl md:text-2xl mb-6">
                    Nơi khơi nguồn sáng tạo và niềm vui cho trẻ em
                </p>
                <div class="flex justify-center space-x-4">
                    <div class="text-center">
                        <div class="text-3xl font-bold">
                            <asp:Label ID="lblYearsExperience" runat="server" Text="8+" />
                        </div>
                        <div class="text-sm">Năm kinh nghiệm</div>
                    </div>
                    <div class="text-center">
                        <div class="text-3xl font-bold">
                            <asp:Label ID="lblCustomersCount" runat="server" Text="50K+" />
                        </div>
                        <div class="text-sm">Khách hàng tin tưởng</div>
                    </div>
                    <div class="text-center">
                        <div class="text-3xl font-bold">
                            <asp:Label ID="lblProductsCount" runat="server" Text="2500+" />
                        </div>
                        <div class="text-sm">Sản phẩm đa dạng</div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- About Content -->
    <section class="py-16">
        <div class="container mx-auto px-4">
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center mb-16">
                <div>
                    <h2 class="text-3xl font-bold text-dark mb-6">
                        Câu chuyện của chúng tôi
                    </h2>
                    <div class="space-y-4">
                        <asp:Literal ID="litAboutContent" runat="server"></asp:Literal>
                    </div>
                    <div class="flex space-x-4 mt-6">
                        <div class="bg-primary bg-opacity-10 p-4 rounded-lg text-center flex-1">
                            <i class="fas fa-shield-alt text-2xl text-primary mb-2"></i>
                            <div class="font-semibold text-dark">An toàn 100%</div>
                        </div>
                        <div class="bg-secondary bg-opacity-10 p-4 rounded-lg text-center flex-1">
                            <i class="fas fa-graduation-cap text-2xl text-secondary mb-2"></i>
                            <div class="font-semibold text-dark">Giáo dục</div>
                        </div>
                        <div class="bg-accent bg-opacity-10 p-4 rounded-lg text-center flex-1">
                            <i class="fas fa-heart text-2xl text-accent mb-2"></i>
                            <div class="font-semibold text-dark">Yêu thương</div>
                        </div>
                    </div>
                </div>
                <div class="relative">
                    <asp:Image ID="imgAboutUs" runat="server" 
                        ImageUrl="https://api.placeholder.com/600/400?text=Về+ToyLand" 
                        AlternateText="Về ToyLand" 
                        CssClass="rounded-lg shadow-lg w-full" />
                    <div class="absolute -bottom-6 -right-6 bg-white p-4 rounded-lg shadow-lg">
                        <div class="flex items-center">
                            <i class="fas fa-star text-yellow-400 text-2xl mr-2"></i>
                            <div>
                                <div class="font-bold text-dark">
                                    <asp:Label ID="lblRating" runat="server" Text="4.8/5" />
                                </div>
                                <div class="text-sm text-gray-600">Đánh giá khách hàng</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Mission & Vision -->
    <section class="bg-gray-100 py-16">
        <div class="container mx-auto px-4">
            <div class="text-center mb-12">
                <h2 class="text-3xl font-bold text-dark mb-4">Sứ mệnh & Tầm nhìn</h2>
                <p class="text-gray-600 max-w-2xl mx-auto">
                    Chúng tôi cam kết tạo ra những trải nghiệm tuyệt vời cho trẻ em và
                    gia đình thông qua các sản phẩm đồ chơi chất lượng cao.
                </p>
            </div>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div class="bg-white rounded-lg p-8 shadow-md">
                    <div class="w-16 h-16 bg-primary bg-opacity-10 rounded-full flex items-center justify-center mb-6">
                        <i class="fas fa-bullseye text-2xl text-primary"></i>
                    </div>
                    <h3 class="text-xl font-bold text-dark mb-4">Sứ mệnh</h3>
                    <p class="text-gray-600 leading-relaxed">
                        <asp:Literal ID="litMission" runat="server"></asp:Literal>
                    </p>
                </div>
                <div class="bg-white rounded-lg p-8 shadow-md">
                    <div class="w-16 h-16 bg-secondary bg-opacity-10 rounded-full flex items-center justify-center mb-6">
                        <i class="fas fa-eye text-2xl text-secondary"></i>
                    </div>
                    <h3 class="text-xl font-bold text-dark mb-4">Tầm nhìn</h3>
                    <p class="text-gray-600 leading-relaxed">
                        <asp:Literal ID="litVision" runat="server"></asp:Literal>
                    </p>
                </div>
            </div>
        </div>
    </section>

    <!-- Core Values -->
    <section class="py-16">
        <div class="container mx-auto px-4">
            <div class="text-center mb-12">
                <h2 class="text-3xl font-bold text-dark mb-4">Giá trị cốt lõi</h2>
                <p class="text-gray-600">
                    Những nguyên tắc định hướng mọi hoạt động của chúng tôi
                </p>
            </div>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <asp:Repeater ID="rptCoreValues" runat="server">
                    <ItemTemplate>
                        <div class="text-center group">
                            <div class="w-20 h-20 bg-<%# Eval("ColorClass") %> bg-opacity-10 rounded-full flex items-center justify-center mx-auto mb-4 group-hover:bg-<%# Eval("ColorClass") %> group-hover:bg-opacity-20 transition-colors">
                                <i class="<%# Eval("IconClass") %> text-3xl text-<%# Eval("ColorClass") %>"></i>
                            </div>
                            <h3 class="text-lg font-bold text-dark mb-2"><%# Eval("Title") %></h3>
                            <p class="text-gray-600 text-sm"><%# Eval("Description") %></p>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>

    <!-- Statistics -->
    <section class="bg-gradient-to-r from-primary to-secondary py-16 text-white">
        <div class="container mx-auto px-4">
            <div class="text-center mb-12">
                <h2 class="text-3xl font-bold mb-4">Con số ấn tượng</h2>
                <p class="text-lg opacity-90">
                    Những thành tích chúng tôi đã đạt được
                </p>
            </div>
            <div class="grid grid-cols-2 md:grid-cols-4 gap-8">
                <asp:Repeater ID="rptStatistics" runat="server">
                    <ItemTemplate>
                        <div class="text-center">
                            <div class="text-4xl md:text-5xl font-bold mb-2 counter-animation" data-count="<%# Eval("Count") %>">
                                <%# Eval("DisplayValue") %>
                            </div>
                            <div class="text-lg"><%# Eval("Label") %></div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>

    <!-- Team Section -->
    <section class="py-16 bg-gray-50">
        <div class="container mx-auto px-4">
            <div class="text-center mb-12">
                <h2 class="text-3xl font-bold text-dark mb-4">
                    Đội ngũ của chúng tôi
                </h2>
                <p class="text-gray-600">
                    Những con người tài năng và tâm huyết đứng sau thành công của ToyLand
                </p>
            </div>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                <asp:Repeater ID="rptTeamMembers" runat="server">
                    <ItemTemplate>
                        <div class="team-card relative group">
                            <div class="bg-white rounded-lg overflow-hidden shadow-md">
                                <div class="relative">
                                    <asp:Image ID="imgTeamMember" runat="server" 
                                        ImageUrl='<%# Eval("ImageUrl") %>' 
                                        AlternateText='<%# Eval("Name") %>' 
                                        CssClass="w-full h-64 object-cover" />
                                    <div class="team-overlay absolute inset-0 bg-<%# Eval("ColorClass") %> bg-opacity-90 flex items-center justify-center opacity-0 transition-opacity">
                                        <div class="text-center text-white">
                                            <p class="mb-4">"<%# Eval("Quote") %>"</p>
                                            <div class="flex justify-center space-x-3">
                                                <asp:Repeater ID="rptSocialLinks" runat="server" DataSource='<%# Eval("SocialLinks") %>'>
                                                    <ItemTemplate>
                                                        <asp:HyperLink ID="lnkSocial" runat="server" 
                                                            NavigateUrl='<%# Eval("Url") %>'
                                                            CssClass="w-8 h-8 bg-white bg-opacity-20 rounded-full flex items-center justify-center hover:bg-opacity-30"
                                                            Target="_blank">
                                                            <i class="<%# Eval("IconClass") %>"></i>
                                                        </asp:HyperLink>
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="p-6 text-center">
                                    <h3 class="text-xl font-bold text-dark mb-1"><%# Eval("Name") %></h3>
                                    <p class="text-<%# Eval("ColorClass") %> font-medium mb-2"><%# Eval("Position") %></p>
                                    <p class="text-gray-600 text-sm"><%# Eval("Experience") %></p>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>

    <!-- Timeline -->
    <section class="py-16">
        <div class="container mx-auto px-4">
            <div class="text-center mb-12">
                <h2 class="text-3xl font-bold text-dark mb-4">
                    Hành trình phát triển
                </h2>
                <p class="text-gray-600">
                    Những cột mốc quan trọng trong quá trình xây dựng và phát triển ToyLand
                </p>
            </div>
            <div class="relative">
                <div class="absolute left-1/2 transform -translate-x-1/2 w-1 h-full bg-primary bg-opacity-20"></div>
                <div class="space-y-12">
                    <asp:Repeater ID="rptTimeline" runat="server">
                        <ItemTemplate>
                            <div class="timeline-item flex items-center">
                              123
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>
    </section>

    <!-- Certificates & Partners -->
    <section class="bg-gray-100 py-16">
        <div class="container mx-auto px-4">
            <div class="text-center mb-12">
                <h2 class="text-3xl font-bold text-dark mb-4">
                    Chứng nhận & Đối tác
                </h2>
                <p class="text-gray-600">
                    Những chứng nhận uy tín và đối tác tin cậy của chúng tôi
                </p>
            </div>

            <!-- Certificates -->
            <div class="mb-12">
                <h3 class="text-xl font-bold text-dark text-center mb-6">
                    Chứng nhận an toàn
                </h3>
                <div class="grid grid-cols-2 md:grid-cols-4 gap-6">
                    <asp:Repeater ID="rptCertificates" runat="server">
                        <ItemTemplate>
                            <div class="bg-white rounded-lg p-6 shadow-md text-center">
                                <asp:Image ID="imgCertificate" runat="server" 
                                    ImageUrl='<%# Eval("ImageUrl") %>' 
                                    AlternateText='<%# Eval("Name") %>' 
                                    CssClass="w-16 h-16 mx-auto mb-3" />
                                <h4 class="font-bold text-dark text-sm"><%# Eval("Name") %></h4>
                                <p class="text-xs text-gray-600"><%# Eval("Description") %></p>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <!-- Partners -->
            <div>
                <h3 class="text-xl font-bold text-dark text-center mb-6">
                    Đối tác thương hiệu
                </h3>
                <div class="grid grid-cols-3 md:grid-cols-6 gap-6">
                    <asp:Repeater ID="rptPartners" runat="server">
                        <ItemTemplate>
                            <div class="bg-white rounded-lg p-4 shadow-md flex items-center justify-center">
                                <asp:Image ID="imgPartner" runat="server" 
                                    ImageUrl='<%# Eval("ImageUrl") %>' 
                                    AlternateText='<%# Eval("Name") %>' 
                                    CssClass="max-w-full max-h-12 opacity-70 hover:opacity-100 transition-opacity" />
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>
    </section>

    <!-- Customer Testimonials -->
    <section class="py-16">
        <div class="container mx-auto px-4">
            <div class="text-center mb-12">
                <h2 class="text-3xl font-bold text-dark mb-4">
                    Khách hàng nói gì về chúng tôi
                </h2>
                <p class="text-gray-600">
                    Những phản hồi chân thực từ các gia đình đã tin tưởng ToyLand
                </p>
            </div>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
                <asp:Repeater ID="rptTestimonials" runat="server">
                    <ItemTemplate>
                        <div class="bg-white rounded-lg p-6 shadow-md">
                            <div class="flex text-yellow-400 mb-4">
                             5
                            </div>
                            <p class="text-gray-600 italic mb-4">
                                "<%# Eval("Content") %>"
                            </p>
                            <div class="flex items-center">
                                <asp:Image ID="imgCustomer" runat="server" 
                                    ImageUrl='<%# Eval("CustomerImage") %>' 
                                    AlternateText='<%# Eval("CustomerName") %>' 
                                    CssClass="w-12 h-12 rounded-full mr-3" />
                                <div>
                                    <div class="font-bold text-dark"><%# Eval("CustomerName") %></div>
                                    <div class="text-sm text-gray-600"><%# Eval("CustomerInfo") %></div>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>

    <!-- CTA Section -->
    <section class="bg-gradient-to-r from-primary to-secondary py-16 text-white">
        <div class="container mx-auto px-4 text-center">
            <h2 class="text-3xl font-bold mb-4">
                Hãy cùng ToyLand tạo nên những kỷ niệm đẹp
            </h2>
            <p class="text-lg mb-8 opacity-90">
                Khám phá bộ sưu tập đồ chơi đa dạng và chất lượng cao của chúng tôi
            </p>
            <div class="flex flex-col sm:flex-row gap-4 justify-center">
                <asp:HyperLink ID="lnkViewProducts" runat="server" NavigateUrl="/Client/ProductList.aspx"
                    CssClass="bg-white text-primary px-8 py-3 rounded-lg font-bold hover:bg-gray-100 transition-colors">
                    Xem sản phẩm
                </asp:HyperLink>
                <asp:HyperLink ID="lnkContact" runat="server" NavigateUrl="/Client/Contact.aspx"
                    CssClass="border-2 border-white text-white px-8 py-3 rounded-lg font-bold hover:bg-white hover:text-primary transition-colors">
                    Liên hệ tư vấn
                </asp:HyperLink>
            </div>
        </div>
    </section>
    <!-- Back to top button -->
    <asp:Button ID="btnBackToTop" runat="server" 
        CssClass="fixed bottom-20 right-4 bg-primary text-white w-10 h-10 rounded-full flex items-center justify-center shadow-lg z-40 hover:bg-dark transition-colors" 
        Style="display: none;" 
        OnClientClick="window.scrollTo({ top: 0, behavior: 'smooth' }); return false;">
    </asp:Button>

    <script>
        // Back to Top Button
        const backToTopButton = document.getElementById('<%= btnBackToTop.ClientID %>');
        window.addEventListener('scroll', () => {
            if (window.scrollY > 300) {
                backToTopButton.style.display = 'flex';
            } else {
                backToTopButton.style.display = 'none';
            }
        });

        // Counter Animation
        const observerOptions = {
            threshold: 0.5,
            rootMargin: '0px 0px -100px 0px',
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach((entry) => {
                if (entry.isIntersecting) {
                    const counters = entry.target.querySelectorAll('[data-count]');
                    counters.forEach((counter) => {
                        const target = parseInt(counter.dataset.count);
                        const current = parseInt(counter.textContent.replace(/[^0-9]/g, ''));

                        if (current < target) {
                            const increment = target / 50;
                            const timer = setInterval(() => {
                                const currentValue = parseInt(counter.textContent.replace(/[^0-9]/g, ''));
                                if (currentValue < target) {
                                    const newValue = Math.min(currentValue + increment, target);
                                    const suffix = counter.textContent.includes('+') ? '+' : '';
                                    counter.textContent = Math.floor(newValue).toLocaleString() + suffix;
                                } else {
                                    clearInterval(timer);
                                }
                            }, 50);
                        }
                    });
                }
            });
        }, observerOptions);

        // Observe statistics section
        const statsSection = document.querySelector('.bg-gradient-to-r.from-primary.to-secondary');
        if (statsSection) {
            observer.observe(statsSection);
        }

        // Bottom Navigation Active State
        const navItems = document.querySelectorAll('.nav-item');
        navItems.forEach((item) => {
            item.addEventListener('click', (e) => {
                // Remove active class from all items
                navItems.forEach((nav) => {
                    nav.classList.remove('active');
                    nav.classList.add('text-gray-600');
                });
                // Add active class to clicked item
                item.classList.add('active');
                item.classList.remove('text-gray-600');
            });
        });

        // Smooth scrolling for anchor links
        document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start',
                    });
                }
            });
        });

        // Parallax effect for hero section (optional)
        window.addEventListener('scroll', () => {
            const scrolled = window.pageYOffset;
            const parallax = document.querySelector('.parallax-bg');
            if (parallax) {
                const speed = scrolled * 0.5;
                parallax.style.transform = `translateY(${speed}px)`;
            }
        });
    </script>
</asp:Content>