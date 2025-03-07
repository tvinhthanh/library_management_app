import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_library/core/api/constants.dart';
import 'package:frontend_library/presentation/screens/management/publisher/add_publisher_screen.dart';
import 'package:frontend_library/presentation/screens/management/publisher/edit_publisher_screen.dart';

class PublisherManagementScreen extends StatefulWidget {
  const PublisherManagementScreen({super.key});

  @override
  State<PublisherManagementScreen> createState() => _PublisherManagementScreenState();
}

class _PublisherManagementScreenState extends State<PublisherManagementScreen> {
  List publishers = [];
  List filteredPublishers = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPublishers();
  }

  Future<void> fetchPublishers() async {
    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/publishers"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          publishers = data;
          filteredPublishers = publishers;
          isLoading = false;
        });
      } else {
        throw Exception("Lỗi API: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải dữ liệu: $e")),
      );
    }
  }

  Future<void> deletePublisher(int id) async {
    try {
      final response = await http.delete(Uri.parse("$apiBaseUrl/publishers/$id"));

      if (response.statusCode == 200) {
        setState(() {
          publishers.removeWhere((publisher) => publisher["publisherId"] == id);
          filteredPublishers = publishers;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xóa nhà xuất bản thành công!")),
        );
      } else {
        throw Exception("Lỗi khi xóa nhà xuất bản: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    }
  }

  void _confirmDelete(int? id) {
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi: ID nhà xuất bản không hợp lệ!")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: const Text("Bạn có chắc chắn muốn xóa nhà xuất bản này?"),
          actions: [
            TextButton(
              child: const Text("Hủy"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Xóa"),
              onPressed: () async {
                Navigator.of(context).pop();
                await deletePublisher(id);
              },
            ),
          ],
        );
      },
    );
  }

  void searchPublishers(String query) {
    setState(() {
      filteredPublishers = publishers
          .where((publisher) => publisher["publisherName"]
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Nhà Xuất Bản"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildButton(Icons.add, "Thêm Nhà Xuất Bản", Colors.blue, () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddPublisherScreen()),
                  );
                  if (result == true) fetchPublishers();
                }),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Tìm kiếm nhà xuất bản...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: searchPublishers,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredPublishers.isEmpty
                      ? const Center(child: Text("Không có nhà xuất bản nào!"))
                      : ListView.builder(
                          itemCount: filteredPublishers.length,
                          itemBuilder: (context, index) {
                            final publisher = filteredPublishers[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(
                                  publisher["publisherName"] ?? "Không có tên",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text("Địa chỉ: ${publisher["address"] ?? "Không có Địa chỉ"}"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.green),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditPublisherScreen(publisherId: publisher["publisherId"]),
                                          ),
                                        );
                                        if (result == true) fetchPublishers();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _confirmDelete(publisher["publisherId"]),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon, String title, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(title, style: const TextStyle(color: Colors.white)),
    );
  }
}

