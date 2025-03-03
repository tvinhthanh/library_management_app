using System;
using System.Collections.Generic;

namespace Backend_Library.Models
{
    public partial class Publisher
    {
        public Publisher()
        {
            Books = new HashSet<Book>();
        }

        public int PublisherId { get; set; }
        public string PublisherName { get; set; } = null!;
        public string? Address { get; set; }

        public virtual ICollection<Book> Books { get; set; }
    }
}
