using System;
using System.Collections.Generic;
using System.Data; // For DataTable or if you use it
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions; // For reading time calculation

namespace WebsiteDoChoi.Client
{
    // Define classes for data structure (can be in a separate Models folder)
    public class BlogPostDetailModel : BlogPostSummary // Inherit or compose
    {
        public string FullContentHtml { get; set; }
        public AuthorInfo AuthorDetails { get; set; }
        public List<CommentModel> Comments { get; set; }
        public List<BlogPostSummary> RelatedPosts { get; set; }
        public string CategoryName { get; set; } // For breadcrumb
        public string CategoryUrl { get; set; }  // For breadcrumb
        public int ReadingTimeMinutes { get; set; }
        public bool IsLikedByCurrentUser { get; set; } // For like button state
        public int LikeCount { get; set; }
        public bool IsSavedByCurrentUser { get; set; } // For save button state
    }

    public class AuthorInfo
    {
        public string Name { get; set; }
        public string Title { get; set; }
        public string Bio { get; set; }
        public string AvatarUrl { get; set; }
        public string FacebookUrl { get; set; }
        public string TwitterUrl { get; set; }
        public string InstagramUrl { get; set; }
        public string EmailAddress { get; set; }
    }

    public class CommentModel
    {
        public int CommentId { get; set; }
        public string AuthorName { get; set; }
        public string AvatarUrl { get; set; }
        public DateTime CommentDate { get; set; }
        public string Content { get; set; }
        public bool IsAuthor { get; set; } // Is this comment by the post author?
        public int LikeCount { get; set; }
        public bool IsLikedByCurrentUser { get; set; }
        public int ParentCommentId { get; set; } // For replies
        public List<CommentModel> Replies { get; set; }
    }


