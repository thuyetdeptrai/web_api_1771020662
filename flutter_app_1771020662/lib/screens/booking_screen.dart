import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'order_food_screen.dart'; // Import màn hình gọi món

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _guests = 2;
  final _noteController = TextEditingController();
  bool _isLoading = false;

  // Chọn ngày
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // Chọn giờ
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // Gửi đơn đặt bàn
  Future<void> _submitBooking() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    // Gộp ngày và giờ thành format ISO (YYYY-MM-DDTHH:mm:ss)
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/reservations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "customer_id": userId,
          "reservation_date": dateTime.toIso8601String(),
          "number_of_guests": _guests,
          "special_requests": _noteController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newReservationId = data['id']; // Lấy ID đơn vừa tạo

        if (!mounted) return;

        // --- ĐOẠN QUAN TRỌNG: CHUYỂN HƯỚNG SANG GỌI MÓN ---
        // Thay vì chỉ báo thành công, ta hỏi khách có muốn gọi món luôn không
        showDialog(
          context: context,
          barrierDismissible: false, // Bắt buộc chọn
          builder: (ctx) => AlertDialog(
            title: const Text("🎉 Đặt bàn thành công!"),
            content: const Text("Bạn có muốn chọn món ăn ngay bây giờ không?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // Đóng dialog
                  Navigator.pop(context); // Quay về trang chủ
                },
                child: const Text("Để sau"),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx); // Đóng dialog
                  // Chuyển thẳng sang màn hình gọi món với ID vừa tạo
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          OrderFoodScreen(reservationId: newReservationId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
                icon: const Icon(Icons.restaurant_menu, color: Colors.white),
                label: const Text(
                  "GỌI MÓN NGAY",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
        // ----------------------------------------------------
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Lỗi đặt bàn")));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lỗi kết nối")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đặt Bàn")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon trang trí
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.table_restaurant_rounded,
                  size: 40,
                  color: Colors.deepOrange,
                ),
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              "Thông tin đặt chỗ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // Chọn Ngày
            Card(
              elevation: 0,
              color: Colors.grey[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Colors.deepOrange,
                  ),
                ),
                title: const Text(
                  "Ngày đến",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                subtitle: Text(
                  DateFormat('EEEE, dd/MM/yyyy', 'vi').format(_selectedDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 10),

            // Chọn Giờ
            Card(
              elevation: 0,
              color: Colors.grey[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.access_time, color: Colors.blue),
                ),
                title: const Text(
                  "Thời gian",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                subtitle: Text(
                  _selectedTime.format(context),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _pickTime,
              ),
            ),
            const SizedBox(height: 20),

            // Số lượng khách
            const Text(
              "Số lượng khách",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.people_outline, color: Colors.deepOrange),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() {
                          if (_guests > 1) _guests--;
                        }),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        "$_guests",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _guests++),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Ghi chú
            const Text(
              "Ghi chú thêm",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Ví dụ: Cần ghế trẻ em, dị ứng...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.edit_note),
              ),
            ),

            const SizedBox(height: 30),

            // Nút Đặt Bàn
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "XÁC NHẬN ĐẶT BÀN",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
