-- ===================================================================

-- Tạo database
CREATE DATABASE IF NOT EXISTS toyland_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE toyland_db;

-- ===================================================================
-- 1. BẢNG QUẢN LÝ NGƯỜI DÙNG
-- ===================================================================

-- Bảng vai trò người dùng
CREATE TABLE user_roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng người dùng
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    gender ENUM('Male', 'Female', 'Other'),
    role_id INT NOT NULL,
    avatar_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES user_roles(id)
);

-- Bảng địa chỉ người dùng
CREATE TABLE user_addresses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    address_type ENUM('Home', 'Work', 'Other') DEFAULT 'Home',
    recipient_name VARCHAR(200) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address_line1 VARCHAR(500) NOT NULL,
    address_line2 VARCHAR(500),
    ward VARCHAR(100),
    district VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ===================================================================
-- 2. BẢNG QUẢN LÝ DANH MỤC VÀ SẢN PHẨM
-- ===================================================================

-- Bảng danh mục sản phẩm
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    slug VARCHAR(200) NOT NULL UNIQUE,
    description TEXT,
    parent_id INT NULL,
    icon VARCHAR(100),
    image_url VARCHAR(500),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    seo_title VARCHAR(200),
    seo_description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- Bảng thương hiệu
CREATE TABLE brands (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL UNIQUE,
    slug VARCHAR(200) NOT NULL UNIQUE,
    description TEXT,
    logo_url VARCHAR(500),
    website_url VARCHAR(500),
    country VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Bảng độ tuổi phù hợp
CREATE TABLE age_groups (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    min_age INT NOT NULL,
    max_age INT NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng sản phẩm chính
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(300) NOT NULL,
    slug VARCHAR(300) NOT NULL UNIQUE,
    sku VARCHAR(100) NOT NULL UNIQUE,
    short_description TEXT,
    detailed_description LONGTEXT,
    category_id INT NOT NULL,
    brand_id INT,
    age_group_id INT,
    original_price DECIMAL(12,2) NOT NULL,
    sale_price DECIMAL(12,2),
    cost_price DECIMAL(12,2),
    weight DECIMAL(8,2),
    dimensions VARCHAR(100),
    material VARCHAR(200),
    color VARCHAR(100),
    stock_quantity INT DEFAULT 0,
    min_stock_level INT DEFAULT 5,
    is_featured BOOLEAN DEFAULT FALSE,
    is_bestseller BOOLEAN DEFAULT FALSE,
    is_new BOOLEAN DEFAULT FALSE,
    status ENUM('Active', 'Inactive', 'OutOfStock', 'Discontinued') DEFAULT 'Active',
    safety_certification VARCHAR(200),
    warranty_months INT DEFAULT 0,
    rating_average DECIMAL(3,2) DEFAULT 0.00,
    rating_count INT DEFAULT 0,
    view_count INT DEFAULT 0,
    sold_count INT DEFAULT 0,
    seo_title VARCHAR(200),
    seo_description TEXT,
    seo_keywords VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (brand_id) REFERENCES brands(id),
    FOREIGN KEY (age_group_id) REFERENCES age_groups(id),
    INDEX idx_category (category_id),
    INDEX idx_brand (brand_id),
    INDEX idx_status (status),
    INDEX idx_featured (is_featured),
    INDEX idx_bestseller (is_bestseller),
    INDEX idx_price_range (sale_price, original_price)
);

-- Bảng hình ảnh sản phẩm
CREATE TABLE product_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(200),
    is_primary BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Bảng thuộc tính sản phẩm
CREATE TABLE product_attributes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    type ENUM('text', 'number', 'boolean', 'select') DEFAULT 'text',
    unit VARCHAR(20),
    is_required BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng giá trị thuộc tính sản phẩm
CREATE TABLE product_attribute_values (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    attribute_id INT NOT NULL,
    value TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (attribute_id) REFERENCES product_attributes(id),
    UNIQUE KEY unique_product_attribute (product_id, attribute_id)
);

-- ===================================================================
-- 3. BẢNG QUẢN LÝ GIỎ HÀNG VÀ ĐƠN HÀNG
-- ===================================================================

-- Bảng giỏ hàng
CREATE TABLE shopping_cart (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    session_id VARCHAR(200),
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    price DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_user_cart (user_id),
    INDEX idx_session_cart (session_id)
);

-- Bảng trạng thái đơn hàng
CREATE TABLE order_statuses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    sort_order INT DEFAULT 0,
    color VARCHAR(7) DEFAULT '#000000',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng phương thức thanh toán
CREATE TABLE payment_methods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    processing_fee DECIMAL(5,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng phương thức vận chuyển
CREATE TABLE shipping_methods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    base_cost DECIMAL(10,2) NOT NULL,
    cost_per_kg DECIMAL(10,2) DEFAULT 0.00,
    estimated_days INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng đơn hàng
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    user_id INT,
    guest_email VARCHAR(255),
    status_id INT NOT NULL,
    payment_method_id INT NOT NULL,
    shipping_method_id INT NOT NULL,
    
    -- Thông tin người nhận
    recipient_name VARCHAR(200) NOT NULL,
    recipient_phone VARCHAR(20) NOT NULL,
    recipient_email VARCHAR(255),
    shipping_address TEXT NOT NULL,
    
    -- Thông tin đơn hàng
    subtotal DECIMAL(12,2) NOT NULL,
    shipping_cost DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    total_amount DECIMAL(12,2) NOT NULL,
    
    -- Thông tin thanh toán
    payment_status ENUM('Pending', 'Paid', 'Failed', 'Refunded') DEFAULT 'Pending',
    payment_date TIMESTAMP NULL,
    payment_reference VARCHAR(200),
    
    -- Thông tin vận chuyển
    shipping_date TIMESTAMP NULL,
    delivery_date TIMESTAMP NULL,
    tracking_number VARCHAR(200),
    
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (status_id) REFERENCES order_statuses(id),
    FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id),
    FOREIGN KEY (shipping_method_id) REFERENCES shipping_methods(id),
    INDEX idx_order_number (order_number),
    INDEX idx_user_orders (user_id),
    INDEX idx_order_status (status_id),
    INDEX idx_order_date (created_at)
);

-- Bảng chi tiết đơn hàng
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(300) NOT NULL,
    product_sku VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    total_price DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Bảng lịch sử đơn hàng
CREATE TABLE order_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    status_id INT NOT NULL,
    comment TEXT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (status_id) REFERENCES order_statuses(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- ===================================================================
-- 4. BẢNG QUẢN LÝ ĐÁNH GIÁ VÀ NHẬN XÉT
-- ===================================================================

-- Bảng đánh giá sản phẩm
CREATE TABLE product_reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT,
    order_id INT,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(200),
    content TEXT,
    pros TEXT,
    cons TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT FALSE,
    helpful_count INT DEFAULT 0,
    reported_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    INDEX idx_product_reviews (product_id),
    INDEX idx_rating (rating),
    INDEX idx_approved (is_approved)
);

-- Bảng hình ảnh đánh giá
CREATE TABLE review_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    review_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (review_id) REFERENCES product_reviews(id) ON DELETE CASCADE
);

-- ===================================================================
-- 5. BẢNG QUẢN LÝ KHUYẾN MÃI VÀ COUPON
-- ===================================================================

-- Bảng mã giảm giá
CREATE TABLE coupons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    type ENUM('percentage', 'fixed_amount', 'free_shipping') NOT NULL,
    value DECIMAL(10,2) NOT NULL,
    minimum_amount DECIMAL(12,2) DEFAULT 0.00,
    maximum_discount DECIMAL(10,2),
    usage_limit INT,
    used_count INT DEFAULT 0,
    usage_limit_per_user INT DEFAULT 1,
    valid_from DATETIME NOT NULL,
    valid_until DATETIME NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_coupon_code (code),
    INDEX idx_coupon_dates (valid_from, valid_until)
);

