/// Định nghĩa các ngoại lệ (Exceptions) xảy ra tại tầng Data.
///
/// Các lớp này được sử dụng để `throw` khi các nguồn dữ liệu bên ngoài
/// (Remote API, Firebase, Local Database) gặp sự cố kỹ thuật.
/// Sau đó, các Exception này sẽ được bắt tại tầng Repository và chuyển đổi
/// thành các đối tượng `Failure` để trả về cho tầng UI.
abstract class AppException implements Exception {
  final String? message;
  AppException([this.message]);
}

/// Ngoại lệ ném ra khi có lỗi phản hồi từ Server hoặc Firebase SDK.
class ServerException extends AppException {
  ServerException([super.message]);
}

/// Ngoại lệ ném ra khi thiết bị không có kết nối Internet hoặc timeout.
class NetworkException extends AppException {
  NetworkException([super.message = "Không có kết nối mạng"]);
}

/// Ngoại lệ ném ra khi gặp sự cố truy cập bộ nhớ cục bộ (Shared Preferences, Isar, SQLite).
class CacheException extends AppException {
  CacheException([super.message]);
}

/// Ngoại lệ đặc thù cho các tác vụ xác thực (Sai mật khẩu, Email đã tồn tại, v.v.).
class AuthException extends AppException {
  AuthException(String message) : super(message);
}

/// Ngoại lệ dùng cho các lỗi không xác định hoặc lỗi logic hệ thống.
class UnknownException extends AppException {
  UnknownException([super.message = "Đã xảy ra lỗi không xác định"]);
}