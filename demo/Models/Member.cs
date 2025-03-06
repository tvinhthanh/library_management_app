using System;
using System.Collections.Generic;

namespace demo.Models
{
    public partial class Member
    {
        public Member()
        {
            Borrowings = new HashSet<Borrowing>();
        }

        public int MemberId { get; set; }
        public string Name { get; set; } = null!;
        public DateTime? DateOfBirth { get; set; }
        public string? Address { get; set; }
        public string? Phone { get; set; }
        public string? Email { get; set; }

        public virtual ICollection<Borrowing> Borrowings { get; set; }
    }
}
