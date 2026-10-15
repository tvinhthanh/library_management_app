using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using System.Text.RegularExpressions;
using demo.DTO;
using demo.Models;
using demo.Services;

namespace demo.Controllers
{
    [Route("api/auth")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private static readonly Regex UsernamePattern = new(@"^[a-z0-9_.]{3,32}$", RegexOptions.CultureInvariant);

        // Hash giả dùng khi tài khoản không tồn tại, để thời gian phản hồi không lộ việc tài khoản có hay không
        private static readonly string DummyHash = PasswordService.Hash("dummy-password-for-timing");

        private readonly LibraryManagementContext _context;
        private readonly TokenService _tokens;

        public AuthController(LibraryManagementContext context, TokenService tokens)
        {
            _context = context;
            _tokens = tokens;
        }

        // Đăng ký tài khoản mới, trả về token để đăng nhập luôn
        [AllowAnonymous]
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDTO request)
        {
            var username = (request.Username ?? string.Empty).Trim().ToLowerInvariant();
            var fullName = (request.FullName ?? string.Empty).Trim();

            if (!UsernamePattern.IsMatch(username))
                return BadRequest(new { message = "Tên đăng nhập 3–32 ký tự, chỉ gồm chữ thường, số, dấu chấm hoặc gạch dưới." });

            if (fullName.Length == 0 || fullName.Length > 100)
                return BadRequest(new { message = "Họ tên không được để trống (tối đa 100 ký tự)." });

            var passwordError = ValidatePassword(request.Password);
            if (passwordError != null)
                return BadRequest(new { message = passwordError });

            if (await _context.UserAccounts.AnyAsync(u => u.Username == username))
                return Conflict(new { message = "Tên đăng nhập đã tồn tại." });

            var account = new UserAccount
            {
                Username = username,
                FullName = fullName,
                PasswordHash = PasswordService.Hash(request.Password),
                CreatedAt = DateTime.UtcNow
            };

            try
            {
                _context.UserAccounts.Add(account);
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                // Hai yêu cầu đăng ký cùng tên gần như đồng thời: unique index chặn bản thứ hai
                return Conflict(new { message = "Tên đăng nhập đã tồn tại." });
            }

            return StatusCode(StatusCodes.Status201Created, BuildResponse(account));
        }

        // Đăng nhập, trả về JWT
        [AllowAnonymous]
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDTO request)
        {
            var username = (request.Username ?? string.Empty).Trim().ToLowerInvariant();
            var password = request.Password ?? string.Empty;

            var account = await _context.UserAccounts.FirstOrDefaultAsync(u => u.Username == username);

            if (account == null)
            {
                // Vẫn băm để tốn cùng thời gian như trường hợp đúng tài khoản
                PasswordService.Verify(password, DummyHash);
                return Unauthorized(new { message = "Sai tên đăng nhập hoặc mật khẩu." });
            }

            if (!PasswordService.Verify(password, account.PasswordHash))
                return Unauthorized(new { message = "Sai tên đăng nhập hoặc mật khẩu." });

            return Ok(BuildResponse(account));
        }

        // Kiểm tra token còn hợp lệ và lấy thông tin người đang đăng nhập
        [HttpGet("me")]
        public async Task<IActionResult> Me()
        {
            var idValue = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(idValue, out var id))
                return Unauthorized();

            var account = await _context.UserAccounts.FindAsync(id);
            if (account == null)
                return Unauthorized();

            return Ok(new CurrentUserDTO
            {
                UserAccountId = account.UserAccountId,
                Username = account.Username,
                FullName = account.FullName
            });
        }

        private AuthResponseDTO BuildResponse(UserAccount account)
        {
            var (token, expiresAt) = _tokens.Create(account);
            return new AuthResponseDTO
            {
                Token = token,
                ExpiresAt = expiresAt,
                Username = account.Username,
                FullName = account.FullName
            };
        }

        private static string? ValidatePassword(string? password)
        {
            if (string.IsNullOrEmpty(password) || password.Length < 8 || password.Length > 128)
                return "Mật khẩu phải từ 8 đến 128 ký tự.";
            if (!password.Any(char.IsLetter) || !password.Any(char.IsDigit))
                return "Mật khẩu phải có cả chữ và số.";
            return null;
        }
    }
}
