using System;
using System.Collections.Generic;

namespace demo.Models
{
    public partial class Book
    {
        public Book()
        {
            BorrowDetails = new HashSet<BorrowDetail>();
            Borrowings = new HashSet<Borrowing>();
        }

        public int BookId { get; set; }
        public string Title { get; set; } = null!;
        public int? AuthorId { get; set; }
        public int? CategoryId { get; set; }
        public int? PublisherId { get; set; }
        public int? PublishedYear { get; set; }
        public string? Isbn { get; set; }
        public int? Quantity { get; set; }

        public virtual Author? Author { get; set; }
        public virtual Category? Category { get; set; }
        public virtual Publisher? Publisher { get; set; }
        public virtual ICollection<BorrowDetail> BorrowDetails { get; set; }
        public virtual ICollection<Borrowing> Borrowings { get; set; }
    }
}