-- Bảng sử dụng coupon
CREATE TABLE coupon_usage (
    id INT AUTO_INCREMENT PRIMARY KEY,
    coupon_id INT NOT NULL,
    user_id INT,
    order_id INT NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL,
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (coupon_id) REFERENCES coupons(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    UNIQUE KEY unique_user_coupon_usage (coupon_id, user_id, order_id)
);

-- Bảng khuyến mãi sản phẩm
CREATE TABLE product_promotions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    type ENUM('percentage', 'fixed_amount', 'buy_x_get_y') NOT NULL,
    value DECIMAL(10,2) NOT NULL,
    applicable_to ENUM('all', 'category', 'product', 'brand') NOT NULL,
    target_id INT,
    valid_from DATETIME NOT NULL,
    valid_until DATETIME NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ===================================================================
-- 6. BẢNG QUẢN LÝ WISHLIST VÀ SO SÁNH
-- ===================================================================

-- Bảng danh sách yêu thích
CREATE TABLE wishlists (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_product_wishlist (user_id, product_id)
);

-- Bảng so sánh sản phẩm
CREATE TABLE product_comparisons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    session_id VARCHAR(200),
    product_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_user_comparison (user_id),
    INDEX idx_session_comparison (session_id)
);

-- ===================================================================
-- 7. BẢNG QUẢN LÝ BANNER VÀ NỘI DUNG
-- ===================================================================

-- Bảng banner quảng cáo
CREATE TABLE banners (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    image_url VARCHAR(500) NOT NULL,
    mobile_image_url VARCHAR(500),
    link_url VARCHAR(500),
    position ENUM('homepage_main', 'homepage_side', 'category_top', 'product_detail') NOT NULL,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    start_date DATETIME NULL,
    end_date DATETIME NULL,
    click_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Bảng bài viết blog
CREATE TABLE blog_posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(300) NOT NULL,
    slug VARCHAR(300) NOT NULL UNIQUE,
    excerpt TEXT,
    content LONGTEXT NOT NULL,
    featured_image VARCHAR(500),
    author_id INT NOT NULL,
    category VARCHAR(100),
    tags VARCHAR(500),
    is_published BOOLEAN DEFAULT FALSE,
    published_at TIMESTAMP NULL,
    view_count INT DEFAULT 0,
    seo_title VARCHAR(200),
    seo_description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(id)
);

-- ===================================================================
-- 8. BẢNG QUẢN LÝ THỐNG KÊ VÀ BÁO CÁO
-- ===================================================================

-- Bảng thống kê truy cập
CREATE TABLE website_analytics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date DATE NOT NULL,
    page_views INT DEFAULT 0,
    unique_visitors INT DEFAULT 0,
    new_visitors INT DEFAULT 0,
    bounce_rate DECIMAL(5,2) DEFAULT 0.00,
    avg_session_duration INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_date_analytics (date)
);

-- Bảng thống kê sản phẩm
CREATE TABLE product_analytics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    date DATE NOT NULL,
    view_count INT DEFAULT 0,
    add_to_cart_count INT DEFAULT 0,
    purchase_count INT DEFAULT 0,
    revenue DECIMAL(12,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_product_date_analytics (product_id, date)
);

-- ===================================================================
-- 9. BẢNG CẤU HÌNH HỆ THỐNG
-- ===================================================================

-- Bảng cấu hình website
CREATE TABLE site_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    setting_type ENUM('text', 'number', 'boolean', 'json') DEFAULT 'text',
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Bảng log hoạt động
CREATE TABLE activity_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(100),
    record_id INT,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_user_activity (user_id),
    INDEX idx_action (action),
    INDEX idx_created_at (created_at)
);

-- ===================================================================
-- 10. BẢNG QUẢN LÝ EMAIL VÀ THÔNG BÁO
-- ===================================================================

-- Bảng đăng ký newsletter
CREATE TABLE newsletter_subscribers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(200),
    is_active BOOLEAN DEFAULT TRUE,
    subscribed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    unsubscribed_at TIMESTAMP NULL,
    INDEX idx_email (email),
    INDEX idx_active (is_active)
);

-- Bảng thông báo hệ thống
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    type ENUM('order', 'promotion', 'system', 'review') NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    related_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_notifications (user_id),
    INDEX idx_read_status (is_read)
);

-- Bảng log lỗi hệ thống
CREATE TABLE error_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    error_type ENUM('SQL', 'PHP', 'JS', 'API', 'System') NOT NULL,
    error_message TEXT NOT NULL,
    error_file VARCHAR(500),
    error_line INT,
    user_id INT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    request_data JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_error_type (error_type),
    INDEX idx_error_date (created_at)
);

-- Bảng log performance
CREATE TABLE performance_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    page_url VARCHAR(500) NOT NULL,
    load_time DECIMAL(8,3) NOT NULL,
    memory_usage INT,
    query_count INT,
    user_id INT NULL,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_page_url (page_url),
    INDEX idx_load_time (load_time),
    INDEX idx_created_at (created_at)
);

-- ===================================================================
-- 11. CHÈN DỮ LIỆU MẪU
-- ===================================================================

-- Dữ liệu vai trò người dùng
INSERT INTO user_roles (role_name, description) VALUES
('Admin', 'Quản trị viên hệ thống'),
('Manager', 'Quản lý cửa hàng'),
('Staff', 'Nhân viên bán hàng'),
('Customer', 'Khách hàng');

-- Dữ liệu trạng thái đơn hàng
INSERT INTO order_statuses (name, description, sort_order, color) VALUES
('Pending', 'Chờ xử lý', 1, '#FFA500'),
('Confirmed', 'Đã xác nhận', 2, '#00BFFF'),
('Processing', 'Đang xử lý', 3, '#1E90FF'),
('Shipped', 'Đã gửi hàng', 4, '#32CD32'),
('Delivered', 'Đã giao hàng', 5, '#008000'),
('Cancelled', 'Đã hủy', 6, '#FF0000'),
('Returned', 'Đã trả lại', 7, '#800080');

-- Dữ liệu phương thức thanh toán
INSERT INTO payment_methods (name, code, description, processing_fee) VALUES
('Tiền mặt', 'COD', 'Thanh toán khi nhận hàng', 0.00),
('Chuyển khoản', 'BANK_TRANSFER', 'Chuyển khoản ngân hàng', 0.00),
('Ví điện tử MoMo', 'MOMO', 'Thanh toán qua ví MoMo', 1.50),
('Ví điện tử ZaloPay', 'ZALOPAY', 'Thanh toán qua ZaloPay', 1.50),
('Thẻ tín dụng', 'CREDIT_CARD', 'Thanh toán bằng thẻ tín dụng', 2.50);

-- Dữ liệu phương thức vận chuyển
INSERT INTO shipping_methods (name, description, base_cost, cost_per_kg, estimated_days) VALUES
('Giao hàng tiêu chuẩn', 'Giao hàng trong 3-5 ngày làm việc', 30000, 5000, 4),
('Giao hàng nhanh', 'Giao hàng trong 1-2 ngày làm việc', 50000, 8000, 2),
('Giao hàng hỏa tốc', 'Giao hàng trong ngày', 100000, 15000, 1);

-- Dữ liệu độ tuổi
INSERT INTO age_groups (name, min_age, max_age, description) VALUES
('0-12 tháng', 0, 1, 'Đồ chơi cho trẻ sơ sinh đến 12 tháng tuổi'),
('1-3 tuổi', 1, 3, 'Đồ chơi cho trẻ mới biết đi'),
('3-6 tuổi', 3, 6, 'Đồ chơi cho trẻ mầm non'),
('6-12 tuổi', 6, 12, 'Đồ chơi cho trẻ tiểu học'),
('12+ tuổi', 12, 99, 'Đồ chơi cho trẻ lớn và người lớn');

