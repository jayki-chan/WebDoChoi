using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Text;
using WebDoChoi.Business;
using static WebDoChoi.Business.ProductService;

namespace WebsiteDoChoi.Client
{
    public partial class ProductDetails : System.Web.UI.Page
    {
        private int productId = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Get product ID from query string
                if (Request.QueryString["id"] != null && int.TryParse(Request.QueryString["id"].ToString(), out productId))
                {
                    LoadProductDetails(productId);
                    LoadProductImages(productId);
                    LoadProductFeatures(productId);
                    LoadProductSpecifications(productId);
                    LoadProductReviews(productId);
                    LoadRelatedProducts(productId);
                    LoadShippingOptions();
                    LoadReturnPolicies();
                    UpdateCartCount();
                }
                else
                {
                    // Redirect to home if no valid product ID
                    Response.Redirect("/Client/Default.aspx");
                }
            }
        }

        #region Load Data Methods

        private void LoadProductDetails(int productId)
        {
            try
            {
                // Get product details using ProductService
                var product = ProductService.GetProductById(productId);
                if (product != null)
                {
                    // Set breadcrumb
                    lnkBreadcrumbCategory.NavigateUrl = $"/Client/ProductList.aspx?category={product.CategoryId}";
                    lblBreadcrumbCategory.Text = product.CategoryName;
                    lblBreadcrumbProduct.Text = product.Name;

                    // Set product details
                    lblProductName.Text = product.Name;
                    litRatingStars.Text = GenerateRatingStars(product.RatingAverage);
                    lblRating.Text = product.RatingAverage.ToString("0.0");
                    lblReviewCount.Text = $"({product.RatingCount} đánh giá)";
                    lblStockStatus.Text = product.StockQuantity > 0 ? "Còn hàng" : "Hết hàng";
                    lblStockStatus.CssClass = product.StockQuantity > 0 ? "text-success" : "text-danger";

                    // Set prices
                    lblPrice.Text = product.CurrentPrice.ToString("N0") + "đ";
                    if (product.SalePrice.HasValue)
                    {
                        pnlOriginalPrice.Visible = true;
                        lblOriginalPrice.Text = product.OriginalPrice.ToString("N0") + "đ";
                        lblDiscountPercent.Text = $"-{product.DiscountPercent}%";
                    }
                    else
                    {
                        pnlOriginalPrice.Visible = false;
                    }

                    // Set age group
                    lblAgeGroup.Text = product.AgeGroupName;

                    // Set description
                    litProductDescription.Text = product.DetailedDescription;

                    // Set SEO
                    Page.Title = product.SeoTitle;
                    Page.MetaDescription = product.SeoDescription;
                    Page.MetaKeywords = product.SeoKeywords;
                }
                else
                {
                    // Product not found
                    Response.Redirect("/Client/Default.aspx");
                }
            }
            catch (Exception ex)
            {
                // Log error
                System.Diagnostics.Debug.WriteLine($"LoadProductDetails Error: {ex.Message}");
                // Show error message to user
                Response.Redirect("/Client/Default.aspx");
            }
        }

        private void LoadProductImages(int productId)
        {
            try
            {
                // Get product images using ProductService
                var product = ProductService.GetProductById(productId);
                if (product != null)
                {
                    // Set main image
                    imgMainProduct.ImageUrl = product.PrimaryImage;
                    imgMainProduct.AlternateText = product.Name;

                    // Set image gallery
                    var images = new List<ProductImage>();
                    if (!string.IsNullOrEmpty(product.PrimaryImage))
                    {
                        images.Add(new ProductImage { ImageUrl = product.PrimaryImage });
                    }
                    foreach (var image in product.Images)
                    {
                        images.Add(new ProductImage { ImageUrl = image });
                    }
                    rptProductImages.DataSource = images;
                    rptProductImages.DataBind();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadProductImages Error: {ex.Message}");
            }
        }

        private void LoadProductFeatures(int productId)
        {
            try
            {
                // Get product features using ProductService
                var product = ProductService.GetProductById(productId);
                if (product != null)
                {
                    var features = new List<ProductFeature>();
                    if (!string.IsNullOrEmpty(product.SafetyCertification))
                    {
                        features.Add(new ProductFeature { FeatureName = $"Chứng nhận an toàn: {product.SafetyCertification}" });
                    }
                    if (product.WarrantyMonths > 0)
                    {
                        features.Add(new ProductFeature { FeatureName = $"Bảo hành: {product.WarrantyMonths} tháng" });
                    }
                    if (!string.IsNullOrEmpty(product.Material))
                    {
                        features.Add(new ProductFeature { FeatureName = $"Chất liệu: {product.Material}" });
                    }
                    if (!string.IsNullOrEmpty(product.Color))
                    {
                        features.Add(new ProductFeature { FeatureName = $"Màu sắc: {product.Color}" });
                    }
                    if (!string.IsNullOrEmpty(product.Dimensions))
                    {
                        features.Add(new ProductFeature { FeatureName = $"Kích thước: {product.Dimensions}" });
                    }
                    if (product.Weight > 0)
                    {
                        features.Add(new ProductFeature { FeatureName = $"Trọng lượng: {product.Weight}kg" });
                    }

                    rptProductFeatures.DataSource = features;
                    rptProductFeatures.DataBind();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadProductFeatures Error: {ex.Message}");
            }
        }

        private void LoadProductSpecifications(int productId)
        {
            try
            {
                // Get product specifications using ProductService
                var product = ProductService.GetProductById(productId);
                if (product != null)
                {
                    var specifications = new List<ProductSpecification>();
                    specifications.Add(new ProductSpecification { SpecName = "Mã sản phẩm", SpecValue = product.Sku });
                    specifications.Add(new ProductSpecification { SpecName = "Danh mục", SpecValue = product.CategoryName });
                    if (!string.IsNullOrEmpty(product.BrandName))
                    {
                        specifications.Add(new ProductSpecification { SpecName = "Thương hiệu", SpecValue = product.BrandName });
                    }
                    if (!string.IsNullOrEmpty(product.AgeGroupName))
                    {
                        specifications.Add(new ProductSpecification { SpecName = "Độ tuổi", SpecValue = product.AgeGroupName });
                    }
                    if (!string.IsNullOrEmpty(product.Material))
                    {
                        specifications.Add(new ProductSpecification { SpecName = "Chất liệu", SpecValue = product.Material });
                    }
                    if (!string.IsNullOrEmpty(product.Color))
                    {
                        specifications.Add(new ProductSpecification { SpecName = "Màu sắc", SpecValue = product.Color });
                    }
                    if (!string.IsNullOrEmpty(product.Dimensions))
                    {
                        specifications.Add(new ProductSpecification { SpecName = "Kích thước", SpecValue = product.Dimensions });
                    }
                    if (product.Weight > 0)
                    {
                        specifications.Add(new ProductSpecification { SpecName = "Trọng lượng", SpecValue = $"{product.Weight}kg" });
                    }
                    if (!string.IsNullOrEmpty(product.SafetyCertification))
                    {
                        specifications.Add(new ProductSpecification { SpecName = "Chứng nhận an toàn", SpecValue = product.SafetyCertification });
                    }
                    if (product.WarrantyMonths > 0)
                    {
                        specifications.Add(new ProductSpecification { SpecName = "Bảo hành", SpecValue = $"{product.WarrantyMonths} tháng" });
                    }

                    // Split specifications into two columns
                    var midPoint = (int)Math.Ceiling(specifications.Count / 2.0);
                    rptSpecificationsLeft.DataSource = specifications.Take(midPoint);
                    rptSpecificationsLeft.DataBind();
                    rptSpecificationsRight.DataSource = specifications.Skip(midPoint);
                    rptSpecificationsRight.DataBind();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadProductSpecifications Error: {ex.Message}");
            }
        }

        private void LoadProductReviews(int productId)
        {
            try
            {
                // Get product reviews using ProductService
                var product = ProductService.GetProductById(productId);
                if (product != null)
                {
                    // Set review summary
                    lblAverageRating.Text = product.RatingAverage.ToString("0.0");
                    litAverageRatingStars.Text = GenerateRatingStars(product.RatingAverage);
                    lblTotalReviews.Text = $"{product.RatingCount} đánh giá";

                    // TODO: Implement review list loading from database
                    var reviews = new List<ProductReview>();
                    rptReviews.DataSource = reviews;
                    rptReviews.DataBind();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadProductReviews Error: {ex.Message}");
            }
        }

        private void LoadRelatedProducts(int productId)
        {
            try
            {
                // Get related products using ProductService
                var product = ProductService.GetProductById(productId);
                if (product != null)
                {
                    var relatedProducts = ProductService.GetProductsByCategory(product.CategoryId, 4);
                    rptRelatedProducts.DataSource = relatedProducts;
                    rptRelatedProducts.DataBind();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadRelatedProducts Error: {ex.Message}");
            }
        }

        private void LoadShippingOptions()
        {
            try
            {
                // Get shipping methods from ProductService
                var shippingMethods = ProductService.GetActiveShippingMethods();
                rptShippingOptions.DataSource = shippingMethods;
                rptShippingOptions.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadShippingOptions Error: {ex.Message}");
            }
        }

        private void LoadReturnPolicies()
        {
            // TODO: Implement return policies loading from database
            var returnPolicies = new List<object>
            {
                new { Title = "Đổi trả miễn phí", Description = "Đổi trả trong vòng 30 ngày" },
                new { Title = "Bảo hành chính hãng", Description = "Bảo hành theo chính sách của nhà sản xuất" },
                new { Title = "Hỗ trợ 24/7", Description = "Hỗ trợ khách hàng 24/7 qua hotline và email" }
            };

            rptReturnPolicies.DataSource = returnPolicies;
            rptReturnPolicies.DataBind();
        }

        private void UpdateCartCount()
        {
            // TODO: Implement cart count update
        }

        #endregion

        #region Helper Methods

        private string GenerateRatingStars(decimal rating)
        {
            var sb = new StringBuilder();
            int fullStars = (int)Math.Floor(rating);
            bool hasHalfStar = rating - fullStars >= 0.5m;

            // Add full stars
            for (int i = 0; i < fullStars; i++)
            {
                sb.Append("<i class='fas fa-star text-warning'></i>");
            }

            // Add half star if needed
            if (hasHalfStar)
            {
                sb.Append("<i class='fas fa-star-half-alt text-warning'></i>");
            }

            // Add empty stars
            int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
            for (int i = 0; i < emptyStars; i++)
            {
                sb.Append("<i class='far fa-star text-warning'></i>");
            }

            return sb.ToString();
        }
        protected void btnAddToCart_Click(object sender, EventArgs e)
        {
            try
            {
                // Get product ID from command argument
                LinkButton btn = (LinkButton)sender;
                int productId = Convert.ToInt32(btn.CommandArgument);

                // Get user ID if logged in
                int? userId = null;
                if (Session["UserId"] != null)
                {
                    userId = Convert.ToInt32(Session["UserId"]);
                }

                // Get session ID for guest users
                string sessionId = Session.SessionID;

                // Add to cart using CartService
                var result = CartService.AddToCart(userId, sessionId, productId);

                if (result.IsSuccess)
                {
                    // Show success message
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "success",
                        $"alert('{result.Message}');", true);
                }
                else
                {
                    // Show error message
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "error",
                        $"alert('{result.Message}');", true);
                }
            }
            catch (Exception ex)
            {
                // Log error
                System.Diagnostics.Debug.WriteLine($"btnAddToCart_Click Error: {ex.Message}");
                // Show error message
                ScriptManager.RegisterStartupScript(this, this.GetType(), "error",
                    "alert('Có lỗi xảy ra khi thêm sản phẩm vào giỏ hàng!');", true);
            }
        }

        protected void btnAddToWishlist_Click(object sender, EventArgs e)
        {
            // TODO: Implement add to wishlist logic
        }

        protected void btnLikeReview_Command(object sender, CommandEventArgs e)
        {
            // TODO: Implement like review logic
        }

        protected void btnLoadMoreReviews_Click(object sender, EventArgs e)
        {
            // TODO: Implement load more reviews logic
        }
        #endregion
    }
}