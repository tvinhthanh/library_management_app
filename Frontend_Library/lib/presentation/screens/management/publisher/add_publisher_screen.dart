import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_library/core/constants.dart';

class AddPublisherScreen extends StatefulWidget {
  const AddPublisherScreen({super.key});

  @override
  State<AddPublisherScreen> createState() => _AddPublisherScreenState();
}

class _AddPublisherScreenState extends State<AddPublisherScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isLoading = false;

  Future<void> addPublisher() async {
    if (nameController.text.isEmpty || addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin!")),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("$apiBaseUrl/publishers"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "publisherName": nameController.text,
          "address": addressController.text,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        throw Exception("Lỗi: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm Nhà Xuất Bản")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Tên Nhà Xuất Bản"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Địa Chỉ"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : addPublisher,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Thêm"),
            ),
          ],
        ),
      ),
    );
  }
}
