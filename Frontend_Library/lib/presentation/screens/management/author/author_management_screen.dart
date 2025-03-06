import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_library/core/constants.dart';
import 'package:frontend_library/presentation/screens/management/author/add_author_screen.dart';
import 'package:frontend_library/presentation/screens/management/author/edit_author_screen.dart';

class AuthorManagementScreen extends StatefulWidget {
  const AuthorManagementScreen({super.key});

  @override
  State<AuthorManagementScreen> createState() => _AuthorManagementScreenState();
}

class _AuthorManagementScreenState extends State<AuthorManagementScreen> {
  List authors = [];
  List filteredAuthors = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAuthors();
  }

  Future<void> fetchAuthors() async {
    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/author"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          authors = data;
          filteredAuthors = authors;
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

    Future<void> deleteAuthor(int id) async {
    try {
      final response = await http.delete(Uri.parse("$apiBaseUrl/author/$id"));

      if (response.statusCode == 200) {
        setState(() {
          authors.removeWhere((author) => author["authorId"] == id);
          filteredAuthors = authors;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xóa tác giả thành công!")),
        );
      } else {
        print("Lỗi API khi xóa: ${response.body}"); // Debug lỗi API
        throw Exception("Lỗi khi xóa tác giả: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e"); // Debug lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    }
  }


    void _confirmDelete(int? id) {
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi: ID tác giả không hợp lệ!")),
      );
      return;
    }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Xác nhận xóa"),
            content: const Text("Bạn có chắc chắn muốn xóa tác giả này?"),
            actions: [
              TextButton(
                child: const Text("Hủy"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text("Xóa"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await deleteAuthor(id);
                },
              ),
            ],
          );
        },
      );
    }

  void searchAuthors(String query) {
    setState(() {
      filteredAuthors = authors
          .where((author) => author["name"]
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
        title: const Text("Quản lý Tác Giả"),
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
                _buildButton(Icons.add, "Thêm Tác Giả", Colors.blue, () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddAuthorScreen()),
                  );
                  if (result == true) fetchAuthors();
                }),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Tìm kiếm tác giả...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: searchAuthors,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredAuthors.isEmpty
                      ? const Center(child: Text("Không có tác giả nào!"))
                      : ListView.builder(
                          itemCount: filteredAuthors.length,
                          itemBuilder: (context, index) {
                            final author = filteredAuthors[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(
                                  author["name"] ?? "Không có tên",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text("Tiểu sử: ${author["bio"] ?? "Không có tiểu sử"}"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.green),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditAuthorScreen(authorId: author["authorId"]),
                                          ),
                                        );
                                        if (result == true) fetchAuthors();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _confirmDelete(author["authorId"]),
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
