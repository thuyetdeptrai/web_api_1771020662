import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MenuDetailScreen extends StatelessWidget {
  final dynamic item;

  const MenuDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // Format tiền tệ
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    // Ép kiểu an toàn
    double price = double.tryParse(item['price'].toString()) ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      // Stack giúp ảnh tràn lên trên cùng
      body: Stack(
        children: [
          // 1. ẢNH MÓN ĂN (HEADER)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350,
            child:
                item['image_url'] != null &&
                    item['image_url'].toString().isNotEmpty
                ? Image.network(
                    item['image_url'],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.fastfood,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Container(
                    color: Colors.orange[100],
                    child: const Icon(
                      Icons.fastfood,
                      size: 80,
                      color: Colors.orange,
                    ),
                  ),
          ),

          // 2. NÚT BACK (Về menu)
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 3. THÔNG TIN CHI TIẾT (Kéo lên đè lên ảnh)
          Positioned.fill(
            top: 300,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thanh trang trí
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tên món
                    Text(
                      item['name'],
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Giá tiền & Thời gian
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currencyFormat.format(price),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${item['preparation_time'] ?? 15} phút",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Mô tả
                    const Text(
                      "Mô tả món ăn",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['description'] ??
                          "Món ăn ngon, đậm đà hương vị truyền thống.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Danh mục & Đặc điểm
                    Row(
                      children: [
                        _buildTag(item['category'] ?? "Khác", Colors.orange),
                        if (item['is_spicy'] == 1) ...[
                          const SizedBox(width: 8),
                          _buildTag("Cay nóng", Colors.red),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
