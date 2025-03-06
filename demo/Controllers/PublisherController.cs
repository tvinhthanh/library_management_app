using Microsoft.AspNetCore.Mvc;
using demo.Models;
using System.Linq;
using demo.DTO;

namespace demo.Controllers
{
    [Route("api/publishers")]
    [ApiController]
    public class PublisherController : ControllerBase
    {
        private readonly LibraryManagementContext _context;

        public PublisherController(LibraryManagementContext context)
        {
            _context = context;
        }

        // Lấy danh sách tất cả nhà xuất bản
        [HttpGet]
        public IActionResult GetAllPublishers()
        {
            var publishers = _context.Publishers.ToList();
            return Ok(publishers);
        }

        // Lấy chi tiết nhà xuất bản theo ID
        [HttpGet("{id}")]
        public IActionResult GetPublisherById(int id)
        {
            var publisher = _context.Publishers.Find(id);
            if (publisher == null)
                return NotFound();
            return Ok(publisher);
        }

        [HttpPost]
        public IActionResult CreatePublisher([FromBody] PublisherDTO publisherDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var publisher = new Publisher
            {
                PublisherName = publisherDto.PublisherName,
                Address = publisherDto.Address
            };

            _context.Publishers.Add(publisher);
            _context.SaveChanges();

            return CreatedAtAction(nameof(GetPublisherById), new { id = publisher.PublisherId }, publisher);
        }


        // Cập nhật thông tin nhà xuất bản
        [HttpPut("{id}")]
        public IActionResult UpdatePublisher(int id, [FromBody] Publisher publisher)
        {
            var existingPublisher = _context.Publishers.Find(id);
            if (existingPublisher == null)
                return NotFound();

            existingPublisher.PublisherName = publisher.PublisherName;
            existingPublisher.Address = publisher.Address;

            _context.SaveChanges();
            return Ok(new
            {
                Message = $"Xóa thành công tác giả có mã  là {id}",
            });

        }

        // Xóa nhà xuất bản
        [HttpDelete("{id}")]
        public IActionResult DeletePublisher(int id)
        {
            var publisher = _context.Publishers.Find(id);
            if (publisher == null)
                return NotFound();

            _context.Publishers.Remove(publisher);
            _context.SaveChanges();
            return Ok(new
            {
                Message = $"Xóa thành công tác giả có mã  là {id}",
            });

        }
    }
}
