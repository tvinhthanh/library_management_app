using Backend_Library.Models; // Đổi namespace theo project của bạn
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Đọc Connection String từ appsettings.json
builder.Services.AddDbContext<LibraryManagementContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthorization();
app.MapControllers();
app.Run();
