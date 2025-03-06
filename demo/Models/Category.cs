﻿using System;
using System.Collections.Generic;

namespace demo.Models
{
    public partial class Category
    {
        public Category()
        {
            Books = new HashSet<Book>();
        }

        public int CategoryId { get; set; }
        public string CategoryName { get; set; } = null!;

        public virtual ICollection<Book> Books { get; set; }
    }
}
