using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace Backend_Library.Models
{
    public partial class LibraryManagementContext : DbContext
    {
        public LibraryManagementContext()
        {
        }

        public LibraryManagementContext(DbContextOptions<LibraryManagementContext> options)
            : base(options)
        {
        }

        public virtual DbSet<Author> Authors { get; set; } = null!;
        public virtual DbSet<Book> Books { get; set; } = null!;
        public virtual DbSet<Borrowing> Borrowings { get; set; } = null!;
        public virtual DbSet<Category> Categories { get; set; } = null!;
        public virtual DbSet<Member> Members { get; set; } = null!;
        public virtual DbSet<Publisher> Publishers { get; set; } = null!;
        public virtual DbSet<staff> staff { get; set; } = null!;

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see http://go.microsoft.com/fwlink/?LinkId=723263.
                optionsBuilder.UseSqlServer("Server=localhost;Database=LibraryManagement;Trusted_Connection=True;");
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Author>(entity =>
            {
                entity.Property(e => e.AuthorId).HasColumnName("AuthorID");

                entity.Property(e => e.Name).HasMaxLength(255);
            });

            modelBuilder.Entity<Book>(entity =>
            {
                entity.HasIndex(e => e.Isbn, "UQ__Books__447D36EA48C55E4D")
                    .IsUnique();

                entity.Property(e => e.BookId).HasColumnName("BookID");

                entity.Property(e => e.AuthorId).HasColumnName("AuthorID");

                entity.Property(e => e.CategoryId).HasColumnName("CategoryID");

                entity.Property(e => e.Isbn)
                    .HasMaxLength(20)
                    .HasColumnName("ISBN");

                entity.Property(e => e.PublisherId).HasColumnName("PublisherID");

                entity.Property(e => e.Quantity).HasDefaultValueSql("((1))");

                entity.Property(e => e.Title).HasMaxLength(255);

                entity.HasOne(d => d.Author)
                    .WithMany(p => p.Books)
                    .HasForeignKey(d => d.AuthorId)
                    .HasConstraintName("FK__Books__AuthorID__3F466844");

                entity.HasOne(d => d.Category)
                    .WithMany(p => p.Books)
                    .HasForeignKey(d => d.CategoryId)
                    .HasConstraintName("FK__Books__CategoryI__403A8C7D");

                entity.HasOne(d => d.Publisher)
                    .WithMany(p => p.Books)
                    .HasForeignKey(d => d.PublisherId)
                    .HasConstraintName("FK__Books__Publisher__412EB0B6");
            });

            modelBuilder.Entity<Borrowing>(entity =>
            {
                entity.Property(e => e.BorrowingId).HasColumnName("BorrowingID");

                entity.Property(e => e.BookId).HasColumnName("BookID");

                entity.Property(e => e.BorrowDate).HasColumnType("date");

                entity.Property(e => e.DueDate).HasColumnType("date");

                entity.Property(e => e.MemberId).HasColumnName("MemberID");

                entity.Property(e => e.ReturnDate).HasColumnType("date");

                entity.Property(e => e.StaffId).HasColumnName("StaffID");

                entity.HasOne(d => d.Book)
                    .WithMany(p => p.Borrowings)
                    .HasForeignKey(d => d.BookId)
                    .HasConstraintName("FK__Borrowing__BookI__4CA06362");

                entity.HasOne(d => d.Member)
                    .WithMany(p => p.Borrowings)
                    .HasForeignKey(d => d.MemberId)
                    .HasConstraintName("FK__Borrowing__Membe__4BAC3F29");

                entity.HasOne(d => d.Staff)
                    .WithMany(p => p.Borrowings)
                    .HasForeignKey(d => d.StaffId)
                    .HasConstraintName("FK__Borrowing__Staff__4D94879B");
            });

            modelBuilder.Entity<Category>(entity =>
            {
                entity.Property(e => e.CategoryId).HasColumnName("CategoryID");

                entity.Property(e => e.CategoryName).HasMaxLength(100);
            });

            modelBuilder.Entity<Member>(entity =>
            {
                entity.HasIndex(e => e.Phone, "UQ__Members__5C7E359EAEF7898F")
                    .IsUnique();

                entity.HasIndex(e => e.Email, "UQ__Members__A9D105345CC7F097")
                    .IsUnique();

                entity.Property(e => e.MemberId).HasColumnName("MemberID");

                entity.Property(e => e.DateOfBirth).HasColumnType("date");

                entity.Property(e => e.Email).HasMaxLength(255);

                entity.Property(e => e.Name).HasMaxLength(255);

                entity.Property(e => e.Phone).HasMaxLength(15);
            });

            modelBuilder.Entity<Publisher>(entity =>
            {
                entity.Property(e => e.PublisherId).HasColumnName("PublisherID");

                entity.Property(e => e.PublisherName).HasMaxLength(255);
            });

            modelBuilder.Entity<staff>(entity =>
            {
                entity.ToTable("Staff");

                entity.HasIndex(e => e.Phone, "UQ__Staff__5C7E359E1F712AA8")
                    .IsUnique();

                entity.HasIndex(e => e.Email, "UQ__Staff__A9D10534D1BA87C9")
                    .IsUnique();

                entity.Property(e => e.StaffId).HasColumnName("StaffID");

                entity.Property(e => e.Email).HasMaxLength(255);

                entity.Property(e => e.Name).HasMaxLength(255);

                entity.Property(e => e.Phone).HasMaxLength(15);

                entity.Property(e => e.Position).HasMaxLength(100);
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
