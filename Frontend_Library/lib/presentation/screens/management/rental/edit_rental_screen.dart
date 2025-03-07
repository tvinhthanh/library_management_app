import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:frontend_library/core/api/constants.dart';
import 'add_book_to_rental_screen.dart';

class EditRentalScreen extends StatefulWidget {
  final int borrowId;

  const EditRentalScreen({super.key, required this.borrowId});

  @override
  State<EditRentalScreen> createState() => _EditRentalScreenState();
}

class _EditRentalScreenState extends State<EditRentalScreen> {
  final TextEditingController memberNameController = TextEditingController();
  final TextEditingController borrowDateController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController returnDateController = TextEditingController();
  bool isLoading = true;
  List<dynamic> borrowedBooks = [];

  @override
  void initState() {
    super.initState();
    fetchBorrowDetails();
  }

  Future<void> fetchBorrowDetails() async {
    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/borrow/${widget.borrowId}"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        String memberName = await fetchMemberName(data["memberId"]);
        List<dynamic> books = data["books"] ?? [];

        List<Map<String, dynamic>> detailedBooks = [];
        for (var book in books) {
          int bookId = book["bookId"];
          String title = await fetchBookTitle(bookId);
          detailedBooks.add({
            "bookId": bookId,
            "title": title,
            "quantity": book["quantity"] ?? 1,
          });
        }

        setState(() {
          borrowedBooks = detailedBooks;
          memberNameController.text = memberName;
          borrowDateController.text = data["borrowDate"] ?? "";
          dueDateController.text = data["dueDate"] ?? "";
          returnDateController.text = data["returnDate"] ?? "";
        });
      } else {
        showError("Không thể tải thông tin phiếu thuê!");
      }
    } catch (e) {
      showError("Lỗi tải dữ liệu: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<String> fetchMemberName(int memberId) async {
    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/user/member/$memberId"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data["name"] ?? "Không xác định";
      }
      return "Không xác định";
    } catch (e) {
      return "Không xác định";
    }
  }

  Future<String> fetchBookTitle(int bookId) async {
    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/book/$bookId"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data["title"] ?? "Không có tiêu đề";
      }
      return "Không có tiêu đề";
    } catch (e) {
      return "Không có tiêu đề";
    }
  }

  Future<void> _selectReturnDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        returnDateController.text = DateFormat("yyyy-MM-dd").format(pickedDate);
      });
    }
  }

  Future<void> updateRental() async {
    try {
      final response = await http.put(
        Uri.parse("$apiBaseUrl/borrow/${widget.borrowId}/return?returnDate=${returnDateController.text}"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        showSuccess("Trả sách thành công!");
        Navigator.pop(context, true);
      } else {
        showError("Trả sách thất bại!");
      }
    } catch (e) {
      showError("Lỗi: $e");
    }
  }

  Future<void> removeBookFromRental(int bookId) async {
    try {
      final url = "$apiBaseUrl/borrow/${widget.borrowId}/remove-book/${bookId}";
      print("Calling API: $url");

      final response = await http.delete(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        showSuccess("Xóa sách khỏi phiếu mượn thành công!");
        await fetchBorrowDetails(); // Load lại danh sách
      } else {
        showError("Lỗi xóa sách: ${response.body}");
      }
    } catch (e) {
      showError("Lỗi kết nối API: $e");
    }
  }



  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chỉnh Sửa Phiếu Thuê")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: memberNameController,
                      decoration: const InputDecoration(labelText: "Tên thành viên"),
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: borrowDateController,
                      decoration: const InputDecoration(labelText: "Ngày mượn"),
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dueDateController,
                      decoration: const InputDecoration(labelText: "Hạn trả"),
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: returnDateController,
                      decoration: InputDecoration(
                        labelText: "Ngày trả",
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectReturnDate(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Danh sách sách đã mượn:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    borrowedBooks.isEmpty
                        ? const Center(child: Text("Chưa có sách nào trong phiếu mượn."))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: borrowedBooks.length,
                            itemBuilder: (context, index) {
                              final book = borrowedBooks[index];
                              return ListTile(
                                title: Text(book["title"] ?? "Không có tên"),
                                subtitle: Text("Số lượng: ${book["quantity"]}"),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => removeBookFromRental(book["bookId"]),
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 20),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text("Thêm sách"),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddBookToRentalScreen(borrowId: widget.borrowId),
                              ),
                            );
                            if (result == true) {
                              fetchBorrowDetails(); 
                            }
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.assignment_return),
                          label: const Text("Trả sách"),
                          onPressed: () {
                            _selectReturnDate(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: updateRental,
                          child: const Text("Cập nhật"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                          child: const Text("Hủy"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}