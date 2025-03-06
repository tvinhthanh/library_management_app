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
        public IActionResult UpdateBook(int id, [FromBody] BookDTO book)
        {
            var existingBook = _context.Books.Find(id);
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
                _context.SaveChanges();
                return Ok(new { Message = $"Cập nhật thành công sách có mã {id}" });
            }
            catch (DbUpdateException ex)
            {
                return BadRequest(new
                {
                    Message = "Lỗi khi cập nhật sách",
                    Error = ex.InnerException?.Message ?? ex.Message
                });
            }

        }

        // Thêm sách mới
        [HttpPost]
        public IActionResult CreateBook([FromBody] Book book)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            _context.Books.Add(book);
            _context.SaveChanges();
            return CreatedAtAction(nameof(GetBookById), new { id = book.BookId }, book);
        }


        // Xóa sách
        [HttpDelete("{id}")]
        public IActionResult DeleteBook(int id)
        {
            var book = _context.Books.Find(id);
            if (book == null)
                return NotFound();

            _context.Books.Remove(book);
            _context.SaveChanges();

            return Ok(new
            {
                Message = $"Xóa thành công sách có mã  là {id}",
            });


            //return NoContent();
        }
    }
}
