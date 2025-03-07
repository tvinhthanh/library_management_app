import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_library/core/api/constants.dart';

class EditAuthorScreen extends StatefulWidget {
  final int authorId;
  const EditAuthorScreen({super.key, required this.authorId});

  @override
  State<EditAuthorScreen> createState() => _EditAuthorScreenState();
}

class _EditAuthorScreenState extends State<EditAuthorScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  bool isLoading = true;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    fetchAuthorDetails();
  }

  Future<void> fetchAuthorDetails() async {
    try {
      final response = await http.get(Uri.parse("$apiBaseUrl/author/${widget.authorId}"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          nameController.text = data["name"] ?? "";
          bioController.text = data["bio"] ?? "";
          isLoading = false;
        });
      } else {
        throw Exception("Lỗi khi tải dữ liệu: ${response.statusCode}");
      }
    } catch (e) {
      _showMessage("Lỗi khi tải dữ liệu: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> updateAuthor() async {
    if (nameController.text.isEmpty) {
      _showMessage("Tên tác giả không được để trống!");
      return;
    }

    setState(() => isUpdating = true);

    try {
      final response = await http.put(
        Uri.parse("$apiBaseUrl/author/${widget.authorId}"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": nameController.text,
          "bio": bioController.text,
        }),
      );

      if (response.statusCode == 200) {
        _showMessage("Cập nhật thành công!", success: true);
        Navigator.pop(context, true);
      } else {
        throw Exception("Lỗi API: ${response.statusCode}");
      }
    } catch (e) {
      _showMessage("Lỗi khi cập nhật: $e");
    } finally {
      setState(() => isUpdating = false);
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
      appBar: AppBar(title: const Text("Chỉnh Sửa Tác Giả")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTextField(nameController, "Tên tác giả"),
                  const SizedBox(height: 10),
                  _buildTextField(bioController, "Tiểu sử", maxLines: 3),
                  const SizedBox(height: 20),
                  isUpdating
                      ? const CircularProgressIndicator()
                      : _buildButton("Lưu Thay Đổi", Colors.green, updateAuthor),
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
