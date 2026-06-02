import 'package:flutter/material.dart';

/// [Summary]: Quản lý cấu hình giao diện (Theme) cho ứng dụng Ebook.
/// Thiết lập các bảng màu, kiểu chữ và thành phần UI phù hợp với trải nghiệm đọc sách.
class AppTheme {
  // Có thể thay đổi font chữ chính tại đây (ví dụ: 'Merriweather' hoặc 'Roboto')
  static const String? _fontFamily = null;

  /// [Summary]: Xây dựng cấu hình TextTheme chung, tối ưu hóa cho việc đọc nội dung dài.
  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontWeight: FontWeight.bold),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.25,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 18,
        height: 1.6, // Tăng khoảng cách dòng để dễ đọc hơn
        letterSpacing: 0.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 16,
        height: 1.5,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    );
  }

  /// [Summary]: Theme sáng (Light Mode). Sử dụng tông màu trắng ngà để tránh chói mắt.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.brown,
        brightness: Brightness.light,
        surface: const Color(0xFFFDFCFB), // Màu nền trắng ngà nhẹ
      ),
      textTheme: _buildTextTheme(Typography.blackMountainView),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// [Summary]: Theme tối (Dark Mode). Sử dụng xám đậm thay vì đen để giảm tương phản gắt.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.brown,
        brightness: Brightness.dark,
        surface: const Color(0xFF1A1A1A), // Nền xám đậm dễ chịu ban đêm
      ),
      textTheme: _buildTextTheme(Typography.whiteMountainView),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// [Summary]: Theme Sepia (Chế độ đọc bảo vệ mắt). Mô phỏng màu giấy cũ.
  static ThemeData get sepiaTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF704214),
        brightness: Brightness.light,
        primary: const Color(0xFF704214),
        surface: const Color(0xFFF4ECD8), // Màu vàng kem/sepia
        onSurface: const Color(0xFF5B4636), // Chữ màu nâu đậm
      ),
      textTheme: _buildTextTheme(Typography.blackMountainView).apply(
        bodyColor: const Color(0xFF5B4636),
        displayColor: const Color(0xFF5B4636),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFE6DAC3),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Color(0xFF5B4636),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: const Color(0xFFE6DAC3), // Màu card phù hợp với nền Sepia
      ),
    );
  }
}
