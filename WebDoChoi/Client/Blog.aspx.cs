using System;
using System.Collections.Generic;
using System.Data; // For DataTable if used for dummy data
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebsiteDoChoi.Client
{
    public class BlogPostSummary
    {
        public int PostId { get; set; }
        public string Title { get; set; }
        public string Excerpt { get; set; }
        public string ImageUrl { get; set; }
        public DateTime DatePublished { get; set; }
        public string Author { get; set; }
        public int ViewCount { get; set; }
        public int CommentCount { get; set; }
        public string PostUrl { get; set; } // e.g., "/Client/BlogDetails.aspx?id=" + PostId
        public List<BlogTag> Tags { get; set; }
    }

    public class BlogTag
    {
        public string TagName { get; set; }
        public string TagUrl { get; set; } // e.g., "/Client/Blog.aspx?tag=" + TagName
        public string TagCssClass { get; set; } // For styling based on tag, e.g. "bg-primary bg-opacity-20 text-primary"
    }

    public class BlogCategory
    {
        public string CategoryName { get; set; }
        public string CategoryUrl { get; set; } // e.g., "/Client/Blog.aspx?category=" + CategoryName
        public int PostCount { get; set; }
        public string CategoryIconCss { get; set; }
    }

    public class PaginationLink
    {
        public string PageNumber { get; set; }
        public bool IsCurrentPage { get; set; }
    }


    public partial class Blog : System.Web.UI.Page
    {
        private const int PageSize = 6; // Number of posts per page

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadBlogData();
                LoadSidebarData();
            }
        }

        private void LoadBlogData(int currentPage = 1, string searchTerm = null, string category = null, string tag = null)
        {
            // In a real app, fetch from database based on currentPage, searchTerm, category, tag
            List<BlogPostSummary> allPosts = GetDummyBlogPosts();

            // --- Filtering (Example) ---
            if (!string.IsNullOrEmpty(searchTerm))
            {
                allPosts = allPosts.Where(p => p.Title.ToLower().Contains(searchTerm.ToLower()) || p.Excerpt.ToLower().Contains(searchTerm.ToLower())).ToList();
            }
            if (!string.IsNullOrEmpty(category))
            {
                // Assuming BlogTag can also represent category for simplicity here
                allPosts = allPosts.Where(p => p.Tags.Any(t => t.TagName.Equals(category, StringComparison.OrdinalIgnoreCase))).ToList();
            }
            if (!string.IsNullOrEmpty(tag))
            {
                allPosts = allPosts.Where(p => p.Tags.Any(t => t.TagName.Equals(tag, StringComparison.OrdinalIgnoreCase))).ToList();
            }


            // --- Featured Post (Example: first post) ---
            if (allPosts.Any() && currentPage == 1 && string.IsNullOrEmpty(searchTerm) && string.IsNullOrEmpty(category) && string.IsNullOrEmpty(tag)) // Show featured only on first page, no filter
            {
                var featured = allPosts.First();
                pnlFeaturedPost.Visible = true;
                imgFeaturedPost.ImageUrl = featured.ImageUrl;
                imgFeaturedPost.AlternateText = featured.Title;
                litFeaturedPostDate.Text = featured.DatePublished.ToString("dd/MM/yyyy");
                litFeaturedPostAuthor.Text = featured.Author;
                litFeaturedPostViews.Text = $"{featured.ViewCount:N0} lượt xem";
                hlFeaturedPostTitle.Text = featured.Title;
                hlFeaturedPostTitle.NavigateUrl = featured.PostUrl;
                litFeaturedPostExcerpt.Text = TruncateString(featured.Excerpt, 200) + "...";
                hlFeaturedPostReadMore.NavigateUrl = featured.PostUrl;
                rptFeaturedPostTags.DataSource = featured.Tags;
                rptFeaturedPostTags.DataBind();

                // Exclude featured post from the main grid if it's shown
                var gridPosts = allPosts.Skip(1).ToList();
                BindPostsWithPagination(gridPosts, currentPage);
            }
            else
            {
                pnlFeaturedPost.Visible = false;
                BindPostsWithPagination(allPosts, currentPage);
            }
        }

        private void BindPostsWithPagination(List<BlogPostSummary> posts, int currentPage)
        {
            int totalPosts = posts.Count;
            pnlNoPosts.Visible = totalPosts == 0;
            rptBlogPosts.Visible = totalPosts > 0;

            var pagedPosts = posts.Skip((currentPage - 1) * PageSize).Take(PageSize).ToList();
            rptBlogPosts.DataSource = pagedPosts;
            rptBlogPosts.DataBind();

            SetupPagination(totalPosts, currentPage);
        }


        private void SetupPagination(int totalItems, int currentPage)
        {
            int totalPages = (int)Math.Ceiling((double)totalItems / PageSize);
            lnkPrevPage.Enabled = currentPage > 1;
            lnkNextPage.Enabled = currentPage < totalPages;

            if (totalPages <= 1)
            {
                rptPagination.Visible = false;
                lnkPrevPage.Visible = false;
                lnkNextPage.Visible = false;
                return;
            }
            rptPagination.Visible = true;
            lnkPrevPage.Visible = true;
            lnkNextPage.Visible = true;

            var pageNumbers = new List<PaginationLink>();
            for (int i = 1; i <= totalPages; i++)
            {
                pageNumbers.Add(new PaginationLink { PageNumber = i.ToString(), IsCurrentPage = (i == currentPage) });
            }
            rptPagination.DataSource = pageNumbers;
            rptPagination.DataBind();
        }

        protected void lnkPage_Click(object sender, EventArgs e)
        {
            string commandArg = ((LinkButton)sender).CommandArgument;
            int currentPage = Convert.ToInt32(ViewState["CurrentPage"] ?? 1);

            if (commandArg == "Prev") { currentPage--; }
            else if (commandArg == "Next") { currentPage++; }
            else { currentPage = Convert.ToInt32(commandArg); }

            ViewState["CurrentPage"] = currentPage;
            LoadBlogData(currentPage, ViewState["SearchTerm"]?.ToString(), ViewState["CategoryFilter"]?.ToString(), ViewState["TagFilter"]?.ToString());
        }

        protected void rptPagination_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Page")
            {
                int currentPage = Convert.ToInt32(e.CommandArgument);
                ViewState["CurrentPage"] = currentPage;
                LoadBlogData(currentPage, ViewState["SearchTerm"]?.ToString(), ViewState["CategoryFilter"]?.ToString(), ViewState["TagFilter"]?.ToString());
            }
        }


        private void LoadSidebarData()
        {
            // Categories
            rptCategories.DataSource = GetDummyCategories();
            rptCategories.DataBind();

            // Popular Posts
            rptPopularPosts.DataSource = GetDummyBlogPosts().OrderByDescending(p => p.ViewCount).Take(3).ToList();
            rptPopularPosts.DataBind();

            // Tags
            rptTags.DataSource = GetDummyTags();
            rptTags.DataBind();
        }

        protected void btnSearchBlog_Click(object sender, EventArgs e)
        {
            string searchTerm = txtSearchBlog.Text.Trim();
            ViewState["SearchTerm"] = searchTerm;
            ViewState["CurrentPage"] = 1; // Reset to first page for new search
            ViewState["CategoryFilter"] = null; // Clear other filters
            ViewState["TagFilter"] = null;
            LoadBlogData(1, searchTerm);
        }

        protected void btnNewsletterSubscribe_Click(object sender, EventArgs e)
        {
            string email = txtNewsletterEmail.Text.Trim();
            if (!string.IsNullOrWhiteSpace(email) && IsValidEmail(email))
            {
                // TODO: Add logic to save email to database/mailing list
                lblNewsletterMessage.Text = "Cảm ơn bạn đã đăng ký!";
                lblNewsletterMessage.CssClass = "text-xs mt-2 block text-green-200"; // Success
                txtNewsletterEmail.Text = "";
            }
            else
            {
                lblNewsletterMessage.Text = "Vui lòng nhập email hợp lệ.";
                lblNewsletterMessage.CssClass = "text-xs mt-2 block text-yellow-300"; // Error
            }
        }

        // Helper function to validate email (basic)
        private bool IsValidEmail(string email)
        {
            try
            {
                var addr = new System.Net.Mail.MailAddress(email);
                return addr.Address == email;
            }
            catch
            {
                return false;
            }
        }

        public static string TruncateString(string value, int maxLength)
        {
            if (string.IsNullOrEmpty(value)) return value;
            return value.Length <= maxLength ? value : value.Substring(0, maxLength);
        }


        #region Dummy Data Generators (Replace with actual data access)
        private List<BlogPostSummary> GetDummyBlogPosts()
        {
            var posts = new List<BlogPostSummary>();
            var allTags = GetDummyTags();

            posts.Add(new BlogPostSummary
            {
                PostId = 1,
                Title = "7 Lợi ích tuyệt vời của đồ chơi giáo dục cho sự phát triển của trẻ",
                Excerpt = "Đồ chơi giáo dục không chỉ mang lại niềm vui cho trẻ mà còn có vai trò quan trọng trong việc phát triển trí tuệ, kỹ năng vận động và khả năng sáng tạo.",
                ImageUrl = "https://api.placeholder.com/800/400?text=FeaturedPost",
                DatePublished = DateTime.Parse("2025-05-22"),
                Author = "Admin ToyLand",
                ViewCount = 1245,
                CommentCount = 22,
                PostUrl = "/Client/BlogDetails.aspx?id=1",
                Tags = new List<BlogTag> { allTags[0], allTags[2] } // Giáo dục, Phát triển trí tuệ
            });
            for (int i = 2; i <= 25; i++)
            {
                posts.Add(new BlogPostSummary
                {
                    PostId = i,
                    Title = $"Cách chọn đồ chơi an toàn cho trẻ {(i % 3) + 1}-{(i % 3) + 4} tuổi",
                    Excerpt = $"Hướng dẫn chi tiết cách lựa chọn đồ chơi phù hợp và an toàn cho trẻ nhỏ {i}, tránh những nguy cơ tiềm ẩn...",
                    ImageUrl = $"https://api.placeholder.com/400/250?text=Blog{i}",
                    DatePublished = DateTime.Now.AddDays(-i * 2),
                    Author = "Người viết " + (i % 5 + 1),
                    ViewCount = 150 + i * 12,
                    CommentCount = 5 + i,
                    PostUrl = $"/Client/BlogDetails.aspx?id={i}",
                    Tags = new List<BlogTag> { allTags[i % allTags.Count], allTags[(i + 1) % allTags.Count] }
                });
            }
            return posts.OrderByDescending(p => p.DatePublished).ToList();
        }

        private List<BlogCategory> GetDummyCategories()
        {
            return new List<BlogCategory>
            {
                new BlogCategory { CategoryName = "Giáo dục", CategoryUrl = "/Client/Blog.aspx?category=Giáo dục", PostCount = 12, CategoryIconCss="fas fa-graduation-cap text-secondary" },
                new BlogCategory { CategoryName = "An toàn", CategoryUrl = "/Client/Blog.aspx?category=An toàn", PostCount = 8, CategoryIconCss="fas fa-shield-alt text-primary" },
                new BlogCategory { CategoryName = "STEM", CategoryUrl = "/Client/Blog.aspx?category=STEM", PostCount = 15, CategoryIconCss="fas fa-cogs text-accent" },
                new BlogCategory { CategoryName = "DIY", CategoryUrl = "/Client/Blog.aspx?category=DIY", PostCount = 6, CategoryIconCss="fas fa-tools text-green-600" },
                new BlogCategory { CategoryName = "Vận động", CategoryUrl = "/Client/Blog.aspx?category=Vận động", PostCount = 9, CategoryIconCss="fas fa-running text-blue-600" },
                new BlogCategory { CategoryName = "Công nghệ", CategoryUrl = "/Client/Blog.aspx?category=Công nghệ", PostCount = 4, CategoryIconCss="fas fa-microchip text-purple-600" }
            };
        }
        private List<BlogTag> GetDummyTags()
        {
            return new List<BlogTag>
            {
                new BlogTag { TagName = "Đồ chơi gỗ", TagUrl = "/Client/Blog.aspx?tag=Đồ chơi gỗ", TagCssClass="bg-primary bg-opacity-20 text-primary hover:bg-primary" },
                new BlogTag { TagName = "STEM", TagUrl = "/Client/Blog.aspx?tag=STEM", TagCssClass="bg-secondary bg-opacity-20 text-secondary hover:bg-secondary" },
                new BlogTag { TagName = "Phát triển trí tuệ", TagUrl = "/Client/Blog.aspx?tag=Phát triển trí tuệ", TagCssClass="bg-accent bg-opacity-20 text-yellow-600 hover:bg-accent" },
                new BlogTag { TagName = "An toàn", TagUrl = "/Client/Blog.aspx?tag=An toàn", TagCssClass="bg-green-100 text-green-600 hover:bg-green-500" },
                new BlogTag { TagName = "Sáng tạo", TagUrl = "/Client/Blog.aspx?tag=Sáng tạo", TagCssClass="bg-blue-100 text-blue-600 hover:bg-blue-500" },
                new BlogTag { TagName = "Robot", TagUrl = "/Client/Blog.aspx?tag=Robot", TagCssClass="bg-purple-100 text-purple-600 hover:bg-purple-500" },
                new BlogTag { TagName = "Bé gái", TagUrl = "/Client/Blog.aspx?tag=Bé gái", TagCssClass="bg-pink-100 text-pink-600 hover:bg-pink-500" },
                new BlogTag { TagName = "Lego", TagUrl = "/Client/Blog.aspx?tag=Lego", TagCssClass="bg-indigo-100 text-indigo-600 hover:bg-indigo-500" }
            };
        }
        #endregion
    }
}