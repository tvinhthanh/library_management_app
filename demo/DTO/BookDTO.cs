namespace demo.DTO
{
    public class BookDTO
    {
        public int BookId { get; set; }
        public string Title { get; set; } = null!;
        public int? AuthorId { get; set; }
        //public string? AuthorName { get; set; }
        public int? CategoryId { get; set; }
        //public string? CategoryName { get; set; }
        public int? PublisherId { get; set; }
        //public string? PublisherName { get; set; }
        public int? PublishedYear { get; set; }
        public string? Isbn { get; set; }
        public int? Quantity { get; set; }
    }
}
