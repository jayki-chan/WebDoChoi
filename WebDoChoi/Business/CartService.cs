using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using MySql.Data.MySqlClient;
using WebDoChoi.Data;

namespace WebDoChoi.Business
{
    /// <summary>
    /// Service quản lý giỏ hàng và wishlist
    /// Tương thích với DatabaseHelper hiện có
    /// ĐÃ SỬA: Khắc phục lỗi logic và tối ưu hóa
    /// </summary>
    public class CartService
    {
        #region Models

        /// <summary>
        /// Model item trong giỏ hàng
        /// </summary>
        public class CartItem
        {
            public int Id { get; set; }
            public int ProductId { get; set; }
            public string ProductName { get; set; }
            public string ProductSku { get; set; }
            public string ImageUrl { get; set; }
            public decimal Price { get; set; }
            public decimal OriginalPrice { get; set; }
            public int Quantity { get; set; }
            public decimal Total => Price * Quantity;
            public int StockQuantity { get; set; }
            public bool IsAvailable => StockQuantity > 0;
            public DateTime CreatedAt { get; set; }
            public DateTime UpdatedAt { get; set; }
        }

        /// <summary>
        /// Model tổng hợp giỏ hàng
        /// </summary>
        public class CartSummary
        {
            public List<CartItem> Items { get; set; } = new List<CartItem>();
            public int TotalItems => Items.Count;
            public int TotalQuantity => Items.Sum(x => x.Quantity);
            public decimal Subtotal => Items.Sum(x => x.Total);
            public bool HasItems => Items.Any();
        }

        /// <summary>
        /// Model kết quả thao tác giỏ hàng
        /// </summary>
        public class CartResult
        {
            public bool IsSuccess { get; set; }
            public string Message { get; set; }
            public CartSummary CartSummary { get; set; }
        }

        #endregion

        #region Cart Management - ĐÃ SỬA

        /// <summary>
        /// Thêm sản phẩm vào giỏ hàng - ĐÃ KHẮC PHỤC
        /// </summary>
        public static CartResult AddToCart(int? userId, string sessionId, int productId, int quantity = 1)
        {
            var result = new CartResult();

            try
            {
                // Validate input - SỬA: Cải thiện validation
                if (productId <= 0 || quantity <= 0)
                {
                    result.Message = "Thông tin sản phẩm không hợp lệ";
                    return result;
                }

                if (!userId.HasValue && string.IsNullOrEmpty(sessionId))
                {
                    result.Message = "Phiên làm việc không hợp lệ";
                    return result;
                }

                // Lấy thông tin sản phẩm
                var product = GetProductForCart(productId);
                if (product == null)
                {
                    result.Message = "Sản phẩm không tồn tại hoặc đã ngừng kinh doanh";
                    return result;
                }

                if (product.StockQuantity <= 0)
                {
                    result.Message = "Sản phẩm đã hết hàng";
                    return result;
                }

                // Kiểm tra số lượng yêu cầu
                if (quantity > product.StockQuantity)
                {
                    result.Message = $"Chỉ còn {product.StockQuantity} sản phẩm trong kho";
                    return result;
                }

                // Kiểm tra sản phẩm đã có trong giỏ hàng chưa
                var existingCartItem = GetCartItem(userId, sessionId, productId);

                if (existingCartItem != null)
                {
                    // Cập nhật số lượng nếu đã có
                    int newQuantity = existingCartItem.Quantity + quantity;

                    if (newQuantity > product.StockQuantity)
                    {
                        result.Message = $"Tổng số lượng vượt quá số hàng có sẵn ({product.StockQuantity})";
                        return result;
                    }

                    UpdateCartItemQuantity(existingCartItem.Id, newQuantity);
                    result.Message = "Đã cập nhật số lượng sản phẩm trong giỏ hàng";
                }
                else
                {
                    // Thêm mới vào giỏ hàng
                    AddNewCartItem(userId, sessionId, productId, quantity, product.Price);
                    result.Message = "Đã thêm sản phẩm vào giỏ hàng";
                }

                result.IsSuccess = true;
                result.CartSummary = GetCartSummary(userId, sessionId);

                System.Diagnostics.Debug.WriteLine($"AddToCart success: Product {productId}, Quantity {quantity}, User {userId}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"AddToCart Error: {ex.Message}");
                result.Message = "Có lỗi xảy ra khi thêm sản phẩm vào giỏ hàng";
            }

            return result;
        }

        /// <summary>
        /// Cập nhật số lượng sản phẩm trong giỏ hàng - ĐÃ SỬA
        /// </summary>
        public static CartResult UpdateCartQuantity(int? userId, string sessionId, int productId, int quantity)
        {
            var result = new CartResult();

            try
            {
                if (quantity <= 0)
                {
                    return RemoveFromCart(userId, sessionId, productId);
                }

                var cartItem = GetCartItem(userId, sessionId, productId);
                if (cartItem == null)
                {
                    result.Message = "Sản phẩm không có trong giỏ hàng";
                    return result;
                }

                var product = GetProductForCart(productId);
                if (product == null)
                {
                    result.Message = "Sản phẩm không tồn tại";
                    return result;
                }

                if (quantity > product.StockQuantity)
                {
                    result.Message = $"Chỉ còn {product.StockQuantity} sản phẩm trong kho";
                    return result;
                }

                UpdateCartItemQuantity(cartItem.Id, quantity);

                result.IsSuccess = true;
                result.Message = "Đã cập nhật số lượng";
                result.CartSummary = GetCartSummary(userId, sessionId);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"UpdateCartQuantity Error: {ex.Message}");
                result.Message = "Có lỗi khi cập nhật số lượng";
            }

            return result;
        }

