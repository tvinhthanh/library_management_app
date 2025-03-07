import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_library/core/api/constants.dart';

class EditCategoryScreen extends StatefulWidget {
  final int categoryId;
  const EditCategoryScreen({super.key, required this.categoryId});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final TextEditingController nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategory();
  }

  Future<void> fetchCategory() async {
    final response = await http.get(Uri.parse("$apiBaseUrl/category/${widget.categoryId}"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        nameController.text = data['categoryName'];
        isLoading = false;
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> updateCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final response = await http.put(
      Uri.parse("$apiBaseUrl/category/${widget.categoryId}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"categoryName": nameController.text}),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật danh mục thất bại!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chỉnh sửa Danh Mục")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Tên danh mục"),
                      validator: (value) => value!.isEmpty ? "Không được để trống" : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: updateCategory, child: const Text("Lưu"))
                  ],
                ),
              ),
            ),
    );
  }
}
