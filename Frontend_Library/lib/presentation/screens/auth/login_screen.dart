import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';
import '../management/book_management_screen.dart';
import '../management/reader_management_screen.dart';
import '../management/publisher_management_screen.dart';
import '../management/rental_management_screen.dart';
import '../management/statistics_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Thư Viện"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<UserProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildMenuButton(context, Icons.book, "Quản lý Sách", Colors.blue, 
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookManagementScreen()))),
            _buildMenuButton(context, Icons.people, "Quản lý Độc Giả", Colors.green, 
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReaderManagementScreen()))),
            _buildMenuButton(context, Icons.business, "Quản lý Nhà Xuất Bản", Colors.orange, 
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PublisherManagementScreen()))),
            _buildMenuButton(context, Icons.assignment, "Quản lý Phiếu Thuê", Colors.purple, 
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RentalManagementScreen()))),
            _buildMenuButton(context, Icons.bar_chart, "Thống Kê", Colors.red, 
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsScreen()))),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
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
