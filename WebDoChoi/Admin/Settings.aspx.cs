using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
// using Newtonsoft.Json; // For JSON import/export, if you choose this library

namespace WebsiteDoChoi.Admin
{
    // Define a class (or classes) to hold all settings
    public class WebsiteSettingsModel
    {
        // General Tab
        public string SiteName { get; set; }
        public string SiteTagline { get; set; }
        public string SiteDescription { get; set; }
        public string StoreAddress { get; set; }
        public string LogoUrl { get; set; }
        public string FaviconUrl { get; set; }
        public string PrimaryColor { get; set; }
        public string SecondaryColor { get; set; }
        public string AccentColor { get; set; }
        public string ContactEmail { get; set; }
        public string ContactPhone { get; set; }
        public string WorkingHours { get; set; }

        // Sales Tab
        public string Currency { get; set; }
        public string CurrencySymbol { get; set; }
        public decimal DefaultTaxRate { get; set; }
        public decimal FreeShippingThreshold { get; set; }
        public int ProductsPerPage { get; set; }
        public bool AutoUpdateStock { get; set; }
        public bool AllowOrderOutOfStock { get; set; }
        public bool ShowStockQuantity { get; set; }
        public bool AllowReviews { get; set; }
        public bool AllowProductComparison { get; set; }
        public int MaxComparisonItems { get; set; }


        // Payment Tab
        public bool EnableCOD { get; set; }
        public decimal CODFeePercent { get; set; }
        public decimal CODMinOrder { get; set; }
        public bool EnableBankTransfer { get; set; }
        public string BankTransferInfo { get; set; }
        public bool EnableMoMo { get; set; }
        public string MoMoPartnerCode { get; set; }
        public string MoMoAccessKey { get; set; }
        public bool EnableZaloPay { get; set; }
        public string ZaloPayAppId { get; set; }
        public string ZaloPayKey1 { get; set; }

        // Email & SMS Tab (add properties for SMTP, SMS Gateway, Email Templates etc.)
        public string SmtpHost { get; set; }
        // ... other settings ...
    }


