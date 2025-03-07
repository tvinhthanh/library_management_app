import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_library/core/api/constants.dart';

class AddRentalScreen extends StatefulWidget {
  const AddRentalScreen({super.key});

  @override
  State<AddRentalScreen> createState() => _AddRentalScreenState();
}

class _AddRentalScreenState extends State<AddRentalScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController dueDateController = TextEditingController();
  
  List<Map<String, dynamic>> members = [];
  int? selectedMemberId;

  @override
  void initState() {
    super.initState();
    fetchAllMembers();
  }

  Future<void> fetchAllMembers() async {
    final response = await http.get(Uri.parse("$apiBaseUrl/user/member/all"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        members = List<Map<String, dynamic>>.from(data["members"]);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi khi tải danh sách thành viên")),
      );
    }
  }

  Future<void> addBorrowing() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn người mượn")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse("$apiBaseUrl/borrow"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "memberId": selectedMemberId,
        "borrowDate": DateTime.now().toIso8601String(),
        "dueDate": dueDateController.text,
        "returnDate": null,
        "staffId": 0,
      }),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${response.body}")),
      );
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dueDateController.text = picked.toIso8601String();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm phiếu thuê")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                value: selectedMemberId,
                decoration: const InputDecoration(labelText: "Người mượn"),
                items: members.map((member) {
                  return DropdownMenuItem<int>(
                    value: member["memberId"],
                    child: Text(member["name"]),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMemberId = value;
                  });
                },
                validator: (value) => value == null ? "Chọn người mượn" : null,
              ),
              TextFormField(
                controller: dueDateController,
                decoration: InputDecoration(
                  labelText: "Hạn trả",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDueDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) => value!.isEmpty ? "Nhập hạn trả" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: addBorrowing,
                child: const Text("Thêm"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}