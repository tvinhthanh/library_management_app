using Microsoft.AspNetCore.Mvc;
using demo.Models;
using System.Linq;
using System.Collections.Generic;
using demo.DTO;

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
            _context.SaveChanges();

            return CreatedAtAction(nameof(GetBorrowById), new { id = borrow.BorrowingId }, borrow);
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
