import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Usecase xử lý việc đăng xuất và dọn dẹp phiên làm việc.
///
/// Đảm bảo trạng thái xác thực được xóa bỏ hoàn toàn trên cả
/// Firebase Auth và Local Storage (nếu có).
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  /// Kết thúc phiên làm việc hiện tại của người dùng.
  Future<Either<Failure, void>> call() async {
    return await repository.signOut();
  }
}