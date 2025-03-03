using System;
using System.Collections.Generic;

namespace Backend_Library.Models
{
    public partial class Borrowing
    {
        public int BorrowingId { get; set; }
        public int? MemberId { get; set; }
        public int? BookId { get; set; }
        public DateTime BorrowDate { get; set; }
        public DateTime DueDate { get; set; }
        public DateTime? ReturnDate { get; set; }
        public int? StaffId { get; set; }

        public virtual Book? Book { get; set; }
        public virtual Member? Member { get; set; }
        public virtual staff? Staff { get; set; }
    }
}
