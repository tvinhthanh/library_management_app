using demo.Models;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace demo.Services
{
    public class TokenService
    {
        public const string Issuer = "library-api";
        public const string Audience = "library-app";
        private static readonly TimeSpan Lifetime = TimeSpan.FromHours(12);

        private readonly IConfiguration _config;

        public TokenService(IConfiguration config)
        {
            _config = config;
        }

        public static SymmetricSecurityKey CreateSigningKey(IConfiguration config)
        {
            return new SymmetricSecurityKey(Encoding.UTF8.GetBytes(config["Jwt:Key"]!));
        }

        public (string Token, DateTime ExpiresAt) Create(UserAccount account)
        {
            var expires = DateTime.UtcNow.Add(Lifetime);
            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, account.UserAccountId.ToString()),
                new Claim(ClaimTypes.Name, account.Username),
            };

            var credentials = new SigningCredentials(CreateSigningKey(_config), SecurityAlgorithms.HmacSha256);
            var jwt = new JwtSecurityToken(Issuer, Audience, claims, expires: expires, signingCredentials: credentials);

            return (new JwtSecurityTokenHandler().WriteToken(jwt), expires);
        }
    }
}
