/// Exception xảy ra khi có lỗi từ Server hoặc Firebase.
class ServerException implements Exception {
  final String? message;
  ServerException([this.message]);
}

/// Exception xảy ra khi có lỗi liên quan đến lưu trữ dữ liệu cục bộ (Cache).
class CacheException implements Exception {}

/// Exception xảy ra khi người dùng nhập sai thông tin xác thực hoặc lỗi từ FirebaseAuth.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

/// Exception xảy ra khi không có kết nối mạng.
class NetworkException implements Exception {}
