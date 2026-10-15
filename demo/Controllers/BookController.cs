using Microsoft.AspNetCore.Mvc;
using demo.Models;
using System.Linq;
using demo.DTO;
using Microsoft.EntityFrameworkCore;

namespace demo.Controllers
{
    [Route("api/book")]
    [ApiController]
    public class BookController : ControllerBase
    {
        private readonly LibraryManagementContext _context;

        public BookController(LibraryManagementContext context)
        {
            _context = context;
        }

        // Lấy danh sách tất cả sách
        [HttpGet]
        public IActionResult GetAllBooks()
        {
            var books = _context.Books.ToList();
            return Ok(books);
        }

        [HttpGet("{id}")]
        public IActionResult GetBookById(int id)
        {
            var book = _context.Books
                .Where(b => b.BookId == id)
                .Select(b => new
                {
                    b.BookId,
                    b.Title,
                    AuthorId = b.Author != null ? b.Author.AuthorId : (int?)null,
                    CategoryId = b.Category != null ? b.Category.CategoryId : (int?)null,
                    PublisherId = b.Publisher != null ? b.Publisher.PublisherId : (int?)null,
                    b.PublishedYear,
                    b.Isbn,
                    b.Quantity
                })
                .FirstOrDefault();

            if (book == null)
                return NotFound();

            return Ok(book);
        }

        // Cập nhật thông tin sách
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateBook(int id, [FromBody] BookDTO book)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var error = ValidateBook(book);
            if (error != null)
                return BadRequest(new { message = error });

            var existingBook = await _context.Books.FindAsync(id);
            if (existingBook == null)
                return NotFound();

            existingBook.Title = book.Title;
            existingBook.AuthorId = book.AuthorId;
            existingBook.CategoryId = book.CategoryId;
            existingBook.PublisherId = book.PublisherId;
            existingBook.PublishedYear = book.PublishedYear;
            existingBook.Isbn = book.Isbn;
            existingBook.Quantity = book.Quantity;

            try
            {
                await _context.SaveChangesAsync();
                return Ok(new { Message = $"Cập nhật thành công sách có mã {id}" });
            }
            catch (DbUpdateException)
            {
                return BadRequest(new { Message = "Lỗi khi cập nhật sách (có thể trùng ISBN hoặc khoá ngoại không tồn tại)." });
            }
        }

        // Thêm sách mới (chỉ nhận các trường nghiệp vụ, không nhận id hay danh sách liên kết từ client)
        [HttpPost]
        public async Task<IActionResult> CreateBook([FromBody] BookDTO request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var error = ValidateBook(request);
            if (error != null)
                return BadRequest(new { message = error });

            var book = new Book
            {
                Title = request.Title,
                AuthorId = request.AuthorId,
                CategoryId = request.CategoryId,
                PublisherId = request.PublisherId,
                PublishedYear = request.PublishedYear,
                Isbn = request.Isbn,
                Quantity = request.Quantity ?? 0
            };

            try
            {
                _context.Books.Add(book);
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                return BadRequest(new { message = "Không thể thêm sách (có thể trùng ISBN hoặc khoá ngoại không tồn tại)." });
            }

            return CreatedAtAction(nameof(GetBookById), new { id = book.BookId }, book);
        }

        // Xóa sách: không cho xóa nếu sách đã từng nằm trong phiếu mượn (giữ lịch sử mượn)
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteBook(int id)
        {
            var book = await _context.Books.FindAsync(id);
            if (book == null)
                return NotFound();

            var inUse = await _context.BorrowDetails.AnyAsync(d => d.BookId == id)
                || await _context.Borrowings.AnyAsync(b => b.BookId == id);
            if (inUse)
                return Conflict(new { message = "Sách đã có trong phiếu mượn nên không thể xóa." });

            _context.Books.Remove(book);
            await _context.SaveChangesAsync();

            return Ok(new { Message = $"Xóa thành công sách có mã {id}" });
        }

        private static string? ValidateBook(BookDTO book)
        {
            if (string.IsNullOrWhiteSpace(book.Title))
                return "Tên sách không được để trống.";
            if (book.Quantity < 0)
                return "Số lượng không được âm.";
            return null;
        }
    }
}
