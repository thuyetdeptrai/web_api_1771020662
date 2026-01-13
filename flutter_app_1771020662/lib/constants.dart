
// 1. Import thư viện này
import 'package:flutter/foundation.dart';

class ApiConstants {
  // ⚠️ QUAN TRỌNG:
  // Nếu chạy trên Web: Dùng 'http://localhost:3000/api'
  // Nếu chạy trên Android Emulator: Dùng 'http://10.0.2.2:3000/api'

  // Vì bạn đang test trên Web (như trong ảnh), hãy dùng dòng này:
  static const String baseUrl = 'http://localhost:3000/api';
}
