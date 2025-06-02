# Tóm tắt dự án WebDoChoi

Dự án WebDoChoi là một ứng dụng web được phát triển bằng ASP.NET Web Forms, sử dụng framework .NET 4.7.2. Dự án này được thiết kế để xây dựng một trang web động với giao diện người dùng thân thiện, sử dụng các công nghệ như HTML, CSS, và JavaScript. Mục đích chính của dự án là cung cấp một nền tảng cho người dùng để tìm hiểu và tương tác với các sản phẩm đồ chơi, đồng thời cung cấp thông tin về dự án và cách liên hệ.

## Cấu trúc dự án

- **WebDoChoi.sln**: File solution chính của dự án.
- **WebDoChoi/**: Thư mục chứa mã nguồn chính của ứng dụng.
  - **WebDoChoi.csproj**: File project chứa thông tin về các tham chiếu, cấu hình và các file mã nguồn.
  - **Web.config**: File cấu hình chính của ứng dụng, chứa các cài đặt cho database, authentication, và routing.
  - **Default.aspx**: Trang chủ của ứng dụng, hiển thị thông tin giới thiệu về ASP.NET và các liên kết đến các tài nguyên khác.
  - **About.aspx** và **Contact.aspx**: Các trang thông tin về dự án và liên hệ.
  - **Site.Master**: File master page chứa bố cục chung cho các trang trong ứng dụng.
  - **Scripts/**: Thư mục chứa các file JavaScript, bao gồm jQuery và Bootstrap.
  - **Content/**: Thư mục chứa các file CSS và các tài nguyên khác.
  - **Admin/**: Thư mục chứa các file liên quan đến quản trị viên, bao gồm các trang quản lý và cấu hình.
  - **Client/**: Thư mục chứa các file liên quan đến người dùng, bao gồm các trang giao diện người dùng và chức năng tương tác.

## Công nghệ sử dụng

- **ASP.NET Web Forms**: Sử dụng để xây dựng giao diện người dùng và xử lý logic.
- **Bootstrap**: Sử dụng để tạo giao diện responsive và hiện đại.
- **jQuery**: Sử dụng để tương tác với DOM và xử lý các sự kiện.
- **Newtonsoft.Json**: Sử dụng để xử lý dữ liệu JSON.

## Chức năng chính

- Hiển thị thông tin giới thiệu về ASP.NET và các tài nguyên liên quan.
- Cung cấp các trang thông tin về dự án và liên hệ.
- Cho phép người dùng tìm kiếm và xem các sản phẩm đồ chơi.
- Quản lý và cấu hình hệ thống thông qua giao diện quản trị viên.

## Cài đặt và chạy dự án

1. Mở file `WebDoChoi.sln` trong Visual Studio.
2. Khôi phục các gói NuGet cần thiết.
3. Chạy ứng dụng bằng cách nhấn F5 hoặc chọn "Start" từ menu Debug.

## Lưu ý

- Dự án này sử dụng IIS Express để chạy ứng dụng web.
- Đảm bảo rằng bạn đã cài đặt .NET Framework 4.7.2 trước khi chạy dự án.
