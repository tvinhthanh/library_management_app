import 'package:flutter/material.dart';
import 'package:frontend_library/presentation/screens/auth/login_screen.dart';
import 'package:frontend_library/presentation/screens/management/author/author_management_screen.dart';
import 'package:frontend_library/presentation/screens/management/book/book_management_screen.dart';
import 'package:frontend_library/presentation/screens/management/category/category_management_screen.dart';
import 'package:frontend_library/presentation/screens/management/publisher/publisher_management_screen.dart';
import 'package:frontend_library/presentation/screens/management/reader/reader_management_screen.dart';
import 'package:frontend_library/presentation/screens/management/rental/rental_management_screen.dart';
import 'package:frontend_library/presentation/screens/management/statistics_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {"icon": Icons.book, "title": "Quản lý Sách", "color": Colors.blue, "screen": const BookManagementScreen()},
      {"icon": Icons.people, "title": "Quản lý Độc Giả", "color": Colors.green, "screen": const ReaderManagementScreen()},
      {"icon": Icons.person, "title": "Quản lý Tác Giả", "color": Colors.orange, "screen": const AuthorManagementScreen()},
      {"icon": Icons.business, "title": "Quản lý Nhà Xuất Bản", "color": Colors.purple, "screen": const PublisherManagementScreen()},
      {"icon": Icons.category, "title": "Quản lý Loại", "color": Colors.red, "screen": const CategoryManagementScreen()},
      {"icon": Icons.assignment, "title": "Quản lý Phiếu mượn", "color": Colors.teal, "screen": const BorrowingManagementScreen()},
      {"icon": Icons.bar_chart, "title": "Thống kê", "color": Colors.indigo, "screen": const StatisticsScreen()},
      {"icon": Icons.logout, "title": "Đăng Xuất", "color": Colors.grey, "screen": null},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Trang chủ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: menuItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return _buildMenuButton(context, item["icon"], item["title"], item["color"], item["screen"]);
          },
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, IconData icon, String title, Color color, Widget? screen) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () {
        if (screen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
        } else {
          _showLogoutDialog(context);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận đăng xuất"),
        content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );
  }
}
