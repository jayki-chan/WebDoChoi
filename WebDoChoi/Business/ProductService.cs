using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using MySql.Data.MySqlClient;
using WebDoChoi.Data;
namespace WebDoChoi.Business
{
    /// <summary>
    /// Lớp xử lý nghiệp vụ liên quan đến sản phẩm và danh mục
    /// Bao gồm quản lý danh mục, sản phẩm, và các chức năng liên quan
    /// </summary>
    public class ProductService
    {
        #region Models - Các lớp dữ liệu

        /// <summary>
        /// Model đại diện cho phương thức vận chuyển
        /// </summary>
        public class ShippingMethodView
        {
            public int MethodId { get; set; }
            public string MethodName { get; set; }
            public string Description { get; set; }
            public string EstimatedTime { get; set; }
            public decimal BaseCost { get; set; }
            public decimal CostPerKg { get; set; }
            public bool IsActive { get; set; }
            public DateTime LastUpdated { get; set; }
            public int OrderCountThisMonth { get; set; }
            public double SuccessRate { get; set; }
            public string IconCss { get; set; } // e.g., "fas fa-shipping-fast"
            public string IconBgCss { get; set; } // e.g., "bg-green-400"
        }

        /// <summary>
        /// Model đại diện cho danh mục sản phẩm
        /// </summary>
        public class Category
        {
            public int Id { get; set; }
            public string Name { get; set; }
            public string Slug { get; set; }
            public string Description { get; set; }
            public int? ParentId { get; set; }
            public string Icon { get; set; }
            public string ImageUrl { get; set; }
            public int SortOrder { get; set; }
            public bool IsActive { get; set; }
            public string SeoTitle { get; set; }
            public string SeoDescription { get; set; }
            public int ProductCount { get; set; }
            public DateTime CreatedAt { get; set; }
            public DateTime UpdatedAt { get; set; }
        }

        /// <summary>
        /// Model đại diện cho thương hiệu
        /// </summary>
        public class Brand
        {
            public int Id { get; set; }
            public string Name { get; set; }
            public string Slug { get; set; }
            public string Description { get; set; }
            public string LogoUrl { get; set; }
            public string WebsiteUrl { get; set; }
            public string Country { get; set; }
            public bool IsActive { get; set; }
            public DateTime CreatedAt { get; set; }
            public DateTime UpdatedAt { get; set; }
        }

        /// <summary>
        /// Model đại diện cho sản phẩm
        /// </summary>
        public class Product
        {
            public int Id { get; set; }
            public string Name { get; set; }
            public string Slug { get; set; }
            public string Sku { get; set; }
            public string ShortDescription { get; set; }
            public string DetailedDescription { get; set; }
            public int CategoryId { get; set; }
            public string CategoryName { get; set; }
            public int? BrandId { get; set; }
            public string BrandName { get; set; }
            public int? AgeGroupId { get; set; }
            public string AgeGroupName { get; set; }
            public decimal OriginalPrice { get; set; }
            public decimal? SalePrice { get; set; }
            public decimal? CostPrice { get; set; }
            public decimal Weight { get; set; }
            public string Dimensions { get; set; }
            public string Material { get; set; }
            public string Color { get; set; }
            public int StockQuantity { get; set; }
            public int MinStockLevel { get; set; }
            public bool IsFeatured { get; set; }
            public bool IsBestseller { get; set; }
            public bool IsNew { get; set; }
            public string Status { get; set; }
            public string SafetyCertification { get; set; }
            public int WarrantyMonths { get; set; }
            public decimal RatingAverage { get; set; }
            public int RatingCount { get; set; }
            public int ViewCount { get; set; }
            public int SoldCount { get; set; }
            public string SeoTitle { get; set; }
            public string SeoDescription { get; set; }
            public string SeoKeywords { get; set; }
            public string PrimaryImage { get; set; }
            public List<string> Images { get; set; } = new List<string>();
            public decimal CurrentPrice => SalePrice ?? OriginalPrice;
            public int DiscountPercent => SalePrice.HasValue && OriginalPrice > 0
                ? (int)Math.Round(((OriginalPrice - SalePrice.Value) / OriginalPrice) * 100)
                : 0;
            public DateTime CreatedAt { get; set; }
            public DateTime UpdatedAt { get; set; }
        }

