using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using MySql.Data.MySqlClient;
using WebDoChoi.Data;
using WebDoChoi.Security;
namespace WebDoChoi.Business
{
    /// <summary>
    /// Lớp xử lý nghiệp vụ liên quan đến người dùng
    /// Bao gồm đăng ký, đăng nhập, quản lý thông tin người dùng
    /// </summary>
    public class UserService
    {
        #region Models - Các lớp dữ liệu

        /// <summary>
        /// Model đại diện cho người dùng trong hệ thống
        /// </summary>
        public class User
        {
            public int Id { get; set; }
            public string Username { get; set; }
            public string Email { get; set; }
            public string FullName { get; set; }
            public string Phone { get; set; }
            public string PasswordHash { get; set; }
            public DateTime? DateOfBirth { get; set; }
            public string Gender { get; set; }
            public int RoleId { get; set; }
            public string RoleName { get; set; }
            public string AvatarUrl { get; set; }
            public bool IsActive { get; set; }
            public bool EmailVerified { get; set; }
            public DateTime? LastLogin { get; set; }
            public DateTime CreatedAt { get; set; }
            public DateTime UpdatedAt { get; set; }
        }

        /// <summary>
        /// Model kết quả xác thực người dùng
        /// </summary>
        public class AuthenticationResult
        {
            public bool IsSuccess { get; set; }
            public string Message { get; set; }
            public User User { get; set; }
            public string SessionToken { get; set; }
        }

        /// <summary>
        /// Model thông tin đăng ký người dùng mới
        /// </summary>
        public class RegisterInfo
        {
            public string Username { get; set; }
            public string Email { get; set; }
            public string FullName { get; set; }
            public string Phone { get; set; }
            public string Password { get; set; }
            public DateTime? DateOfBirth { get; set; }
            public string Gender { get; set; }
            public bool SubscribeNewsletter { get; set; }
        }

        #endregion

        #region Phương thức xác thực người dùng

        /// <summary>
        /// Xác thực đăng nhập người dùng
        /// </summary>
        /// <param name="email">Email đăng nhập</param>
        /// <param name="password">Mật khẩu</param>
        /// <param name="ipAddress">Địa chỉ IP</param>
        /// <param name="userAgent">User Agent</param>
        /// <returns>Kết quả xác thực</returns>
        public static AuthenticationResult AuthenticateUser(string email, string password,
            string ipAddress = "", string userAgent = "")
        {
            var result = new AuthenticationResult();

            try
            {
                // Validate input
                if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
                {
                    result.Message = "Email và mật khẩu không được để trống";
                    return result;
                }

                // Sanitize email
                email = SecurityHelper.SanitizeEmail(email);

                // Hash password để so sánh
                string hashedPassword = SecurityHelper.HashPassword(password);

                // Truy vấn thông tin người dùng
                string query = @"
                    SELECT u.id, u.username, u.email, u.full_name, u.phone, 
                           u.password_hash, u.date_of_birth, u.gender, 
                           u.role_id, ur.role_name, u.avatar_url, 
                           u.is_active, u.email_verified, u.last_login,
                           u.created_at, u.updated_at
                    FROM users u
                    INNER JOIN user_roles ur ON u.role_id = ur.id
                    WHERE u.email = @Email AND u.password_hash = @PasswordHash
                          AND u.is_active = 1";

                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@Email", email),
                    DatabaseHelper.CreateParameter("@PasswordHash", hashedPassword)
                };

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);

                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];

