using Microsoft.AspNetCore.Mvc;
using demo.Models;
using System.Linq;

namespace demo.Controllers
{
    [Route("api/category")]
    [ApiController]
    public class CategoryController : ControllerBase
    {
        private readonly LibraryManagementContext _context;

        public CategoryController(LibraryManagementContext context)
        {
            _context = context;
        }

        // Lấy danh sách tất cả danh mục
        [HttpGet]
        public IActionResult GetAllCategories()
        {
            var categories = _context.Categories.ToList();
            return Ok(categories);
        }

        // Lấy chi tiết danh mục theo ID
        [HttpGet("{id}")]
        public IActionResult GetCategoryById(int id)
        {
            var category = _context.Categories.Find(id);
            if (category == null)
                return NotFound();
            return Ok(category);
        }

        // Thêm danh mục mới
        [HttpPost]
        public IActionResult CreateCategory([FromBody] Category category)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            _context.Categories.Add(category);
            _context.SaveChanges();
            return CreatedAtAction(nameof(GetCategoryById), new { id = category.CategoryId }, category);
        }

        // Cập nhật thông tin danh mục
        [HttpPut("{id}")]
        public IActionResult UpdateCategory(int id, [FromBody] Category category)
        {
            var existingCategory = _context.Categories.Find(id);
            if (existingCategory == null)
                return NotFound();

            existingCategory.CategoryName = category.CategoryName;

            _context.SaveChanges();
            return Ok(new
            {
                Message = $"Xóa thành công sách có mã  là {id}",
            });
        }

        // Xóa danh mục
        [HttpDelete("{id}")]
        public IActionResult DeleteCategory(int id)
        {
            var category = _context.Categories.Find(id);
            if (category == null)
                return NotFound();

            _context.Categories.Remove(category);
            _context.SaveChanges();
            return Ok(new
            {
                Message = $"Xóa thành công danh mục có mã  là {id}",
            });
        }
    }
}
