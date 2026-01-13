import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'order_food_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}/customers/$userId/reservations?t=${DateTime.now().millisecondsSinceEpoch}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _reservations = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

 Future<void> _payBooking(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận thanh toán"),
        content: const Text(
          "Bạn muốn thanh toán hóa đơn này?\n(Hệ thống sẽ tự động trừ điểm tích lũy nếu có)",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Chưa"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text("Thanh toán luôn"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.post(
          Uri.parse('${ApiConstants.baseUrl}/reservations/$id/pay'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "payment_method": "cash",
            "use_loyalty_points": true, // <--- Gửi true để Server trừ điểm
          }),
        );

        if (response.statusCode == 200) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Thanh toán thành công!"),
              backgroundColor: Colors.green,
            ),
          );
          _fetchHistory();
        } else {
          // In lỗi ra để dễ debug
          print(response.body);
          throw Exception("Lỗi server");
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lỗi kết nối"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Future<void> _cancelBooking(int id, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận hủy"),
        content: const Text("Bạn muốn hủy đơn này?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Không"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hủy", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.delete(
          Uri.parse('${ApiConstants.baseUrl}/reservations/$id'),
        );
        if (response.statusCode == 200) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Đã hủy thành công"),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _reservations[index]['status'] = 'cancelled';
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lỗi kết nối"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      appBar: AppBar(title: const Text("Lịch Sử & Món Đã Gọi")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reservations.length,
              itemBuilder: (context, index) {
                final item = _reservations[index];
                final status = item['status'] ?? 'pending';

                final List<dynamic> foodItems = item['items'] ?? [];

                // Tính tổng tiền (Fix lỗi 0đ)
                double totalMoney =
                    double.tryParse(item['total'].toString()) ?? 0;
                if (totalMoney == 0 && foodItems.isNotEmpty) {
                  double subtotal = 0;
                  for (var food in foodItems) {
                    double price =
                        double.tryParse(food['price_at_time'].toString()) ?? 0;
                    int qty = int.tryParse(food['quantity'].toString()) ?? 1;
                    subtotal += price * qty;
                  }
                  totalMoney = subtotal + (subtotal * 0.1);
                }

                // Màu sắc trạng thái
                Color color = Colors.orange;
                String statusText = "ĐANG CHỜ";
                if (status == 'confirmed') {
                  color = Colors.blue;
                  statusText = "ĐANG ĂN";
                }
                if (status == 'completed') {
                  color = Colors.green;
                  statusText = "ĐÃ THANH TOÁN";
                }
                if (status == 'cancelled') {
                  color = Colors.red;
                  statusText = "ĐÃ HỦY";
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Mã: ${item['reservation_number']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),

                        Text(
                          "📅 Thời gian: ${_formatDate(item['reservation_date'])}",
                        ),
                        Text("👥 Số khách: ${item['number_of_guests']}"),
                        if (item['table_number'] != null)
                          Text(
                            "🪑 Bàn: ${item['table_number']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),

                        const SizedBox(height: 10),
                        const Text(
                          "🍽️ Món đã gọi:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        if (foodItems.isEmpty)
                          const Text(
                            "   (Chưa gọi món nào)",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          )
                        else
                          ...foodItems.map((food) {
                            double price =
                                double.tryParse(
                                  food['price_at_time'].toString(),
                                ) ??
                                0;
                            int qty =
                                int.tryParse(food['quantity'].toString()) ?? 1;
                            return Padding(
                              padding: const EdgeInsets.only(left: 10, top: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text("• ${food['name']} (x$qty)"),
                                  ),
                                  Text(currencyFormat.format(price * qty)),
                                ],
                              ),
                            );
                          }),

                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              "Tổng cộng: ",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              currencyFormat.format(totalMoney),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // --- CÁC NÚT BẤM (QUAN TRỌNG) ---
                        if (status == 'pending')
                          // Nếu đang chờ: Chỉ hiện nút Hủy
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _cancelBooking(item['id'], index),
                              icon: const Icon(Icons.close, color: Colors.red),
                              label: const Text(
                                "Hủy đặt bàn",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),

                        if (status == 'confirmed')
                          // Nếu đã có bàn: Hiện Gọi món & Thanh toán
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OrderFoodScreen(
                                          reservationId: item['id'],
                                        ),
                                      ),
                                    );
                                    _fetchHistory();
                                  },
                                  icon: const Icon(
                                    Icons.restaurant_menu,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Gọi thêm",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _payBooking(item['id']),
                                  icon: const Icon(
                                    Icons.payment,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Thanh toán",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      return DateFormat('HH:mm - dd/MM/yyyy').format(DateTime.parse(dateStr));
    } catch (e) {
      return dateStr;
    }
  }
}
