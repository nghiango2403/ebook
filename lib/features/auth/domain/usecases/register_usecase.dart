import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Usecase xử lý việc tạo tài khoản mới cho người dùng.
///
/// Ngoài việc tạo tài khoản, Usecase này đảm bảo các giá trị mặc định như
/// [UserRole.reader] và [AccountLevel.normal] được thiết lập chính xác.
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  /// Đăng ký tài khoản mới với các thông tin định danh cơ bản.
  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String username,
    required String gender,
  }) async {
    return await repository.signUpWithEmail(
      email: email,
      password: password,
      username: username,
      gender: gender,
    );
  }
}