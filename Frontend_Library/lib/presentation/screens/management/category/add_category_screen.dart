import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_library/core/constants.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> addCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final response = await http.post(
      Uri.parse("$apiBaseUrl/category"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"categoryName": nameController.text}),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thêm danh mục thất bại!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm Danh Mục")),
      body: Padding(
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
              ElevatedButton(onPressed: addCategory, child: const Text("Thêm"))
            ],
          ),
        ),
      ),
    );
  }
}