using Microsoft.AspNetCore.Mvc;
using demo.Models;
using demo.DTO;
using Microsoft.EntityFrameworkCore;

namespace demo.Controllers
{
    [Route("api/borrow")]
    [ApiController]
    public class BorrowController : ControllerBase
    {
        private readonly LibraryManagementContext _context;

        public BorrowController(LibraryManagementContext context)
        {
            _context = context;
        }

        // Lấy danh sách tất cả phiếu mượn kèm chi tiết sách
        [HttpGet]
        public IActionResult GetAllBorrows()
        {
            var borrows = _context.Borrowings
                .Select(b => new
                {
                    b.BorrowingId,
                    b.MemberId,
                    b.BorrowDate,
                    b.DueDate,
                    b.ReturnDate,
                    b.StaffId,
                    Books = _context.BorrowDetails
                        .Where(d => d.BorrowId == b.BorrowingId)
                        .Select(d => new { d.BookId, d.Quantity })
                        .ToList()
                }).ToList();

            return Ok(borrows);
        }

        // Lấy chi tiết phiếu mượn theo ID (kèm danh sách sách mượn)
        [HttpGet("{id}")]
        public IActionResult GetBorrowById(int id)
        {
            var borrow = _context.Borrowings
                .Where(b => b.BorrowingId == id)
                .Select(b => new
                {
                    b.BorrowingId,
                    b.MemberId,
                    b.BorrowDate,
                    b.DueDate,
                    b.ReturnDate,
                    b.StaffId,
                    Books = _context.BorrowDetails
                        .Where(d => d.BorrowId == b.BorrowingId)
                        .Select(d => new { d.BookId, d.Quantity })
                        .ToList()
                }).FirstOrDefault();

            if (borrow == null)
                return NotFound();

            return Ok(borrow);
        }

