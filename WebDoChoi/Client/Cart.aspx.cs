using System;
using System.Collections.Generic;
using System.Data; // For DataTable if used for dummy data
using System.Globalization;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebsiteDoChoi.Client
{
    // Dummy Product Class for demonstration
    public class CartProduct
    {
        public int ProductId { get; set; }
        public string ProductName { get; set; }
        public string ProductCode { get; set; }
        public decimal Price { get; set; }
        public decimal OriginalPrice { get; set; }
        public int Quantity { get; set; }
        public string ImageUrl { get; set; }
        public decimal TotalPrice => Price * Quantity;
    }

    public partial class Cart : System.Web.UI.Page
    {
        // Use Session to store cart items for this demo
        private List<CartProduct> CurrentCart
        {
            get
            {
                if (Session["CartData"] == null)
                {
                    Session["CartData"] = new List<CartProduct>();
                }
                return (List<CartProduct>)Session["CartData"];
            }
            set
            {
                Session["CartData"] = value;
            }
        }

        private decimal AppliedDiscount = 0m; // Store discount amount
        private string AppliedCoupon = ""; // Store applied coupon

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Load dummy cart data for demonstration
                LoadDummyCart();
                BindCartRepeater();
                UpdateCartSummary();
                UpdateStepUI();
                PopulateAddressDropdowns(); // For shipping form
                                            // Set initial payment method related panel visibility
                UpdatePaymentPanelsVisibility();
            }
        }

        private void LoadDummyCart()
        {
            if (CurrentCart.Count == 0) // Only load if cart is empty
            {
                CurrentCart = new List<CartProduct>
                {
                    new CartProduct { ProductId = 1, ProductName = "Robot biến hình thông minh", ProductCode = "TOY001", Price = 450000m, OriginalPrice = 550000m, Quantity = 1, ImageUrl = "https://api.placeholder.com/300/300?text=Robot1" },
                    new CartProduct { ProductId = 2, ProductName = "Xe đua điều khiển từ xa địa hình", ProductCode = "TOY002", Price = 520000m, OriginalPrice = 0m, Quantity = 1, ImageUrl = "https://api.placeholder.com/300/300?text=Car2" },
                    new CartProduct { ProductId = 3, ProductName = "Bộ xếp khối gỗ hình học màu sắc", ProductCode = "TOY003", Price = 175000m, OriginalPrice = 0m, Quantity = 2, ImageUrl = "https://api.placeholder.com/300/300?text=Blocks3" }
                };
            }
        }

        private void PopulateAddressDropdowns()
        {
            // Tỉnh/Thành phố
            if (ddlProvince.Items.Count <= 1) // Check if not already populated
            {
                ddlProvince.Items.Add(new ListItem("Hà Nội", "HN"));
                ddlProvince.Items.Add(new ListItem("TP. Hồ Chí Minh", "HCM"));
                ddlProvince.Items.Add(new ListItem("Đà Nẵng", "DN"));
                // Add more provinces...
            }
            // Quận/Huyện và Phường/Xã sẽ được populate dựa trên lựa chọn (cần logic phức tạp hơn)
            // For demo, adding static items to District if a Province is selected
            if (!string.IsNullOrEmpty(ddlProvince.SelectedValue) && ddlDistrict.Items.Count <= 1)
            {
                ddlDistrict.Items.Clear();
                ddlDistrict.Items.Add(new ListItem("Chọn quận/huyện", ""));
                if (ddlProvince.SelectedValue == "HCM")
                {
                    ddlDistrict.Items.Add(new ListItem("Quận 1", "Q1"));
                    ddlDistrict.Items.Add(new ListItem("Quận Bình Thạnh", "QBT"));
                }
                else if (ddlProvince.SelectedValue == "HN")
                {
                    ddlDistrict.Items.Add(new ListItem("Quận Ba Đình", "BD"));
                    ddlDistrict.Items.Add(new ListItem("Quận Hoàn Kiếm", "HK"));
                }
                // ...
            }
            if (!string.IsNullOrEmpty(ddlDistrict.SelectedValue) && ddlWard.Items.Count <= 1)
            {
                ddlWard.Items.Clear();
                ddlWard.Items.Add(new ListItem("Chọn phường/xã", ""));
                if (ddlDistrict.SelectedValue == "Q1")
                {
                    ddlWard.Items.Add(new ListItem("Phường Bến Nghé", "PBN"));
                    ddlWard.Items.Add(new ListItem("Phường Cầu Ông Lãnh", "PCOL"));
                }
                else if (ddlDistrict.SelectedValue == "BD")
                {
                    ddlWard.Items.Add(new ListItem("Phường Phúc Xá", "PPX"));
                    ddlWard.Items.Add(new ListItem("Phường Trúc Bạch", "PTB"));
                }
                // ...
            }
        }


        #region Cart Item Management
        private void BindCartRepeater()
        {
            rptCartItems.DataSource = CurrentCart;
            rptCartItems.DataBind();
            lblCartItemCount.Text = $"{CurrentCart.Sum(item => item.Quantity)} sản phẩm";

            // Show/hide empty cart message and continue shopping link
            pnlContinueShopping.Visible = CurrentCart.Count > 0;
            pnlOrderSummaryCart.Visible = CurrentCart.Count > 0;
        }

        protected void rptCartItems_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int productId = Convert.ToInt32(e.CommandArgument);
            CartProduct product = CurrentCart.FirstOrDefault(p => p.ProductId == productId);

            if (product != null)
            {
                if (e.CommandName == "IncreaseQuantity")
                {
                    product.Quantity++;
                }
                else if (e.CommandName == "DecreaseQuantity")
                {
                    if (product.Quantity > 1)
                        product.Quantity--;
                    else // Quantity is 1, so remove
                        CurrentCart.Remove(product);
                }
                else if (e.CommandName == "RemoveItem")
                {
                    CurrentCart.Remove(product);
                }
            }
            BindCartRepeater();
            UpdateCartSummary();
        }
        #endregion

        #region Coupon and Summary
        protected void btnApplyCoupon_Click(object sender, EventArgs e)
        {
            string couponCode = txtCouponCode.Text.Trim().ToUpper();
            // Dummy coupon logic
            if (couponCode == "TOYLAND10")
            {
                AppliedDiscount = CurrentCart.Sum(p => p.TotalPrice) * 0.1m; // 10% discount
                AppliedCoupon = couponCode;
                lblCouponMessage.Text = "Áp dụng mã giảm giá TOYLAND10 thành công!";
                lblCouponMessage.CssClass = "text-xs mt-1 text-green-600";
            }
            else if (couponCode == "GIAM50K")
            {
                AppliedDiscount = 50000m;
                AppliedCoupon = couponCode;
                lblCouponMessage.Text = "Áp dụng mã giảm giá GIAM50K thành công!";
                lblCouponMessage.CssClass = "text-xs mt-1 text-green-600";
            }
            else
            {
                AppliedDiscount = 0m;
                AppliedCoupon = "";
                lblCouponMessage.Text = "Mã giảm giá không hợp lệ hoặc đã hết hạn.";
                lblCouponMessage.CssClass = "text-xs mt-1 text-red-500";
            }
            UpdateCartSummary();
        }

        private void UpdateCartSummary()
        {
            decimal subtotal = CurrentCart.Sum(item => item.TotalPrice);
            decimal shippingFee = GetShippingFee(); // Get current shipping fee based on selection or default
            decimal totalAmount = subtotal - AppliedDiscount + shippingFee;
            if (totalAmount < 0) totalAmount = 0; // Ensure total is not negative

            // Cart Step Summary
            lblSubtotal.Text = subtotal.ToString("N0", CultureInfo.InvariantCulture) + "đ";
            lblDiscount.Text = AppliedDiscount > 0 ? $"-{AppliedDiscount.ToString("N0", CultureInfo.InvariantCulture)}đ" : "0đ";
            lblDiscount.CssClass = AppliedDiscount > 0 ? "text-green-600 font-medium" : "font-medium";
            lblShippingFeeCart.Text = shippingFee == 0 ? "Miễn phí" : shippingFee.ToString("N0", CultureInfo.InvariantCulture) + "đ";
            lblTotalAmountCart.Text = totalAmount.ToString("N0", CultureInfo.InvariantCulture) + "đ";

            // Info Step Summary (Repeater and Labels)
            lblSubtotalInfo.Text = subtotal.ToString("N0", CultureInfo.InvariantCulture) + "đ";
            lblDiscountInfo.Text = AppliedDiscount > 0 ? $"-{AppliedDiscount.ToString("N0", CultureInfo.InvariantCulture)}đ" : "0đ";
            lblDiscountInfo.CssClass = AppliedDiscount > 0 ? "text-green-600 font-medium" : "font-medium";
            lblShippingFeeInfo.Text = shippingFee == 0 ? "Miễn phí" : shippingFee.ToString("N0", CultureInfo.InvariantCulture) + "đ";
            lblTotalAmountInfo.Text = totalAmount.ToString("N0", CultureInfo.InvariantCulture) + "đ";
            lblItemCountInfo.Text = CurrentCart.Sum(i => i.Quantity).ToString();
            rptCartSummaryInfo.DataSource = CurrentCart;
            rptCartSummaryInfo.DataBind();


            // Payment Step Summary
            lblSubtotalPayment.Text = subtotal.ToString("N0", CultureInfo.InvariantCulture) + "đ";
            lblDiscountPayment.Text = AppliedDiscount > 0 ? $"-{AppliedDiscount.ToString("N0", CultureInfo.InvariantCulture)}đ" : "0đ";
            lblDiscountPayment.CssClass = AppliedDiscount > 0 ? "text-green-600 font-medium" : "font-medium";
            lblShippingFeePayment.Text = shippingFee == 0 ? "Miễn phí" : shippingFee.ToString("N0", CultureInfo.InvariantCulture) + "đ";
            lblTotalAmountPayment.Text = totalAmount.ToString("N0", CultureInfo.InvariantCulture) + "đ";
        }
        #endregion

        #region Step Navigation and UI
        private void UpdateStepUI()
        {
            int currentViewIndex = mvCheckoutSteps.ActiveViewIndex;
            ScriptManager.RegisterStartupScript(this, GetType(), "UpdateSteps", $"updateStepIndicators({currentViewIndex + 1});", true);
        }

        protected void btnProceedToInfo_Click(object sender, EventArgs e)
        {
            if (CurrentCart.Count == 0)
            {
                // Optionally show a message if cart is empty
                ScriptManager.RegisterStartupScript(this, GetType(), "EmptyCart", "alert('Giỏ hàng của bạn đang trống. Vui lòng thêm sản phẩm để tiếp tục.');", true);
                return;
            }
            mvCheckoutSteps.ActiveViewIndex = 1;
            UpdateStepUI();
            UpdateCartSummary(); // Ensure summary is updated for the new step
            PopulateAddressDropdowns();
        }

        protected void btnBackToCart_Click(object sender, EventArgs e)
        {
            mvCheckoutSteps.ActiveViewIndex = 0;
            UpdateStepUI();
        }

        protected void btnProceedToPayment_Click(object sender, EventArgs e)
        {
            Page.Validate("ShippingInfo");
            if (Page.IsValid)
            {
                mvCheckoutSteps.ActiveViewIndex = 2;
                UpdateStepUI();
                // Update payment step summary with shipping info
                litShippingAddressSummary.Text = $"{txtFullName.Text}<br />{txtPhone.Text}<br />{txtStreetAddress.Text}, {ddlWard.SelectedItem.Text},<br />{ddlDistrict.SelectedItem.Text}, {ddlProvince.SelectedItem.Text}";
                lblShippingMethodSummary.Text = rblShippingMethods.SelectedItem.Text.Split(new[] { " - " }, StringSplitOptions.None)[0]; // Get only name part
                lblOrderCodeForBank.Text = GenerateOrderCode(); // Example for bank transfer
                UpdateCartSummary(); // Ensure summary is updated for the new step
                UpdatePaymentPanelsVisibility(); // Ensure correct payment panel is shown
            }
            else
            {
                // Validation failed, stay on current step, errors will be displayed by validators
                mvCheckoutSteps.ActiveViewIndex = 1; // Ensure we are on the info view
                UpdateStepUI();
            }
        }

        protected void ddlProvince_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Populate ddlDistrict based on ddlProvince.SelectedValue
            // This requires database lookup or predefined lists
            ddlDistrict.Items.Clear();
            ddlDistrict.Items.Add(new ListItem("Chọn quận/huyện", ""));
            ddlWard.Items.Clear();
            ddlWard.Items.Add(new ListItem("Chọn phường/xã", ""));

            if (ddlProvince.SelectedValue == "HCM")
            { // Example
                ddlDistrict.Items.Add(new ListItem("Quận 1", "Q1"));
                ddlDistrict.Items.Add(new ListItem("Quận Bình Thạnh", "QBT"));
            }
            else if (ddlProvince.SelectedValue == "HN")
            {
                ddlDistrict.Items.Add(new ListItem("Quận Ba Đình", "QBD"));
            }
            // ... more logic
            UpdateCartSummary(); // Recalculate shipping if it depends on address
        }

        protected void ddlDistrict_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Populate ddlWard based on ddlDistrict.SelectedValue
            ddlWard.Items.Clear();
            ddlWard.Items.Add(new ListItem("Chọn phường/xã", ""));
            if (ddlDistrict.SelectedValue == "Q1")
            { // Example
                ddlWard.Items.Add(new ListItem("Phường Bến Nghé", "PBN"));
                ddlWard.Items.Add(new ListItem("Phường Cầu Ông Lãnh", "PCOL"));
            }
            // ...
            UpdateCartSummary(); // Recalculate shipping
        }


        protected void btnBackToInfo_Click(object sender, EventArgs e)
        {
            mvCheckoutSteps.ActiveViewIndex = 1;
            UpdateStepUI();
        }

        protected void btnCompleteOrder_Click(object sender, EventArgs e)
        {
            Page.Validate("Payment"); // Assuming a validation group for payment step if needed
            bool termsAccepted = chkAcceptTerms.Checked;
            if (!termsAccepted)
            {
                // Force validation for the checkbox if CustomValidator client script fails or is bypassed
                cvAcceptTerms.IsValid = false;
            }

            if (Page.IsValid && termsAccepted)
            {
                // 1. Process Payment (Simulated here)
                // 2. Save Order to Database
                string orderCode = GenerateOrderCode(); // Implement this
                // Save order details: items from CurrentCart, shipping info from TextBoxes/DropDownLists, payment method, total amount, etc.

                // 3. Clear Cart
                CurrentCart.Clear(); // Or Session.Remove("CartData");

                // 4. Show Success Modal
                lblSuccessOrderCode.Text = "#" + orderCode;
                lblSuccessTotalAmount.Text = lblTotalAmountPayment.Text; // Get the final total
                pnlSuccessModal.Visible = true;

                // Prevent further interaction with the form steps if needed, or redirect
                mvCheckoutSteps.Visible = false;
                // Hide progress steps or other irrelevant UI elements
                // (this part might need more granular control over element visibility)
            }
            else
            {
                mvCheckoutSteps.ActiveViewIndex = 2; // Stay on payment view
                UpdateStepUI();
            }
        }

        private string GenerateOrderCode()
        {
            return "TOY" + DateTime.Now.ToString("yyMMddHHmmss");
        }

        #endregion

        #region Shipping and Payment Methods
        protected void rblShippingMethods_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdateCartSummary(); // Recalculate totals based on new shipping fee
        }

        private decimal GetShippingFee()
        {
            if (rblShippingMethods.SelectedItem != null)
            {
                string feeStr = rblShippingMethods.SelectedItem.Attributes["data-fee"];
                if (decimal.TryParse(feeStr, out decimal fee))
                {
                    return fee;
                }
            }
            return 0m; // Default to free shipping
        }

        protected void rblPaymentMethods_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdatePaymentPanelsVisibility();
        }

        private void UpdatePaymentPanelsVisibility()
        {
            string selectedPayment = rblPaymentMethods.SelectedValue;
            pnlCardDetails.Visible = (selectedPayment == "card");
            pnlBankDetails.Visible = (selectedPayment == "bank");
            pnlEWalletDetails.Visible = (selectedPayment == "ewallet");

            // Style the selected radio button's label (more robustly done server-side if client-side is tricky)
            foreach (ListItem item in rblPaymentMethods.Items)
            {
                // This is a bit tricky with how RadioButtonList renders. 
                // Client-side script is often better for detailed styling of choices.
                // For server-side, you'd need to find the control and add/remove a class.
            }
            ScriptManager.RegisterStartupScript(this, this.GetType(), "UpdatePaymentSelectionStyle", "updatePaymentDetailsVisibility();", true);

        }

        #endregion
    }
}