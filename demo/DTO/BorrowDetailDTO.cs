namespace demo.DTO
{
    public class BorrowDetailDTO
    {
        public int BorrowDetailId { get; set; }
        public int BorrowId { get; set; }
        public int? BookId { get; set; }
        public int Quantity { get; set; }
    }
}
