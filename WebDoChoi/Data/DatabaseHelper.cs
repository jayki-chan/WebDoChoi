using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient;
namespace WebDoChoi.Data
{
    /// <summary>
    /// Lớp hỗ trợ kết nối và thao tác với cơ sở dữ liệu MySQL
    /// Cung cấp các phương thức cơ bản để thực hiện truy vấn
    /// </summary>
    public class DatabaseHelper
    {
        #region Properties và Constructor

        /// <summary>
        /// Chuỗi kết nối đến cơ sở dữ liệu MySQL
        /// </summary>
        private static string ConnectionString
        {
            get
            {
                return ConfigurationManager.ConnectionStrings["MySQLConnection"].ConnectionString;
            }
        }

        #endregion

        #region Phương thức thực hiện truy vấn

        /// <summary>
        /// Thực hiện truy vấn SELECT và trả về DataTable
        /// </summary>
        /// <param name="query">Câu truy vấn SQL</param>
        /// <param name="parameters">Danh sách tham số</param>
        /// <returns>DataTable chứa kết quả</returns>
        public static DataTable ExecuteQuery(string query, params MySqlParameter[] parameters)
        {
            DataTable dataTable = new DataTable();

            try
            {
                using (MySqlConnection connection = new MySqlConnection(ConnectionString))
                {
                    using (MySqlCommand command = new MySqlCommand(query, connection))
                    {
                        // Thêm tham số vào command
                        if (parameters != null)
                        {
                            command.Parameters.AddRange(parameters);
                        }

                        connection.Open();
                        using (MySqlDataAdapter adapter = new MySqlDataAdapter(command))
                        {
                            adapter.Fill(dataTable);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Log lỗi vào file hoặc database
                System.Diagnostics.Debug.WriteLine($"Database Error: {ex.Message}");
                throw new Exception($"Lỗi khi thực hiện truy vấn: {ex.Message}");
            }

            return dataTable;
        }

        /// <summary>
        /// Thực hiện câu lệnh INSERT, UPDATE, DELETE
        /// </summary>
        /// <param name="query">Câu lệnh SQL</param>
        /// <param name="parameters">Danh sách tham số</param>
        /// <returns>Số dòng bị ảnh hưởng</returns>
        public static int ExecuteNonQuery(string query, params MySqlParameter[] parameters)
        {
            int result = 0;

            try
            {
                using (MySqlConnection connection = new MySqlConnection(ConnectionString))
                {
                    using (MySqlCommand command = new MySqlCommand(query, connection))
                    {
                        // Thêm tham số vào command
                        if (parameters != null)
                        {
                            command.Parameters.AddRange(parameters);
                        }

                        connection.Open();
                        result = command.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                // Log lỗi
                System.Diagnostics.Debug.WriteLine($"Database Error: {ex.Message}");
                throw new Exception($"Lỗi khi thực hiện câu lệnh: {ex.Message}");
            }

            return result;
        }

        /// <summary>
        /// Thực hiện truy vấn và trả về giá trị đơn (scalar)
        /// </summary>
        /// <param name="query">Câu truy vấn SQL</param>
        /// <param name="parameters">Danh sách tham số</param>
        /// <returns>Giá trị scalar</returns>
        public static object ExecuteScalar(string query, params MySqlParameter[] parameters)
        {
            object result = null;

            try
            {
                using (MySqlConnection connection = new MySqlConnection(ConnectionString))
                {
                    using (MySqlCommand command = new MySqlCommand(query, connection))
                    {
                        // Thêm tham số vào command
                        if (parameters != null)
                        {
                            command.Parameters.AddRange(parameters);
                        }

                        connection.Open();
                        result = command.ExecuteScalar();
                    }
                }
            }
            catch (Exception ex)
            {
                // Log lỗi
                System.Diagnostics.Debug.WriteLine($"Database Error: {ex.Message}");
                throw new Exception($"Lỗi khi thực hiện truy vấn scalar: {ex.Message}");
            }

            return result;
        }

        /// <summary>
        /// Thực hiện Stored Procedure
        /// </summary>
        /// <param name="procedureName">Tên stored procedure</param>
        /// <param name="parameters">Danh sách tham số</param>
        /// <returns>DataTable chứa kết quả</returns>
        public static DataTable ExecuteStoredProcedure(string procedureName, params MySqlParameter[] parameters)
        {
            DataTable dataTable = new DataTable();

            try
            {
                using (MySqlConnection connection = new MySqlConnection(ConnectionString))
                {
                    using (MySqlCommand command = new MySqlCommand(procedureName, connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        // Thêm tham số vào command
                        if (parameters != null)
                        {
                            command.Parameters.AddRange(parameters);
                        }

                        connection.Open();
                        using (MySqlDataAdapter adapter = new MySqlDataAdapter(command))
                        {
                            adapter.Fill(dataTable);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Log lỗi
                System.Diagnostics.Debug.WriteLine($"Database Error: {ex.Message}");
                throw new Exception($"Lỗi khi thực hiện stored procedure: {ex.Message}");
            }

            return dataTable;
        }

        /// <summary>
        /// Kiểm tra kết nối đến cơ sở dữ liệu
        /// </summary>
        /// <returns>True nếu kết nối thành công</returns>
        public static bool TestConnection()
        {
            try
            {
                using (MySqlConnection connection = new MySqlConnection(ConnectionString))
                {
                    connection.Open();
                    return true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Connection Error: {ex.Message}");
                return false;
            }
        }

        #endregion

        #region Phương thức hỗ trợ tham số

        /// <summary>
        /// Tạo tham số MySQL
        /// </summary>
        /// <param name="name">Tên tham số</param>
        /// <param name="value">Giá trị tham số</param>
        /// <returns>MySqlParameter</returns>
        public static MySqlParameter CreateParameter(string name, object value)
        {
            return new MySqlParameter(name, value ?? DBNull.Value);
        }

        /// <summary>
        /// Tạo tham số MySQL với kiểu dữ liệu cụ thể
        /// </summary>
        /// <param name="name">Tên tham số</param>
        /// <param name="value">Giá trị tham số</param>
        /// <param name="dbType">Kiểu dữ liệu MySQL</param>
        /// <returns>MySqlParameter</returns>
        public static MySqlParameter CreateParameter(string name, object value, MySqlDbType dbType)
        {
            return new MySqlParameter(name, dbType) { Value = value ?? DBNull.Value };
        }

        #endregion
    }
}