        // Thêm phiếu mượn mới (chưa có sách)
        [HttpPost]
        public async Task<IActionResult> CreateBorrow([FromBody] BorrowDTO request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            if (request.MemberId == null || !await _context.Members.AnyAsync(m => m.MemberId == request.MemberId.Value))
                return BadRequest(new { message = "Thành viên không tồn tại." });

            if (request.DueDate.Date < DateTime.Today)
                return BadRequest(new { message = "Hạn trả không được trước hôm nay." });

            var borrow = new Borrowing
            {
                MemberId = request.MemberId,
                BorrowDate = DateTime.Now,
                DueDate = request.DueDate,
                ReturnDate = null,
                StaffId = 1,
            };

            _context.Borrowings.Add(borrow);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetBorrowById), new { id = borrow.BorrowingId }, borrow);
        }

        // Thêm sách vào phiếu mượn: trừ tồn kho, cộng dồn nếu sách đã có trong phiếu
        [HttpPost("{borrowId}/add-book")]
        public async Task<IActionResult> AddBookToBorrow(int borrowId, [FromBody] BorrowDetailDTO request)
        {
            if (request == null || request.BookId == null || request.BookId <= 0)
                return BadRequest("Thông tin sách không hợp lệ.");

            if (request.Quantity < 1)
                return BadRequest("Số lượng phải lớn hơn 0.");

            var bookId = request.BookId.Value;

            using var transaction = await _context.Database.BeginTransactionAsync();

            var borrow = await _context.Borrowings.FindAsync(borrowId);
            if (borrow == null)
                return NotFound("Không tìm thấy phiếu mượn!");

            if (borrow.ReturnDate != null)
                return BadRequest("Phiếu mượn đã trả, không thể thêm sách.");

            var book = await _context.Books.FindAsync(bookId);
            if (book == null)
                return NotFound("Không tìm thấy sách!");

            var available = book.Quantity ?? 0;
            if (request.Quantity > available)
                return BadRequest(new { message = $"Không đủ sách trong kho. Hiện còn {available} cuốn." });

            book.Quantity = available - request.Quantity;

            var detail = await _context.BorrowDetails
                .FirstOrDefaultAsync(d => d.BorrowId == borrowId && d.BookId == bookId);

            if (detail == null)
            {
                detail = new BorrowDetail
                {
                    BorrowId = borrowId,
                    BookId = bookId,
                    Quantity = request.Quantity
                };
                _context.BorrowDetails.Add(detail);
            }
            else
            {
                detail.Quantity += request.Quantity;
            }

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();

            return Ok(new BorrowDetailDTO
            {
                BorrowDetailId = detail.BorrowDetailId,
                BorrowId = detail.BorrowId,
                BookId = detail.BookId,
                Quantity = detail.Quantity
            });
        }

        // Cập nhật thông tin chung của phiếu mượn (không đổi ngày trả và chi tiết sách)
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateBorrow(int id, [FromBody] BorrowDTO borrow)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var existingBorrow = await _context.Borrowings.FindAsync(id);
            if (existingBorrow == null)
                return NotFound();

            if (borrow.MemberId == null || !await _context.Members.AnyAsync(m => m.MemberId == borrow.MemberId.Value))
                return BadRequest(new { message = "Thành viên không tồn tại." });

            var borrowDate = borrow.BorrowDate == default ? existingBorrow.BorrowDate : borrow.BorrowDate;
            if (borrow.DueDate.Date < borrowDate.Date)
                return BadRequest(new { message = "Hạn trả không được trước ngày mượn." });

            existingBorrow.MemberId = borrow.MemberId;
            existingBorrow.BorrowDate = borrowDate;
            existingBorrow.DueDate = borrow.DueDate;

            await _context.SaveChangesAsync();
            return Ok(new { Message = $"Cập nhật thành công phiếu mượn có mã {id}" });
        }

        // Trả sách: cộng lại tồn kho, giữ nguyên chi tiết phiếu để còn lưu lịch sử
        [HttpPut("{borrowId}/return")]
        public async Task<IActionResult> ReturnBorrow(int borrowId, [FromQuery] DateTime? returnDate)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();

            var borrow = await _context.Borrowings
                .Include(b => b.BorrowDetails)
                .FirstOrDefaultAsync(b => b.BorrowingId == borrowId);

            if (borrow == null)
                return NotFound(new { message = "Phiếu thuê không tồn tại!" });

            if (borrow.ReturnDate != null)
                return BadRequest(new { message = "Phiếu mượn này đã được trả trước đó." });

            var actualReturnDate = returnDate ?? DateTime.Now;
            if (actualReturnDate.Date < borrow.BorrowDate.Date)
                return BadRequest(new { message = "Ngày trả không được trước ngày mượn." });

            foreach (var detail in borrow.BorrowDetails)
            {
                await ChangeStockAsync(detail.BookId, detail.Quantity);
            }

            borrow.ReturnDate = actualReturnDate;
            await _context.SaveChangesAsync();
            await transaction.CommitAsync();

            return Ok(new { message = "Trả sách thành công!" });
        }

        // Xóa một sách khỏi phiếu mượn: hoàn lại tồn kho
        [HttpDelete("{borrowId}/remove-book/{bookId}")]
        public async Task<IActionResult> RemoveBookFromBorrowing(int borrowId, int bookId)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();

            var borrowing = await _context.Borrowings
                .Include(b => b.BorrowDetails)
                .FirstOrDefaultAsync(b => b.BorrowingId == borrowId);

            if (borrowing == null)
                return NotFound(new { message = "Phiếu mượn không tồn tại." });

            if (borrowing.ReturnDate != null)
                return BadRequest(new { message = "Phiếu mượn đã trả, không thể xóa sách khỏi phiếu." });

            var borrowDetail = borrowing.BorrowDetails.FirstOrDefault(d => d.BookId == bookId);
            if (borrowDetail == null)
                return NotFound(new { message = "Sách không có trong phiếu mượn." });

            await ChangeStockAsync(borrowDetail.BookId, borrowDetail.Quantity);
            _context.BorrowDetails.Remove(borrowDetail);

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();

            return Ok(new { message = "Xóa sách khỏi phiếu mượn thành công." });
        }

        // Xóa phiếu mượn: nếu chưa trả thì hoàn lại tồn kho của các sách đang mượn
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteBorrow(int id)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();

            var borrow = await _context.Borrowings
                .Include(b => b.BorrowDetails)
                .FirstOrDefaultAsync(b => b.BorrowingId == id);

            if (borrow == null)
                return NotFound();

            if (borrow.ReturnDate == null)
            {
                foreach (var detail in borrow.BorrowDetails)
                {
                    await ChangeStockAsync(detail.BookId, detail.Quantity);
                }
            }

            _context.BorrowDetails.RemoveRange(borrow.BorrowDetails);
            _context.Borrowings.Remove(borrow);

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();

            return Ok(new { Message = $"Xóa thành công phiếu mượn có mã {id}" });
        }

        // Cộng (delta dương) hoặc trừ (delta âm) tồn kho của một sách
        private async Task ChangeStockAsync(int? bookId, int delta)
        {
            if (bookId == null)
                return;

            var book = await _context.Books.FindAsync(bookId.Value);
            if (book != null)
                book.Quantity = (book.Quantity ?? 0) + delta;
        }
    }
}
