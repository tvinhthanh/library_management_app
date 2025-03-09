import 'package:flutter/material.dart';
import 'package:frontend_library/core/api/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditBookScreen extends StatefulWidget {
  final int bookId;

  const EditBookScreen({super.key, required this.bookId});

  @override
  _EditBookScreenState createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController publishedYearController = TextEditingController();
  final TextEditingController isbnController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController publishedIdController = TextEditingController();
  final TextEditingController authorIdController = TextEditingController();
  final TextEditingController categoryIdController = TextEditingController();

  String authorName = "Đang tải...";
  String categoryName = "Đang tải...";
  String publisherName = "Đang tải...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookDetails();
  }

  /// Fetch book details from API
  Future<void> fetchBookDetails() async {
    print("Bắt đầu gọi API...");
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/book/${widget.bookId}'));
      print("Trạng thái API: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("Dữ liệu API trả về: ${response.body}");
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        if (data.isEmpty || data["title"] == null) {
          showError("Dữ liệu sách không hợp lệ!");
          return;
        }

        setState(() {
          titleController.text = data["title"] ?? "";
          publishedYearController.text = _toStringOrEmpty(data["publishedYear"]);
          isbnController.text = data["isbn"] ?? "";
          quantityController.text = _toStringOrEmpty(data["quantity"]);
          authorIdController.text = _toStringOrEmpty(data["authorId"]);
          categoryIdController.text = _toStringOrEmpty(data["categoryId"]);
          publishedIdController.text = _toStringOrEmpty(data["publisherId"]);

          fetchAuthorName(data["authorId"]);
          fetchCategoryName(data["categoryId"]);
          fetchPublisherName(data["publisherId"]);
          isLoading = false;
        });

        print("Dữ liệu sau khi cập nhật vào controller:");
        print("Title: ${titleController.text}");
        print("Published Year: ${publishedYearController.text}");
        print("ISBN: ${isbnController.text}");
        print("Quantity: ${quantityController.text}");
        print("Author ID: ${authorIdController.text}");
        print("Category ID: ${categoryIdController.text}");
        print("Publisher ID: ${publishedIdController.text}");
      } else {
        showError("Lỗi tải thông tin sách!");
      }
    } catch (e) {
      print("Lỗi trong fetchBookDetails(): $e");
      showError("Lỗi kết nối đến máy chủ!");
    }
  }

  /// Update book details
  Future<void> updateBook() async {
    final bookData = {
      "title": titleController.text,
      "authorId": _toIntOrDefault(authorIdController.text, 1),
      "categoryId": _toIntOrDefault(categoryIdController.text, 1),
      "publisherId": _toIntOrDefault(publishedIdController.text, 1),
      "publishedYear": _toIntOrDefault(publishedYearController.text, 2022),
      "isbn": isbnController.text,
      "quantity": _toIntOrDefault(quantityController.text, 0),
    };

    print("Dữ liệu gửi lên API: $bookData");

    try {
      final response = await http.put(
        Uri.parse("$apiBaseUrl/book/${widget.bookId}"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(bookData),
      );

      print("Trạng thái phản hồi: ${response.statusCode}");
      print("Phản hồi từ server: ${response.body}");

      if (response.statusCode == 200) {
        showSuccess("Cập nhật sách thành công!");
        Navigator.pop(context, true);
      } else {
        showError("Lỗi khi cập nhật sách!");
      }
    } catch (e) {
      print("Lỗi trong updateBook(): $e");
      showError("Lỗi kết nối đến server!");
    }
  }

  Future<void> fetchAuthorName(int authorId) async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/author/$authorId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() => authorName = data["name"] ?? "Không có dữ liệu");
      } else {
        setState(() => authorName = "Không có dữ liệu");
      }
    } catch (e) {
      setState(() => authorName = "Lỗi tải dữ liệu");
    }
  }

  Future<void> fetchCategoryName(int categoryId) async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/category/$categoryId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() => categoryName = data["categoryName"] ?? "Không có dữ liệu");
      } else {
        setState(() => categoryName = "Không có dữ liệu");
      }
    } catch (e) {
      setState(() => categoryName = "Lỗi tải dữ liệu");
    }
  }

  Future<void> fetchPublisherName(int publisherId) async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/publishers/$publisherId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() => publisherName = data["publisherName"] ?? "Không có dữ liệu");
      } else {
        setState(() => publisherName = "Không có dữ liệu");
      }
    } catch (e) {
      setState(() => publisherName = "Lỗi tải dữ liệu");
    }
  }

  int _toIntOrDefault(String? value, int defaultValue) {
    return int.tryParse(value ?? '') ?? defaultValue;
  }

  String _toStringOrEmpty(dynamic value) {
    return value?.toString() ?? "";
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool enabled = true, TextInputType? inputType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        enabled: enabled,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cập nhật sách")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTextField("Tên sách", titleController),
                    Text("Tác giả: $authorName", style: TextStyle(fontSize: 16)),
                    Text("Thể loại: $categoryName", style: TextStyle(fontSize: 16)),
                    Text("Nhà xuất bản: $publisherName", style: TextStyle(fontSize: 16)),
                    buildTextField("Năm xuất bản", publishedYearController, inputType: TextInputType.number),
                    buildTextField("ISBN", isbnController),
                    buildTextField("Số lượng", quantityController, inputType: TextInputType.number),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: updateBook,
                        child: const Text("Lưu cập nhật"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