-- Dữ liệu danh mục sản phẩm
INSERT INTO categories (name, slug, description, icon, sort_order) VALUES
('Đồ chơi giáo dục', 'do-choi-giao-duc', 'Đồ chơi phát triển trí tuệ và kỹ năng học tập', 'fas fa-puzzle-piece', 1),
('Xe & Điều khiển', 'xe-dieu-khien', 'Xe đồ chơi và xe điều khiển từ xa', 'fas fa-car', 2),
('Đồ chơi cho bé 0-3 tuổi', 'do-choi-be-0-3-tuoi', 'Đồ chơi an toàn cho trẻ nhỏ', 'fas fa-baby', 3),
('Robot & Nhân vật', 'robot-nhan-vat', 'Robot và các nhân vật hoạt hình', 'fas fa-robot', 4),
('Đồ chơi thông minh', 'do-choi-thong-minh', 'Đồ chơi công nghệ cao', 'fas fa-chess', 5),
('Đồ chơi sáng tạo', 'do-choi-sang-tao', 'Đồ chơi phát triển sáng tạo', 'fas fa-paint-brush', 6),
('Đồ chơi vận động', 'do-choi-van-dong', 'Đồ chơi thể thao và vận động', 'fas fa-basketball-ball', 7),
('Đồ chơi xây dựng', 'do-choi-xay-dung', 'Lego và đồ chơi lắp ráp', 'fas fa-building', 8);

-- Dữ liệu thương hiệu
INSERT INTO brands (name, slug, description, country) VALUES
('LEGO', 'lego', 'Thương hiệu đồ chơi xây dựng nổi tiếng thế giới', 'Denmark'),
('Fisher-Price', 'fisher-price', 'Thương hiệu đồ chơi trẻ em hàng đầu', 'USA'),
('Barbie', 'barbie', 'Thương hiệu búp bê nổi tiếng', 'USA'),
('Hot Wheels', 'hot-wheels', 'Thương hiệu xe đồ chơi', 'USA'),
('Nerf', 'nerf', 'Thương hiệu đồ chơi bắn súng', 'USA'),
('Playmobil', 'playmobil', 'Thương hiệu đồ chơi lắp ráp', 'Germany'),
('Melissa & Doug', 'melissa-doug', 'Đồ chơi gỗ giáo dục', 'USA'),
('VTech', 'vtech', 'Đồ chơi điện tử giáo dục', 'Hong Kong');

-- Dữ liệu sản phẩm mẫu
INSERT INTO products (name, slug, sku, short_description, detailed_description, category_id, brand_id, age_group_id, original_price, sale_price, stock_quantity, is_featured, is_bestseller, is_new, material, weight, dimensions, safety_certification) VALUES
('Robot biến hình thông minh', 'robot-bien-hinh-thong-minh', 'RBT001', 'Robot có thể biến hình thành xe hơi với âm thanh và đèn LED', 'Robot biến hình thông minh với khả năng chuyển đổi từ robot thành xe hơi chỉ trong vài giây. Sản phẩm có âm thanh sống động và đèn LED nhiều màu sắc.', 4, 1, 4, 550000, 450000, 25, TRUE, TRUE, FALSE, 'Nhựa ABS cao cấp', 0.8, '25x15x10 cm', 'CE, EN71'),

('Bộ xếp hình thành phố 520 chi tiết', 'bo-xep-hinh-thanh-pho-520-chi-tiet', 'LEGO001', 'Bộ LEGO xây dựng thành phố mini với nhiều tòa nhà và phương tiện', 'Bộ xếp hình LEGO thành phố với 520 chi tiết bao gồm các tòa nhà, xe cộ, và nhân vật. Phát triển tư duy logic và khả năng sáng tạo cho trẻ.', 8, 1, 4, 850000, 690000, 15, TRUE, TRUE, FALSE, 'Nhựa ABS', 1.2, '35x25x8 cm', 'CE, ASTM'),

('Xe đua điều khiển từ xa địa hình', 'xe-dua-dieu-khien-tu-xa-dia-hinh', 'RC001', 'Xe điều khiển từ xa có thể chạy trên mọi địa hình', 'Xe đua điều khiển từ xa với động cơ mạnh mẽ, có thể di chuyển trên cát, đất, và đường nhựa. Tầm điều khiển lên đến 50m.', 2, 4, 3, 520000, 520000, 30, FALSE, FALSE, TRUE, 'Nhựa và kim loại', 1.5, '30x20x15 cm', 'FCC, CE'),

('Bộ ghép hình thông minh phát triển trí tuệ', 'bo-ghep-hinh-thong-minh-phat-trien-tri-tue', 'PUZ001', 'Bộ ghép hình 3D giúp phát triển tư duy không gian', 'Bộ đồ chơi ghép hình 3D với các mảnh ghép đa dạng hình dạng và màu sắc, giúp trẻ phát triển tư duy logic và khả năng giải quyết vấn đề.', 1, 7, 3, 350000, 290000, 40, TRUE, FALSE, FALSE, 'Gỗ tự nhiên', 0.5, '20x20x5 cm', 'FSC, EN71'),

('Bộ đồ chơi học toán vui nhộn', 'bo-do-choi-hoc-toan-vui-nhon', 'EDU001', 'Bộ đồ chơi giúp trẻ học toán một cách thú vị', 'Bộ đồ chơi giáo dục bao gồm các số, dấu toán học và bảng tính, giúp trẻ làm quen với toán học từ sớm thông qua trò chơi.', 1, 8, 3, 250000, 195000, 50, TRUE, FALSE, FALSE, 'Nhựa an toàn', 0.6, '25x18x8 cm', 'CE, CPSIA'),

('Đồ chơi nhà bếp mini', 'do-choi-nha-bep-mini', 'KITCHEN001', 'Bộ đồ chơi nhà bếp với đầy đủ dụng cụ nấu ăn', 'Bộ đồ chơi nhà bếp mini hoàn chỉnh với bếp gas, nồi niêu, và các thực phẩm giả, giúp trẻ phát triển kỹ năng sống và trí tưởng tượng.', 6, 2, 3, 280000, 230000, 35, FALSE, FALSE, TRUE, 'Nhựa ABS', 2.0, '40x30x25 cm', 'EN71, ASTM'),

('Máy bay điều khiển từ xa', 'may-bay-dieu-khien-tu-xa', 'PLANE001', 'Máy bay điều khiển từ xa dễ bay cho người mới bắt đầu', 'Máy bay điều khiển từ xa thiết kế đơn giản, dễ điều khiển với tính năng tự cân bằng và chế độ bay cho người mới bắt đầu.', 2, NULL, 4, 480000, 480000, 20, FALSE, FALSE, TRUE, 'Foam EPP', 0.3, '35x35x8 cm', 'CE, FCC'),

('Búp bê cảm ứng thông minh', 'bup-be-cam-ung-thong-minh', 'DOLL001', 'Búp bê có thể nói chuyện và phản ứng với tiếng nói', 'Búp bê thông minh với công nghệ nhận diện giọng nói, có thể trò chuyện, hát và kể chuyện cùng trẻ em.', 5, 3, 3, 420000, 350000, 25, TRUE, FALSE, FALSE, 'Vinyl và vải', 0.8, '30x12x8 cm', 'CE, CPSC');

