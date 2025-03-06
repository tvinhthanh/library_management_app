using demo.Models;

namespace demo.DTO
{
    public class BorrowDTO
    {
        public int BorrowingId { get; set; }
        public int? MemberId { get; set; }
        public DateTime BorrowDate { get; set; }
        public DateTime DueDate { get; set; }
        public DateTime? ReturnDate { get; set; }

    }
}
