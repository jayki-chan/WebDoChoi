using System;
using System.Web.UI;

namespace WebsiteDoChoi.Admin
{
    public partial class AdminMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // TODO: Check if admin is logged in. If not, redirect to login page.
                // Example: if (Session["AdminUser"] == null) { Response.Redirect("~/Admin/Login.aspx"); }

                // Populate dynamic data for master page if any (e.g., admin name, notification counts)
                // lblAdminName.Text = Session["AdminUser"]?.ToString() ?? "Admin"; 
                // litCurrentYear.Text = DateTime.Now.Year.ToString();
                // LoadNotificationCounts(); // Method to get counts from DB
            }
        }

        protected void lnkAdminLogout_Click(object sender, EventArgs e)
        {
            // TODO: Implement logout logic
            // Session.Clear();
            // Session.Abandon();
            // Response.Redirect("~/Admin/Login.aspx"); // Redirect to admin login page
        }

        // private void LoadNotificationCounts() {
        //    litProductCount.Text = $"<span class='ml-auto bg-primary text-white rounded-full px-2 py-1 text-xs'>{GetProductCount()}</span>";
        //    litOrderCount.Text = $"<span class='ml-auto bg-secondary text-white rounded-full px-2 py-1 text-xs'>{GetNewOrderCount()}</span>";
        //    litNotificationCount.Text = $"<span class='absolute -top-1 -right-1 bg-primary text-white rounded-full w-4 h-4 md:w-5 md:h-5 flex items-center justify-center text-xs'>{GetUnreadNotificationCount()}</span>";
        //    litMessageCount.Text = $"<span class='absolute -top-1 -right-1 bg-secondary text-white rounded-full w-4 h-4 md:w-5 md:h-5 flex items-center justify-center text-xs'>{GetUnreadMessageCount()}</span>";
        // }
        // Implement Get...Count() methods to fetch from DB
    }
}