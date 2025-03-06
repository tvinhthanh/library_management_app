import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_library/core/constants.dart';

class EditPublisherScreen extends StatefulWidget {
  final int publisherId;
  const EditPublisherScreen({super.key, required this.publisherId});

  @override
  State<EditPublisherScreen> createState() => _EditPublisherScreenState();
}

class _EditPublisherScreenState extends State<EditPublisherScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    fetchPublisher();
  }

  Future<void> fetchPublisher() async {
    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/publisher/${widget.publisherId}"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          nameController.text = data["publisherName"];
          addressController.text = data["address"];
          isLoading = false;
        });
      } else {
        throw Exception("Lỗi tải dữ liệu");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> updatePublisher() async {
    if (nameController.text.isEmpty || addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin!")),
      );
      return;
    }

    setState(() => isSaving = true);
    try {
      final response = await http.put(
        Uri.parse("$apiBaseUrl/publisher/${widget.publisherId}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "publisherName": nameController.text,
          "address": addressController.text,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        throw Exception("Lỗi: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chỉnh sửa Nhà Xuất Bản")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                    onPressed: isSaving ? null : updatePublisher,
                    child: isSaving
                        ? const CircularProgressIndicator()
                        : const Text("Lưu"),
                  ),
                ],
              ),
            ),
    );
  }
}
