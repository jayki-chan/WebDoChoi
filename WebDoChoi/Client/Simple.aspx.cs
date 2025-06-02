using System;
using System.Web.UI;
using WebDoChoi.Business;

namespace WebDoChoi.Client
{
    public partial class Simple : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblResult.Text = "Page loaded successfully at " + DateTime.Now.ToString();
            }
        }

        protected void btnTest_Click(object sender, EventArgs e)
        {
            try
            {
                lblResult.Text = "Button clicked successfully at " + DateTime.Now.ToString();
                lblResult.Text += "<br/>PostBack working correctly!";
            }
            catch (Exception ex)
            {
                lblResult.Text = "Button click error: " + ex.Message;
            }
        }

        protected void btnTestDB_Click(object sender, EventArgs e)
        {
            try
            {
                lblResult.Text = "Testing database connection...<br/>";

                // Test 1: Check if class exists
                lblResult.Text += "UserService class: OK<br/>";

                // Test 2: Test connection
                bool isConnected = UserService.TestDatabaseConnection();
                lblResult.Text += "Database connected: " + isConnected + "<br/>";

                if (isConnected)
                {
                    lblResult.Text += "✅ Database connection successful!";
                }
                else
                {
                    lblResult.Text += "❌ Database connection failed!";
                }
            }
            catch (Exception ex)
            {
                lblResult.Text = "Database test error: " + ex.Message + "<br/>";
                lblResult.Text += "Stack trace: " + ex.StackTrace;
            }
        }
    }
}