    public partial class BlogDetails : System.Web.UI.Page
    {
        protected BlogPostDetailModel CurrentPost { get; set; } // Property to hold current post data

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (int.TryParse(Request.QueryString["id"], out int postId))
                {
                    LoadPostDetails(postId);
                    LoadSidebarData(); // Load sidebar widgets like categories, popular posts
                }
                else
                {
                    ShowPostNotFoundError();
                }
            }
            // Re-bind comments if a new comment was added, to include it
            if (ViewState["CommentAdded"] != null && (bool)ViewState["CommentAdded"])
            {
                if (CurrentPost != null) LoadComments(CurrentPost.PostId); // Reload comments for the current post
                ViewState["CommentAdded"] = false; // Reset flag
            }
        }

        private void LoadPostDetails(int postId)
        {
            // TODO: Replace with actual database call
            CurrentPost = GetDummyPostDetails(postId);

            if (CurrentPost == null)
            {
                ShowPostNotFoundError();
                return;
            }

            pnlPostContentArea.Visible = true;
            pnlPostNotFound.Visible = false;

            // Set Page Title Dynamically
            this.Title = CurrentPost.Title + " - ToyLand Blog";

            // Breadcrumbs
            litBreadcrumbPostTitle.Text = TruncateString(CurrentPost.Title, 50); // Truncate if too long for breadcrumb
            if (!string.IsNullOrEmpty(CurrentPost.CategoryName))
            {
                pnlBreadcrumbCategory.Visible = true;
                lnkBreadcrumbCategory.Text = CurrentPost.CategoryName;
                lnkBreadcrumbCategory.NavigateUrl = CurrentPost.CategoryUrl;
            }

            // Article Header
            imgPostHeader.ImageUrl = string.IsNullOrEmpty(CurrentPost.ImageUrl) ? "https://api.placeholder.com/800/400?text=ToyLand" : CurrentPost.ImageUrl;
            imgPostHeader.AlternateText = CurrentPost.Title;
            hlPostCategoryTag.Text = CurrentPost.CategoryName;
            hlPostCategoryTag.NavigateUrl = CurrentPost.CategoryUrl;

            // Meta
            litPostDate.Text = CurrentPost.DatePublished.ToString("dd/MM/yyyy");
            litPostAuthor.Text = CurrentPost.AuthorDetails?.Name ?? "Admin";
            litPostViews.Text = CurrentPost.ViewCount.ToString("N0");
            litPostCommentCount.Text = CurrentPost.Comments?.Count.ToString() ?? "0"; // Update this after loading comments
            litPostReadingTime.Text = CalculateReadingTime(CurrentPost.FullContentHtml).ToString();


            // Title
            litPostTitle.Text = CurrentPost.Title;

            // Social Share (URLs are dynamic based on current page)
            string currentPageUrl = Request.Url.AbsoluteUri;
            string encodedUrl = Server.UrlEncode(currentPageUrl);
            string encodedTitle = Server.UrlEncode(CurrentPost.Title);
            hlShareFacebook.NavigateUrl = $"https://www.facebook.com/sharer/sharer.php?u={encodedUrl}";
            hlShareTwitter.NavigateUrl = $"https://twitter.com/intent/tweet?url={encodedUrl}&text={encodedTitle}";
            hlShareWhatsapp.NavigateUrl = $"https://wa.me/?text={encodedTitle}%20{encodedUrl}";
            hlSharePinterest.NavigateUrl = $"https://pinterest.com/pin/create/button/?url={encodedUrl}&media={Server.UrlEncode(imgPostHeader.ImageUrl)}&description={encodedTitle}";
            // btnCopyLink will use client-side script

            // Like & Save Buttons state
            UpdateLikeButtonUI(CurrentPost.IsLikedByCurrentUser, CurrentPost.LikeCount);
            UpdateSaveButtonUI(CurrentPost.IsSavedByCurrentUser);


            // Article Content
            litPostContent.Text = CurrentPost.FullContentHtml; // Assuming this is safe HTML from your CMS/DB

            // Tags
            rptPostTags.DataSource = CurrentPost.Tags;
            rptPostTags.DataBind();

            // Author Info
            if (CurrentPost.AuthorDetails != null)
            {
                pnlAuthorInfo.Visible = true;
                imgAuthorAvatar.ImageUrl = string.IsNullOrEmpty(CurrentPost.AuthorDetails.AvatarUrl) ? "https://api.placeholder.com/80/80?text=Author" : CurrentPost.AuthorDetails.AvatarUrl;
                litAuthorName.Text = CurrentPost.AuthorDetails.Name;
                litAuthorTitle.Text = CurrentPost.AuthorDetails.Title;
                litAuthorBio.Text = CurrentPost.AuthorDetails.Bio;

                hlAuthorFacebook.Visible = !string.IsNullOrEmpty(CurrentPost.AuthorDetails.FacebookUrl);
                hlAuthorFacebook.NavigateUrl = CurrentPost.AuthorDetails.FacebookUrl;
                hlAuthorTwitter.Visible = !string.IsNullOrEmpty(CurrentPost.AuthorDetails.TwitterUrl);
                hlAuthorTwitter.NavigateUrl = CurrentPost.AuthorDetails.TwitterUrl;
                hlAuthorInstagram.Visible = !string.IsNullOrEmpty(CurrentPost.AuthorDetails.InstagramUrl);
                hlAuthorInstagram.NavigateUrl = CurrentPost.AuthorDetails.InstagramUrl;
                hlAuthorEmail.Visible = !string.IsNullOrEmpty(CurrentPost.AuthorDetails.EmailAddress);
                hlAuthorEmail.NavigateUrl = "mailto:" + CurrentPost.AuthorDetails.EmailAddress;
            }

            // Related Posts
            if (CurrentPost.RelatedPosts != null && CurrentPost.RelatedPosts.Any())
            {
                pnlRelatedPosts.Visible = true;
                rptRelatedPosts.DataSource = CurrentPost.RelatedPosts;
                rptRelatedPosts.DataBind();
            }

            // Comments
            LoadComments(postId);
        }

        private void LoadComments(int postId)
        {
            // TODO: Fetch actual comments for postId
            List<CommentModel> comments = CurrentPost?.Comments ?? GetDummyComments(postId); // Use CurrentPost.Comments if already loaded
            litCommentSectionCount.Text = comments.Count.ToString();
            rptComments.DataSource = comments;
            rptComments.DataBind();
            pnlNoComments.Visible = !comments.Any();
            btnLoadMoreComments.Visible = comments.Count > 5; // Example: Show if more than 5 comments
        }

        private void UpdateLikeButtonUI(bool isLiked, int likeCount)
        {
            lblLikeCount.Text = likeCount.ToString();
            if (isLiked)
            {
                iconLikePost.Attributes["class"] = "fas fa-heart mr-1 text-red-500"; // Liked state
            }
            else
            {
                iconLikePost.Attributes["class"] = "far fa-heart mr-1"; // Default state
            }
        }

        private void UpdateSaveButtonUI(bool isSaved)
        {
            if (isSaved)
            {
                iconSavePost.Attributes["class"] = "fas fa-bookmark mr-1 text-primary"; // Saved state
            }
            else
            {
                iconSavePost.Attributes["class"] = "far fa-bookmark mr-1"; // Default state
            }
        }

        protected void btnLikePost_Click(object sender, EventArgs e)
        {
            if (CurrentPost == null) return;
            // TODO: Implement actual like/unlike logic (update database)
            CurrentPost.IsLikedByCurrentUser = !CurrentPost.IsLikedByCurrentUser;
            if (CurrentPost.IsLikedByCurrentUser) CurrentPost.LikeCount++;
            else CurrentPost.LikeCount--;

            UpdateLikeButtonUI(CurrentPost.IsLikedByCurrentUser, CurrentPost.LikeCount);
            // Persist this change to your data source
        }

        protected void btnSavePost_Click(object sender, EventArgs e)
        {
            if (CurrentPost == null) return;
            // TODO: Implement actual save/unsave logic (update database)
            CurrentPost.IsSavedByCurrentUser = !CurrentPost.IsSavedByCurrentUser;
            UpdateSaveButtonUI(CurrentPost.IsSavedByCurrentUser);
            // Persist this change
        }


        private void ShowPostNotFoundError()
        {
            pnlPostContentArea.Visible = false;
            pnlPostNotFound.Visible = true;
            this.Title = "Không tìm thấy bài viết - ToyLand Blog";
        }

        protected void btnSubmitComment_Click(object sender, EventArgs e)
        {
            Page.Validate("Comment");
            if (Page.IsValid)
            {
                if (int.TryParse(Request.QueryString["id"], out int postId))
                {
                    // TODO: Save comment to database
                    string name = txtCommentName.Text.Trim();
                    string email = txtCommentEmail.Text.Trim();
                    string content = txtCommentContent.Text.Trim();
                    // bool saveInfo = chkSaveCommentInfo.Checked; (handle cookie/session for this)

                    // AddCommentToDatabase(postId, name, email, content);

                    litCommentStatus.Text = "<div class='text-green-600 p-3 bg-green-50 rounded-md my-4'>Bình luận của bạn đã được gửi và đang chờ duyệt.</div>";
                    txtCommentName.Text = "";
                    txtCommentEmail.Text = "";
                    txtCommentContent.Text = "";
                    chkSaveCommentInfo.Checked = false;

                    ViewState["CommentAdded"] = true; // Set flag to reload comments on next load
                    // Re-fetch and re-bind comments to show the new one (or the pending message)
                    LoadComments(postId);
                }
                else
                {
                    litCommentStatus.Text = "<div class='text-red-600 p-3 bg-red-50 rounded-md my-4'>Lỗi: Không tìm thấy bài viết để bình luận.</div>";
                }
            }
        }

        protected void rptComments_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int commentId = Convert.ToInt32(e.CommandArgument);
            if (e.CommandName == "Like")
            {
                // TODO: Handle comment like logic
                // Find comment in CurrentPost.Comments, update its like status/count
                // Rebind rptComments or use UpdatePanel
                var comment = FindCommentRecursive(CurrentPost.Comments, commentId);
                if (comment != null)
                {
                    comment.IsLikedByCurrentUser = !comment.IsLikedByCurrentUser;
                    if (comment.IsLikedByCurrentUser) comment.LikeCount++; else comment.LikeCount--;
                    // Update your data source here
                    LoadComments(CurrentPost.PostId); // Rebind to reflect changes
                }
            }
            else if (e.CommandName == "Reply")
            {
                // TODO: Handle reply logic (e.g., show a reply form)
            }
        }

        private CommentModel FindCommentRecursive(List<CommentModel> comments, int commentId)
        {
            if (comments == null) return null;
            foreach (var comment in comments)
            {
                if (comment.CommentId == commentId) return comment;
                var foundInReply = FindCommentRecursive(comment.Replies, commentId);
                if (foundInReply != null) return foundInReply;
            }
            return null;
        }


        protected void btnLoadMoreComments_Click(object sender, EventArgs e)
        {
            // TODO: Implement logic to load more comments (pagination for comments)
        }

        private void LoadSidebarData()
        {
            // This data might be similar to Blog.aspx sidebar or specific to context
            rptCategoriesSidebar.DataSource = GetDummyCategories(); // Use the one from Blog.aspx.cs or similar
            rptCategoriesSidebar.DataBind();

            rptPopularPostsSidebar.DataSource = GetDummyBlogPosts().OrderByDescending(p => p.ViewCount).Take(3).ToList(); // From Blog.aspx.cs or similar
            rptPopularPostsSidebar.DataBind();

            pnlTableOfContents.Visible = true; // Or based on whether post content is loaded and headings exist
        }

        protected void btnNewsletterSubscribe_Click(object sender, EventArgs e)
        {
            string email = txtNewsletterEmailSidebar.Text.Trim();
            if (!string.IsNullOrWhiteSpace(email) && IsValidEmail(email))
            {
                lblNewsletterMessageSidebar.Text = "Cảm ơn bạn đã đăng ký!";
                lblNewsletterMessageSidebar.CssClass = "text-xs mt-2 block text-green-200";
                txtNewsletterEmailSidebar.Text = "";
            }
            else
            {
                lblNewsletterMessageSidebar.Text = "Vui lòng nhập email hợp lệ.";
                lblNewsletterMessageSidebar.CssClass = "text-xs mt-2 block text-yellow-300";
            }
        }
        private bool IsValidEmail(string email)
        {
            try { var addr = new System.Net.Mail.MailAddress(email); return addr.Address == email; }
            catch { return false; }
        }
        private static int CalculateReadingTime(string text, int wordsPerMinute = 200)
        {
            if (string.IsNullOrWhiteSpace(text)) return 0;
            string plainText = Regex.Replace(text, "<.*?>", string.Empty); // Strip HTML tags
            int wordCount = plainText.Split(new[] { ' ', '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries).Length;
            return (int)Math.Ceiling((double)wordCount / wordsPerMinute);
        }

        public static string TruncateString(string value, int maxLength)
        {
            if (string.IsNullOrEmpty(value)) return value;
            return value.Length <= maxLength ? value : value.Substring(0, maxLength) + "...";
        }


        #region Dummy Data Generators (Replace with actual data access from your DB)

        private BlogPostDetailModel GetDummyPostDetails(int postId)
        {
            // Find the post summary from the list (simulating a DB lookup)
            var postSummary = GetDummyBlogPosts().FirstOrDefault(p => p.PostId == postId);
            if (postSummary == null) return null;

            return new BlogPostDetailModel
            {
                PostId = postSummary.PostId,
                Title = postSummary.Title,
                Excerpt = postSummary.Excerpt,
                ImageUrl = "https://api.placeholder.com/800/400?text=ToyLand+Post+" + postId, // Override for detail view
                DatePublished = postSummary.DatePublished,
                Author = postSummary.Author, // This should come from AuthorDetails
                ViewCount = postSummary.ViewCount + 100, // Simulate more views for detail
                CommentCount = GetDummyComments(postId).Count, // Calculate from actual comments
                PostUrl = postSummary.PostUrl,
                Tags = postSummary.Tags,
                FullContentHtml = GenerateDummyFullContent(postSummary.Title),
                AuthorDetails = GetDummyAuthorInfo(postSummary.Author),
                RelatedPosts = GetDummyBlogPosts().Where(p => p.PostId != postId && p.Tags.Any(t => postSummary.Tags.Select(pt => pt.TagName).Contains(t.TagName))).Take(4).ToList(),
                Comments = GetDummyComments(postId),
                CategoryName = postSummary.Tags.FirstOrDefault()?.TagName ?? "Chung", // Use first tag as category for demo
                CategoryUrl = postSummary.Tags.FirstOrDefault()?.TagUrl ?? "/Client/Blog.aspx",
                IsLikedByCurrentUser = (postId % 2 == 0), // Dummy like state
                LikeCount = 50 + postId * 3,
                IsSavedByCurrentUser = (postId % 3 == 0) // Dummy save state
            };
        }

        private string GenerateDummyFullContent(string title)
        {
            return $@"
                <p class='text-lg text-gray-700 leading-relaxed mb-6 font-medium'>
                    Đây là phần mở đầu chi tiết cho bài viết '{title}'. Đồ chơi giáo dục đã trở thành một phần không thể thiếu trong
                    quá trình nuôi dạy trẻ em hiện đại. Không chỉ đơn thuần là phương tiện giải trí, chúng còn đóng vai trò quan trọng trong
                    việc phát triển toàn diện các kỹ năng của trẻ từ nhỏ.
                </p>
                <h2>1. Phát triển trí tuệ và tư duy logic</h2>
                <p>
                    Đồ chơi giáo dục như xếp hình, ghép puzzle, hoặc các bộ đồ chơi STEM giúp trẻ phát triển khả năng tư duy logic, giải
                    quyết vấn đề và sáng tạo. Khi chơi với những đồ chơi này, trẻ em phải suy nghĩ, lập kế hoạch và thực hiện các bước một cách
                    có hệ thống. Nhiều nghiên cứu đã chỉ ra rằng việc tiếp xúc sớm với các hoạt động kích thích tư duy sẽ tạo nền tảng vững chắc cho sự phát triển nhận thức sau này.
                </p>
                <div class='bg-gradient-to-r from-secondary to-primary bg-opacity-10 p-6 rounded-lg my-6'>
                    <h3 class='text-secondary font-bold mb-3'>Lợi ích nổi bật:</h3>
                    <ul class='space-y-2'>
                        <li class='flex items-start'><i class='fas fa-check-circle text-primary mr-2 mt-1'></i><span>Tăng cường khả năng tập trung và kiên nhẫn</span></li>
                        <li class='flex items-start'><i class='fas fa-check-circle text-primary mr-2 mt-1'></i><span>Phát triển tư duy phản biện và logic</span></li>
                        <li class='flex items-start'><i class='fas fa-check-circle text-primary mr-2 mt-1'></i><span>Cải thiện trí nhớ và khả năng ghi nhớ</span></li>
                    </ul>
                </div>
                <img src='https://api.placeholder.com/600/300?text=Logic+Toys' alt='Đồ chơi tư duy logic' class='w-full rounded-lg my-6 shadow-md' />
                <h2>2. Nâng cao kỹ năng vận động tinh và thô</h2>
                <p>
                    Việc lắp ráp, xếp chồng, hoặc thao tác với các chi tiết nhỏ giúp trẻ phát triển kỹ năng vận động tinh. Đồng thời, những đồ
                    chơi như xe đạp, bóng đá, hay các trò chơi vận động giúp tăng cường sức khỏe thể chất, sự dẻo dai và phối hợp các bộ phận cơ thể.
                </p>
                <blockquote>
                    ""Đồ chơi không chỉ là phương tiện giải trí, mà còn là cầu nối giúp trẻ em khám phá thế giới xung quanh và phát triển bản
                    thân một cách tự nhiên nhất."" - Chuyên gia giáo dục ToyLand
                </blockquote>
                <h2>3. Khuyến khích sự sáng tạo và tưởng tượng</h2>
                <p>
                    Đồ chơi như đất nặn, bộ vẽ, hoặc các khối xây dựng cho phép trẻ em thể hiện sự sáng tạo không giới hạn. Chúng có thể tạo
                    ra những tác phẩm nghệ thuật nhỏ, xây dựng những tòa nhà tưởng tượng, hay kể những câu chuyện độc đáo. Đây là cách tuyệt vời để trẻ bộc lộ cảm xúc và ý tưởng của mình.
                </p>
                 <div class='bg-accent bg-opacity-10 border-l-4 border-accent p-6 my-8'>
                    <h3 class='font-bold text-dark mb-3'>Kết luận</h3>
                    <p class='text-gray-700'>
                        Đồ chơi giáo dục không chỉ là những món đồ đơn thuần mà là những công cụ mạnh mẽ hỗ trợ sự phát triển toàn diện của trẻ em. Việc lựa chọn và sử dụng đúng cách sẽ mang lại những lợi ích to lớn cho con em chúng ta. Hãy đầu tư thông minh vào tương lai của trẻ ngay từ hôm nay!
                    </p>
                </div>";
        }

        private AuthorInfo GetDummyAuthorInfo(string authorName)
        {
            if (authorName == "Admin ToyLand" || string.IsNullOrEmpty(authorName))
            {
                return new AuthorInfo
                {
                    Name = "Admin ToyLand",
                    Title = "Chuyên gia tư vấn đồ chơi và phát triển trẻ em",
                    Bio = "Với hơn 10 năm kinh nghiệm trong lĩnh vực đồ chơi trẻ em, tôi luôn đam mê chia sẻ những kiến thức hữu ích giúp các bậc phụ huynh chọn lựa đồ chơi phù hợp cho con em mình.",
                    AvatarUrl = "https://api.placeholder.com/80/80?text=Admin",
                    FacebookUrl = "#",
                    TwitterUrl = "#",
                    InstagramUrl = "#",
                    EmailAddress = "admin@toyland.com"
                };
            }
            return new AuthorInfo
            {
                Name = authorName,
                Title = "Cộng tác viên",
                Bio = "Một người yêu thích chia sẻ về đồ chơi và trẻ em.",
                AvatarUrl = "https://api.placeholder.com/80/80?text=" + authorName.Substring(0, 1),
                EmailAddress = "contributor@example.com"
            };
        }

        private List<CommentModel> GetDummyComments(int postId)
        {
            var comments = new List<CommentModel>();
            comments.Add(new CommentModel { CommentId = 101, AuthorName = "Nguyễn Thị Hoa", AvatarUrl = "https://api.placeholder.com/50/50?text=H", CommentDate = DateTime.Now.AddDays(-2).AddHours(-5), Content = "Bài viết rất hữu ích! Tôi đã áp dụng và thấy con mình rất thích thú.", IsAuthor = false, LikeCount = 12, IsLikedByCurrentUser = false, Replies = new List<CommentModel>() });
            comments[0].Replies.Add(new CommentModel { CommentId = 201, AuthorName = "Admin ToyLand", AvatarUrl = "https://api.placeholder.com/40/40?text=A", CommentDate = DateTime.Now.AddDays(-2).AddHours(-3), Content = "Cảm ơn bạn đã chia sẻ! Rất vui khi biết bài viết giúp ích cho bạn.", IsAuthor = true, LikeCount = 5, IsLikedByCurrentUser = true });
            comments.Add(new CommentModel { CommentId = 102, AuthorName = "Trần Văn Nam", AvatarUrl = "https://api.placeholder.com/50/50?text=N", CommentDate = DateTime.Now.AddDays(-1).AddHours(-2), Content = "Tôi muốn hỏi về độ tuổi phù hợp cho từng loại đồ chơi STEM.", IsAuthor = false, LikeCount = 8, IsLikedByCurrentUser = true, Replies = new List<CommentModel>() });
            if (postId % 2 == 0)
            { // Add more comments for some posts
                comments.Add(new CommentModel { CommentId = 103, AuthorName = "Lê Thị Mai", AvatarUrl = "https://api.placeholder.com/50/50?text=M", CommentDate = DateTime.Now.AddHours(-10), Content = "Bài viết rất chi tiết, cảm ơn tác giả!", IsAuthor = false, LikeCount = 15, IsLikedByCurrentUser = false, Replies = new List<CommentModel>() });
            }
            return comments;
        }

        // Methods from Blog.aspx.cs for sidebar (can be moved to a shared utility class)
        private List<BlogPostSummary> GetDummyBlogPosts() => new Blog().GetPublicDummyBlogPosts(); // Assuming you make it public or internal
        private List<BlogCategory> GetDummyCategories() => new Blog().GetPublicDummyCategories();
        // ... and so on for other shared dummy data methods if needed.
        // OR, re-implement them here if they are different for BlogDetails context.

        #endregion
    }
    // Add these to your Blog.aspx.cs if you want to share them, or make them static in a utility class
    public partial class Blog // Make methods public for BlogDetails to access
    {
        public List<BlogPostSummary> GetPublicDummyBlogPosts()
        {
            var posts = new List<BlogPostSummary>();
            var allTags = GetPublicDummyTags();

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
                Tags = new List<BlogTag> { allTags[0], allTags[2] }
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
        public List<BlogCategory> GetPublicDummyCategories()
        {
            return new List<BlogCategory>
            {
                new BlogCategory { CategoryName = "Giáo dục", CategoryUrl = "/Client/Blog.aspx?category=Giáo dục", PostCount = 12, CategoryIconCss="fas fa-graduation-cap text-secondary" },
                new BlogCategory { CategoryName = "An toàn", CategoryUrl = "/Client/Blog.aspx?category=An toàn", PostCount = 8, CategoryIconCss="fas fa-shield-alt text-primary" },
                // ... other categories from Blog.aspx.cs
                 new BlogCategory { CategoryName = "STEM", CategoryUrl = "/Client/Blog.aspx?category=STEM", PostCount = 15, CategoryIconCss="fas fa-cogs text-accent" }
            };
        }
        public List<BlogTag> GetPublicDummyTags()
        {
            return new List<BlogTag>
            {
                new BlogTag { TagName = "Đồ chơi gỗ", TagUrl = "/Client/Blog.aspx?tag=Đồ chơi gỗ", TagCssClass="bg-primary bg-opacity-20 text-primary hover:bg-primary" },
                new BlogTag { TagName = "STEM", TagUrl = "/Client/Blog.aspx?tag=STEM", TagCssClass="bg-secondary bg-opacity-20 text-secondary hover:bg-secondary" },
                new BlogTag { TagName = "Phát triển trí tuệ", TagUrl = "/Client/Blog.aspx?tag=Phát triển trí tuệ", TagCssClass="bg-accent bg-opacity-20 text-yellow-600 hover:bg-accent" },
                // ... other tags
            };
        }
    }
}