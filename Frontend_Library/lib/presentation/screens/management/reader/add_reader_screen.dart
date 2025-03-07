import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_library/core/api/constants.dart';
import 'package:intl/intl.dart';

class AddReaderScreen extends StatefulWidget {
  const AddReaderScreen({super.key});

  @override
  State<AddReaderScreen> createState() => _AddReaderScreenState();
}

class _AddReaderScreenState extends State<AddReaderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  /// Chọn ngày từ Date Picker
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  /// Gửi dữ liệu lên API
  Future<void> _addReader() async {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> requestBody = {
        "name": nameController.text,
        "dateOfBirth": dobController.text.isNotEmpty ? dobController.text : null,
        "address": addressController.text,
        "phone": phoneController.text,
        "email": emailController.text,
    };

    print("Dữ liệu gửi lên API: ${jsonEncode(requestBody)}");

    try {
      final response = await http.post(
        Uri.parse("$apiBaseUrl/user/member"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("Response: ${response.body}");

      if (response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi thêm độc giả: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi kết nối API: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm Độc Giả")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Tên độc giả"),
                validator: (value) => value!.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: dobController,
                decoration: const InputDecoration(labelText: "Ngày sinh"),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Địa chỉ"),
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Số điện thoại"),
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addReader,
                child: const Text("Thêm"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
