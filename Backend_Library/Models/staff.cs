using System;
using System.Collections.Generic;

namespace Backend_Library.Models
{
    public partial class staff
    {
        public staff()
        {
            Borrowings = new HashSet<Borrowing>();
        }

        public int StaffId { get; set; }
        public string Name { get; set; } = null!;
        public string? Position { get; set; }
        public string? Phone { get; set; }
        public string? Email { get; set; }

        public virtual ICollection<Borrowing> Borrowings { get; set; }
    }
}
