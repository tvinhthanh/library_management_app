import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_library/core/api/constants.dart';

class AddAuthorScreen extends StatefulWidget {
  const AddAuthorScreen({super.key});

  @override
  State<AddAuthorScreen> createState() => _AddAuthorScreenState();
}

class _AddAuthorScreenState extends State<AddAuthorScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  bool isLoading = false;

  Future<void> addAuthor() async {
    if (nameController.text.isEmpty) {
      _showMessage("Tên tác giả không được để trống!");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$apiBaseUrl/author"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": nameController.text,
          "bio": bioController.text,
        }),
      );

      if (response.statusCode == 201) {
        _showMessage("Thêm tác giả thành công!", success: true);
        Navigator.pop(context, true);
      } else {
        throw Exception("Lỗi API: ${response.statusCode}");
      }
    } catch (e) {
      _showMessage("Lỗi khi thêm tác giả: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm Tác Giả")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(nameController, "Tên tác giả"),
            const SizedBox(height: 10),
            _buildTextField(bioController, "Tiểu sử (không bắt buộc)", maxLines: 3),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : _buildButton("Thêm Tác Giả", Colors.blue, addAuthor),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildButton(String title, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.all(16)),
        onPressed: onPressed,
        child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
