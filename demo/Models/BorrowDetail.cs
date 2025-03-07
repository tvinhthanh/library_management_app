using System;
using System.Collections.Generic;

namespace demo.Models
{
    public partial class BorrowDetail
    {
        public int BorrowDetailId { get; set; }
        public int BorrowId { get; set; }
        public int? BookId { get; set; }
        public int Quantity { get; set; }

        public virtual Book Book { get; set; } = null!;
        public virtual Borrowing Borrow { get; set; } = null!;
    }
}
