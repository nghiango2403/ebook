import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Usecase xử lý logic đăng nhập người dùng.
///
/// Nhận thông tin đăng nhập từ UI, thực hiện kiểm tra sơ bộ và gọi
/// [AuthRepository] để xác thực với hệ thống.
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// Thực thi đăng nhập bằng Email và Password.
  ///
  /// Trả về [UserEntity] chứa thông tin Role, Level và Tokens nếu thành công.
  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return const Left(AuthFailure("Email và mật khẩu không được để trống"));
    }
    return await repository.signInWithEmail(email: email, password: password);
  }
}