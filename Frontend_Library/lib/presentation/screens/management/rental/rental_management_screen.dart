import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_library/core/constants.dart';
import 'package:frontend_library/presentation/screens/management/rental/add_rental_screen.dart';
import 'package:frontend_library/presentation/screens/management/rental/edit_rental_screen.dart';

class BorrowingManagementScreen extends StatefulWidget {
  const BorrowingManagementScreen({super.key});

  @override
  State<BorrowingManagementScreen> createState() => _BorrowingManagementScreenState();
}

class _BorrowingManagementScreenState extends State<BorrowingManagementScreen> {
  List borrowings = [];
  List filteredBorrowings = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBorrowings();
    searchController.addListener(() {
      filterBorrowings();
    });
  }

  Future<void> fetchBorrowings() async {
    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/borrow"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        for (var borrowing in data) {
          int memberId = borrowing["memberId"];
          borrowing["memberName"] = await fetchMemberName(memberId);
        }

        setState(() {
          borrowings = data;
          filteredBorrowings = data;
          isLoading = false;
        });
      } else {
        throw Exception("Lỗi API: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải dữ liệu: $e")),
      );
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
        if (data is Map<String, dynamic> && data.containsKey("name")) {
          return data["name"];
        }
      }
      return "Không xác định";
    } catch (e) {
      return "Không xác định";
    }
  }

  void filterBorrowings() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredBorrowings = borrowings.where((borrowing) {
        String memberName = borrowing["memberName"]?.toLowerCase() ?? "";
        return memberName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Phiếu Thuê"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Tìm kiếm phiếu thuê...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredBorrowings.isEmpty
                      ? const Center(child: Text("Không có phiếu thuê nào!"))
                      : ListView.builder(
                          itemCount: filteredBorrowings.length,
                          itemBuilder: (context, index) {
                            final borrowing = filteredBorrowings[index];
                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Mã phiếu: ${borrowing["borrowingId"]}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      )),
                                    Text("Người thuê: ${borrowing["memberName"] ?? "Không xác định"}"),
                                    Text("Ngày thuê: ${borrowing["borrowDate"]}"),
                                    Text("Hạn trả: ${borrowing["dueDate"]}"),
                                    Text("Ngày trả: ${borrowing["returnDate"] ?? "Chưa trả"}",
                                      style: TextStyle(
                                        color: borrowing["returnDate"] == null
                                            ? Colors.red
                                            : Colors.green,
                                      )),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRentalScreen()),
          ).then((_) => fetchBorrowings());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
