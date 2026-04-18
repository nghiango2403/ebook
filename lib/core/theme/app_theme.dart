import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 1. Định nghĩa bảng màu rực rỡ (Vibrant Color Scheme)
  static const _primaryColor = Color(0xFF6750A4);
  static const _secondaryColor = Color(0xFFE91E63);
  static const _accentColor = Color(0xFF00BCD4);

  // 2. Cấu hình Theme Sáng (Light Mode)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        primary: _primaryColor,
        secondary: _secondaryColor,
        tertiary: _accentColor,
        brightness: Brightness.light,
      ),
      // Cấu hình font chữ chuyên cho đọc truyện (chống mỏi mắt)
      textTheme: GoogleFonts.notoSansTextTheme().copyWith(
        displayLarge: GoogleFonts.philosopher(
          fontWeight: FontWeight.bold,
          color: _primaryColor,
        ),
        bodyLarge: const TextStyle(fontSize: 18, height: 1.6),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        // Bạn có thể thêm màu nền mặc định cho Card tại đây nếu muốn rực rỡ hơn
        surfaceTintColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // 3. Cấu hình Theme Tối (Dark Mode) - Rất quan trọng cho App đọc sách
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.dark,
        primary: const Color(0xFFD0BCFF), // Tím nhạt cho Dark mode
        surface: const Color(0xFF1C1B1F), // Nền tối sâu
      ),
      textTheme: GoogleFonts.notoSansTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: const TextStyle(fontSize: 18, height: 1.6, color: Color(0xFFE6E1E5)),
      ),
    );
  }
}