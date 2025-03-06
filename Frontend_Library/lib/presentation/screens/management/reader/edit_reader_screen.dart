import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_library/core/constants.dart';
import 'package:intl/intl.dart';

class EditReaderScreen extends StatefulWidget {
  final int readerId;
  const EditReaderScreen({super.key, required this.readerId});

  @override
  State<EditReaderScreen> createState() => _EditReaderScreenState();
}

class _EditReaderScreenState extends State<EditReaderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReaderDetails();
  }

  /// Hàm lấy thông tin độc giả từ API
  Future<void> _fetchReaderDetails() async {
    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/user/member/${widget.readerId}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          nameController.text = data['name'] ?? "";
          dobController.text = data['dateOfBirth'] ?? ""; // Nếu null thì giữ rỗng
          addressController.text = data['address'] ?? "";
          phoneController.text = data['phone'] ?? "";
          emailController.text = data['email'] ?? "";
          isLoading = false;
        });
      } else {
        _showError("Không tìm thấy độc giả!");
      }
    } catch (e) {
      _showError("Lỗi khi tải dữ liệu độc giả!");
    }
  }

  /// Hàm cập nhật độc giả
  Future<void> _updateReader() async {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> requestData = {
      "name": nameController.text,
      "dateOfBirth": dobController.text.isNotEmpty ? dobController.text : null,
      "address": addressController.text,
      "phone": phoneController.text,
      "email": emailController.text,
    };

    try {
      final response = await http.put(
        Uri.parse("$apiBaseUrl/user/member/${widget.readerId}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        _showError("Lỗi khi cập nhật độc giả!");
      }
    } catch (e) {
      _showError("Lỗi kết nối đến máy chủ!");
    }
  }

  /// Hiển thị thông báo lỗi
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Hiển thị DatePicker để chọn ngày sinh
  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chỉnh sửa Độc Giả")),
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
                      decoration: const InputDecoration(labelText: "Tên độc giả"),
                      validator: (value) => value!.isEmpty ? "Không được để trống" : null,
                    ),
                    TextFormField(
                      controller: dobController,
                      decoration: const InputDecoration(
                        labelText: "Ngày sinh",
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: _selectDate,
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
                      validator: (value) => value!.isEmpty ? "Không được để trống" : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateReader,
                      child: const Text("Lưu"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
