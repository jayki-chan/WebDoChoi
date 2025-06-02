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

namespace WebsiteDoChoi.Client
{
    public partial class About : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadAboutContent();
                LoadStatistics();
                LoadCoreValues();
                LoadTeamMembers();
                LoadTimeline();
                LoadCertificates();
                LoadPartners();
                LoadTestimonials();
                UpdateCartCount();
            }
        }

        #region Load Data Methods

        private void LoadAboutContent()
        {
            try
            {
                // Load basic info
                lblYearsExperience.Text = "8+";
                lblCustomersCount.Text = "50K+";
                lblProductsCount.Text = "2500+";
                lblRating.Text = "4.8/5";

                // Load about content
                litAboutContent.Text = @"
                    <p class='text-gray-600 mb-4 leading-relaxed'>
                        ToyLand được thành lập vào năm 2016 với sứ mệnh mang đến những món
                        đồ chơi an toàn, chất lượng và giáo dục cho trẻ em Việt Nam. Chúng
                        tôi hiểu rằng đồ chơi không chỉ đơn thuần là vật dụng giải trí, mà
                        còn là công cụ quan trọng giúp trẻ em phát triển trí tuệ, kỹ năng
                        và tính cách.
                    </p>
                    <p class='text-gray-600 mb-4 leading-relaxed'>
                        Với đội ngũ chuyên gia giàu kinh nghiệm và tâm huyết, chúng tôi tỉ
                        mỉ tuyển chọn từng sản phẩm để đảm bảo chúng đáp ứng các tiêu
                        chuẩn khắt khe về an toàn và chất lượng. Mỗi món đồ chơi tại
                        ToyLand đều được kiểm định kỹ lưỡng và có chứng nhận an toàn quốc
                        tế.
                    </p>";

                // Load mission and vision
                litMission.Text = @"Mang đến cho trẻ em Việt Nam những sản phẩm đồ chơi an toàn, chất
                    lượng và có tính giáo dục cao. Chúng tôi tin rằng mỗi đứa trẻ đều
                    xứng đáng có một tuổi thơ hạnh phúc và phát triển toàn diện.";

                litVision.Text = @"Trở thành thương hiệu đồ chơi trẻ em hàng đầu tại Việt Nam, được
                    tin tưởng bởi hàng triệu gia đình. Chúng tôi hướng tới việc mở
                    rộng ra toàn khu vực Đông Nam Á trong 10 năm tới.";
            }
            catch (Exception ex)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert",
                    $"alert('Lỗi khi tải nội dung: {ex.Message}');", true);
            }
        }

        private void LoadStatistics()
        {
            try
            {
                var statistics = new List<Statistic>
                {
                    new Statistic { Count = 50000, DisplayValue = "50,000+", Label = "Khách hàng hài lòng" },
                    new Statistic { Count = 2500, DisplayValue = "2,500+", Label = "Sản phẩm đa dạng" },
                    new Statistic { Count = 15, DisplayValue = "15+", Label = "Thương hiệu hợp tác" },
                    new Statistic { Count = 8, DisplayValue = "8+", Label = "Năm kinh nghiệm" }
                };

                rptStatistics.DataSource = statistics;
                rptStatistics.DataBind();
            }
            catch (Exception ex)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert",
                    $"alert('Lỗi khi tải thống kê: {ex.Message}');", true);
            }
        }

        private void LoadCoreValues()
        {
            try
            {
                var coreValues = new List<CoreValue>
                {
                    new CoreValue
                    {
                        Title = "An toàn",
                        Description = "Đặt an toàn của trẻ em lên hàng đầu trong mọi sản phẩm",
                        IconClass = "fas fa-shield-alt",
                        ColorClass = "primary"
                    },
                    new CoreValue
                    {
                        Title = "Chất lượng",
                        Description = "Cam kết mang đến sản phẩm chất lượng cao nhất",
                        IconClass = "fas fa-gem",
                        ColorClass = "secondary"
                    },
                    new CoreValue
                    {
                        Title = "Sáng tạo",
                        Description = "Khuyến khích sự sáng tạo và phát triển trí tuệ",
                        IconClass = "fas fa-lightbulb",
                        ColorClass = "accent"
                    },
                    new CoreValue
                    {
                        Title = "Cộng đồng",
                        Description = "Xây dựng cộng đồng gia đình hạnh phúc và gắn kết",
                        IconClass = "fas fa-users",
                        ColorClass = "dark"
                    }
                };

                rptCoreValues.DataSource = coreValues;
                rptCoreValues.DataBind();
            }
            catch (Exception ex)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert",
                    $"alert('Lỗi khi tải giá trị cốt lõi: {ex.Message}');", true);
            }
        }

        private void LoadTeamMembers()
        {
            try
            {
                var teamMembers = new List<TeamMember>
                {
                    new TeamMember
                    {
                        Name = "Nguyễn Minh Anh",
                        Position = "CEO & Founder",
                        Experience = "15 năm kinh nghiệm trong ngành đồ chơi trẻ em",
                        ImageUrl = "https://api.placeholder.com/300/300?text=CEO",
                        Quote = "Niềm vui của trẻ em chính là động lực để chúng tôi không ngừng phát triển",
                        ColorClass = "primary",
                        SocialLinks = new List<SocialLink>
                        {
                            new SocialLink { Url = "#", IconClass = "fab fa-facebook-f" },
                            new SocialLink { Url = "#", IconClass = "fab fa-linkedin-in" }
                        }
                    },
                    new TeamMember
                    {
                        Name = "Trần Văn Hùng",
                        Position = "CTO",
                        Experience = "Chuyên gia công nghệ với 12 năm kinh nghiệm",
                        ImageUrl = "https://api.placeholder.com/300/300?text=CTO",
                        Quote = "Công nghệ giúp chúng tôi mang đến trải nghiệm mua sắm tốt nhất",
                        ColorClass = "secondary",
                        SocialLinks = new List<SocialLink>
                        {
                            new SocialLink { Url = "#", IconClass = "fab fa-twitter" },
                            new SocialLink { Url = "#", IconClass = "fab fa-github" }
                        }
                    },
                    new TeamMember
                    {
                        Name = "Lê Thị Mai",
                        Position = "Trưởng phòng Marketing",
                        Experience = "Chuyên gia marketing với 10 năm kinh nghiệm",
                        ImageUrl = "https://api.placeholder.com/300/300?text=Marketing",
                        Quote = "Mỗi chiến dịch marketing đều hướng tới lợi ích của trẻ em",
                        ColorClass = "accent",
                        SocialLinks = new List<SocialLink>
                        {
                            new SocialLink { Url = "#", IconClass = "fab fa-instagram" },
                            new SocialLink { Url = "#", IconClass = "fab fa-linkedin-in" }
                        }
                    }
                };

                rptTeamMembers.DataSource = teamMembers;
                rptTeamMembers.DataBind();
            }
            catch (Exception ex)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert",
                    $"alert('Lỗi khi tải thông tin đội ngũ: {ex.Message}');", true);
            }
        }

        private void LoadTimeline()
        {
            try
            {
                var timeline = new List<TimelineItem>
                {
                    new TimelineItem
                    {
                        Year = "2016",
                        Title = "Thành lập công ty",
                        Description = "ToyLand được thành lập với 3 nhân viên đầu tiên và cửa hàng nhỏ 50m² tại TP.HCM",
                        IconClass = "fas fa-rocket",
                        ColorClass = "primary",
                        IsLeft = true
                    },
                    new TimelineItem
                    {
                        Year = "2018",
                        Title = "Mở rộng cửa hàng",
                        Description = "Khai trương thêm 5 cửa hàng mới tại Hà Nội, Đà Nẵng và các tỉnh thành lớn",
                        IconClass = "fas fa-store",
                        ColorClass = "secondary",
                        IsLeft = false
                    },
                    new TimelineItem
                    {
                        Year = "2020",
                        Title = "Ra mắt website",
                        Description = "Chính thức kinh doanh online và giao hàng toàn quốc, đáp ứng nhu cầu mua sắm từ xa",
                        IconClass = "fas fa-globe",
                        ColorClass = "accent",
                        IsLeft = true
                    },
                    new TimelineItem
                    {
                        Year = "2022",
                        Title = "Đạt 50,000 khách hàng",
                        Description = "Cột mốc quan trọng với 50,000 khách hàng tin tưởng và đội ngũ 50+ nhân viên",
                        IconClass = "fas fa-award",
                        ColorClass = "dark",
                        IsLeft = false
                    },
                    new TimelineItem
                    {
                        Year = "2024",
                        Title = "Thương hiệu uy tín",
                        Description = "Được vinh danh \"Top 10 thương hiệu đồ chơi trẻ em uy tín nhất Việt Nam\"",
                        IconClass = "fas fa-star",
                        ColorClass = "primary",
                        IsLeft = true
                    }
                };

                rptTimeline.DataSource = timeline;
                rptTimeline.DataBind();
            }
            catch (Exception ex)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert",
                    $"alert('Lỗi khi tải timeline: {ex.Message}');", true);
            }
        }

        private void LoadCertificates()
        {
            try
            {
                var certificates = new List<Certificate>
                {
                    new Certificate
                    {
                        Name = "CE European",
                        Description = "Chứng nhận an toàn châu Âu",
                        ImageUrl = "https://api.placeholder.com/100/100?text=CE"
                    },
                    new Certificate
                    {
                        Name = "ASTM F963",
                        Description = "Tiêu chuẩn an toàn Mỹ",
                        ImageUrl = "https://api.placeholder.com/100/100?text=ASTM"
                    },
                    new Certificate
                    {
                        Name = "ISO 9001",
                        Description = "Quản lý chất lượng",
                        ImageUrl = "https://api.placeholder.com/100/100?text=ISO"
                    },
                    new Certificate
                    {
                        Name = "TCVN",
                        Description = "Tiêu chuẩn Việt Nam",
                        ImageUrl = "https://api.placeholder.com/100/100?text=TCVN"
                    }
                };

                rptCertificates.DataSource = certificates;
                rptCertificates.DataBind();
            }
            catch (Exception ex)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert",
                    $"alert('Lỗi khi tải chứng nhận: {ex.Message}');", true);
            }
        }

        private void LoadPartners()
        {
            try
            {
                var partners = new List<Partner>
                {
                    new Partner { Name = "LEGO", ImageUrl = "https://api.placeholder.com/120/60?text=LEGO" },
                    new Partner { Name = "Fisher Price", ImageUrl = "https://api.placeholder.com/120/60?text=Fisher+Price" },
                    new Partner { Name = "Mattel", ImageUrl = "https://api.placeholder.com/120/60?text=Mattel" },
                    new Partner { Name = "Hasbro", ImageUrl = "https://api.placeholder.com/120/60?text=Hasbro" },
                    new Partner { Name = "Playmobil", ImageUrl = "https://api.placeholder.com/120/60?text=Playmobil" },
                    new Partner { Name = "Melissa & Doug", ImageUrl = "https://api.placeholder.com/120/60?text=Melissa" }
                };

                rptPartners.DataSource = partners;
                rptPartners.DataBind();
            }
            catch (Exception ex)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert",
                    $"alert('Lỗi khi tải đối tác: {ex.Message}');", true);
            }
        }

        private void LoadTestimonials()
        {
            try
            {
                var testimonials = new List<Testimonial>
                {
                    new Testimonial
                    {
                        CustomerName = "Chị Nguyễn Lan Anh",
                        CustomerInfo = "Mẹ của bé Minh An (5 tuổi)",
                        CustomerImage = "https://api.placeholder.com/50/50?text=KH1",
                        Content = "ToyLand có rất nhiều đồ chơi giáo dục chất lượng cao. Con tôi rất thích những bộ xếp hình LEGO và đã học được rất nhiều điều từ việc chơi.",
                        Rating = 5
                    },
                    new Testimonial
                    {
                        CustomerName = "Anh Trần Văn Đức",
                        CustomerInfo = "Bố của bé Thảo My (3 tuổi)",
                        CustomerImage = "https://api.placeholder.com/50/50?text=KH2",
                        Content = "Dịch vụ giao hàng nhanh chóng, đóng gói cẩn thận. Quan trọng nhất là tất cả đồ chơi đều có chứng nhận an toàn, tôi hoàn toàn yên tâm.",
                        Rating = 5
                    },
                    new Testimonial
                    {
                        CustomerName = "Chị Lê Thị Hoa",
                        CustomerInfo = "Mẹ của bé Quang Minh (7 tuổi)",
                        CustomerImage = "https://api.placeholder.com/50/50?text=KH3",
                        Content = "Nhân viên tư vấn rất nhiệt tình và am hiểu. Họ đã giúp tôi chọn được những món đồ chơi phù hợp với độ tuổi và sở thích của con.",
                        Rating = 5
                    }
                };

                rptTestimonials.DataSource = testimonials;
                rptTestimonials.DataBind();
            }
            catch (Exception ex)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert",
                    $"alert('Lỗi khi tải đánh giá khách hàng: {ex.Message}');", true);
            }
        }

        private void UpdateCartCount()
        {
            try
            {
                int cartCount = 0;
                if (Session["CartCount"] != null)
                {
                    cartCount = (int)Session["CartCount"];
                }

            }
            catch (Exception ex)
            {
            }
        }

       

        #endregion

        #region Event Handlers

        #endregion

        #region Helper Methods

        protected string GetTimelineItemHtml(object dataItem)
        {
            try
            {
                TimelineItem item = (TimelineItem)dataItem;
                StringBuilder html = new StringBuilder();

                if (item.IsLeft)
                {
                    html.Append($@"
                        <div class='timeline-content w-5/12 bg-white p-6 rounded-lg shadow-md'>
                            <div class='flex items-center mb-3'>
                                <div class='w-8 h-8 bg-{item.ColorClass} rounded-full flex items-center justify-center mr-3'>
                                    <i class='{item.IconClass} text-white text-sm'></i>
                                </div>
                                <span class='text-{item.ColorClass} font-bold'>{item.Year}</span>
                            </div>
                            <h3 class='text-lg font-bold text-dark mb-2'>{item.Title}</h3>
                            <p class='text-gray-600 text-sm'>{item.Description}</p>
                        </div>
                        <div class='w-2/12 flex justify-center'>
                            <div class='w-4 h-4 bg-{item.ColorClass} rounded-full'></div>
                        </div>
                        <div class='w-5/12'></div>");
                }
                else
                {
                    html.Append($@"
                        <div class='w-5/12'></div>
                        <div class='w-2/12 flex justify-center'>
                            <div class='w-4 h-4 bg-{item.ColorClass} rounded-full'></div>
                        </div>
                        <div class='timeline-content w-5/12 bg-white p-6 rounded-lg shadow-md'>
                            <div class='flex items-center mb-3'>
                                <div class='w-8 h-8 bg-{item.ColorClass} rounded-full flex items-center justify-center mr-3'>
                                    <i class='{item.IconClass} text-white text-sm'></i>
                                </div>
                                <span class='text-{item.ColorClass} font-bold'>{item.Year}</span>
                            </div>
                            <h3 class='text-lg font-bold text-dark mb-2'>{item.Title}</h3>
                            <p class='text-gray-600 text-sm'>{item.Description}</p>
                        </div>");
                }

                return html.ToString();
            }
            catch (Exception ex)
            {
                return $"<div class='w-full text-center text-red-500'>Lỗi hiển thị timeline: {ex.Message}</div>";
            }
        }

        protected string GenerateStars(int rating)
        {
            StringBuilder stars = new StringBuilder();
            for (int i = 0; i < 5; i++)
            {
                if (i < rating)
                {
                    stars.Append("<i class='fas fa-star'></i>");
                }
                else
                {
                    stars.Append("<i class='far fa-star'></i>");
                }
            }
            return stars.ToString();
        }

        #endregion
    }

    #region Data Classes

    public class Statistic
    {
        public int Count { get; set; }
        public string DisplayValue { get; set; }
        public string Label { get; set; }
    }

    public class CoreValue
    {
        public string Title { get; set; }
        public string Description { get; set; }
        public string IconClass { get; set; }
        public string ColorClass { get; set; }
    }

    public class TeamMember
    {
        public string Name { get; set; }
        public string Position { get; set; }
        public string Experience { get; set; }
        public string ImageUrl { get; set; }
        public string Quote { get; set; }
        public string ColorClass { get; set; }
        public List<SocialLink> SocialLinks { get; set; }
    }

    public class SocialLink
    {
        public string Url { get; set; }
        public string IconClass { get; set; }
    }

    public class TimelineItem
    {
        public string Year { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string IconClass { get; set; }
        public string ColorClass { get; set; }
        public bool IsLeft { get; set; }
    }

    public class Certificate
    {
        public string Name { get; set; }
        public string Description { get; set; }
        public string ImageUrl { get; set; }
    }

    public class Partner
    {
        public string Name { get; set; }
        public string ImageUrl { get; set; }
    }

    public class Testimonial
    {
        public string CustomerName { get; set; }
        public string CustomerInfo { get; set; }
        public string CustomerImage { get; set; }
        public string Content { get; set; }
        public int Rating { get; set; }
    }

    #endregion
}