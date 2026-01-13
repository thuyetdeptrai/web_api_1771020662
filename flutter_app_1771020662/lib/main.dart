import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Để chỉnh màu thanh trạng thái (Status Bar)
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart'; // Hỗ trợ tiếng Việt
import 'screens/login_screen.dart';

void main() {
  // Đảm bảo Flutter Binding đã khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Làm cho thanh trạng thái (Status Bar) trong suốt để app đẹp hơn
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Trong suốt
      statusBarIconBrightness: Brightness.dark, // Icon màu đen
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Foodie App - 1771020662',

      // --- 1. CẤU HÌNH NGÔN NGỮ (TIẾNG VIỆT) ---
      // Phần này giúp DatePicker hiển thị "Thứ 2, Tháng 1..."
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'), // Tiếng Việt
      ],

      // --- 2. THEME CHUNG CHO TOÀN APP ---
      theme: ThemeData(
        useMaterial3: true, // Sử dụng Material Design 3 mới nhất
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange, // Màu chủ đạo là Cam đậm
          primary: Colors.deepOrange,
          secondary: Colors.orangeAccent,
          background: Colors.grey[50],
        ),
        scaffoldBackgroundColor: Colors.grey[50], // Màu nền mặc định xám nhạt
        // Cấu hình Font chữ mặc định (nếu muốn)
        fontFamily: 'Roboto',

        // Style chung cho App Bar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, // Màu chữ/icon đen
          elevation: 0, // Không đổ bóng
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),

        // Style chung cho Input (Ô nhập liệu)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.grey),
        ),

        // Style chung cho Button (Nút bấm)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),
      ),

      // Màn hình đầu tiên khi mở App
      home: const LoginScreen(),
    );
  }
}