        /// <summary>
        /// Model đại diện cho nhóm tuổi
        /// </summary>
        public class AgeGroup
        {
            public int Id { get; set; }
            public string Name { get; set; }
            public int MinAge { get; set; }
            public int MaxAge { get; set; }
            public string Description { get; set; }
            public DateTime CreatedAt { get; set; }
        }

        /// <summary>
        /// Model đại diện cho hình ảnh sản phẩm
        /// </summary>
        public class ProductImage
        {
            public int Id { get; set; }
            public int ProductId { get; set; }
            public string ImageUrl { get; set; }
            public bool IsPrimary { get; set; }
            public int SortOrder { get; set; }
            public string AltText { get; set; }
            public string Title { get; set; }
            public DateTime CreatedAt { get; set; }
            public DateTime UpdatedAt { get; set; }
        }

        /// <summary>
        /// Model đại diện cho tính năng sản phẩm
        /// </summary>
        public class ProductFeature
        {
            public int Id { get; set; }
            public int ProductId { get; set; }
            public string FeatureName { get; set; }
            public string FeatureValue { get; set; }
            public string Description { get; set; }
            public string Icon { get; set; }
            public int SortOrder { get; set; }
            public bool IsActive { get; set; }
            public DateTime CreatedAt { get; set; }
            public DateTime UpdatedAt { get; set; }
        }

        /// <summary>
        /// Model đại diện cho thông số kỹ thuật sản phẩm
        /// </summary>
        public class ProductSpecification
        {
            public int Id { get; set; }
            public int ProductId { get; set; }
            public string SpecName { get; set; }
            public string SpecValue { get; set; }
            public string Unit { get; set; }
            public string Description { get; set; }
            public int SortOrder { get; set; }
            public bool IsActive { get; set; }
            public DateTime CreatedAt { get; set; }
            public DateTime UpdatedAt { get; set; }
        }

        /// <summary>
        /// Model đại diện cho đánh giá sản phẩm
        /// </summary>
        public class ProductReview
        {
            public int Id { get; set; }
            public int ProductId { get; set; }
            public int UserId { get; set; }
            public string UserName { get; set; }
            public string UserAvatar { get; set; }
            public decimal Rating { get; set; }
            public string Title { get; set; }
            public string Comment { get; set; }
            public List<string> Images { get; set; } = new List<string>();
            public bool IsVerifiedPurchase { get; set; }
            public bool IsHelpful { get; set; }
            public int HelpfulCount { get; set; }
            public string Status { get; set; }
            public DateTime CreatedAt { get; set; }
            public DateTime UpdatedAt { get; set; }
        }

        #endregion

        #region Phương thức quản lý danh mục

        /// <summary>
        /// Lấy tất cả danh mục đang hoạt động
        /// </summary>
        /// <param name="includeProductCount">Có đếm số sản phẩm không</param>
        /// <returns>Danh sách danh mục</returns>
        public static List<Category> GetActiveCategories(bool includeProductCount = true)
        {
            var categories = new List<Category>();

            try
            {
                string query = @"
                    SELECT c.id, c.name, c.slug, c.description, c.parent_id, 
                           c.icon, c.image_url, c.sort_order, c.is_active,
                           c.seo_title, c.seo_description, c.created_at, c.updated_at";

                if (includeProductCount)
                {
                    query += @",
                           (SELECT COUNT(*) FROM products p 
                            WHERE p.category_id = c.id AND p.status = 'Active') as product_count";
                }

                query += @"
                    FROM categories c
                    WHERE c.is_active = 1
                    ORDER BY c.sort_order ASC, c.name ASC";

                DataTable dt = DatabaseHelper.ExecuteQuery(query);

                foreach (DataRow row in dt.Rows)
                {
                    var category = new Category
                    {
                        Id = Convert.ToInt32(row["id"]),
                        Name = row["name"].ToString(),
                        Slug = row["slug"].ToString(),
                        Description = row["description"].ToString(),
                        ParentId = row["parent_id"] == DBNull.Value ?
                            (int?)null : Convert.ToInt32(row["parent_id"]),
                        Icon = row["icon"].ToString(),
                        ImageUrl = row["image_url"].ToString(),
                        SortOrder = Convert.ToInt32(row["sort_order"]),
                        IsActive = Convert.ToBoolean(row["is_active"]),
                        SeoTitle = row["seo_title"].ToString(),
                        SeoDescription = row["seo_description"].ToString(),
                        CreatedAt = Convert.ToDateTime(row["created_at"]),
                        UpdatedAt = Convert.ToDateTime(row["updated_at"])
                    };

                    if (includeProductCount)
                    {
                        category.ProductCount = Convert.ToInt32(row["product_count"]);
                    }

                    categories.Add(category);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetActiveCategories Error: {ex.Message}");
            }

            return categories;
        }

        /// <summary>
        /// Lấy danh mục theo ID
        /// </summary>
        /// <param name="categoryId">ID danh mục</param>
        /// <returns>Thông tin danh mục</returns>
        public static Category GetCategoryById(int categoryId)
        {
            try
            {
                string query = @"
                    SELECT c.id, c.name, c.slug, c.description, c.parent_id, 
                           c.icon, c.image_url, c.sort_order, c.is_active,
                           c.seo_title, c.seo_description, c.created_at, c.updated_at,
                           (SELECT COUNT(*) FROM products p 
                            WHERE p.category_id = c.id AND p.status = 'Active') as product_count
                    FROM categories c
                    WHERE c.id = @CategoryId";

                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@CategoryId", categoryId)
                };

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);

                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];

