import 'package:flutter/material.dart';

/// Quản lý hệ thống màu sắc (Color Palette) toàn diện cho ứng dụng.
///
/// Lớp này sử dụng các màu sắc chủ đạo theo phong cách Vibrant (rực rỡ)
/// nhưng vẫn đảm bảo các tiêu chuẩn về độ tương phản (Accessibility)
/// của Material Design 3.
///
/// Các nhóm màu bao gồm:
/// * **Brand Colors**: Nhận diện thương hiệu (Tím, Hồng, Cyan).
/// * **Status Colors**: Thông báo trạng thái (Thành công, Lỗi, Cảnh báo).
/// * **Neutral Colors**: Màu nền và màu chữ cho cả hai chế độ Light/Dark.
class AppColors {
  // --- Brand Colors (Hệ màu chủ đạo) ---

  /// Màu chính (Primary): Tím hiện đại, dùng cho các thành phần quan trọng nhất.
  static const Color primary = Color(0xFF6750A4);

  /// Màu phụ (Secondary): Hồng rực rỡ, tạo sự năng động cho UI.
  static const Color secondary = Color(0xFFE91E63);

  /// Màu nhấn (Tertiary): Xanh Cyan, dùng để phân tách các khu vực chức năng.
  static const Color tertiary = Color(0xFF00BCD4);

  // --- Status Colors (Màu trạng thái) ---

  /// Hiển thị khi thao tác thành công hoặc trạng thái tích cực.
  static const Color success = Color(0xFF4CAF50);

  /// Hiển thị lỗi hệ thống, thông báo quan trọng hoặc hành động nguy hiểm.
  static const Color error = Color(0xFFB00020);

  /// Cảnh báo người dùng về các vấn đề tiềm ẩn.
  static const Color warning = Color(0xFFFFC107);

  // --- Neutral Colors (Hệ màu trung tính) ---

  // Light Mode
  /// Nền chính cho chế độ sáng.
  static const Color backgroundLight = Color(0xFFF8F9FA);
  /// Màu chữ chính trên nền sáng.
  static const Color textPrimary = Color(0xFF212121);
  /// Màu chữ phụ (mờ hơn) trên nền sáng.
  static const Color textSecondary = Color(0xFF757575);

  // Dark Mode
  /// Nền chính cho chế độ tối.
  static const Color backgroundDark = Color(0xFF121212);
  /// Nền cho các thành phần nổi (Card, Dialog) trong chế độ tối.
  static const Color surfaceDark = Color(0xFF1E1E1E);
  /// Màu chữ chính trên nền tối.
  static const Color textWhite = Color(0xFFFFFFFF);
  /// Màu chữ phụ trên nền tối.
  static const Color textGrey = Color(0xFFB0B0B0);
}