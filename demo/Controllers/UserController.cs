using Microsoft.AspNetCore.Mvc;
using demo.Models;
using System.Linq;
using Microsoft.EntityFrameworkCore;

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

        // Thêm nhân viên mới (chỉ nhận các trường nghiệp vụ, không nhận id hay danh sách liên kết từ client)
        [HttpPost("staff")]
        public async Task<IActionResult> CreateStaff([FromBody] staff request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            if (string.IsNullOrWhiteSpace(request.Name))
                return BadRequest(new { message = "Tên nhân viên không được để trống." });

            var staff = new staff
            {
                Name = request.Name,
                Position = request.Position,
                Phone = request.Phone,
                Email = request.Email
            };

            try
            {
                _context.staff.Add(staff);
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                return BadRequest(new { message = "Không thể thêm nhân viên (có thể trùng số điện thoại hoặc email)." });
            }

            return CreatedAtAction(nameof(GetStaffById), new { id = staff.StaffId }, staff);
        }

        // Thêm thành viên mới (chỉ nhận các trường nghiệp vụ)
        [HttpPost("member")]
        public async Task<IActionResult> CreateMember([FromBody] Member request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            if (string.IsNullOrWhiteSpace(request.Name))
                return BadRequest(new { message = "Tên đọc giả không được để trống." });

            var member = new Member
            {
                Name = request.Name,
                DateOfBirth = request.DateOfBirth,
                Address = request.Address,
                Phone = request.Phone,
                Email = request.Email
            };

            try
            {
                _context.Members.Add(member);
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                return BadRequest(new { message = "Không thể thêm đọc giả (có thể trùng số điện thoại hoặc email)." });
            }

            return CreatedAtAction(nameof(GetMemberById), new { id = member.MemberId }, member);
        }

        // Cập nhật thông tin nhân viên
        [HttpPut("staff/{id}")]
        public async Task<IActionResult> UpdateStaff(int id, [FromBody] staff staff)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            if (string.IsNullOrWhiteSpace(staff.Name))
                return BadRequest(new { message = "Tên nhân viên không được để trống." });

            var existingStaff = await _context.staff.FindAsync(id);
            if (existingStaff == null)
                return NotFound();

            existingStaff.Name = staff.Name;
            existingStaff.Position = staff.Position;
            existingStaff.Phone = staff.Phone;
            existingStaff.Email = staff.Email;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                return BadRequest(new { message = "Không thể cập nhật nhân viên (có thể trùng số điện thoại hoặc email)." });
            }

            return NoContent();
        }

        // Cập nhật thông tin thành viên
        [HttpPut("member/{id}")]
        public async Task<IActionResult> UpdateMember(int id, [FromBody] Member member)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            if (string.IsNullOrWhiteSpace(member.Name))
                return BadRequest(new { message = "Tên đọc giả không được để trống." });

            var existingMember = await _context.Members.FindAsync(id);
            if (existingMember == null)
                return NotFound();

            existingMember.Name = member.Name;
            existingMember.DateOfBirth = member.DateOfBirth;
            existingMember.Address = member.Address;
            existingMember.Phone = member.Phone;
            existingMember.Email = member.Email;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                return BadRequest(new { message = "Không thể cập nhật đọc giả (có thể trùng số điện thoại hoặc email)." });
            }

            return Ok(new
            {
                Message = $"Cập nhật thành công đọc giả có mã {id}",
            });
        }

        // Xóa nhân viên: không cho xóa nếu còn phiếu mượn do nhân viên này lập
        [HttpDelete("staff/{id}")]
        public async Task<IActionResult> DeleteStaff(int id)
        {
            var staff = await _context.staff.FindAsync(id);
            if (staff == null)
                return NotFound();

            if (await _context.Borrowings.AnyAsync(b => b.StaffId == id))
                return Conflict(new { message = "Nhân viên đã lập phiếu mượn nên không thể xóa." });

            _context.staff.Remove(staff);
            await _context.SaveChangesAsync();
            return Ok(new
            {
                Message = $"Xóa thành công nhân viên có mã {id}",
            });
        }

        // Xóa thành viên: không cho xóa nếu đã có phiếu mượn
        [HttpDelete("member/{id}")]
        public async Task<IActionResult> DeleteMember(int id)
        {
            var member = await _context.Members.FindAsync(id);
            if (member == null)
                return NotFound();

            if (await _context.Borrowings.AnyAsync(b => b.MemberId == id))
                return Conflict(new { message = "Đọc giả đã có phiếu mượn nên không thể xóa." });

            _context.Members.Remove(member);
            await _context.SaveChangesAsync();
            return Ok(new
            {
                Message = $"Xóa thành công đọc giả có mã {id}",
            });
        }
    }
}