                    return new Category
                    {
                        Id = Convert.ToInt32(row["id"]),
                        Name = row["name"].ToString(),
                        Slug = row["slug"].ToString(),
                        Description = row["description"].ToString(),
                        ParentId = row["parent_id"] == DBNull.Value ?
                            (int?)null : Convert.ToInt32(row["parent_id"]),
                        Icon = row["icon"].ToString(),
                        ImageUrl = row["image_url"].ToString(),
                        SortOrder = Convert.ToInt32(row["sort_order"]),
                        IsActive = Convert.ToBoolean(row["is_active"]),
                        SeoTitle = row["seo_title"].ToString(),
                        SeoDescription = row["seo_description"].ToString(),
                        ProductCount = Convert.ToInt32(row["product_count"]),
                        CreatedAt = Convert.ToDateTime(row["created_at"]),
                        UpdatedAt = Convert.ToDateTime(row["updated_at"])
                    };
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetCategoryById Error: {ex.Message}");
            }

            return null;
        }

        #endregion

        #region Phương thức quản lý sản phẩm

        /// <summary>
        /// Lấy thông tin chi tiết sản phẩm theo ID
        /// </summary>
        /// <param name="productId">ID sản phẩm</param>
        /// <returns>Thông tin sản phẩm</returns>
        public static Product GetProductById(int productId)
        {
            try
            {
                string query = @"
                    SELECT p.*, c.name as category_name, b.name as brand_name,
                           ag.name as age_group_name, pi.image_url as primary_image
                    FROM products p
                    LEFT JOIN categories c ON p.category_id = c.id
                    LEFT JOIN brands b ON p.brand_id = b.id
                    LEFT JOIN age_groups ag ON p.age_group_id = ag.id
                    LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = 1
                    WHERE p.id = @ProductId AND p.status = 'Active'";

                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@ProductId", productId)
                };

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);
                var products = ConvertDataTableToProducts(dt);

                if (products.Count > 0)
                {
                    var product = products[0];
                    
                    // Load additional images
                    product.Images = GetProductImages(productId);
                    
                    return product;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetProductById Error: {ex.Message}");
            }

            return null;
        }

        /// <summary>
        /// Lấy danh sách hình ảnh của sản phẩm
        /// </summary>
        /// <param name="productId">ID sản phẩm</param>
        /// <returns>Danh sách URL hình ảnh</returns>
        public static List<string> GetProductImages(int productId)
        {
            var images = new List<string>();

            try
            {
                string query = @"
                    SELECT image_url
                    FROM product_images
                    WHERE product_id = @ProductId
                    ORDER BY sort_order ASC";

                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@ProductId", productId)
                };

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);

                foreach (DataRow row in dt.Rows)
                {
                    images.Add(row["image_url"].ToString());
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetProductImages Error: {ex.Message}");
            }

            return images;
        }

        /// <summary>
        /// Lấy sản phẩm bán chạy nhất
        /// </summary>
        /// <param name="limitCount">Số lượng sản phẩm</param>
        /// <param name="categoryId">ID danh mục (tùy chọn)</param>
        /// <returns>Danh sách sản phẩm bán chạy</returns>
        public static List<Product> GetBestSellingProducts(int limitCount = 8, int? categoryId = null)
        {
            var products = new List<Product>();

            try
            {
                // Sử dụng stored procedure đã có trong database
                var parameters = new List<MySqlParameter>
                {
                    DatabaseHelper.CreateParameter("limit_count", limitCount),
                    DatabaseHelper.CreateParameter("category_filter", categoryId)
                };

                DataTable dt = DatabaseHelper.ExecuteStoredProcedure("GetBestSellingProducts",
                    parameters.ToArray());

                products = ConvertDataTableToProducts(dt);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetBestSellingProducts Error: {ex.Message}");
                // Fallback to direct query if stored procedure fails
                products = GetBestSellingProductsFallback(limitCount, categoryId);
            }

            return products;
        }

        /// <summary>
        /// Lấy sản phẩm nổi bật
        /// </summary>
        /// <param name="limitCount">Số lượng sản phẩm</param>
        /// <returns>Danh sách sản phẩm nổi bật</returns>
        public static List<Product> GetFeaturedProducts(int limitCount = 6)
        {
            var products = new List<Product>();

            try
            {
                string query = @"
                    SELECT p.*, c.name as category_name, b.name as brand_name,
                           ag.name as age_group_name, pi.image_url as primary_image
                    FROM products p
                    LEFT JOIN categories c ON p.category_id = c.id
                    LEFT JOIN brands b ON p.brand_id = b.id
                    LEFT JOIN age_groups ag ON p.age_group_id = ag.id
                    LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = 1
                    WHERE p.status = 'Active' AND p.is_featured = 1
                    ORDER BY p.rating_average DESC, p.sold_count DESC, p.created_at DESC
                    LIMIT @LimitCount";

                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@LimitCount", limitCount)
                };

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);
                products = ConvertDataTableToProducts(dt);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetFeaturedProducts Error: {ex.Message}");
            }

            return products;
        }

        /// <summary>
        /// Lấy sản phẩm mới nhất
        /// </summary>
        /// <param name="limitCount">Số lượng sản phẩm</param>
        /// <returns>Danh sách sản phẩm mới</returns>
        public static List<Product> GetNewProducts(int limitCount = 6)
        {
            var products = new List<Product>();

            try
            {
                string query = @"
                    SELECT p.*, c.name as category_name, b.name as brand_name,
                           ag.name as age_group_name, pi.image_url as primary_image
                    FROM products p
                    LEFT JOIN categories c ON p.category_id = c.id
                    LEFT JOIN brands b ON p.brand_id = b.id
                    LEFT JOIN age_groups ag ON p.age_group_id = ag.id
                    LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = 1
                    WHERE p.status = 'Active' AND p.is_new = 1
                    ORDER BY p.created_at DESC, p.rating_average DESC
                    LIMIT @LimitCount";

                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@LimitCount", limitCount)
                };

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);
                products = ConvertDataTableToProducts(dt);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetNewProducts Error: {ex.Message}");
            }

            return products;
        }

        /// <summary>
        /// Lấy sản phẩm theo danh mục
        /// </summary>
        /// <param name="categoryId">ID danh mục</param>
        /// <param name="pageSize">Số sản phẩm trên trang</param>
        /// <param name="pageNumber">Số trang</param>
        /// <param name="sortBy">Sắp xếp theo</param>
        /// <returns>Danh sách sản phẩm</returns>
        public static List<Product> GetProductsByCategory(int categoryId, int pageSize = 12,
            int pageNumber = 1, string sortBy = "newest")
        {
            var products = new List<Product>();

            try
            {
                int offset = (pageNumber - 1) * pageSize;

                string orderBy = GetOrderByClause(sortBy);

                string query = $@"
                    SELECT p.*, c.name as category_name, b.name as brand_name,
                           ag.name as age_group_name, pi.image_url as primary_image
                    FROM products p
                    LEFT JOIN categories c ON p.category_id = c.id
                    LEFT JOIN brands b ON p.brand_id = b.id
                    LEFT JOIN age_groups ag ON p.age_group_id = ag.id
                    LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = 1
                    WHERE p.status = 'Active' AND p.category_id = @CategoryId
                    {orderBy}
                    LIMIT @PageSize OFFSET @Offset";

                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@CategoryId", categoryId),
                    DatabaseHelper.CreateParameter("@PageSize", pageSize),
                    DatabaseHelper.CreateParameter("@Offset", offset)
                };

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);
                products = ConvertDataTableToProducts(dt);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetProductsByCategory Error: {ex.Message}");
            }

            return products;
        }

        /// <summary>
        /// Tìm kiếm sản phẩm
        /// </summary>
        /// <param name="keyword">Từ khóa tìm kiếm</param>
        /// <param name="categoryId">ID danh mục</param>
        /// <param name="brandId">ID thương hiệu</param>
        /// <param name="minPrice">Giá tối thiểu</param>
        /// <param name="maxPrice">Giá tối đa</param>
        /// <param name="pageSize">Số sản phẩm trên trang</param>
        /// <param name="pageNumber">Số trang</param>
        /// <param name="sortBy">Sắp xếp theo</param>
        /// <returns>Danh sách sản phẩm</returns>
        public static List<Product> SearchProducts(string keyword = "", int? categoryId = null,
            int? brandId = null, decimal? minPrice = null, decimal? maxPrice = null, decimal? minRating=0,
            int pageSize = 12, int pageNumber = 1, string sortBy = "newest")
        {
            var products = new List<Product>();

            try
            {
                // Sử dụng stored procedure SearchProductsAdvanced
                var parameters = new List<MySqlParameter>
                {
                    DatabaseHelper.CreateParameter("search_keyword", keyword),
                    DatabaseHelper.CreateParameter("category_id_param", categoryId),
                    DatabaseHelper.CreateParameter("brand_id_param", brandId),
                    DatabaseHelper.CreateParameter("min_price", minPrice),
                    DatabaseHelper.CreateParameter("max_price", maxPrice),
                    DatabaseHelper.CreateParameter("min_rating", minRating),
                    DatabaseHelper.CreateParameter("sort_by", sortBy),
                    DatabaseHelper.CreateParameter("limit_count", pageSize),
                    DatabaseHelper.CreateParameter("offset_count", (pageNumber - 1) * pageSize)
                };

                DataTable dt = DatabaseHelper.ExecuteStoredProcedure("SearchProductsAdvanced",
                    parameters.ToArray());

                products = ConvertDataTableToProducts(dt);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"SearchProducts Error: {ex.Message}");
            }

            return products;
        }

        #endregion

        #region Phương thức hỗ trợ

        /// <summary>
        /// Chuyển đổi DataTable thành danh sách Product
        /// </summary>
        /// <param name="dt">DataTable</param>
        /// <returns>Danh sách Product</returns>
        private static List<Product> ConvertDataTableToProducts(DataTable dt)
        {
            var products = new List<Product>();

            try
            {
                foreach (DataRow row in dt.Rows)
                {
                    var product = new Product
                    {
                        Id = Convert.ToInt32(row["id"]),
                        Name = row["name"].ToString(),
                        Slug = row["slug"].ToString(),
                        Sku = row["sku"].ToString(),
                        ShortDescription = row["short_description"].ToString(),
                        DetailedDescription = row["detailed_description"].ToString(),
                        CategoryId = Convert.ToInt32(row["category_id"]),
                        CategoryName = row.Table.Columns.Contains("category_name") ?
                            row["category_name"].ToString() : "",
                        BrandId = row["brand_id"] == DBNull.Value ?
                            (int?)null : Convert.ToInt32(row["brand_id"]),
                        BrandName = row.Table.Columns.Contains("brand_name") ?
                            row["brand_name"].ToString() : "",
                        AgeGroupId = row["age_group_id"] == DBNull.Value ?
                            (int?)null : Convert.ToInt32(row["age_group_id"]),
                        AgeGroupName = row.Table.Columns.Contains("age_group_name") ?
                            row["age_group_name"].ToString() : "",
                        OriginalPrice = Convert.ToDecimal(row["original_price"]),
                        SalePrice = row["sale_price"] == DBNull.Value ?
                            (decimal?)null : Convert.ToDecimal(row["sale_price"]),
                        CostPrice = row["cost_price"] == DBNull.Value ?
                            (decimal?)null : Convert.ToDecimal(row["cost_price"]),
                        Weight = row["weight"] == DBNull.Value ?
                            0 : Convert.ToDecimal(row["weight"]),
                        Dimensions = row["dimensions"].ToString(),
                        Material = row["material"].ToString(),
                        Color = row["color"].ToString(),
                        StockQuantity = Convert.ToInt32(row["stock_quantity"]),
                        MinStockLevel = Convert.ToInt32(row["min_stock_level"]),
                        IsFeatured = Convert.ToBoolean(row["is_featured"]),
                        IsBestseller = Convert.ToBoolean(row["is_bestseller"]),
                        IsNew = Convert.ToBoolean(row["is_new"]),
                        Status = row["status"].ToString(),
                        SafetyCertification = row["safety_certification"].ToString(),
                        WarrantyMonths = Convert.ToInt32(row["warranty_months"]),
                        RatingAverage = Convert.ToDecimal(row["rating_average"]),
                        RatingCount = Convert.ToInt32(row["rating_count"]),
                        ViewCount = Convert.ToInt32(row["view_count"]),
                        SoldCount = Convert.ToInt32(row["sold_count"]),
                        SeoTitle = row["seo_title"].ToString(),
                        SeoDescription = row["seo_description"].ToString(),
                        SeoKeywords = row["seo_keywords"].ToString(),
                        PrimaryImage = row.Table.Columns.Contains("primary_image") ?
                            row["primary_image"].ToString() : "",
                        CreatedAt = Convert.ToDateTime(row["created_at"]),
                        UpdatedAt = Convert.ToDateTime(row["updated_at"])
                    };

                    // Đặt ảnh mặc định nếu không có
                    if (string.IsNullOrEmpty(product.PrimaryImage))
                    {
                        product.PrimaryImage = "https://api.placeholder.com/300/300?text=" +
                            Uri.EscapeDataString(product.Name);
                    }

                    products.Add(product);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ConvertDataTableToProducts Error: {ex.Message}");
            }

            return products;
        }

        /// <summary>
        /// Lấy câu ORDER BY từ kiểu sắp xếp
        /// </summary>
        /// <param name="sortBy">Kiểu sắp xếp</param>
        /// <returns>Câu ORDER BY</returns>
        private static string GetOrderByClause(string sortBy)
        {
            switch (sortBy?.ToLower())
            {
                case "price_asc":
                    return "ORDER BY COALESCE(p.sale_price, p.original_price) ASC";
                case "price_desc":
                    return "ORDER BY COALESCE(p.sale_price, p.original_price) DESC";
                case "rating":
                    return "ORDER BY p.rating_average DESC, p.rating_count DESC";
                case "bestseller":
                    return "ORDER BY p.sold_count DESC, p.rating_average DESC";
                case "name_asc":
                    return "ORDER BY p.name ASC";
                case "name_desc":
                    return "ORDER BY p.name DESC";
                case "newest":
                default:
                    return "ORDER BY p.created_at DESC, p.rating_average DESC";
            }
        }

        /// <summary>
        /// Fallback method để lấy sản phẩm bán chạy khi stored procedure lỗi
        /// </summary>
        private static List<Product> GetBestSellingProductsFallback(int limitCount, int? categoryId)
        {
            var products = new List<Product>();

            try
            {
                string whereClause = categoryId.HasValue ?
                    "AND p.category_id = @CategoryId" : "";

                string query = $@"
                    SELECT p.*, c.name as category_name, b.name as brand_name,
                           ag.name as age_group_name, pi.image_url as primary_image
                    FROM products p
                    LEFT JOIN categories c ON p.category_id = c.id
                    LEFT JOIN brands b ON p.brand_id = b.id
                    LEFT JOIN age_groups ag ON p.age_group_id = ag.id
                    LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = 1
                    WHERE p.status = 'Active' {whereClause}
                    ORDER BY p.sold_count DESC, p.rating_average DESC
                    LIMIT @LimitCount";

                var parameters = new List<MySqlParameter>
                {
                    DatabaseHelper.CreateParameter("@LimitCount", limitCount)
                };

                if (categoryId.HasValue)
                {
                    parameters.Add(DatabaseHelper.CreateParameter("@CategoryId", categoryId.Value));
                }

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters.ToArray());
                products = ConvertDataTableToProducts(dt);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetBestSellingProductsFallback Error: {ex.Message}");
            }

            return products;
        }

        #endregion

        #region Phương thức lấy thông tin thống kê

        /// <summary>
        /// Lấy số lượng sản phẩm theo danh mục
        /// </summary>
        /// <param name="categoryId">ID danh mục</param>
        /// <returns>Số lượng sản phẩm</returns>
        public static int GetProductCountByCategory(int categoryId)
        {
            try
            {
                string query = "SELECT COUNT(*) FROM products WHERE category_id = @CategoryId AND status = 'Active'";
                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@CategoryId", categoryId)
                };

                object result = DatabaseHelper.ExecuteScalar(query, parameters);
                return Convert.ToInt32(result);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetProductCountByCategory Error: {ex.Message}");
                return 0;
            }
        }

        /// <summary>
        /// Lấy tổng số sản phẩm đang hoạt động
        /// </summary>
        /// <returns>Tổng số sản phẩm</returns>
        public static int GetTotalActiveProducts()
        {
            try
            {
                string query = "SELECT COUNT(*) FROM products WHERE status = 'Active'";
                object result = DatabaseHelper.ExecuteScalar(query);
                return Convert.ToInt32(result);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetTotalActiveProducts Error: {ex.Message}");
                return 0;
            }
        }

        #endregion

        #region Phương thức quản lý vận chuyển

        /// <summary>
        /// Lấy danh sách phương thức vận chuyển đang hoạt động
        /// </summary>
        /// <returns>Danh sách phương thức vận chuyển</returns>
        public static List<ShippingMethodView> GetActiveShippingMethods()
        {
            var shippingMethods = new List<ShippingMethodView>();

            try
            {
                var parameters = new List<MySqlParameter>();
                DataTable dt = DatabaseHelper.ExecuteStoredProcedure("GetActiveShippingMethods", parameters.ToArray());

                foreach (DataRow row in dt.Rows)
                {
                    var method = new ShippingMethodView
                    {
                        MethodId = Convert.ToInt32(row["id"]),
                        MethodName = row["name"].ToString(),
                        Description = row["description"].ToString(),
                        BaseCost = Convert.ToDecimal(row["base_cost"]),
                        CostPerKg = Convert.ToDecimal(row["cost_per_kg"]),
                        EstimatedTime = $"{row["estimated_days"]} ngày",
                        IsActive = Convert.ToBoolean(row["is_active"]),
                        LastUpdated = Convert.ToDateTime(row["created_at"]),
                        OrderCountThisMonth = 0, // Có thể tính toán từ bảng orders
                        SuccessRate = 100.0, // Có thể tính toán từ bảng orders
                        IconCss = "fas fa-shipping-fast",
                        IconBgCss = "bg-blue-400"
                    };

                    shippingMethods.Add(method);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetActiveShippingMethods Error: {ex.Message}");
            }

            return shippingMethods;
        }

        #endregion

        #region Phương thức quản lý thương hiệu

        /// <summary>
        /// Lấy danh sách thương hiệu đang hoạt động
        /// </summary>
        /// <returns>Danh sách thương hiệu</returns>
        public static List<Brand> GetActiveBrands()
        {
            var brands = new List<Brand>();

            try
            {
                var parameters = new List<MySqlParameter>();
                DataTable dt = DatabaseHelper.ExecuteStoredProcedure("GetActiveBrands", parameters.ToArray());

                foreach (DataRow row in dt.Rows)
                {
                    brands.Add(new Brand
                    {
                        Id = Convert.ToInt32(row["id"]),
                        Name = row["name"].ToString(),
                        Slug = row["slug"].ToString(),
                        Description = row["description"].ToString(),
                        LogoUrl = row["logo_url"].ToString(),
                        WebsiteUrl = row["website_url"].ToString(),
                        Country = row["country"].ToString(),
                        IsActive = Convert.ToBoolean(row["is_active"]),
                        CreatedAt = Convert.ToDateTime(row["created_at"]),
                        UpdatedAt = Convert.ToDateTime(row["updated_at"])
                    });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetActiveBrands Error: {ex.Message}");
            }

            return brands;
        }

        #endregion
    }
}