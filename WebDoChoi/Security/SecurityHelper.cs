using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Security.Cryptography;
using System.Text;
namespace WebDoChoi.Security
{
    /// <summary>
    /// Lớp hỗ trợ mã hóa và bảo mật
    /// Cung cấp các phương thức mã hóa mật khẩu và xác thực
    /// </summary>
    public class SecurityHelper
    {
        #region Constants - Hằng số bảo mật

        /// <summary>
        /// Salt key để tăng cường bảo mật mật khẩu
        /// </summary>
        private const string SALT_KEY = "ToyLand2025@SecureKey#VietNam";

        /// <summary>
        /// Pepper key bổ sung cho việc mã hóa
        /// </summary>
        private const string PEPPER_KEY = "WebsiteDoChoi!Security$2025";

        #endregion

        #region Phương thức mã hóa mật khẩu

        /// <summary>
        /// Mã hóa mật khẩu sử dụng SHA-256 với Salt và Pepper
        /// </summary>
        /// <param name="password">Mật khẩu gốc</param>
        /// <returns>Mật khẩu đã được mã hóa</returns>
        public static string HashPassword(string password)
        {
            if (string.IsNullOrEmpty(password))
                throw new ArgumentException("Mật khẩu không được để trống", nameof(password));

            try
            {
                // Kết hợp password với salt và pepper
                string combinedPassword = $"{SALT_KEY}{password}{PEPPER_KEY}";

                using (SHA256 sha256Hash = SHA256.Create())
                {
                    // Chuyển đổi chuỗi thành byte array
                    byte[] bytes = sha256Hash.ComputeHash(Encoding.UTF8.GetBytes(combinedPassword));

                    // Chuyển đổi byte array thành chuỗi hexadecimal
                    StringBuilder builder = new StringBuilder();
                    for (int i = 0; i < bytes.Length; i++)
                    {
                        builder.Append(bytes[i].ToString("x2"));
                    }

                    return builder.ToString();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Password Hashing Error: {ex.Message}");
                throw new Exception("Lỗi trong quá trình mã hóa mật khẩu", ex);
            }
        }

        /// <summary>
        /// Xác thực mật khẩu bằng cách so sánh hash
        /// </summary>
        /// <param name="inputPassword">Mật khẩu người dùng nhập</param>
        /// <param name="hashedPassword">Mật khẩu đã mã hóa trong database</param>
        /// <returns>True nếu mật khẩu đúng</returns>
        public static bool VerifyPassword(string inputPassword, string hashedPassword)
        {
            if (string.IsNullOrEmpty(inputPassword) || string.IsNullOrEmpty(hashedPassword))
                return false;

            try
            {
                // Mã hóa mật khẩu input và so sánh
                string hashedInput = HashPassword(inputPassword);
                return hashedInput.Equals(hashedPassword, StringComparison.OrdinalIgnoreCase);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Password Verification Error: {ex.Message}");
                return false;
            }
        }

        #endregion

        #region Phương thức tạo mã ngẫu nhiên

        /// <summary>
        /// Tạo mã xác thực ngẫu nhiên
        /// </summary>
        /// <param name="length">Độ dài mã</param>
        /// <returns>Mã xác thực</returns>
        public static string GenerateRandomCode(int length = 6)
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            Random random = new Random();
            StringBuilder result = new StringBuilder();

            for (int i = 0; i < length; i++)
            {
                result.Append(chars[random.Next(chars.Length)]);
            }

            return result.ToString();
        }

        /// <summary>
        /// Tạo session token bảo mật
        /// </summary>
        /// <returns>Session token</returns>
        public static string GenerateSessionToken()
        {
            using (RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider())
            {
                byte[] tokenBytes = new byte[32];
                rng.GetBytes(tokenBytes);
                return Convert.ToBase64String(tokenBytes);
            }
        }

        #endregion

        #region Phương thức xử lý dữ liệu đầu vào

