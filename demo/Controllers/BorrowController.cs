using Microsoft.AspNetCore.Mvc;
using demo.Models;
using System.Linq;
using System.Collections.Generic;
using demo.DTO;
using System.Text.Json;
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

        // Thêm phiếu mượn mới kèm danh sách sách mượn
        [HttpPost]
        public IActionResult CreateBorrow([FromBody] BorrowDTO request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var borrow = new Borrowing
            {
                MemberId = request.MemberId,
                BorrowDate = DateTime.Now,
                DueDate = request.DueDate,
                ReturnDate = null,
                StaffId = 1,
            };

            _context.Borrowings.Add(borrow);
            _context.SaveChanges(); // Lưu vào database

            return CreatedAtAction(nameof(GetBorrowById), new { id = borrow.BorrowingId }, borrow);
        }

        [HttpPost("{borrowId}/add-book")]
        public IActionResult AddBookToBorrow(int borrowId, [FromBody] BorrowDetailDTO request)
        {
            if (request == null || request.BookId <= 0)
            {
                return BadRequest("Thông tin sách không hợp lệ.");
            }

            var borrow = _context.Borrowings.Find(borrowId);
            if (borrow == null)
                return NotFound("Không tìm thấy phiếu mượn!");

            // ✅ Sửa: Thêm đúng entity vào database
            var newBorrowDetail = new BorrowDetail
            {
                BorrowId = borrowId,
                BookId = request.BookId,
                Quantity = request.Quantity
            };

            _context.BorrowDetails.Add(newBorrowDetail);
            _context.SaveChanges();

            var responseDto = new BorrowDetailDTO
            {
                BorrowId = newBorrowDetail.BorrowId,
                BookId = newBorrowDetail.BookId,
                Quantity = newBorrowDetail.Quantity
            };

            return Ok(responseDto);
        }


        // Cập nhật phiếu mượn (chỉ cập nhật thông tin chung, không sửa chi tiết sách mượn)
        [HttpPut("{id}")]
        public IActionResult UpdateBorrow(int id, [FromBody] BorrowDTO borrow)
        {
            var existingBorrow = _context.Borrowings.Find(id);
            if (existingBorrow == null)
                return NotFound();

            existingBorrow.MemberId = borrow.MemberId;
            existingBorrow.BorrowDate = borrow.BorrowDate;
            existingBorrow.DueDate = borrow.DueDate;
            existingBorrow.ReturnDate = borrow.ReturnDate;

            _context.SaveChanges();
            return Ok(new { Message = $"Cập nhật thành công phiếu mượn có mã {id}" });
        }
        [HttpPut("{borrowId}/return")]
        public async Task<IActionResult> ReturnBorrow(int borrowId, [FromQuery] DateTime? returnDate)
        {
            try
            {
                using (var transaction = await _context.Database.BeginTransactionAsync())
                {
                    // ✅ Xóa chi tiết phiếu thuê (BorrowDetails)
                    var borrowDetails = _context.BorrowDetails.Where(b => b.BorrowId == borrowId);
                    _context.BorrowDetails.RemoveRange(borrowDetails);

                    // ✅ Cập nhật returnDate trong bảng Borrowings
                    var borrow = await _context.Borrowings.FindAsync(borrowId);
                    if (borrow == null)
                    {
                        return NotFound(new { message = "Phiếu thuê không tồn tại!" });
                    }

                    borrow.ReturnDate = returnDate ?? DateTime.Now;
                    await _context.SaveChangesAsync();
                    await transaction.CommitAsync();

                    return Ok(new { message = "Trả sách thành công!" });
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }
        [HttpDelete("{borrowId}/remove-book/{bookId}")]
        public async Task<IActionResult> RemoveBookFromBorrowing(int borrowId, int bookId)
        {
            try
            {
                var borrowing = await _context.Borrowings
                    .Include(b => b.BorrowDetails)
                    .FirstOrDefaultAsync(b => b.BorrowingId == borrowId);

                if (borrowing == null)
                {
                    return NotFound(new { message = "Phiếu mượn không tồn tại." });
                }

                var borrowDetail = borrowing.BorrowDetails.FirstOrDefault(d => d.BookId == bookId);
                if (borrowDetail == null)
                {
                    return NotFound(new { message = "Sách không có trong phiếu mượn." });
                }

                // Xóa chi tiết sách khỏi phiếu mượn
                _context.BorrowDetails.Remove(borrowDetail);
                await _context.SaveChangesAsync();

                return Ok(new { message = "Xóa sách khỏi phiếu mượn thành công." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // Xóa phiếu mượn (sẽ tự động xóa chi tiết phiếu mượn nhờ ràng buộc khóa ngoại)
        [HttpDelete("{id}")]
        public IActionResult DeleteBorrow(int id)
        {
            var borrow = _context.Borrowings.Find(id);
            if (borrow == null)
                return NotFound();

            _context.Borrowings.Remove(borrow);
            _context.SaveChanges();

            return Ok(new { Message = $"Xóa thành công phiếu mượn có mã {id}" });
        }
    }

    // Định nghĩa model cho request thêm phiếu mượn kèm sách
    public class BorrowRequest
    {
        public int MemberId { get; set; }
        public DateTime BorrowDate { get; set; }
        public DateTime DueDate { get; set; }
        public DateTime? ReturnDate { get; set; }
        public int StaffId { get; set; }
        public List<BorrowBook> Books { get; set; }
    }

    public class BorrowBook
    {
        public int BookID { get; set; }
        public int Quantity { get; set; }
    }
}
