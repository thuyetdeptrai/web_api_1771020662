import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../constants.dart';

class OrderFoodScreen extends StatefulWidget {
  final int reservationId; // ID đơn đặt bàn cần thêm món

  const OrderFoodScreen({super.key, required this.reservationId});

  @override
  State<OrderFoodScreen> createState() => _OrderFoodScreenState();
}

class _OrderFoodScreenState extends State<OrderFoodScreen> {
  List<dynamic> _menuItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/menu-items'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _menuItems = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addItemToOrder(int menuItemId, String itemName) async {
    final quantityController = TextEditingController(text: "1");
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Thêm: $itemName"),
        content: TextField(
          controller: quantityController,
          decoration: const InputDecoration(labelText: "Số lượng"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text("Thêm"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.post(
          Uri.parse(
            '${ApiConstants.baseUrl}/reservations/${widget.reservationId}/items',
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "menu_item_id": menuItemId,
            "quantity": int.tryParse(quantityController.text) ?? 1,
          }),
        );

        if (response.statusCode == 200) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Đã thêm $itemName vào đơn!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Lỗi kết nối!")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return Scaffold(
      appBar: AppBar(title: const Text("Gọi Món Thêm")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                double price = double.tryParse(item['price'].toString()) ?? 0;
                return Card(
                  child: ListTile(
                    leading: Image.network(
                      item['image_url'] ?? "",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.fastfood),
                    ),
                    title: Text(
                      item['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(currencyFormat.format(price)),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.deepOrange,
                        size: 30,
                      ),
                      onPressed: () =>
                          _addItemToOrder(item['id'], item['name']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
