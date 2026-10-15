-- Tạo bảng tài khoản đăng nhập cho database LibraryManagement.
-- Chạy một lần trên SQL Server trước khi khởi động API. Idempotent: chạy lại không lỗi.

IF OBJECT_ID(N'dbo.UserAccounts', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.UserAccounts (
        UserAccountID INT IDENTITY(1,1) NOT NULL,
        Username      NVARCHAR(32)  NOT NULL,
        PasswordHash  NVARCHAR(256) NOT NULL,
        FullName      NVARCHAR(100) NOT NULL,
        CreatedAt     DATETIME2     NOT NULL CONSTRAINT DF_UserAccounts_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_UserAccounts PRIMARY KEY (UserAccountID),
        CONSTRAINT UQ_UserAccounts_Username UNIQUE (Username)
    );
END
GO