        /// <summary>
        /// Xóa sản phẩm khỏi giỏ hàng - ĐÃ SỬA
        /// </summary>
        public static CartResult RemoveFromCart(int? userId, string sessionId, int productId)
        {
            var result = new CartResult();

            try
            {
                string query = @"
                    DELETE FROM shopping_cart 
                    WHERE product_id = @ProductId 
                    AND ((@UserId IS NOT NULL AND user_id = @UserId) OR 
                         (@UserId IS NULL AND session_id = @SessionId))";

                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@ProductId", productId),
                    DatabaseHelper.CreateParameter("@UserId", userId),
                    DatabaseHelper.CreateParameter("@SessionId", sessionId)
                };

                int rowsAffected = DatabaseHelper.ExecuteNonQuery(query, parameters);

                if (rowsAffected > 0)
                {
                    result.IsSuccess = true;
                    result.Message = "Đã xóa sản phẩm khỏi giỏ hàng";
                    System.Diagnostics.Debug.WriteLine($"Removed product {productId} from cart for user {userId}");
                }
                else
                {
                    result.Message = "Sản phẩm không có trong giỏ hàng";
                }

                result.CartSummary = GetCartSummary(userId, sessionId);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"RemoveFromCart Error: {ex.Message}");
                result.Message = "Có lỗi khi xóa sản phẩm";
            }

