import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_library/core/api/constants.dart';

class AddBookToRentalScreen extends StatefulWidget {
  final int borrowId;

  const AddBookToRentalScreen({super.key, required this.borrowId});

  @override
  State<AddBookToRentalScreen> createState() => _AddBookToRentalScreenState();
}

class _AddBookToRentalScreenState extends State<AddBookToRentalScreen> {
  List<dynamic> books = [];
  int? selectedBookId;
  bool isLoading = true;
  String? errorMessage; // Lưu lỗi nếu có

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/book"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedBooks = json.decode(utf8.decode(response.bodyBytes));

        setState(() {
          books = fetchedBooks;
          selectedBookId = books.isNotEmpty ? books.first["bookId"] : null;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Không thể tải danh sách sách!";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Lỗi tải dữ liệu: $e";
        isLoading = false;
      });
    }
  }

  Future<void> addBookToRental() async {
  if (selectedBookId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vui lòng chọn một cuốn sách!")),
    );
    return;
  }

  try {
    final response = await http.post(
      Uri.parse("$apiBaseUrl/borrow/${widget.borrowId}/add-book"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "bookId": selectedBookId,  
        "quantity": 1,            
      }),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thêm sách thành công!")),
      );
      Navigator.pop(context, responseData);
    } else {
      final Map<String, dynamic>? errorData = jsonDecode(response.body);
      String errorMessage = errorData?["message"] ?? "Lỗi không xác định!";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $errorMessage")),
      );
    }
  } catch (e) {
    print("Lỗi kết nối: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Lỗi kết nối: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm Sách Vào Phiếu Mượn")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mã phiếu mượn: ${widget.borrowId}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      books.isEmpty
                          ? const Text("Không có sách để chọn.", style: TextStyle(color: Colors.grey))
                          : DropdownButtonFormField<int>(
                              decoration: const InputDecoration(labelText: "Chọn sách"),
                              value: selectedBookId,
                              items: books.map((book) {
                                return DropdownMenuItem<int>(
                                  value: book["bookId"],
                                  child: Text(book["title"] ?? "Không có tên"),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => selectedBookId = value);
                              },
                            ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: books.isEmpty ? null : addBookToRental,
                        child: const Text("Thêm vào phiếu mượn"),
                      ),
                    ],
                  ),
      ),
    );
  }
}
