using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace demo.Models
{
    // Tài khoản đăng nhập vào ứng dụng (tách biệt với staff/member nghiệp vụ)
    [Table("UserAccounts")]
    [Index(nameof(Username), IsUnique = true)]
    public partial class UserAccount
    {
        [Column("UserAccountID")]
        public int UserAccountId { get; set; }

        // Luôn lưu chữ thường để so sánh không phân biệt hoa thường
        [Required]
        [MaxLength(32)]
        public string Username { get; set; } = null!;

        [Required]
        [MaxLength(256)]
        public string PasswordHash { get; set; } = null!;

        [Required]
        [MaxLength(100)]
        public string FullName { get; set; } = null!;

        public DateTime CreatedAt { get; set; }
    }
}
