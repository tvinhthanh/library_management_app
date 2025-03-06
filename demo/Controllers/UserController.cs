using Microsoft.AspNetCore.Mvc;
using demo.Models;
using System.Linq;

namespace demo.Controllers
{
    [Route("api/user")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly LibraryManagementContext _context;

        public UserController(LibraryManagementContext context)
        {
            _context = context;
        }

        // Lấy danh sách tất cả nhân viên và thành viên
        [HttpGet("all")]
        public IActionResult GetAllUsers()
        {
            var staff = _context.staff.ToList();
            var members = _context.Members.ToList();
            return Ok(new { Staff = staff, Members = members });
        }
        [HttpGet("staff/all")]
        public IActionResult GetAllStaff()
        {
            var staff = _context.staff.ToList();
            return Ok(new { Staff = staff });
        }
        [HttpGet("member/all")]
        public IActionResult GetAllMember()
        {
            var members = _context.Members.ToList();
            return Ok(new { Members = members });
        }
        // Lấy thông tin nhân viên theo ID
        [HttpGet("staff/{id}")]
        public IActionResult GetStaffById(int id)
        {
            var staff = _context.staff.Find(id);
            if (staff == null)
                return NotFound();
            return Ok(staff);
        }

        // Lấy thông tin thành viên theo ID
        [HttpGet("member/{id}")]
        public IActionResult GetMemberById(int id)
        {
            var member = _context.Members.Find(id);
            if (member == null)
                return NotFound();
            return Ok(member);
        }

        // Thêm nhân viên mới
        [HttpPost("staff")]
        public IActionResult CreateStaff([FromBody] staff staff)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            _context.staff.Add(staff);
            _context.SaveChanges();
            return CreatedAtAction(nameof(GetStaffById), new { id = staff.StaffId }, staff);
        }

        // Thêm thành viên mới
        [HttpPost("member")]
        public IActionResult CreateMember([FromBody] Member member)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            _context.Members.Add(member);
            _context.SaveChanges();
            return CreatedAtAction(nameof(GetMemberById), new { id = member.MemberId }, member);
        }

        // Cập nhật thông tin nhân viên
        [HttpPut("staff/{id}")]
        public IActionResult UpdateStaff(int id, [FromBody] staff staff)
        {
            var existingStaff = _context.staff.Find(id);
            if (existingStaff == null)
                return NotFound();

            existingStaff.Name = staff.Name;
            existingStaff.Position = staff.Position;
            existingStaff.Phone = staff.Phone;
            existingStaff.Email = staff.Email;

            _context.SaveChanges();
            return NoContent();
        }

        // Cập nhật thông tin thành viên
        [HttpPut("member/{id}")]
        public IActionResult UpdateMember(int id, [FromBody] Member member)
        {
            var existingMember = _context.Members.Find(id);
            if (existingMember == null)
                return NotFound();

            existingMember.Name = member.Name;
            existingMember.DateOfBirth = member.DateOfBirth;
            existingMember.Address = member.Address;
            existingMember.Phone = member.Phone;
            existingMember.Email = member.Email;

            _context.SaveChanges();
            return Ok(new
            {
                Message = $"Cập nhật thành công đọc giả có mã  là {id}",
            });
        }

        // Xóa nhân viên
        [HttpDelete("staff/{id}")]
        public IActionResult DeleteStaff(int id)
        {
            var staff = _context.staff.Find(id);
            if (staff == null)
                return NotFound();

            _context.staff.Remove(staff);
            _context.SaveChanges();
            return Ok(new
            {
                Message = $"Xóa thành công nhân viên có mã  là {id}",
            });
        }

        // Xóa thành viên
        [HttpDelete("member/{id}")]
        public IActionResult DeleteMember(int id)
        {
            var member = _context.Members.Find(id);
            if (member == null)
                return NotFound();

            _context.Members.Remove(member);
            _context.SaveChanges();
            return Ok(new
            {
                Message = $"Xóa thành công đọc giả có mã  là {id}",
            });
        }
    }
}