                    // Tạo đối tượng User
                    result.User = new User
                    {
                        Id = Convert.ToInt32(row["id"]),
                        Username = row["username"].ToString(),
                        Email = row["email"].ToString(),
                        FullName = row["full_name"].ToString(),
                        Phone = row["phone"].ToString(),
                        PasswordHash = row["password_hash"].ToString(),
                        DateOfBirth = row["date_of_birth"] == DBNull.Value ?
                            (DateTime?)null : Convert.ToDateTime(row["date_of_birth"]),
                        Gender = row["gender"].ToString(),
                        RoleId = Convert.ToInt32(row["role_id"]),
                        RoleName = row["role_name"].ToString(),
                        AvatarUrl = row["avatar_url"].ToString(),
                        IsActive = Convert.ToBoolean(row["is_active"]),
                        EmailVerified = Convert.ToBoolean(row["email_verified"]),
                        LastLogin = row["last_login"] == DBNull.Value ?
                            (DateTime?)null : Convert.ToDateTime(row["last_login"]),
                        CreatedAt = Convert.ToDateTime(row["created_at"]),
                        UpdatedAt = Convert.ToDateTime(row["updated_at"])
                    };

                    // Cập nhật thời gian đăng nhập cuối
                    UpdateLastLogin(result.User.Id, ipAddress, userAgent);

                    // Tạo session token
                    result.SessionToken = SecurityHelper.GenerateSessionToken();

                    result.IsSuccess = true;
                    result.Message = "Đăng nhập thành công";

