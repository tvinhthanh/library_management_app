import 'package:flutter/material.dart';
import 'package:frontend_library/core/api/constants.dart';
import 'package:frontend_library/presentation/screens/management/book/add_book_srceen.dart';
import 'package:frontend_library/presentation/screens/management/book/edit_book_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookManagementScreen extends StatelessWidget {
  const BookManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Sách"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const BookHomePage(),
    );
  }
}

class BookHomePage extends StatefulWidget {
  const BookHomePage({super.key});

  @override
  _BookHomePageState createState() => _BookHomePageState();
}

class _BookHomePageState extends State<BookHomePage> {
  List books = [];
  List filteredBooks = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    final response = await http.get(Uri.parse("$apiBaseUrl/book"));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      // Lọc ra sách không có `id`
      setState(() {
        books = data.where((book) => book["bookId"] != null).toList();
        filteredBooks = books;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi khi tải sách!")),
      );
    }
  }

  Future<String> fetchAuthorById(int authorId) async {
    final response = await http.get(Uri.parse("$apiBaseUrl/author/$authorId"));

    if (response.statusCode == 200) {
      final author = json.decode(response.body);
      return author["name"];
    } else {
      return "Không rõ";
    }
  }

 Future<void> deleteBook(int id) async {
  final response = await http.delete(Uri.parse("$apiBaseUrl/book/$id"));

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã xóa sách thành công!")),
    );
    fetchBooks();

    // Delay 300ms
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        books.removeWhere((book) => book["id"] == id);
        filteredBooks.removeWhere((book) => book["id"] == id);
      });
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Lỗi khi xóa sách! Mã lỗi: ${response.statusCode}")),
    );
  }
}

  void _confirmDelete(int? id) {
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi: Không tìm thấy ID sách!")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: const Text("Bạn có chắc chắn muốn xóa cuốn sách này?"),
          actions: [
            TextButton(
              child: const Text("Hủy"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Xóa"),
              onPressed: () {
                deleteBook(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void searchBooks(String query) {
    setState(() {
      filteredBooks = books
          .where((book) =>
              book["title"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildButton(context, Icons.add, "Thêm Sách", Colors.blue, () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddBookScreen()),
                );

                if (result == true) {
                  fetchBooks();
                }
              }),
            ],
          ),
          const SizedBox(height: 10),

          // Ô tìm kiếm sách
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: "Tìm kiếm sách...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: searchBooks,
          ),
          const SizedBox(height: 10),

          // Danh sách sách
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          leading: const Icon(Icons.book, color: Colors.blue),
                          title: Text(book["title"] ?? "Không có tiêu đề"),
                          subtitle: FutureBuilder<String>(
                            future: fetchAuthorById(book["authorId"] ?? 0),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Text("Đang tải tác giả...");
                              } else if (snapshot.hasError) {
                                return const Text("Lỗi tải tác giả");
                              } else {
                                return Text("Tác giả: ${snapshot.data}");
                              }
                            },
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.green),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditBookScreen(bookId: book["bookId"]),
                                    ),
                                  );

                                  if (result == true) {
                                    fetchBooks();
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  print("Dữ liệu book: $book");
                                  _confirmDelete(book["bookId"]); 
                                },
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
    );
  }

  Widget _buildButton(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
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
