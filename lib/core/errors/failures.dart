import 'package:equatable/equatable.dart';

/// Định nghĩa các lớp lỗi (Failures) tại tầng Domain.
///
/// Trong kiến trúc Clean Architecture, [Failure] đại diện cho các lỗi nghiệp vụ
/// đã được xử lý và chuyển đổi từ tầng Data để hiển thị lên UI.
///
/// Việc sử dụng [Equatable] giúp so sánh các đối tượng lỗi dựa trên nội dung
/// [message] thay vì địa chỉ ô nhớ, hỗ trợ tốt cho việc quản lý State (Riverpod/Bloc).
abstract class Failure extends Equatable {
  /// Thông báo lỗi thân thiện với người dùng cuối.
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Lỗi xảy ra khi có sự cố từ phía máy chủ hoặc Firebase API.
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Lỗi kết nối từ máy chủ']) : super(message);
}

/// Lỗi xảy ra khi thiết bị mất kết nối Internet hoặc yêu cầu bị quá hạn (Timeout).
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Không có kết nối Internet']) : super(message);
}

/// Lỗi xảy ra khi không thể đọc hoặc ghi dữ liệu vào bộ nhớ cục bộ (Local Storage).
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Lỗi truy xuất dữ liệu cục bộ']) : super(message);
}

/// Lỗi đặc thù cho các tính năng xác thực như: sai mật khẩu, email đã tồn tại,
/// hoặc tài khoản bị khóa.
class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

/// Lỗi dùng cho các trường hợp ngoại lệ chưa được phân loại cụ thể.
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'Đã xảy ra lỗi không xác định']) : super(message);
}