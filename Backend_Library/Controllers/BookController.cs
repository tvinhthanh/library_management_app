using Microsoft.AspNetCore.Mvc;
using Backend_Library.Models;
using System.Linq;

namespace Backend_Library.Controllers
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

        // Lấy chi tiết sách theo ID
        [HttpGet("{id}")]
        public IActionResult GetBookById(int id)
        {
            var book = _context.Books.Find(id);
            if (book == null)
                return NotFound();
            return Ok(book);
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

        // Cập nhật thông tin sách
        [HttpPut("{id}")]
        public IActionResult UpdateBook(int id, [FromBody] Book book)
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

            _context.SaveChanges();
            return NoContent();
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
            return NoContent();
        }
    }
}
