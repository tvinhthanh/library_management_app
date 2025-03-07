import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_library/core/api/constants.dart';
import 'package:frontend_library/presentation/screens/management/reader/add_reader_screen.dart';
import 'package:frontend_library/presentation/screens/management/reader/edit_reader_screen.dart';

class ReaderManagementScreen extends StatefulWidget {
  const ReaderManagementScreen({super.key});

  @override
  State<ReaderManagementScreen> createState() => _ReaderManagementScreenState();
}

class _ReaderManagementScreenState extends State<ReaderManagementScreen> {
  List member = [];
  List filteredReaders = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchReaders();
  }

  Future<void> fetchReaders() async {
    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/user/member/all"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body)["members"];
        setState(() {
          member = data;
          filteredReaders = member;
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

  Future<void> deleteReader(int id) async {
    try {
      final response = await http.delete(Uri.parse("$apiBaseUrl/user/member/$id"));

      if (response.statusCode == 200) {
        setState(() {
          member.removeWhere((reader) => reader["memberId"] == id);
          filteredReaders = member;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xóa độc giả thành công!")),
        );
      } else {
        throw Exception("Lỗi khi xóa độc giả: ${response.statusCode}");
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
        const SnackBar(content: Text("Lỗi: ID độc giả không hợp lệ!")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: const Text("Bạn có chắc chắn muốn xóa độc giả này?"),
          actions: [
            TextButton(
              child: const Text("Hủy"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Xóa"),
              onPressed: () async {
                Navigator.of(context).pop();
                await deleteReader(id);
              },
            ),
          ],
        );
      },
    );
  }

  void searchReaders(String query) {
    setState(() {
      filteredReaders = member
          .where((reader) => reader["name"]
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
        title: const Text("Quản lý Độc Giả"),
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
                _buildButton(Icons.person_add, "Thêm Độc Giả", Colors.blue, () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddReaderScreen()),
                  );
                  if (result == true) fetchReaders();
                }),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Tìm kiếm độc giả...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: searchReaders,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredReaders.isEmpty
                      ? const Center(child: Text("Không có độc giả nào!"))
                      : ListView.builder(
                          itemCount: filteredReaders.length,
                          itemBuilder: (context, index) {
                            final reader = filteredReaders[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(
                                  reader["name"] ?? "Không có tên",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text("Email: ${reader["email"] ?? "Không có email"}"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.green),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditReaderScreen(readerId: reader["memberId"]),
                                          ),
                                        );
                                        if (result == true) fetchReaders();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _confirmDelete(reader["memberId"]),
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