                    // Log hoạt động bảo mật
                    SecurityHelper.LogSecurityAction("LOGIN_SUCCESS", result.User.Id, ipAddress, userAgent);
                }
                else
                {
                    result.Message = "Email hoặc mật khẩu không đúng";

                    // Log hoạt động bảo mật
                    SecurityHelper.LogSecurityAction("LOGIN_FAILED", null, ipAddress, userAgent);
                }
            }
            catch (Exception ex)
            {
                result.Message = "Có lỗi xảy ra trong quá trình đăng nhập";
                System.Diagnostics.Debug.WriteLine($"Authentication Error: {ex.Message}");

                // Log lỗi
                SecurityHelper.LogSecurityAction("LOGIN_ERROR", null, ipAddress, userAgent);
            }

            return result;
        }

        /// <summary>
        /// Đăng ký người dùng mới
        /// </summary>
        /// <param name="registerInfo">Thông tin đăng ký</param>
        /// <param name="ipAddress">Địa chỉ IP</param>
        /// <param name="userAgent">User Agent</param>
        /// <returns>Kết quả đăng ký</returns>
        public static AuthenticationResult RegisterUser(RegisterInfo registerInfo,
            string ipAddress = "", string userAgent = "")
        {
            var result = new AuthenticationResult();

            try
            {
                // Validate thông tin đăng ký
                string validationError = ValidateRegisterInfo(registerInfo);
                if (!string.IsNullOrEmpty(validationError))
                {
                    result.Message = validationError;
                    return result;
                }

                // Sanitize dữ liệu đầu vào
                registerInfo.Email = SecurityHelper.SanitizeEmail(registerInfo.Email);
                registerInfo.Username = SecurityHelper.SanitizeInput(registerInfo.Username);
                registerInfo.FullName = SecurityHelper.SanitizeInput(registerInfo.FullName);
                registerInfo.Phone = SecurityHelper.SanitizeInput(registerInfo.Phone);

                // Kiểm tra email đã tồn tại
                if (IsEmailExists(registerInfo.Email))
                {
                    result.Message = "Email này đã được sử dụng. Vui lòng chọn email khác";
                    return result;
                }

                // Kiểm tra username đã tồn tại (nếu có)
                if (!string.IsNullOrEmpty(registerInfo.Username) && IsUsernameExists(registerInfo.Username))
                {
                    result.Message = "Tên đăng nhập này đã được sử dụng";
                    return result;
                }

                // Mã hóa mật khẩu
                string hashedPassword = SecurityHelper.HashPassword(registerInfo.Password);

                // Lấy role_id cho Customer (mặc định là 4 theo database)
                int customerRoleId = GetRoleIdByName("Customer");

                // Tạo username từ email nếu không có
                if (string.IsNullOrEmpty(registerInfo.Username))
                {
                    registerInfo.Username = registerInfo.Email.Split('@')[0];
                }

                // Insert người dùng mới
                string insertQuery = @"
                    INSERT INTO users (username, email, password_hash, full_name, phone, 
                                     date_of_birth, gender, role_id, is_active, email_verified, 
                                     created_at, updated_at)
                    VALUES (@Username, @Email, @PasswordHash, @FullName, @Phone, 
                            @DateOfBirth, @Gender, @RoleId, 1, 0, NOW(), NOW());
                    SELECT LAST_INSERT_ID();";

                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@Username", registerInfo.Username),
                    DatabaseHelper.CreateParameter("@Email", registerInfo.Email),
                    DatabaseHelper.CreateParameter("@PasswordHash", hashedPassword),
                    DatabaseHelper.CreateParameter("@FullName", registerInfo.FullName),
                    DatabaseHelper.CreateParameter("@Phone", registerInfo.Phone),
                    DatabaseHelper.CreateParameter("@DateOfBirth", registerInfo.DateOfBirth),
                    DatabaseHelper.CreateParameter("@Gender", registerInfo.Gender ?? "Other"),
                    DatabaseHelper.CreateParameter("@RoleId", customerRoleId)
                };

                object newUserId = DatabaseHelper.ExecuteScalar(insertQuery, parameters);

                if (newUserId != null && Convert.ToInt32(newUserId) > 0)
                {
                    int userId = Convert.ToInt32(newUserId);

                    // Đăng ký newsletter nếu được chọn
                    if (registerInfo.SubscribeNewsletter)
                    {
                        RegisterNewsletter(registerInfo.Email, registerInfo.FullName);
                    }

                    // Lấy thông tin user vừa tạo để trả về
                    result.User = GetUserById(userId);

                    if (result.User != null)
                    {
                        // Tạo session token
                        result.SessionToken = SecurityHelper.GenerateSessionToken();

                        result.IsSuccess = true;
                        result.Message = "Đăng ký thành công";

                        // Log hoạt động bảo mật
                        SecurityHelper.LogSecurityAction("REGISTER_SUCCESS", userId, ipAddress, userAgent);
                    }
                    else
                    {
                        result.Message = "Có lỗi xảy ra sau khi tạo tài khoản";
                    }
                }
                else
                {
                    result.Message = "Không thể tạo tài khoản. Vui lòng thử lại";
                }
            }
            catch (Exception ex)
            {
                result.Message = "Có lỗi xảy ra trong quá trình đăng ký";
                System.Diagnostics.Debug.WriteLine($"Registration Error: {ex.Message}");

                // Log lỗi
                SecurityHelper.LogSecurityAction("REGISTER_ERROR", null, ipAddress, userAgent);
            }

            return result;
        }

        #endregion

        #region Phương thức quản lý người dùng

        /// <summary>
        /// Lấy thông tin người dùng theo ID
        /// </summary>
        /// <param name="userId">ID người dùng</param>
        /// <returns>Thông tin người dùng</returns>
        public static User GetUserById(int userId)
        {
            try
            {
                string query = @"
                    SELECT u.id, u.username, u.email, u.full_name, u.phone, 
                           u.password_hash, u.date_of_birth, u.gender, 
                           u.role_id, ur.role_name, u.avatar_url, 
                           u.is_active, u.email_verified, u.last_login,
                           u.created_at, u.updated_at
                    FROM users u
                    INNER JOIN user_roles ur ON u.role_id = ur.id
                    WHERE u.id = @UserId";

                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@UserId", userId)
                };

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters);

                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];

                    return new User
                    {
                        Id = Convert.ToInt32(row["id"]),
                        Username = row["username"].ToString(),
                        Email = row["email"].ToString(),
                        FullName = row["full_name"].ToString(),
                        Phone = row["phone"].ToString(),
                        PasswordHash = row["password_hash"].ToString(),
                        DateOfBirth = row["date_of_birth"] == DBNull.Value ?
                            (DateTime?)null : Convert.ToDateTime(row["date_of_birth"]),
                        Gender = row["gender"].ToString(),
                        RoleId = Convert.ToInt32(row["role_id"]),
                        RoleName = row["role_name"].ToString(),
                        AvatarUrl = row["avatar_url"].ToString(),
                        IsActive = Convert.ToBoolean(row["is_active"]),
                        EmailVerified = Convert.ToBoolean(row["email_verified"]),
                        LastLogin = row["last_login"] == DBNull.Value ?
                            (DateTime?)null : Convert.ToDateTime(row["last_login"]),
                        CreatedAt = Convert.ToDateTime(row["created_at"]),
                        UpdatedAt = Convert.ToDateTime(row["updated_at"])
                    };
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetUserById Error: {ex.Message}");
            }

            return null;
        }

        /// <summary>
        /// Cập nhật thời gian đăng nhập cuối
        /// </summary>
        /// <param name="userId">ID người dùng</param>
        /// <param name="ipAddress">Địa chỉ IP</param>
        /// <param name="userAgent">User Agent</param>
        private static void UpdateLastLogin(int userId, string ipAddress, string userAgent)
        {
            try
            {
                string updateQuery = @"
                    UPDATE users 
                    SET last_login = NOW(), updated_at = NOW() 
                    WHERE id = @UserId";

                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@UserId", userId)
                };

                DatabaseHelper.ExecuteNonQuery(updateQuery, parameters);

                // Log vào activity_logs nếu cần
                LogUserActivity(userId, "LOGIN", null, null, null, ipAddress, userAgent);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"UpdateLastLogin Error: {ex.Message}");
            }
        }

        /// <summary>
        /// Ghi log hoạt động của người dùng
        /// </summary>
        private static void LogUserActivity(int? userId, string action, string tableName,
            int? recordId, string description, string ipAddress, string userAgent)
        {
            try
            {
                string insertQuery = @"
                    INSERT INTO activity_logs (user_id, action, table_name, record_id, 
                                             old_values, new_values, ip_address, user_agent, created_at)
                    VALUES (@UserId, @Action, @TableName, @RecordId, 
                            @OldValues, @NewValues, @IpAddress, @UserAgent, NOW())";

                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@UserId", userId),
                    DatabaseHelper.CreateParameter("@Action", action),
                    DatabaseHelper.CreateParameter("@TableName", tableName),
                    DatabaseHelper.CreateParameter("@RecordId", recordId),
                    DatabaseHelper.CreateParameter("@OldValues", DBNull.Value),
                    DatabaseHelper.CreateParameter("@NewValues", description),
                    DatabaseHelper.CreateParameter("@IpAddress", ipAddress),
                    DatabaseHelper.CreateParameter("@UserAgent", userAgent)
                };

                DatabaseHelper.ExecuteNonQuery(insertQuery, parameters);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LogUserActivity Error: {ex.Message}");
            }
        }

        #endregion

        #region Phương thức kiểm tra và validate

        /// <summary>
        /// Kiểm tra email đã tồn tại
        /// </summary>
        /// <param name="email">Email cần kiểm tra</param>
        /// <returns>True nếu email đã tồn tại</returns>
        public static bool IsEmailExists(string email)
        {
            try
            {
                string query = "SELECT COUNT(*) FROM users WHERE email = @Email";
                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@Email", email)
                };

                object result = DatabaseHelper.ExecuteScalar(query, parameters);
                return Convert.ToInt32(result) > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"IsEmailExists Error: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Kiểm tra username đã tồn tại
        /// </summary>
        /// <param name="username">Username cần kiểm tra</param>
        /// <returns>True nếu username đã tồn tại</returns>
        public static bool IsUsernameExists(string username)
        {
            try
            {
                string query = "SELECT COUNT(*) FROM users WHERE username = @Username";
                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@Username", username)
                };

                object result = DatabaseHelper.ExecuteScalar(query, parameters);
                return Convert.ToInt32(result) > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"IsUsernameExists Error: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Validate thông tin đăng ký
        /// </summary>
        /// <param name="registerInfo">Thông tin đăng ký</param>
        /// <returns>Thông điệp lỗi nếu có</returns>
        private static string ValidateRegisterInfo(RegisterInfo registerInfo)
        {
            if (registerInfo == null)
                return "Thông tin đăng ký không hợp lệ";

            if (string.IsNullOrWhiteSpace(registerInfo.Email))
                return "Email không được để trống";

            if (string.IsNullOrWhiteSpace(registerInfo.FullName))
                return "Họ tên không được để trống";

            if (string.IsNullOrWhiteSpace(registerInfo.Password))
                return "Mật khẩu không được để trống";

            // Validate độ mạnh mật khẩu
            string passwordError = SecurityHelper.ValidatePasswordStrength(registerInfo.Password);
            if (!string.IsNullOrEmpty(passwordError))
                return passwordError;

            // Validate email format
            try
            {
                SecurityHelper.SanitizeEmail(registerInfo.Email);
            }
            catch (ArgumentException ex)
            {
                return ex.Message;
            }

            // Validate phone number nếu có
            if (!string.IsNullOrEmpty(registerInfo.Phone))
            {
                if (registerInfo.Phone.Length < 10 || registerInfo.Phone.Length > 15)
                    return "Số điện thoại không hợp lệ";
            }

            return string.Empty; // Không có lỗi
        }

        /// <summary>
        /// Lấy role ID theo tên role
        /// </summary>
        /// <param name="roleName">Tên role</param>
        /// <returns>Role ID</returns>
        private static int GetRoleIdByName(string roleName)
        {
            try
            {
                string query = "SELECT id FROM user_roles WHERE role_name = @RoleName";
                var parameters = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@RoleName", roleName)
                };

                object result = DatabaseHelper.ExecuteScalar(query, parameters);
                return result != null ? Convert.ToInt32(result) : 4; // Mặc định Customer = 4
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetRoleIdByName Error: {ex.Message}");
                return 4; // Mặc định Customer
            }
        }

        /// <summary>
        /// Đăng ký newsletter
        /// </summary>
        /// <param name="email">Email</param>
        /// <param name="name">Tên</param>
        private static void RegisterNewsletter(string email, string name)
        {
            try
            {
                // Kiểm tra đã đăng ký newsletter chưa
                string checkQuery = "SELECT COUNT(*) FROM newsletter_subscribers WHERE email = @Email";
                var checkParams = new MySqlParameter[]
                {
                    DatabaseHelper.CreateParameter("@Email", email)
                };

                object existing = DatabaseHelper.ExecuteScalar(checkQuery, checkParams);

                if (Convert.ToInt32(existing) == 0)
                {
                    string insertQuery = @"
                        INSERT INTO newsletter_subscribers (email, name, is_active, subscribed_at)
                        VALUES (@Email, @Name, 1, NOW())";

                    var parameters = new MySqlParameter[]
                    {
                        DatabaseHelper.CreateParameter("@Email", email),
                        DatabaseHelper.CreateParameter("@Name", name)
                    };

                    DatabaseHelper.ExecuteNonQuery(insertQuery, parameters);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"RegisterNewsletter Error: {ex.Message}");
            }
        }

        #endregion

        #region Phương thức hỗ trợ khác

        /// <summary>
        /// Đăng xuất người dùng (có thể mở rộng để xử lý session)
        /// </summary>
        /// <param name="userId">ID người dùng</param>
        /// <param name="ipAddress">Địa chỉ IP</param>
        /// <param name="userAgent">User Agent</param>
        public static void LogoutUser(int userId, string ipAddress = "", string userAgent = "")
        {
            try
            {
                // Log hoạt động đăng xuất
                SecurityHelper.LogSecurityAction("LOGOUT", userId, ipAddress, userAgent);
                LogUserActivity(userId, "LOGOUT", null, null, null, ipAddress, userAgent);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LogoutUser Error: {ex.Message}");
            }
        }

        /// <summary>
        /// Kiểm tra trạng thái kết nối database
        /// </summary>
        /// <returns>True nếu kết nối thành công</returns>
        public static bool TestDatabaseConnection()
        {
            return DatabaseHelper.TestConnection();
        }

        #endregion
    }
}