/// Quản lý toàn bộ đường dẫn tài nguyên (Assets) của ứng dụng.
///
/// Lớp này tập trung tất cả các hằng số liên quan đến hình ảnh, biểu tượng
/// và các tệp tĩnh khác để tránh việc ghi đè chuỗi (Hardcoding) trong UI.
///
/// **Lưu ý:** Tất cả tài nguyên khai báo ở đây phải được đăng ký trong
/// file `pubspec.yaml` tại mục `assets:`.
class AppAssets {
  // Thư mục gốc
  static const String _imagePath = "assets/images";
  static const String _iconPath = "assets/icons";

  // --- Images ---

  /// Logo chính thức của ứng dụng, sử dụng tại màn hình Splash và Login.
  static const String logo = "$_imagePath/logo.png";

  /// Hình ảnh mặc định hiển thị khi bìa sách chưa kịp tải hoặc bị lỗi.
  static const String placeholder = "$_imagePath/book_placeholder.jpg";

  // --- Icons ---

  /// Biểu tượng Google chuẩn, sử dụng cho nút "Đăng nhập bằng Google".
  static const String googleIcon = "$_iconPath/ic_google.svg";

  /// Biểu tượng đại diện cho người đọc hoặc tính năng liên quan đến đọc truyện.
  static const String readerIcon = "$_iconPath/ic_reader.svg";
}