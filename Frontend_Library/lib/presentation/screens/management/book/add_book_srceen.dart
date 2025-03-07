import 'package:flutter/material.dart';
import 'package:frontend_library/core/api/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController isbnController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(text: "1");

  List authors = [];
  List categories = [];
  List publishers = [];

  int? selectedAuthor;
  int? selectedCategory;
  int? selectedPublisher;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    try {
      final authorsResponse = await http.get(Uri.parse("$apiBaseUrl/author"));
      final categoriesResponse = await http.get(Uri.parse("$apiBaseUrl/category"));
      final publishersResponse = await http.get(Uri.parse("$apiBaseUrl/publishers"));

      if (authorsResponse.statusCode == 200 &&
          categoriesResponse.statusCode == 200 &&
          publishersResponse.statusCode == 200) {
        setState(() {
          authors = json.decode(authorsResponse.body) ?? [];
          categories = json.decode(categoriesResponse.body) ?? [];
          publishers = json.decode(publishersResponse.body) ?? [];
          isLoading = false;
        });
      } else {
        throw Exception("Lỗi tải dữ liệu");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${e.toString()}")),
      );
    }
  }

  Future<void> addBook() async {
    if (titleController.text.isEmpty ||
        selectedAuthor == null ||
        selectedCategory == null ||
        selectedPublisher == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    final bookData = {
      "title": titleController.text,
      "authorId": selectedAuthor,
      "categoryId": selectedCategory,
      "publisherId": selectedPublisher,
      "publishedYear": int.tryParse(yearController.text) ?? 0,
      "isbn": isbnController.text,
      "quantity": int.tryParse(quantityController.text) ?? 1,
    };

    final response = await http.post(
      Uri.parse("$apiBaseUrl/book"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(bookData),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thêm sách thành công!")),
      );
      Navigator.pop(context, true); // Trả về `true` để cập nhật danh sách
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi khi thêm sách!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm Sách"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Tên Sách"),
                  ),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: "Tác Giả"),
                    value: authors.isNotEmpty ? selectedAuthor : null,
                    items: authors.map((author) {
                      return DropdownMenuItem(
                        value: author["authorId"] as int?,
                        child: Text(author["name"] ?? "Không có tên"),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedAuthor = value),
                  ),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: "Danh Mục"),
                    value: categories.isNotEmpty ? selectedCategory : null,
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category["categoryId"] as int?,
                        child: Text(category["categoryName"] ?? "Không có danh mục"),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedCategory = value),
                  ),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: "Nhà Xuất Bản"),
                    value: publishers.isNotEmpty ? selectedPublisher : null,
                    items: publishers.map((publisher) {
                      return DropdownMenuItem(
                        value: publisher["publisherId"] as int?,
                        child: Text(publisher["publisherName"] ?? "Không có nhà xuất bản"),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedPublisher = value),
                  ),
                  TextField(
                    controller: yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Năm Xuất Bản"),
                  ),
                  TextField(
                    controller: isbnController,
                    decoration: const InputDecoration(labelText: "ISBN"),
                  ),
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Số lượng"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: addBook,
                    child: const Text("Thêm Sách"),
                  ),
                ],
              ),
            ),
    );
  }
}
