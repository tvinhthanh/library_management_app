import 'package:flutter/material.dart';
import 'package:frontend_library/core/constants.dart';
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


  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookDetails();
  }

    Future<void> fetchBookDetails() async {
      try {
        final response = await http.get(Uri.parse('$apiBaseUrl/book/${widget.bookId}'));
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          
          print("Dữ liệu API trả về: $data");

          if (data.isEmpty || data["title"] == null) {
            showError("Dữ liệu không hợp lệ!");
            return;
          }

          setState(() {
            titleController.text = data["title"] ?? "";
            publishedYearController.text = (data["publishedYear"] ?? "").toString();
            isbnController.text = data["isbn"] ?? "";
            quantityController.text = (data["quantity"] ?? "").toString();

            authorIdController.text = (data["authorId"] is int) ? data["authorId"].toString() : "0";
            categoryIdController.text = (data["categoryId"] is int) ? data["categoryId"].toString() : "0";
            publishedIdController.text = (data["publisherId"] is int) ? data["publisherId"].toString() : "0";


            isLoading = false;
          });

        } else {
          showError("Lỗi tải thông tin sách!");
        }
      } catch (e) {
        print("Lỗi trong fetchBookDetails(): $e");
        showError("Lỗi kết nối đến server!");
      }
    }



  Future<void> updateBook() async {
  try {
    final response = await http.put(
      Uri.parse("$apiBaseUrl/book/${widget.bookId}"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "title": titleController.text,
        "authorId": int.tryParse(authorIdController.text) ?? 1,
        "categoryId": int.tryParse(categoryIdController.text) ?? 1,
        "publisherId": int.tryParse(publishedIdController.text) ?? 1,
        "publishedYear": int.tryParse(publishedYearController.text) ?? 2022,
        "isbn": isbnController.text,
        "quantity": int.tryParse(quantityController.text) ?? 0,
      }),
    );

    if (response.statusCode == 200) {
      showSuccess("Cập nhật sách thành công!");
      Navigator.pop(context, true);
    } else {
      showError("Lỗi khi cập nhật sách!");
    }
  } catch (e) {
    showError("Lỗi kết nối đến server!");
  }
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
                children: [
                  // ID Sách (Không chỉnh sửa)
                  TextField(
                    controller: TextEditingController(text: widget.bookId.toString()),
                    enabled: false,
                    decoration: const InputDecoration(labelText: "ID Sách"),
                  ),
                  const SizedBox(height: 10),

                  // Tên sách
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Tên sách"),
                  ),
                  const SizedBox(height: 10),

                  // ID Tác giả (Không chỉnh sửa)
                  TextField(
                    controller: authorIdController,
                    enabled: false,
                    decoration: const InputDecoration(labelText: "ID Tác giả"),
                  ),
                  const SizedBox(height: 10),

                  // ID Thể loại (Không chỉnh sửa)
                  TextField(
                    controller: categoryIdController,
                    enabled: false,
                    decoration: const InputDecoration(labelText: "ID Thể loại"),
                  ),
                  const SizedBox(height: 10),

                  // ID Nhà xuất bản (Không chỉnh sửa)
                  TextField(
                    controller: publishedIdController,
                    enabled: false,
                    decoration: const InputDecoration(labelText: "ID Nhà xuất bản"),
                  ),
                  const SizedBox(height: 10),

                  // Năm xuất bản
                  TextField(
                    controller: publishedYearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Năm xuất bản"),
                  ),
                  const SizedBox(height: 10),

                  // ISBN
                  TextField(
                    controller: isbnController,
                    decoration: const InputDecoration(labelText: "ISBN"),
                  ),
                  const SizedBox(height: 10),

                  // Số lượng
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Số lượng"),
                  ),
                  const SizedBox(height: 10),

                  // Nút cập nhật
                  ElevatedButton(
                    onPressed: updateBook,
                    child: const Text("Lưu cập nhật"),
                  ),
                ],
              ),
            ),
          ),
  );
}
}