            return result;
        }

        /// <summary>
        /// Lấy tổng hợp giỏ hàng - ĐÃ TỐI ƯU
        /// </summary>
        public static CartSummary GetCartSummary(int? userId, string sessionId)
        {
            var summary = new CartSummary();

            try
            {
                string query = @"
                    SELECT 
                        sc.id, sc.product_id, sc.quantity, sc.price, sc.created_at, sc.updated_at,
                        p.name as product_name, p.sku, p.original_price, p.stock_quantity, p.status,
                        COALESCE(pi.image_url, '') as image_url
                    FROM shopping_cart sc
                    JOIN products p ON sc.product_id = p.id
                    LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = 1
                    WHERE p.status = 'Active'
                    AND ((@UserId IS NOT NULL AND sc.user_id = @UserId) OR 
                         (@UserId IS NULL AND sc.session_id = @SessionId))
                    ORDER BY sc.created_at DESC";

                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@UserId", userId),
                    DatabaseHelper.CreateParameter("@SessionId", sessionId)
                };

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);

                foreach (DataRow row in dt.Rows)
                {
                    var item = new CartItem
                    {
                        Id = Convert.ToInt32(row["id"]),
                        ProductId = Convert.ToInt32(row["product_id"]),
                        ProductName = row["product_name"].ToString(),
                        ProductSku = row["sku"].ToString(),
                        ImageUrl = row["image_url"].ToString(),
                        Price = Convert.ToDecimal(row["price"]),
                        OriginalPrice = Convert.ToDecimal(row["original_price"]),
                        Quantity = Convert.ToInt32(row["quantity"]),
                        StockQuantity = Convert.ToInt32(row["stock_quantity"]),
                        CreatedAt = Convert.ToDateTime(row["created_at"]),
                        UpdatedAt = Convert.ToDateTime(row["updated_at"])
                    };

                    summary.Items.Add(item);
                }

                System.Diagnostics.Debug.WriteLine($"Cart summary loaded: {summary.TotalItems} items, {summary.TotalQuantity} total quantity");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetCartSummary Error: {ex.Message}");
            }

            return summary;
        }

        #endregion

        #region Wishlist Management - ĐÃ KHẮC PHỤC

        /// <summary>
        /// Thêm sản phẩm vào wishlist - ĐÃ SỬA
        /// </summary>
        public static CartResult AddToWishlist(int userId, int productId)
        {
            var result = new CartResult();

            try
            {
                // Validate input
                if (userId <= 0 || productId <= 0)
                {
                    result.Message = "Thông tin không hợp lệ";
                    return result;
                }

                // Kiểm tra sản phẩm có tồn tại không
                if (!IsProductExists(productId))
                {
                    result.Message = "Sản phẩm không tồn tại";
                    return result;
                }

                // Kiểm tra đã có trong wishlist chưa
                string checkQuery = @"
                    SELECT COUNT(*) FROM wishlists 
                    WHERE user_id = @UserId AND product_id = @ProductId";

                var checkParams = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@UserId", userId),
                    DatabaseHelper.CreateParameter("@ProductId", productId)
                };

                int existing = Convert.ToInt32(DatabaseHelper.ExecuteScalar(checkQuery, checkParams));

                if (existing > 0)
                {
                    result.Message = "Sản phẩm đã có trong danh sách yêu thích";
                    return result;
                }

                // Thêm vào wishlist
                string insertQuery = @"
                    INSERT INTO wishlists (user_id, product_id, created_at) 
                    VALUES (@UserId, @ProductId, NOW())";

                var insertParams = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@UserId", userId),
                    DatabaseHelper.CreateParameter("@ProductId", productId)
                };

                int rowsAffected = DatabaseHelper.ExecuteNonQuery(insertQuery, insertParams);

                if (rowsAffected > 0)
                {
                    result.IsSuccess = true;
                    result.Message = "Đã thêm vào danh sách yêu thích";
                    System.Diagnostics.Debug.WriteLine($"Added product {productId} to wishlist for user {userId}");
                }
                else
                {
                    result.Message = "Không thể thêm vào danh sách yêu thích";
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"AddToWishlist Error: {ex.Message}");
                result.Message = "Có lỗi khi thêm vào danh sách yêu thích";
            }

            return result;
        }

        /// <summary>
        /// Xóa khỏi wishlist - ĐÃ SỬA
        /// </summary>
        public static CartResult RemoveFromWishlist(int userId, int productId)
        {
            var result = new CartResult();

            try
            {
                string query = @"
                    DELETE FROM wishlists 
                    WHERE user_id = @UserId AND product_id = @ProductId";

                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@UserId", userId),
                    DatabaseHelper.CreateParameter("@ProductId", productId)
                };

                int rowsAffected = DatabaseHelper.ExecuteNonQuery(query, parameters);

                if (rowsAffected > 0)
                {
                    result.IsSuccess = true;
                    result.Message = "Đã xóa khỏi danh sách yêu thích";
                    System.Diagnostics.Debug.WriteLine($"Removed product {productId} from wishlist for user {userId}");
                }
                else
                {
                    result.Message = "Sản phẩm không có trong danh sách yêu thích";
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"RemoveFromWishlist Error: {ex.Message}");
                result.Message = "Có lỗi khi xóa khỏi danh sách yêu thích";
            }

            return result;
        }

        /// <summary>
        /// Lấy số lượng items trong wishlist
        /// </summary>
        public static int GetWishlistCount(int userId)
        {
            try
            {
                string query = "SELECT COUNT(*) FROM wishlists WHERE user_id = @UserId";
                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@UserId", userId)
                };

                return Convert.ToInt32(DatabaseHelper.ExecuteScalar(query, parameters));
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetWishlistCount Error: {ex.Message}");
                return 0;
            }
        }

        /// <summary>
        /// Merge session cart với user cart sau khi đăng nhập - ĐÃ TỐI ƯU
        /// </summary>
        public static void MergeSessionCartToUser(int userId, string sessionId)
        {
            try
            {
                if (string.IsNullOrEmpty(sessionId))
                {
                    System.Diagnostics.Debug.WriteLine("MergeSessionCartToUser: sessionId is null or empty");
                    return;
                }

                // Lấy danh sách items từ session cart
                string getSessionItemsQuery = @"
                    SELECT product_id, quantity, price 
                    FROM shopping_cart 
                    WHERE session_id = @SessionId AND user_id IS NULL";

                var getSessionParams = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@SessionId", sessionId)
                };

                DataTable sessionItems = DatabaseHelper.ExecuteQuery(getSessionItemsQuery, getSessionParams);

                if (sessionItems.Rows.Count == 0)
                {
                    System.Diagnostics.Debug.WriteLine("MergeSessionCartToUser: No session cart items to merge");
                    return;
                }

                foreach (DataRow row in sessionItems.Rows)
                {
                    int productId = Convert.ToInt32(row["product_id"]);
                    int quantity = Convert.ToInt32(row["quantity"]);
                    decimal price = Convert.ToDecimal(row["price"]);

                    // Kiểm tra sản phẩm đã có trong user cart chưa
                    var existingUserItem = GetCartItem(userId, null, productId);

                    if (existingUserItem != null)
                    {
                        // Cộng dồn số lượng
                        int newQuantity = existingUserItem.Quantity + quantity;
                        UpdateCartItemQuantity(existingUserItem.Id, newQuantity);
                    }
                    else
                    {
                        // Thêm mới vào user cart
                        AddNewCartItem(userId, null, productId, quantity, price);
                    }
                }

                // Xóa session cart sau khi merge
                string deleteSessionCartQuery = @"
                    DELETE FROM shopping_cart 
                    WHERE session_id = @SessionId AND user_id IS NULL";

                DatabaseHelper.ExecuteNonQuery(deleteSessionCartQuery, getSessionParams);

                System.Diagnostics.Debug.WriteLine($"MergeSessionCartToUser completed: Merged {sessionItems.Rows.Count} items");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"MergeSessionCartToUser Error: {ex.Message}");
            }
        }

        #endregion

        #region Helper Methods - ĐÃ SỬA VÀ BỔ SUNG

        /// <summary>
        /// Lấy thông tin sản phẩm cho giỏ hàng - ĐÃ SỬA
        /// </summary>
        private static CartItem GetProductForCart(int productId)
        {
            try
            {
                string query = @"
                    SELECT 
                        p.id, p.name, p.sku, p.original_price, 
                        COALESCE(p.sale_price, p.original_price) as current_price,
                        p.stock_quantity, p.status,
                        COALESCE(pi.image_url, '') as image_url
                    FROM products p
                    LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = 1
                    WHERE p.id = @ProductId AND p.status = 'Active'";

                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@ProductId", productId)
                };

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);

                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];
                    return new CartItem
                    {
                        ProductId = Convert.ToInt32(row["id"]),
                        ProductName = row["name"].ToString(),
                        ProductSku = row["sku"].ToString(),
                        Price = Convert.ToDecimal(row["current_price"]),
                        OriginalPrice = Convert.ToDecimal(row["original_price"]),
                        StockQuantity = Convert.ToInt32(row["stock_quantity"]),
                        ImageUrl = row["image_url"].ToString()
                    };
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetProductForCart Error: {ex.Message}");
            }

            return null;
        }

        /// <summary>
        /// Lấy cart item hiện tại - ĐÃ SỬA
        /// </summary>
        private static CartItem GetCartItem(int? userId, string sessionId, int productId)
        {
            try
            {
                string query = @"
                    SELECT id, quantity FROM shopping_cart 
                    WHERE product_id = @ProductId 
                    AND ((@UserId IS NOT NULL AND user_id = @UserId) OR 
                         (@UserId IS NULL AND session_id = @SessionId))";

                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@ProductId", productId),
                    DatabaseHelper.CreateParameter("@UserId", userId),
                    DatabaseHelper.CreateParameter("@SessionId", sessionId)
                };

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);

                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];
                    return new CartItem
                    {
                        Id = Convert.ToInt32(row["id"]),
                        ProductId = productId,
                        Quantity = Convert.ToInt32(row["quantity"])
                    };
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetCartItem Error: {ex.Message}");
            }

            return null;
        }

        /// <summary>
        /// Thêm cart item mới - ĐÃ SỬA
        /// </summary>
        private static void AddNewCartItem(int? userId, string sessionId, int productId, int quantity, decimal price)
        {
            string query = @"
                INSERT INTO shopping_cart (user_id, session_id, product_id, quantity, price, created_at, updated_at)
                VALUES (@UserId, @SessionId, @ProductId, @Quantity, @Price, NOW(), NOW())";

            var parameters = new MySqlParameter[]
            {
                DatabaseHelper.CreateParameter("@UserId", userId),
                DatabaseHelper.CreateParameter("@SessionId", userId.HasValue ? null : sessionId),
                DatabaseHelper.CreateParameter("@ProductId", productId),
                DatabaseHelper.CreateParameter("@Quantity", quantity),
                DatabaseHelper.CreateParameter("@Price", price)
            };

            DatabaseHelper.ExecuteNonQuery(query, parameters);
            System.Diagnostics.Debug.WriteLine($"Added new cart item: Product {productId}, Quantity {quantity}, User {userId}");
        }

        /// <summary>
        /// Cập nhật số lượng cart item
        /// </summary>
        private static void UpdateCartItemQuantity(int cartItemId, int quantity)
        {
            string query = @"
                UPDATE shopping_cart 
                SET quantity = @Quantity, updated_at = NOW() 
                WHERE id = @CartItemId";

            var parameters = new MySqlParameter[]
            {
                DatabaseHelper.CreateParameter("@Quantity", quantity),
                DatabaseHelper.CreateParameter("@CartItemId", cartItemId)
            };

            DatabaseHelper.ExecuteNonQuery(query, parameters);
            System.Diagnostics.Debug.WriteLine($"Updated cart item {cartItemId} quantity to {quantity}");
        }

        /// <summary>
        /// Kiểm tra sản phẩm có tồn tại không - THÊM MỚI
        /// </summary>
        private static bool IsProductExists(int productId)
        {
            try
            {
                string query = "SELECT COUNT(*) FROM products WHERE id = @ProductId AND status = 'Active'";
                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@ProductId", productId)
                };

                return Convert.ToInt32(DatabaseHelper.ExecuteScalar(query, parameters)) > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"IsProductExists Error: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Làm sạch giỏ hàng cũ (session cart cũ hơn 7 ngày) - THÊM MỚI
        /// </summary>
        public static void CleanupOldCarts()
        {
            try
            {
                string query = @"
                    DELETE FROM shopping_cart 
                    WHERE user_id IS NULL 
                    AND created_at < DATE_SUB(NOW(), INTERVAL 7 DAY)";

                int rowsAffected = DatabaseHelper.ExecuteNonQuery(query);
                System.Diagnostics.Debug.WriteLine($"Cleaned up {rowsAffected} old cart items");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"CleanupOldCarts Error: {ex.Message}");
            }
        }

        #endregion
    }
}