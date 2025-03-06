using Microsoft.AspNetCore.Mvc;
using demo.Models;
using System.Linq;

namespace demo.Controllers
{
    [Route("api/author")]
    [ApiController]
    public class AuthorController : ControllerBase
    {
        private readonly LibraryManagementContext _context;

        public AuthorController(LibraryManagementContext context)
        {
            _context = context;
        }

        // Lấy danh sách tất cả tác giả
        [HttpGet]
        public IActionResult GetAllAuthors()
        {
            var authors = _context.Authors.ToList();
            return Ok(authors);
        }

        // Lấy chi tiết tác giả theo ID
        [HttpGet("{id}")]
        public IActionResult GetAuthorById(int id)
        {
            var author = _context.Authors.Find(id);
            if (author == null)
                return NotFound();
            return Ok(author);
        }

        // Thêm tác giả mới
        [HttpPost]
        public IActionResult CreateAuthor([FromBody] Author author)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            _context.Authors.Add(author);
            _context.SaveChanges();
            return CreatedAtAction(nameof(GetAuthorById), new { id = author.AuthorId }, author);
        }

        // Cập nhật thông tin tác giả
        [HttpPut("{id}")]
        public IActionResult UpdateAuthor(int id, [FromBody] Author author)
        {
            var existingAuthor = _context.Authors.Find(id);
            if (existingAuthor == null)
                return NotFound();

            existingAuthor.Name = author.Name;
            existingAuthor.Bio = author.Bio;

            _context.SaveChanges();
            return Ok(new
            {
                Message = $"Xóa thành công tác giả có mã  là {id}",
            });

        }

        // Xóa tác giả
        [HttpDelete("{id}")]
        public IActionResult DeleteAuthor(int id)
        {
            var author = _context.Authors.Find(id);
            if (author == null)
                return NotFound();

            _context.Authors.Remove(author);
            _context.SaveChanges();


            return Ok(new
            {
                Message = $"Xóa thành công tác giả có mã  là {id}",
            });

        }
    }
}