-- Dữ liệu hình ảnh sản phẩm
INSERT INTO product_images (product_id, image_url, alt_text, is_primary, sort_order) VALUES
(1, 'https://kenhchinhhang.vn/upload/imageManage/2_1719479840.jpg', 'Robot biến hình thông minh', TRUE, 1),
(1, 'https://kenhchinhhang.vn/upload/imageManage/1_1719479837.jpg', 'Chế độ robot', FALSE, 2),
(1, 'https://steamland.vn/wp-content/uploads/2024/07/1-3.jpg', 'Chế độ xe hơi', FALSE, 3),
(2, 'https://mbmart.com.vn/100/329/420/products/do-choi-lego-520-chi-tiet-5.jpg.webp', 'Bộ xếp hình thành phố', TRUE, 1),
(3, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQlHRbpaJSm81thBWVt8LIBIVInyfEFle-VFg&s', 'Xe điều khiển từ xa', TRUE, 1),
(4, 'https://img.lazcdn.com/g/p/2dbd4e8cbee65e939b509b208f3f7ef1.jpg_720x720q80.jpg', 'Bộ ghép hình thông minh', TRUE, 1),
(5, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSeUevTwIKHYrWvRkgdq26tGhwzdA4q5ra_tw&s', 'Đồ chơi học toán', TRUE, 1),
(6, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQSYSzjJrvbpOxUobRwMMKV7nKTZ8WyuMat8w&s', 'Đồ chơi nhà bếp', TRUE, 1),
(7, 'https://jola.vn/cdn/720/Product/WnjBVkJTT/may-bay-dieu-khien-tu-xa-mini-ls222-4-chieu-chay-pin4.jpg', 'Máy bay điều khiển từ xa', TRUE, 1),
(8, 'https://linhkienlamphat.com/upload/product/600x430/2/bup-be-cam-ung-biet-bay-702.jpg', 'Búp bê thông minh', TRUE, 1);

-- Dữ liệu thuộc tính sản phẩm
INSERT INTO product_attributes (name, type, unit, is_required) VALUES
('Kích thước', 'text', 'cm', TRUE),
('Trọng lượng', 'number', 'kg', TRUE),
('Chất liệu', 'text', NULL, TRUE),
('Màu sắc', 'select', NULL, FALSE),
('Độ tuổi khuyến nghị', 'text', 'tuổi', TRUE),
('Nguồn điện', 'select', NULL, FALSE),
('Thời gian bảo hành', 'number', 'tháng', FALSE),
('Xuất xứ', 'text', NULL, TRUE);

-- Dữ liệu banner quảng cáo
INSERT INTO banners (title, description, image_url, link_url, position, sort_order, is_active, start_date, end_date) VALUES
('Khuyến mãi mùa hè - Giảm 50%', 'Giảm giá lên đến 50% cho tất cả đồ chơi giáo dục', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQaXuyy2a0O0DWjcV2VHphb1evarnukN5gVmQ&s', '/khuyen-mai-mua-he', 'homepage_main', 1, TRUE, '2025-01-01 00:00:00', '2025-07-31 23:59:59'),
('Đồ chơi thông minh mới nhất', 'Khám phá bộ sưu tập đồ chơi công nghệ cao', 'https://www.mykingdom.com.vn/cdn/shop/articles/mykingdom-do-choi-cong-nghe-thong-minh-cho-tre-em-image.jpg?v=1686020840', '/do-choi-thong-minh', 'homepage_main', 2, TRUE, '2025-01-01 00:00:00', '2025-12-31 23:59:59'),
('Miễn phí vận chuyển', 'Miễn phí giao hàng cho đơn hàng từ 500.000đ', 'https://cdn.tgdd.vn/News/1561562/mien-phi-giao-hang-tan-noi-cho-don-tu-500-000d-9-845x442.png', '/mien-phi-van-chuyen', 'homepage_side', 1, TRUE, '2025-01-01 00:00:00', '2025-12-31 23:59:59');

-- Dữ liệu coupon giảm giá
INSERT INTO coupons (code, name, description, type, value, minimum_amount, usage_limit, valid_from, valid_until) VALUES
('WELCOME10', 'Chào mừng khách hàng mới', 'Giảm 10% cho khách hàng đăng ký mới', 'percentage', 10.00, 200000, 1000, '2025-01-01 00:00:00', '2025-04-30 23:59:59'),
('SUMMER50', 'Khuyến mãi mùa hè', 'Giảm 50.000đ cho đơn hàng từ 500.000đ', 'fixed_amount', 50000.00, 500000, 500, '2025-06-01 00:00:00', '2025-08-31 23:59:59'),
('FREESHIP', 'Miễn phí vận chuyển', 'Miễn phí giao hàng toàn quốc', 'free_shipping', 0.00, 300000, 2000, '2025-01-01 00:00:00', '2025-12-31 23:59:59'),
('LOYAL20', 'Khách hàng thân thiết', 'Giảm 20% cho khách hàng VIP', 'percentage', 20.00, 1000000, 100, '2025-01-01 00:00:00', '2025-12-31 23:59:59');

-- Dữ liệu cấu hình website
INSERT INTO site_settings (setting_key, setting_value, setting_type, description, is_public) VALUES
('site_name', 'ToyLand - Shop Đồ Chơi Trẻ Em', 'text', 'Tên website', TRUE),
('site_description', 'Chuyên cung cấp đồ chơi an toàn và giáo dục cho trẻ em mọi lứa tuổi', 'text', 'Mô tả website', TRUE),
('contact_phone', '0987 654 321', 'text', 'Số điện thoại liên hệ', TRUE),
('contact_email', 'info@toyland.vn', 'text', 'Email liên hệ', TRUE),
('contact_address', '123 Đường ABC, Quận 1, TP.HCM', 'text', 'Địa chỉ liên hệ', TRUE),
('working_hours', '8:00 - 21:00, Thứ 2 - Chủ nhật', 'text', 'Giờ làm việc', TRUE),
('free_shipping_minimum', '500000', 'number', 'Số tiền tối thiểu để được miễn phí vận chuyển', FALSE),
('currency_symbol', 'đ', 'text', 'Ký hiệu tiền tệ', TRUE),
('items_per_page', '12', 'number', 'Số sản phẩm hiển thị trên mỗi trang', FALSE),
('enable_reviews', 'true', 'boolean', 'Cho phép đánh giá sản phẩm', FALSE),
('enable_wishlist', 'true', 'boolean', 'Cho phép danh sách yêu thích', FALSE),
('enable_comparison', 'true', 'boolean', 'Cho phép so sánh sản phẩm', FALSE),
('max_compare_items', '4', 'number', 'Số sản phẩm tối đa có thể so sánh', FALSE),
('facebook_url', 'https://facebook.com/toyland', 'text', 'URL Facebook', TRUE),
('instagram_url', 'https://instagram.com/toyland', 'text', 'URL Instagram', TRUE),
('youtube_url', 'https://youtube.com/toyland', 'text', 'URL YouTube', TRUE),
('tiktok_url', 'https://tiktok.com/@toyland', 'text', 'URL TikTok', TRUE),
('google_analytics_id', 'GA-XXXXXXXXX', 'text', 'ID Google Analytics', FALSE),
('facebook_pixel_id', 'XXXXXXXXX', 'text', 'ID Facebook Pixel', FALSE);

-- Thêm người dùng demo
INSERT INTO users (username, email, password_hash, full_name, phone, role_id, is_active, email_verified) VALUES
('admin', 'admin@toyland.vn', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Quản trị viên', '0901234567', 1, TRUE, TRUE),
('manager', 'manager@toyland.vn', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Nguyễn Văn Quản lý', '0901234568', 2, TRUE, TRUE),
('customer1', 'customer1@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Trần Thị Hoa', '0901234569', 4, TRUE, TRUE),
('customer2', 'customer2@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Lê Văn Nam', '0901234570', 4, TRUE, TRUE);

-- Thêm địa chỉ cho khách hàng
INSERT INTO user_addresses (user_id, address_type, recipient_name, phone, address_line1, district, city, is_default) VALUES
(3, 'Home', 'Trần Thị Hoa', '0901234569', '123 Đường Nguyễn Trãi', 'Quận 1', 'TP.HCM', TRUE),
(4, 'Home', 'Lê Văn Nam', '0901234570', '456 Đường Lê Lợi', 'Quận 3', 'TP.HCM', TRUE),
(3, 'Work', 'Trần Thị Hoa', '0901234569', '789 Đường Điện Biên Phủ', 'Quận Bình Thạnh', 'TP.HCM', FALSE);

-- Thêm đánh giá sản phẩm demo
INSERT INTO product_reviews (product_id, user_id, rating, title, content, is_verified_purchase, is_approved) VALUES
(1, 3, 5, 'Rất hài lòng với sản phẩm', 'Robot biến hình rất đẹp, chất lượng tốt, con tôi rất thích chơi. Âm thanh và đèn LED rất sống động.', TRUE, TRUE),
(1, 4, 4, 'Sản phẩm tốt', 'Chất lượng ổn, giá cả hợp lý. Tuy nhiên hướng dẫn sử dụng hơi khó hiểu.', TRUE, TRUE),
(2, 3, 5, 'LEGO chất lượng cao', 'Bộ LEGO này rất chi tiết, nhiều chi tiết nhỏ giúp bé phát triển tư duy. Đáng đồng tiền bát gạo.', TRUE, TRUE),
(3, 4, 4, 'Xe chạy khỏe', 'Xe điều khiển chạy rất nhanh và bền. Pin sử dụng được lâu. Giá hơi cao một chút.', TRUE, TRUE),
(4, 3, 5, 'Đồ chơi giáo dục tuyệt vời', 'Con tôi học được rất nhiều từ bộ đồ chơi này. Chất liệu gỗ an toàn cho trẻ.', TRUE, TRUE);

-- Thêm sản phẩm vào giỏ hàng demo
INSERT INTO shopping_cart (user_id, product_id, quantity, price) VALUES
(3, 1, 1, 450000),
(3, 3, 1, 520000),
(3, 5, 2, 195000),
(4, 2, 1, 690000),
(4, 4, 1, 290000);

-- Thêm sản phẩm vào wishlist
INSERT INTO wishlists (user_id, product_id) VALUES
(3, 2), (3, 6), (3, 7),
(4, 1), (4, 5), (4, 8);

-- Thêm newsletter subscribers
INSERT INTO newsletter_subscribers (email, name, subscribed_at) VALUES
('subscriber1@example.com', 'Nguyễn Văn A', DATE_SUB(NOW(), INTERVAL 30 DAY)),
('subscriber2@example.com', 'Trần Thị B', DATE_SUB(NOW(), INTERVAL 25 DAY)),
('subscriber3@example.com', 'Lê Văn C', DATE_SUB(NOW(), INTERVAL 20 DAY)),
('subscriber4@example.com', 'Phạm Thị D', DATE_SUB(NOW(), INTERVAL 15 DAY)),
('subscriber5@example.com', 'Hoàng Văn E', DATE_SUB(NOW(), INTERVAL 10 DAY));

-- Thêm bài viết blog
INSERT INTO blog_posts (title, slug, excerpt, content, featured_image, author_id, category, tags, is_published, published_at) VALUES
('Cách chọn đồ chơi an toàn cho trẻ em', 'cach-chon-do-choi-an-toan-cho-tre-em', 'Hướng dẫn các bậc phụ huynh cách lựa chọn đồ chơi an toàn và phù hợp với lứa tuổi của trẻ', 'Việc lựa chọn đồ chơi phù hợp cho trẻ em là một việc quan trọng mà các bậc phụ huynh cần chú ý. Đồ chơi không chỉ giúp trẻ giải trí mà còn hỗ trợ phát triển trí tuệ và kỹ năng...', 'https://api.placeholder.com/800/400/FF6B6B/FFFFFF?text=Safe+Toys+Guide', 1, 'Hướng dẫn', 'đồ chơi, an toàn, trẻ em', TRUE, DATE_SUB(NOW(), INTERVAL 7 DAY)),
('Top 10 đồ chơi giáo dục tốt nhất 2025', 'top-10-do-choi-giao-duc-tot-nhat-2025', 'Danh sách những đồ chơi giáo dục được đánh giá cao nhất trong năm 2025', 'Năm 2025 chứng kiến sự phát triển mạnh mẽ của ngành đồ chơi giáo dục với nhiều sản phẩm sáng tạo và hiệu quả...', 'https://api.placeholder.com/800/400/4ECDC4/FFFFFF?text=Educational+Toys+2025', 1, 'Đánh giá', 'đồ chơi giáo dục, 2025, top 10', TRUE, DATE_SUB(NOW(), INTERVAL 3 DAY)),
('Lợi ích của đồ chơi STEM cho trẻ em', 'loi-ich-cua-do-choi-stem-cho-tre-em', 'Tìm hiểu về tầm quan trọng của đồ chơi STEM trong việc phát triển tư duy logic cho trẻ', 'STEM (Science, Technology, Engineering, Mathematics) đang trở thành xu hướng giáo dục quan trọng...', 'https://api.placeholder.com/800/400/FFE66D/1A535C?text=STEM+Toys+Benefits', 1, 'Giáo dục', 'STEM, giáo dục, phát triển', TRUE, DATE_SUB(NOW(), INTERVAL 1 DAY));

-- Thêm đơn hàng demo
INSERT INTO orders (order_number, user_id, status_id, payment_method_id, shipping_method_id, recipient_name, recipient_phone, recipient_email, shipping_address, subtotal, shipping_cost, total_amount, payment_status, created_at) VALUES
('TL202500001', 3, 5, 1, 2, 'Trần Thị Hoa', '0901234569', 'customer1@example.com', '123 Đường Nguyễn Trãi, Quận 1, TP.HCM', 970000, 50000, 1020000, 'Paid', DATE_SUB(NOW(), INTERVAL 5 DAY)),
('TL202500002', 4, 3, 2, 1, 'Lê Văn Nam', '0901234570', 'customer2@example.com', '456 Đường Lê Lợi, Quận 3, TP.HCM', 580000, 30000, 610000, 'Paid', DATE_SUB(NOW(), INTERVAL 3 DAY)),
('TL202500003', 3, 2, 3, 2, 'Trần Thị Hoa', '0901234569', 'customer1@example.com', '123 Đường Nguyễn Trãi, Quận 1, TP.HCM', 450000, 50000, 500000, 'Pending', DATE_SUB(NOW(), INTERVAL 1 DAY));

-- Thêm chi tiết đơn hàng
INSERT INTO order_items (order_id, product_id, product_name, product_sku, quantity, unit_price, total_price) VALUES
(1, 1, 'Robot biến hình thông minh', 'RBT001', 1, 450000, 450000),
(1, 3, 'Xe đua điều khiển từ xa địa hình', 'RC001', 1, 520000, 520000),
(2, 4, 'Bộ ghép hình thông minh phát triển trí tuệ', 'PUZ001', 2, 290000, 580000),
(3, 1, 'Robot biến hình thông minh', 'RBT001', 1, 450000, 450000);

-- Thêm lịch sử đơn hàng
INSERT INTO order_history (order_id, status_id, comment, created_by) VALUES
(1, 1, 'Đơn hàng được tạo', 3),
(1, 2, 'Đơn hàng đã được xác nhận', 2),
(1, 3, 'Đang chuẩn bị hàng', 2),
(1, 4, 'Đã gửi hàng', 2),
(1, 5, 'Đã giao hàng thành công', 2),
(2, 1, 'Đơn hàng được tạo', 4),
(2, 2, 'Đơn hàng đã được xác nhận', 2),
(2, 3, 'Đang chuẩn bị hàng', 2),
(3, 1, 'Đơn hàng được tạo', 3),
(3, 2, 'Đơn hàng đã được xác nhận', 2);

-- Thêm thông báo cho người dùng
INSERT INTO notifications (user_id, type, title, message, related_id) VALUES
(3, 'order', 'Đơn hàng đã được giao', 'Đơn hàng #TL202500001 của bạn đã được giao thành công. Cảm ơn bạn đã mua sắm tại ToyLand!', 1),
(3, 'promotion', 'Khuyến mãi đặc biệt', 'Giảm 20% cho tất cả đồ chơi LEGO. Áp dụng từ ngày mai!', NULL),
(4, 'order', 'Đơn hàng đang được xử lý', 'Đơn hàng #TL202500002 của bạn đang được chuẩn bị. Dự kiến giao hàng trong 2-3 ngày.', 2),
(4, 'review', 'Đánh giá sản phẩm', 'Hãy đánh giá sản phẩm bạn đã mua để giúp khách hàng khác có thêm thông tin tham khảo.', NULL);

-- Thêm dữ liệu thống kê website
INSERT INTO website_analytics (date, page_views, unique_visitors, new_visitors, bounce_rate, avg_session_duration) VALUES
(DATE_SUB(CURDATE(), INTERVAL 30 DAY), 1250, 890, 234, 45.6, 180),
(DATE_SUB(CURDATE(), INTERVAL 29 DAY), 1180, 820, 198, 48.2, 165),
(DATE_SUB(CURDATE(), INTERVAL 28 DAY), 1320, 950, 287, 42.1, 195),
(DATE_SUB(CURDATE(), INTERVAL 27 DAY), 1450, 1050, 312, 39.8, 210),
(DATE_SUB(CURDATE(), INTERVAL 26 DAY), 1380, 990, 298, 41.5, 188),
(DATE_SUB(CURDATE(), INTERVAL 25 DAY), 1520, 1120, 334, 38.2, 220),
(DATE_SUB(CURDATE(), INTERVAL 24 DAY), 1280, 915, 256, 44.7, 175);

-- Thêm dữ liệu thống kê sản phẩm
INSERT INTO product_analytics (product_id, date, view_count, add_to_cart_count, purchase_count, revenue) VALUES
(1, DATE_SUB(CURDATE(), INTERVAL 7 DAY), 45, 8, 3, 1350000),
(1, DATE_SUB(CURDATE(), INTERVAL 6 DAY), 52, 12, 2, 900000),
(1, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 38, 6, 1, 450000),
(2, DATE_SUB(CURDATE(), INTERVAL 7 DAY), 28, 4, 1, 690000),
(2, DATE_SUB(CURDATE(), INTERVAL 6 DAY), 35, 7, 2, 1380000),
(3, DATE_SUB(CURDATE(), INTERVAL 7 DAY), 42, 9, 4, 2080000),
(3, DATE_SUB(CURDATE(), INTERVAL 6 DAY), 31, 5, 1, 520000);

-- ===================================================================
-- 12. CÁC TRIGGER TỰ ĐỘNG HÓA
-- ===================================================================

-- Trigger cập nhật rating trung bình cho sản phẩm
DELIMITER //
CREATE TRIGGER update_product_rating_after_review_insert
AFTER INSERT ON product_reviews
FOR EACH ROW
BEGIN
    UPDATE products 
    SET 
        rating_average = (
            SELECT AVG(rating) 
            FROM product_reviews 
            WHERE product_id = NEW.product_id AND is_approved = TRUE
        ),
        rating_count = (
            SELECT COUNT(*) 
            FROM product_reviews 
            WHERE product_id = NEW.product_id AND is_approved = TRUE
        )
    WHERE id = NEW.product_id;
END //

CREATE TRIGGER update_product_rating_after_review_update
AFTER UPDATE ON product_reviews
FOR EACH ROW
BEGIN
    UPDATE products 
    SET 
        rating_average = (
            SELECT AVG(rating) 
            FROM product_reviews 
            WHERE product_id = NEW.product_id AND is_approved = TRUE
        ),
        rating_count = (
            SELECT COUNT(*) 
            FROM product_reviews 
            WHERE product_id = NEW.product_id AND is_approved = TRUE
        )
    WHERE id = NEW.product_id;
END //

-- Trigger cập nhật tồn kho sau khi đặt hàng
CREATE TRIGGER update_stock_after_order
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products 
    SET 
        stock_quantity = stock_quantity - NEW.quantity,
        sold_count = sold_count + NEW.quantity
    WHERE id = NEW.product_id;
END //

-- Trigger tạo mã đơn hàng tự động
CREATE TRIGGER generate_order_number_before_insert
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    DECLARE next_order_num INT;
    SELECT COALESCE(MAX(CAST(SUBSTRING(order_number, 3) AS UNSIGNED)), 0) + 1 
    INTO next_order_num 
    FROM orders 
    WHERE order_number LIKE CONCAT('TL', YEAR(NOW()), '%');
    
    SET NEW.order_number = CONCAT('TL', YEAR(NOW()), LPAD(next_order_num, 6, '0'));
END //

-- ===================================================================
-- 13. STORED PROCEDURES - ĐÃ SỬA LỖI DEFAULT PARAMETERS
-- ===================================================================

-- Stored Procedure lấy sản phẩm bán chạy
CREATE PROCEDURE GetBestSellingProducts(
    IN limit_count INT,
    IN category_filter INT
)
BEGIN
    -- Xử lý giá trị NULL cho limit_count (mặc định 10)
    IF limit_count IS NULL OR limit_count <= 0 THEN
        SET limit_count = 10;
    END IF;
    
    SELECT 
        p.*,
        c.name as category_name,
        b.name as brand_name,
        pi.image_url as primary_image
    FROM products p
    LEFT JOIN categories c ON p.category_id = c.id
    LEFT JOIN brands b ON p.brand_id = b.id
    LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = TRUE
    WHERE p.status = 'Active'
    AND (category_filter IS NULL OR p.category_id = category_filter)
    ORDER BY p.sold_count DESC, p.rating_average DESC
    LIMIT limit_count;
END //

-- Stored Procedure lấy sản phẩm liên quan
CREATE PROCEDURE GetRelatedProducts(
    IN current_product_id INT,
    IN limit_count INT
)
BEGIN
    DECLARE current_category_id INT;
    DECLARE current_brand_id INT;
    
    -- Xử lý giá trị NULL cho limit_count (mặc định 8)
    IF limit_count IS NULL OR limit_count <= 0 THEN
        SET limit_count = 8;
    END IF;
    
    SELECT category_id, brand_id INTO current_category_id, current_brand_id
    FROM products WHERE id = current_product_id;
    
    SELECT 
        p.*,
        c.name as category_name,
        b.name as brand_name,
        pi.image_url as primary_image
    FROM products p
    LEFT JOIN categories c ON p.category_id = c.id
    LEFT JOIN brands b ON p.brand_id = b.id
    LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = TRUE
    WHERE p.id != current_product_id
    AND p.status = 'Active'
    AND (p.category_id = current_category_id OR p.brand_id = current_brand_id)
    ORDER BY 
        CASE WHEN p.category_id = current_category_id THEN 1 ELSE 2 END,
        p.rating_average DESC,
        p.sold_count DESC
    LIMIT limit_count;
END //

-- Stored Procedure tính toán giá trị đơn hàng
CREATE PROCEDURE CalculateOrderTotal(
    IN user_id_param INT,
    IN coupon_code_param VARCHAR(50),
    IN shipping_method_id_param INT,
    OUT subtotal_result DECIMAL(12,2),
    OUT shipping_cost_result DECIMAL(10,2),
    OUT discount_amount_result DECIMAL(10,2),
    OUT total_result DECIMAL(12,2)
)
BEGIN
    DECLARE total_weight DECIMAL(8,2) DEFAULT 0;
    DECLARE base_shipping_cost DECIMAL(10,2) DEFAULT 0;
    DECLARE cost_per_kg DECIMAL(10,2) DEFAULT 0;
    DECLARE coupon_discount DECIMAL(10,2) DEFAULT 0;
    DECLARE coupon_type VARCHAR(20);
    DECLARE coupon_value DECIMAL(10,2);
    DECLARE coupon_min_amount DECIMAL(12,2);
    
    -- Tính subtotal và tổng trọng lượng
    SELECT 
        COALESCE(SUM(sc.quantity * sc.price), 0),
        COALESCE(SUM(sc.quantity * COALESCE(p.weight, 0)), 0)
    INTO subtotal_result, total_weight
    FROM shopping_cart sc
    JOIN products p ON sc.product_id = p.id
    WHERE sc.user_id = user_id_param;
    
    -- Lấy thông tin phí vận chuyển
    SELECT base_cost, cost_per_kg 
    INTO base_shipping_cost, cost_per_kg
    FROM shipping_methods 
    WHERE id = shipping_method_id_param;
    
    SET shipping_cost_result = base_shipping_cost + (total_weight * cost_per_kg);
    
    -- Xử lý coupon nếu có
    IF coupon_code_param IS NOT NULL THEN
        SELECT type, value, minimum_amount
        INTO coupon_type, coupon_value, coupon_min_amount
        FROM coupons 
        WHERE code = coupon_code_param 
        AND is_active = TRUE 
        AND valid_from <= NOW() 
        AND valid_until >= NOW()
        AND (usage_limit IS NULL OR used_count < usage_limit)
        LIMIT 1;
        
        IF coupon_type IS NOT NULL AND subtotal_result >= COALESCE(coupon_min_amount, 0) THEN
            IF coupon_type = 'percentage' THEN
                SET coupon_discount = subtotal_result * (coupon_value / 100);
            ELSEIF coupon_type = 'fixed_amount' THEN
                SET coupon_discount = coupon_value;
            ELSEIF coupon_type = 'free_shipping' THEN
                SET shipping_cost_result = 0;
            END IF;
        END IF;
    END IF;
    
    SET discount_amount_result = coupon_discount;
    SET total_result = subtotal_result + shipping_cost_result - discount_amount_result;
    
    -- Đảm bảo total không âm
    IF total_result < 0 THEN
        SET total_result = 0;
    END IF;
END //

-- Stored Procedure báo cáo doanh thu theo tháng
CREATE PROCEDURE GetMonthlyRevenue(
    IN year_param INT,
    IN month_param INT
)
BEGIN
    -- Xử lý month_param NULL (mặc định báo cáo cả năm)
    IF month_param IS NULL THEN
        -- Báo cáo cả năm
        SELECT 
            MONTH(created_at) as month,
            MONTHNAME(created_at) as month_name,
            COUNT(*) as total_orders,
            SUM(total_amount) as total_revenue,
            AVG(total_amount) as average_order_value
        FROM orders 
        WHERE YEAR(created_at) = year_param
        AND payment_status = 'Paid'
        GROUP BY MONTH(created_at), MONTHNAME(created_at)
        ORDER BY month;
    ELSE
        -- Báo cáo theo ngày trong tháng
        SELECT 
            DAY(created_at) as day,
            DATE(created_at) as date,
            COUNT(*) as total_orders,
            SUM(total_amount) as total_revenue,
            AVG(total_amount) as average_order_value
        FROM orders 
        WHERE YEAR(created_at) = year_param 
        AND MONTH(created_at) = month_param
        AND payment_status = 'Paid'
        GROUP BY DAY(created_at), DATE(created_at)
        ORDER BY day;
    END IF;
END //

-- Stored Procedure thống kê sản phẩm bán chạy theo danh mục
CREATE PROCEDURE GetTopProductsByCategory(
    IN limit_count INT
)
BEGIN
    -- Xử lý limit_count NULL (mặc định 5)
    IF limit_count IS NULL OR limit_count <= 0 THEN
        SET limit_count = 5;
    END IF;
    
    -- Tạo bảng tạm để tính toán
    CREATE TEMPORARY TABLE temp_category_products AS
    SELECT 
        c.id as category_id,
        c.name as category_name,
        p.id as product_id,
        p.name as product_name,
        p.sold_count,
        p.rating_average,
        COALESCE(SUM(oi.total_price), 0) as total_revenue,
        ROW_NUMBER() OVER (PARTITION BY c.id ORDER BY p.sold_count DESC, p.rating_average DESC) as row_num
    FROM categories c
    JOIN products p ON c.id = p.category_id
    LEFT JOIN order_items oi ON p.id = oi.product_id
    LEFT JOIN orders o ON oi.order_id = o.id AND o.payment_status = 'Paid'
    WHERE p.status = 'Active'
    GROUP BY c.id, c.name, p.id, p.name, p.sold_count, p.rating_average;
    
    -- Lấy top sản phẩm từ mỗi danh mục
    SELECT 
        category_name,
        product_name,
        sold_count,
        rating_average,
        total_revenue
    FROM temp_category_products 
    WHERE row_num <= limit_count
    ORDER BY category_name, row_num;
    
    -- Xóa bảng tạm
    DROP TEMPORARY TABLE temp_category_products;
END //

-- Stored Procedure tìm kiếm sản phẩm nâng cao
CREATE PROCEDURE SearchProductsAdvanced(
    IN search_keyword VARCHAR(200),
    IN category_id_param INT,
    IN brand_id_param INT,
    IN min_price DECIMAL(12,2),
    IN max_price DECIMAL(12,2),
    IN min_rating DECIMAL(3,2),
    IN sort_by VARCHAR(50),
    IN limit_count INT,
    IN offset_count INT
)
BEGIN
    -- Xử lý giá trị mặc định
    IF limit_count IS NULL OR limit_count <= 0 THEN SET limit_count = 20; END IF;
    IF offset_count IS NULL OR offset_count < 0 THEN SET offset_count = 0; END IF;
    IF min_rating IS NULL THEN SET min_rating = 0; END IF;
    IF sort_by IS NULL THEN SET sort_by = 'newest'; END IF;
    
    SELECT 
        p.*,
        c.name as category_name,
        b.name as brand_name,
        pi.image_url as primary_image,
        CASE 
            WHEN p.sale_price IS NOT NULL THEN 
                ROUND(((p.original_price - p.sale_price) / p.original_price) * 100)
            ELSE 0 
        END as discount_percentage
    FROM products p
    LEFT JOIN categories c ON p.category_id = c.id
    LEFT JOIN brands b ON p.brand_id = b.id
    LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = TRUE
    WHERE p.status = 'Active'
    AND p.rating_average >= min_rating
    AND (search_keyword IS NULL OR p.name LIKE CONCAT('%', search_keyword, '%') OR p.short_description LIKE CONCAT('%', search_keyword, '%'))
    AND (category_id_param IS NULL OR p.category_id = category_id_param)
    AND (brand_id_param IS NULL OR p.brand_id = brand_id_param)
    AND (min_price IS NULL OR COALESCE(p.sale_price, p.original_price) >= min_price)
    AND (max_price IS NULL OR COALESCE(p.sale_price, p.original_price) <= max_price)
    ORDER BY 
        CASE 
            WHEN sort_by = 'price_asc' THEN COALESCE(p.sale_price, p.original_price)
            ELSE NULL
        END ASC,
        CASE 
            WHEN sort_by = 'price_desc' THEN COALESCE(p.sale_price, p.original_price)
            ELSE NULL
        END DESC,
        CASE 
            WHEN sort_by = 'rating' THEN p.rating_average
            ELSE NULL
        END DESC,
        CASE 
            WHEN sort_by = 'bestseller' THEN p.sold_count
            ELSE NULL
        END DESC,
        CASE 
            WHEN sort_by = 'newest' THEN p.created_at
            ELSE p.created_at
        END DESC
    LIMIT limit_count OFFSET offset_count;
END //

-- Stored Procedure thống kê dashboard
CREATE PROCEDURE GetDashboardStats()
BEGIN
    DECLARE total_products INT DEFAULT 0;
    DECLARE total_orders INT DEFAULT 0;
    DECLARE total_customers INT DEFAULT 0;
    DECLARE monthly_revenue DECIMAL(15,2) DEFAULT 0;
    DECLARE low_stock_count INT DEFAULT 0;
    
    -- Tổng số sản phẩm
    SELECT COUNT(*) INTO total_products FROM products WHERE status = 'Active';
    
    -- Tổng số đơn hàng
    SELECT COUNT(*) INTO total_orders FROM orders WHERE payment_status = 'Paid';
    
    -- Tổng số khách hàng
    SELECT COUNT(*) INTO total_customers FROM users WHERE role_id = 4 AND is_active = TRUE;
    
    -- Doanh thu tháng hiện tại
    SELECT COALESCE(SUM(total_amount), 0) INTO monthly_revenue 
    FROM orders 
    WHERE payment_status = 'Paid' 
    AND YEAR(created_at) = YEAR(NOW()) 
    AND MONTH(created_at) = MONTH(NOW());
    
    -- Số sản phẩm sắp hết hàng
    SELECT COUNT(*) INTO low_stock_count 
    FROM products 
    WHERE status = 'Active' 
    AND stock_quantity <= min_stock_level;
    
    -- Trả về kết quả
    SELECT 
        total_products as total_products,
        total_orders as total_orders,
        total_customers as total_customers,
        monthly_revenue as monthly_revenue,
        low_stock_count as low_stock_count,
        (SELECT COUNT(*) FROM orders WHERE status_id = 1) as pending_orders,
        (SELECT COUNT(*) FROM product_reviews WHERE is_approved = FALSE) as pending_reviews;
END //

DELIMITER ;

-- ===================================================================
-- 14. CÁC VIEW THƯỜNG DÙNG
-- ===================================================================

-- View sản phẩm với thông tin đầy đủ
CREATE VIEW product_details_view AS
SELECT 
    p.*,
    c.name as category_name,
    c.slug as category_slug,
    b.name as brand_name,
    b.slug as brand_slug,
    ag.name as age_group_name,
    pi.image_url as primary_image,
    CASE 
        WHEN p.sale_price IS NOT NULL THEN 
            ROUND(((p.original_price - p.sale_price) / p.original_price) * 100)
        ELSE 0 
    END as discount_percentage,
    CASE 
        WHEN p.stock_quantity <= p.min_stock_level THEN 'Low Stock'
        WHEN p.stock_quantity = 0 THEN 'Out of Stock'
        ELSE 'In Stock'
    END as stock_status
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
LEFT JOIN brands b ON p.brand_id = b.id
LEFT JOIN age_groups ag ON p.age_group_id = ag.id
LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = TRUE;

-- View đơn hàng với thông tin chi tiết
CREATE VIEW order_details_view AS
SELECT 
    o.*,
    os.name as status_name,
    os.color as status_color,
    pm.name as payment_method_name,
    sm.name as shipping_method_name,
    u.username,
    u.full_name as customer_name,
    COUNT(oi.id) as total_items,
    SUM(oi.quantity) as total_quantity
FROM orders o
LEFT JOIN order_statuses os ON o.status_id = os.id
LEFT JOIN payment_methods pm ON o.payment_method_id = pm.id
LEFT JOIN shipping_methods sm ON o.shipping_method_id = sm.id
LEFT JOIN users u ON o.user_id = u.id
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id;

-- View thống kê sản phẩm
CREATE VIEW product_statistics_view AS
SELECT 
    p.id,
    p.name,
    p.sku,
    c.name as category_name,
    p.stock_quantity,
    p.sold_count,
    p.view_count,
    p.rating_average,
    p.rating_count,
    COALESCE(p.sale_price, p.original_price) as current_price,
    COALESCE(SUM(oi.total_price), 0) as total_revenue,
    COUNT(DISTINCT o.id) as total_orders
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id AND o.payment_status = 'Paid'
GROUP BY p.id;

-- ===================================================================
-- 15. CÁC INDEX ĐÃ SỬA LỖI - TỐI ƯU HIỆU SUẤT
-- ===================================================================

-- Index cho tìm kiếm sản phẩm (sử dụng prefix length để tránh lỗi key too long)
CREATE INDEX idx_products_name ON products(name(50));
CREATE INDEX idx_products_description ON products(short_description(100));
CREATE INDEX idx_products_sale_price ON products(sale_price);
CREATE INDEX idx_products_original_price ON products(original_price);
CREATE INDEX idx_products_rating_desc ON products(rating_average DESC);
CREATE INDEX idx_products_rating_count_desc ON products(rating_count DESC);
CREATE INDEX idx_products_sold_count_desc ON products(sold_count DESC);
CREATE INDEX idx_products_view_count_desc ON products(view_count DESC);

-- Index kết hợp cho tìm kiếm nâng cao
CREATE INDEX idx_products_category_status ON products(category_id, status);
CREATE INDEX idx_products_brand_status ON products(brand_id, status);
CREATE INDEX idx_products_featured_status ON products(is_featured, status);
CREATE INDEX idx_products_bestseller_status ON products(is_bestseller, status);
CREATE INDEX idx_products_new_status ON products(is_new, status);

-- Index cho đơn hàng
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_orders_status_created ON orders(status_id, created_at DESC);
CREATE INDEX idx_orders_user_created ON orders(user_id, created_at DESC);
CREATE INDEX idx_orders_payment_created ON orders(payment_status, created_at DESC);

-- Index cho giỏ hàng
CREATE INDEX idx_cart_user_updated ON shopping_cart(user_id, updated_at DESC);
CREATE INDEX idx_cart_session_updated ON shopping_cart(session_id, updated_at DESC);
CREATE INDEX idx_cart_product ON shopping_cart(product_id);

-- Index cho đánh giá
CREATE INDEX idx_reviews_product_approved ON product_reviews(product_id, is_approved);
CREATE INDEX idx_reviews_user_created ON product_reviews(user_id, created_at DESC);
CREATE INDEX idx_reviews_approved_created ON product_reviews(is_approved, created_at DESC);
CREATE INDEX idx_reviews_rating ON product_reviews(rating DESC);

-- Index cho coupon
CREATE INDEX idx_coupons_active_dates ON coupons(is_active, valid_from, valid_until);
CREATE INDEX idx_coupons_type ON coupons(type);

-- Index cho banner
CREATE INDEX idx_banners_position_active ON banners(position, is_active);
CREATE INDEX idx_banners_dates ON banners(start_date, end_date);

-- Index cho categories
CREATE INDEX idx_categories_parent_active ON categories(parent_id, is_active);
CREATE INDEX idx_categories_sort ON categories(sort_order);

-- Index cho users
CREATE INDEX idx_users_role_active ON users(role_id, is_active);

-- Index cho notifications
CREATE INDEX idx_notifications_user_read ON notifications(user_id, is_read);
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);

-- Index cho analytics
CREATE INDEX idx_website_analytics_date ON website_analytics(date DESC);
CREATE INDEX idx_product_analytics_product_date ON product_analytics(product_id, date DESC);

-- Index cho blog
CREATE INDEX idx_blog_published ON blog_posts(is_published, published_at DESC);
CREATE INDEX idx_blog_author ON blog_posts(author_id);

-- FULLTEXT INDEX cho tìm kiếm nâng cao (tùy chọn)
ALTER TABLE products ADD FULLTEXT(name, short_description, detailed_description);
ALTER TABLE blog_posts ADD FULLTEXT(title, excerpt, content);

-- ===================================================================