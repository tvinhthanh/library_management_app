import 'package:flutter/material.dart';

void main() {
  runApp(const BookManagementScreen());
}

class BookManagementScreen extends StatelessWidget {
  const BookManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý thư viện',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LibraryHomePage(),
    );
  }
}

class LibraryHomePage extends StatelessWidget {
  const LibraryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Thư Viện"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Hiển thị 2 cột
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildMenuButton(
                context, Icons.book, "Quản lý Sách", Colors.blue, () {}),
            _buildMenuButton(
                context, Icons.people, "Quản lý Độc Giả", Colors.green, () {}),
            _buildMenuButton(context, Icons.business, "Quản lý Nhà Xuất Bản",
                Colors.orange, () {}),
            _buildMenuButton(context, Icons.assignment, "Quản lý Phiếu Thuê",
                Colors.purple, () {}),
            _buildMenuButton(
                context, Icons.bar_chart, "Thống Kê", Colors.red, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, IconData icon, String title,
      Color color, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
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
}