    public partial class Settings : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ViewState["ActiveAdminSettingsTab"] = "General"; // Default tab
                LoadSettingsData();
                UpdateSettingsTabsUI();
            }
            // Ensure checkbox JS styling is re-applied after UpdatePanel postback
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ReapplyToggleStyles",
                "document.querySelectorAll('.toggle-switch-settings-aspnet').forEach(cb => toggleAdminSwitch(cb.id));", true);
        }

        protected void SettingsTab_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            ViewState["ActiveAdminSettingsTab"] = btn.CommandArgument;
            UpdateSettingsTabsUI();
            // Load data for the specific tab if needed, or assume all data is loaded once.
        }

        private void UpdateSettingsTabsUI()
        {
            string activeTab = ViewState["ActiveAdminSettingsTab"]?.ToString() ?? "General";
            var allTabs = new List<LinkButton> { tabBtnGeneral, tabBtnSales, tabBtnPayment, tabBtnEmail, tabBtnSeo, tabBtnSecurity, tabBtnPerformance, tabBtnSocial };
            var allPanels = new List<Panel> { pnlGeneralSettings, pnlSalesSettings, pnlPaymentSettings, pnlEmailSettings, pnlSeoSettings, pnlSecuritySettings, pnlPerformanceSettings, pnlSocialSettings };

            for (int i = 0; i < allTabs.Count; i++)
            {
                bool isActive = allTabs[i].CommandArgument == activeTab;
                allTabs[i].CssClass = "tab-button-settings px-3 py-3 text-xs sm:text-sm font-medium whitespace-nowrap" + (isActive ? " active text-primary border-primary" : " text-gray-500 hover:text-gray-700 hover:border-gray-300 border-transparent");
                if (allPanels[i] != null) allPanels[i].Visible = isActive;
            }
        }

        private void LoadSettingsData()
        {
            // TODO: Load settings from Database or Configuration file/class
            var settings = GetDummySettings(); // Replace with actual data loading

            // General Tab
            txtSiteName.Text = settings.SiteName;
            txtSiteTagline.Text = settings.SiteTagline;
            txtSiteDescription.Text = settings.SiteDescription;
            txtStoreAddress.Text = settings.StoreAddress;
            if (!string.IsNullOrEmpty(settings.LogoUrl)) { imgLogoPreview.ImageUrl = ResolveUrl(settings.LogoUrl); imgLogoPreview.Visible = true; }
            if (!string.IsNullOrEmpty(settings.FaviconUrl)) { imgFaviconPreview.ImageUrl = ResolveUrl(settings.FaviconUrl); imgFaviconPreview.Visible = true; }
            txtPrimaryColor.Text = settings.PrimaryColor;
            txtSecondaryColor.Text = settings.SecondaryColor;
            txtAccentColor.Text = settings.AccentColor;
            txtContactEmail.Text = settings.ContactEmail;
            txtContactPhone.Text = settings.ContactPhone;
            txtWorkingHours.Text = settings.WorkingHours;

            // Sales Tab
            ddlCurrency.SelectedValue = settings.Currency;
            txtCurrencySymbol.Text = settings.CurrencySymbol;
            txtDefaultTaxRate.Text = settings.DefaultTaxRate.ToString();
            txtFreeShippingThreshold.Text = settings.FreeShippingThreshold.ToString("F0");
            ddlProductsPerPage.SelectedValue = settings.ProductsPerPage.ToString();
            chkAutoUpdateStock.Checked = settings.AutoUpdateStock;
            chkAllowOrderOutOfStock.Checked = settings.AllowOrderOutOfStock;
            chkShowStockQuantity.Checked = settings.ShowStockQuantity;
            chkAllowReviews.Checked = settings.AllowReviews;
            // ... and other sales settings ...

            // Payment Tab
            chkEnableCOD.Checked = settings.EnableCOD;
            txtCODFeePercent.Text = settings.CODFeePercent.ToString();
            txtCODMinOrder.Text = settings.CODMinOrder.ToString("F0");
            chkEnableBankTransfer.Checked = settings.EnableBankTransfer;
            txtBankTransferInfo.Text = settings.BankTransferInfo;
            chkEnableMoMo.Checked = settings.EnableMoMo;
            txtMoMoPartnerCode.Text = settings.MoMoPartnerCode;
            txtMoMoAccessKey.Text = settings.MoMoAccessKey; // Consider not pre-filling passwords
            chkEnableZaloPay.Checked = settings.EnableZaloPay;
            txtZaloPayAppId.Text = settings.ZaloPayAppId;
            txtZaloPayKey1.Text = settings.ZaloPayKey1; // Consider not pre-filling passwords

            // Load other tabs data...
            LoadSystemStatus();
        }

        private void LoadSystemStatus()
        {
            // TODO: Implement real checks
            //lblSystemStatus.Text = "Hoạt động"; ((System.Web.UI.HtmlControls.HtmlGenericControl)lblSystemStatus.Parent.FindControl("status_indicator_system")).Attributes["class"] = "status-indicator-settings status-healthy-settings"; // Need to add ID to span in ASPX for this
            //lblDbStatus.Text = "Kết nối tốt";
            //lblDbPing.Text = "12ms";
            //lblCacheStatus.Text = "Cần tối ưu";
            //lblCacheHitRate.Text = "78%";
            //lblSslStatus.Text = "Active";
            //lblSslExpiry.Text = "Còn 89 ngày";
        }


        protected void btnSaveAllSettings_Click(object sender, EventArgs e)
        {
            // Validate all groups if needed, or rely on individual group validation when switching tabs
            // For a "Save All", it's better to validate everything or save tab by tab.

            // TODO: Create a WebsiteSettingsModel object from all form fields
            WebsiteSettingsModel settings = new WebsiteSettingsModel
            {
                SiteName = txtSiteName.Text,
                SiteTagline = txtSiteTagline.Text,
                // ... populate all other fields from all tabs ...
                Currency = ddlCurrency.SelectedValue,
                CurrencySymbol = txtCurrencySymbol.Text,
                DefaultTaxRate = decimal.Parse(txtDefaultTaxRate.Text),
                EnableCOD = chkEnableCOD.Checked,
                // ... etc.
            };

            // Handle Logo Upload
            if (fuLogo.HasFile)
            {
                try
                {
                    string fileName = Path.GetFileName(fuLogo.FileName);
                    string uploadFolder = Server.MapPath("~/Content/Uploads/Site/");
                    if (!Directory.Exists(uploadFolder)) Directory.CreateDirectory(uploadFolder);
                    fuLogo.SaveAs(Path.Combine(uploadFolder, fileName));
                    settings.LogoUrl = $"~/Content/Uploads/Site/{fileName}";
                }
                catch (Exception ex) { ShowAdminNotification("Lỗi tải logo: " + ex.Message, "error"); return; }
            }
            else if (!string.IsNullOrEmpty(imgLogoPreview.ImageUrl) && imgLogoPreview.Visible)
            {
                // Keep existing logo if no new one is uploaded
                settings.LogoUrl = imgLogoPreview.ImageUrl; // Or from a hidden field storing the path
            }

            // Handle Favicon Upload (similar to logo)
            if (fuFavicon.HasFile) { /* ... save favicon ... */ settings.FaviconUrl = "..."; }
            else if (!string.IsNullOrEmpty(imgFaviconPreview.ImageUrl) && imgFaviconPreview.Visible)
            {
                settings.FaviconUrl = imgFaviconPreview.ImageUrl;
            }


            // TODO: Save the 'settings' object to Database or Configuration file
            // SaveSettingsToDataSource(settings); 
            ShowAdminNotification("Thành công!", "Tất cả cài đặt đã được lưu.", "success");
        }

        protected void btnExportSettings_Click(object sender, EventArgs e)
        {
            // TODO: Collect current settings from form fields or DB
            var currentSettings = GetCurrentSettingsFromForm(); // Implement this
            string jsonSettings = SerializeToJson(currentSettings);

            Response.Clear();
            Response.ContentType = "application/json";
            Response.AddHeader("content-disposition", $"attachment; filename=ToyLand_Settings_{DateTime.Now:yyyyMMdd}.json");
            Response.Write(jsonSettings);
            Response.Flush(); Response.SuppressContent = true; Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnImportSettings_Click(object sender, EventArgs e)
        {
            pnlImportModal.Visible = true;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "OpenImportModal", "document.body.style.overflow = 'hidden'; setupModalClose();", true);
        }
        protected void btnCloseImportModal_Click(object sender, EventArgs e)
        {
            pnlImportModal.Visible = false;
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "CloseImportModal", "document.body.style.overflow = 'auto';", true);
        }
        protected void btnConfirmImport_Click(object sender, EventArgs e)
        {
            if (fuImportSettingsFile.HasFile)
            {
                if (fuImportSettingsFile.PostedFile.ContentType == "application/json" || fuImportSettingsFile.PostedFile.ContentType == "text/plain") // Some browsers might send json as text/plain
                {
                    try
                    {
                        using (StreamReader reader = new StreamReader(fuImportSettingsFile.PostedFile.InputStream))
                        {
                            string jsonContent = reader.ReadToEnd();
                            // TODO: Deserialize jsonContent into WebsiteSettingsModel
                            // var importedSettings = DeserializeFromJson<WebsiteSettingsModel>(jsonContent);
                            // TODO: Apply importedSettings to form fields or save directly
                            // PopulateFormWithSettings(importedSettings); // Method to update all textboxes, dropdowns etc.
                            ShowAdminNotification("Thành công!", "Cấu hình đã được nhập. Vui lòng xem lại và Lưu tất cả.", "success");
                        }
                    }
                    catch (Exception ex) { lblImportError.Text = "Lỗi đọc file: " + ex.Message; lblImportError.Visible = true; }
                }
                else { lblImportError.Text = "Chỉ chấp nhận file .json."; lblImportError.Visible = true; }
            }
            else { lblImportError.Text = "Vui lòng chọn một file."; lblImportError.Visible = true; }

            pnlImportModal.Visible = true; // Keep modal open to show error or if user needs to re-select
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "KeepImportModal", "document.body.style.overflow = 'hidden'; setupModalClose();", true);

        }

        // Placeholder for methods to interact with actual settings storage
        private WebsiteSettingsModel GetCurrentSettingsFromForm() { /* Collect all values from ASP.NET controls */ return new WebsiteSettingsModel(); }


        // Other button click handlers (Test Email, Generate Sitemap, Clear Cache, etc.)
        // These would typically call respective service methods or business logic.
        // Example: protected void btnTestEmail_Click(object sender, EventArgs e) { /* ... call email test logic ... */ }

        private void ShowAdminNotification(string title, string message, string type = "success")
        {
            // ScriptManager.RegisterStartupScript(this.upnlSettingsPage, this.GetType(), Guid.NewGuid().ToString(), $"showNotification('{title}', '{message.Replace("'", "\\\'")}', '{type}');", true);
            // For the panel-based notification:
            pnlAdminNotification.Visible = true;
            lblNotificationTitle.Text = title;
            lblNotificationMessage.Text = message;
            string iconClass = "fas text-xl mr-3 ";
            string borderClass = "border-l-4 ";
            switch (type)
            {
                case "success": iconClass += "fa-check-circle text-green-500"; borderClass += "border-green-500"; break;
                case "error": iconClass += "fa-times-circle text-red-500"; borderClass += "border-red-500"; break;
                case "warning": iconClass += "fa-exclamation-triangle text-yellow-500"; borderClass += "border-yellow-500"; break;
                default: iconClass += "fa-info-circle text-blue-500"; borderClass += "border-blue-500"; break;
            }
            litNotificationIcon.Text = $"<i class='{iconClass}'></i>";
            pnlAdminNotification.CssClass = $"notification-settings fixed bottom-5 right-5 bg-white shadow-lg rounded-lg p-4 min-w-[280px] z-[100] {borderClass} transform transition-transform duration-300 show"; // Add show class
            ScriptManager.RegisterStartupScript(this.upnlSettingsPage, this.GetType(), "ShowNotificationScript", "setTimeout(function() { document.getElementById('" + pnlAdminNotification.ClientID + "').classList.remove('show'); setTimeout(function() { document.getElementById('" + pnlAdminNotification.ClientID + "').style.display = 'none';}, 300); }, 5000);", true);


        }
        protected void btnCloseNotification_Click(object sender, EventArgs e)
        {
            pnlAdminNotification.Visible = false;
        }


        private string SerializeToJson(object obj) => new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(obj);
        // T Deserializer(string json) => new System.Web.Script.Serialization.JavaScriptSerializer().Deserialize<T>(json);

        #region Dummy Data
        private WebsiteSettingsModel GetDummySettings()
        {
            return new WebsiteSettingsModel
            {
                SiteName = "ToyLand - Đồ Chơi Vui Vẻ",
                SiteTagline = "Khơi nguồn sáng tạo cho bé",
                SiteDescription = "ToyLand chuyên cung cấp đồ chơi an toàn, chất lượng cao, giúp bé phát triển toàn diện. Mua sắm trực tuyến dễ dàng, giao hàng nhanh chóng.",
                StoreAddress = "123 Đường Vui Chơi, Phường Bé Ngoan, Quận Trẻ Em, TP. Ước Mơ",
                LogoUrl = "https://api.placeholder.com/200x80/FF6B6B/FFFFFF?text=ToyLand",
                FaviconUrl = "https://api.placeholder.com/32x32/4ECDC4/FFFFFF?text=T",
                PrimaryColor = "#FF6B6B",
                SecondaryColor = "#4ECDC4",
                AccentColor = "#FFE66D",
                ContactEmail = "hotro@toyland.vn",
                ContactPhone = "1900 1234",
                WorkingHours = "8:00 - 21:00 (T2-CN)",
                Currency = "VND",
                CurrencySymbol = "đ",
                DefaultTaxRate = 10,
                FreeShippingThreshold = 300000,
                ProductsPerPage = 12,
                AutoUpdateStock = true,
                AllowOrderOutOfStock = false,
                ShowStockQuantity = true,
                AllowReviews = true,
                AllowProductComparison = true,
                MaxComparisonItems = 4,
                EnableCOD = true,
                CODFeePercent = 0,
                CODMinOrder = 0,
                EnableBankTransfer = true,
                BankTransferInfo = "Ngân hàng Á Châu (ACB)\nSTK: 9876543210\nChủ TK: CTY TNHH TOYLAND VN",
                EnableMoMo = false,
                EnableZaloPay = true,
                ZaloPayAppId = "ZP123456",
                SmtpHost = "smtp.example.com"
                // ... other dummy settings for other tabs ...
            };
        }
        #endregion
    }
}