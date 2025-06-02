<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Logout.aspx.cs" Inherits="WebDoChoi.Client.Logout" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng xuất - ToyLand</title>
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
            background: linear-gradient(135deg, #FF6B6B 0%, #4ECDC4 100%);
            min-height: 100vh;
        }
        
        .floating-toys {
            position: absolute;
            font-size: 2rem;
            color: rgba(255, 255, 255, 0.1);
            animation: float 6s ease-in-out infinite;
        }
        
        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-20px); }
        }
        
        .toy-1 { top: 10%; left: 10%; animation-delay: 0s; }
        .toy-2 { top: 20%; right: 15%; animation-delay: 1s; }
        .toy-3 { bottom: 30%; left: 20%; animation-delay: 2s; }
        .toy-4 { bottom: 15%; right: 10%; animation-delay: 3s; }
        
        .logout-animation {
            animation: slideInUp 0.5s ease-out;
        }
        
        @keyframes slideInUp {
            from {
                transform: translateY(50px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Floating Toy Icons -->
        <div class="floating-toys toy-1"><i class="fas fa-rocket"></i></div>
        <div class="floating-toys toy-2"><i class="fas fa-robot"></i></div>
        <div class="floating-toys toy-3"><i class="fas fa-car"></i></div>
        <div class="floating-toys toy-4"><i class="fas fa-puzzle-piece"></i></div>

        <div class="flex items-center justify-center min-h-screen py-12 px-4">
            <div class="logout-animation bg-white rounded-2xl shadow-2xl overflow-hidden max-w-md w-full">
                <!-- Header -->
                <div class="bg-gradient-to-r from-primary to-secondary p-6 text-center">
                    <div class="text-3xl font-bold text-white mb-2">
                        <span>Toy</span>Land
                        <i class="fas fa-rocket ml-2 text-accent"></i>
                    </div>
                    <p class="text-white/90">Cảm ơn bạn đã sử dụng dịch vụ</p>
                </div>

                <!-- Content -->
                <div class="p-8 text-center">
                    <div class="w-20 h-20 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-6">
                        <i class="fas fa-sign-out-alt text-3xl text-red-600"></i>
                    </div>
                    
                    <h2 class="text-2xl font-bold text-dark mb-4">Đăng xuất thành công</h2>
                    
                    <asp:Panel ID="pnlLogoutSuccess" runat="server" Visible="false">
                        <p class="text-gray-600 mb-6">
                            Bạn đã đăng xuất khỏi tài khoản thành công. 
                            Cảm ơn bạn đã sử dụng ToyLand!
                        </p>
                        
                        <div class="space-y-3">
                            <asp:HyperLink ID="lnkBackToHome" runat="server" 
                                NavigateUrl="~/Client/Default.aspx"
                                CssClass="block w-full bg-primary text-white py-3 rounded-lg hover:bg-primary/90 transition-colors font-medium">
                                <i class="fas fa-home mr-2"></i>Về trang chủ
                            </asp:HyperLink>
                            
                            <asp:HyperLink ID="lnkLoginAgain" runat="server" 
                                NavigateUrl="~/Client/Login.aspx"
                                CssClass="block w-full border-2 border-primary text-primary py-3 rounded-lg hover:bg-primary hover:text-white transition-colors font-medium">
                                <i class="fas fa-sign-in-alt mr-2"></i>Đăng nhập lại
                            </asp:HyperLink>
                        </div>
                    </asp:Panel>

                    <asp:Panel ID="pnlLogoutError" runat="server" Visible="false">
                        <p class="text-red-600 mb-6">
                            <asp:Label ID="lblErrorMessage" runat="server"></asp:Label>
                        </p>
                        
                        <asp:Button ID="btnTryAgain" runat="server" 
                            Text="Thử lại" 
                            CssClass="w-full bg-red-500 text-white py-3 rounded-lg hover:bg-red-600 transition-colors font-medium"
                            OnClick="btnTryAgain_Click" />
                    </asp:Panel>

                    <asp:Panel ID="pnlLoggingOut" runat="server" Visible="true">
                        <div class="text-center">
                            <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto mb-4"></div>
                            <p class="text-gray-600">Đang đăng xuất...</p>
                        </div>
                    </asp:Panel>
                </div>

                <!-- Footer -->
                <div class="bg-gray-50 px-8 py-4 text-center text-sm text-gray-500">
                    <p>© 2025 ToyLand. Tất cả quyền được bảo lưu.</p>
                    <div class="flex justify-center space-x-4 mt-2">
                        <a href="#" class="text-gray-400 hover:text-primary transition-colors">
                            <i class="fab fa-facebook-f"></i>
                        </a>
                        <a href="#" class="text-gray-400 hover:text-primary transition-colors">
                            <i class="fab fa-instagram"></i>
                        </a>
                        <a href="#" class="text-gray-400 hover:text-primary transition-colors">
                            <i class="fab fa-youtube"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script>
        // Auto redirect after successful logout
        document.addEventListener('DOMContentLoaded', function() {
            const successPanel = document.getElementById('<%= pnlLogoutSuccess.ClientID %>');
            
            if (successPanel && successPanel.style.display !== 'none') {
                // Auto redirect to home page after 5 seconds
                setTimeout(function() {
                    window.location.href = '<%= ResolveUrl("~/Client/Default.aspx") %>';
                }, 5000);
                
                // Show countdown
                let countdown = 5;
                const countdownElement = document.createElement('p');
                countdownElement.className = 'text-sm text-gray-500 mt-4';
                countdownElement.innerHTML = `Tự động chuyển về trang chủ sau <span class="font-bold text-primary">${countdown}</span> giây`;
                successPanel.appendChild(countdownElement);
                
                const interval = setInterval(function() {
                    countdown--;
                    const span = countdownElement.querySelector('span');
                    if (span) {
                        span.textContent = countdown;
                    }
                    
                    if (countdown <= 0) {
                        clearInterval(interval);
                    }
                }, 1000);
            }
        });
    </script>
</body>
</html>