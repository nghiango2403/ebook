import 'package:equatable/equatable.dart';

/// Lớp trừu tượng định nghĩa các lỗi (Failure) trả về cho tầng Domain/UI.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Lỗi xảy ra từ phía Server hoặc API.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Lỗi xảy ra khi không có kết nối Internet.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Lỗi xảy ra liên quan đến Cache/Local Storage.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Lỗi xảy ra trong quá trình xác thực (Authentication).
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