        /// <summary>
        /// Làm sạch và validate email
        /// </summary>
        /// <param name="email">Email cần validate</param>
        /// <returns>Email đã được làm sạch</returns>
        public static string SanitizeEmail(string email)
        {
            if (string.IsNullOrWhiteSpace(email))
                return string.Empty;

            email = email.Trim().ToLower();

            // Kiểm tra format email cơ bản
            if (!System.Text.RegularExpressions.Regex.IsMatch(email,
                @"^[^\s@]+@[^\s@]+\.[^\s@]+$"))
            {
                throw new ArgumentException("Định dạng email không hợp lệ");
            }

            return email;
        }

        /// <summary>
        /// Làm sạch input để tránh SQL Injection và XSS
        /// </summary>
        /// <param name="input">Dữ liệu đầu vào</param>
        /// <returns>Dữ liệu đã được làm sạch</returns>
        public static string SanitizeInput(string input)
        {
            if (string.IsNullOrEmpty(input))
                return string.Empty;

            // Loại bỏ các ký tự nguy hiểm
            input = input.Trim();
            input = input.Replace("'", "''"); // Escape single quotes
            input = input.Replace("--", ""); // Remove comment syntax
            input = input.Replace(";", ""); // Remove semicolons
            input = input.Replace("/*", ""); // Remove comment start
            input = input.Replace("*/", ""); // Remove comment end

            // HTML encode để tránh XSS
            input = System.Web.HttpUtility.HtmlEncode(input);

            return input;
        }

        /// <summary>
        /// Validate độ mạnh của mật khẩu
        /// </summary>
        /// <param name="password">Mật khẩu cần kiểm tra</param>
        /// <returns>Thông điệp lỗi nếu mật khẩu không đạt yêu cầu</returns>
        public static string ValidatePasswordStrength(string password)
        {
            if (string.IsNullOrEmpty(password))
                return "Mật khẩu không được để trống";

            if (password.Length < 6)
                return "Mật khẩu phải có ít nhất 6 ký tự";

            if (password.Length > 50)
                return "Mật khẩu không được quá 50 ký tự";

            // Kiểm tra có ít nhất 1 chữ cái
            if (!System.Text.RegularExpressions.Regex.IsMatch(password, @"[a-zA-Z]"))
                return "Mật khẩu phải chứa ít nhất 1 chữ cái";

            // Kiểm tra có ít nhất 1 số
            if (!System.Text.RegularExpressions.Regex.IsMatch(password, @"[0-9]"))
                return "Mật khẩu phải chứa ít nhất 1 chữ số";

            return string.Empty; // Mật khẩu hợp lệ
        }

        #endregion

        #region Phương thức kiểm tra bảo mật

        /// <summary>
        /// Kiểm tra IP có trong whitelist không
        /// </summary>
        /// <param name="ipAddress">Địa chỉ IP</param>
        /// <returns>True nếu IP được phép</returns>
        public static bool IsIpAllowed(string ipAddress)
        {
            // Có thể implement logic kiểm tra IP blacklist/whitelist
            // Hiện tại cho phép tất cả IP
            return true;
        }

        /// <summary>
        /// Ghi log hoạt động bảo mật
        /// </summary>
        /// <param name="action">Hành động</param>
        /// <param name="userId">ID người dùng</param>
        /// <param name="ipAddress">Địa chỉ IP</param>
        /// <param name="userAgent">User Agent</param>
        public static void LogSecurityAction(string action, int? userId, string ipAddress, string userAgent)
        {
            try
            {
                // Có thể implement việc ghi log vào database hoặc file
                string logMessage = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] " +
                                  $"Action: {action}, " +
                                  $"UserId: {userId?.ToString() ?? "Guest"}, " +
                                  $"IP: {ipAddress}, " +
                                  $"UserAgent: {userAgent}";

                System.Diagnostics.Debug.WriteLine(logMessage);

                // TODO: Implement actual logging to database
                // LogToDatabase(action, userId, ipAddress, userAgent);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Logging Error: {ex.Message}");
            }
        }

        #endregion
    }
}