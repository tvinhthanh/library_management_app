import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_library/core/constants.dart';

class EditRentalScreen extends StatefulWidget {
  final int borrowingId;
  const EditRentalScreen({super.key, required this.borrowingId});

  @override
  State<EditRentalScreen> createState() => _EditBorrowingScreenState();
}

class _EditBorrowingScreenState extends State<EditRentalScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController borrowerController = TextEditingController();
  final TextEditingController bookController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBorrowingDetails();
  }

  Future<void> fetchBorrowingDetails() async {
    final response = await http.get(Uri.parse("$apiBaseUrl/borrow/${widget.borrowingId}"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        borrowerController.text = data["borrower"];
        bookController.text = data["book"];
        dueDateController.text = data["dueDate"];
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải dữ liệu: ${response.body}")),
      );
    }
  }

  Future<void> updateBorrowing() async {
    if (!_formKey.currentState!.validate()) return;

    final response = await http.put(
      Uri.parse("$apiBaseUrl/borrow/${widget.borrowingId}"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "borrower": borrowerController.text,
        "book": bookController.text,
        "dueDate": dueDateController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chỉnh sửa phiếu thuê")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: borrowerController,
                      decoration: const InputDecoration(labelText: "Người mượn"),
                      validator: (value) => value!.isEmpty ? "Nhập tên người mượn" : null,
                    ),
                    TextFormField(
                      controller: bookController,
                      decoration: const InputDecoration(labelText: "Sách"),
                      validator: (value) => value!.isEmpty ? "Nhập tên sách" : null,
                    ),
                    TextFormField(
                      controller: dueDateController,
                      decoration: const InputDecoration(labelText: "Hạn trả"),
                      validator: (value) => value!.isEmpty ? "Nhập hạn trả" : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: updateBorrowing,
                      child: const Text("Cập nhật"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
