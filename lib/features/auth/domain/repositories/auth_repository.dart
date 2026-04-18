import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Hợp đồng quản lý các hành động xác thực và dữ liệu người dùng.
///
/// Lớp này định nghĩa các phương thức mà tầng Presentation có thể gọi,
/// nhưng việc thực thi cụ thể (bằng Firebase hay API) sẽ nằm ở tầng Data.
abstract class AuthRepository {

  /// Đăng nhập bằng Email và Mật khẩu.
  ///
  /// Trả về [UserEntity] nếu thành công, hoặc [Failure] nếu có lỗi.
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Đăng ký tài khoản mới.
  ///
  /// Mặc định khi đăng ký, [UserRole] sẽ là `reader` và [AccountLevel] là `normal`.
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String gender,
  });


  /// Đăng xuất khỏi hệ thống.
  Future<Either<Failure, void>> signOut();

  /// Lấy thông tin người dùng hiện tại đang đăng nhập.
  ///
  /// Hàm này sẽ kiểm tra Firebase Auth và truy vấn thêm Firestore để lấy
  /// đầy đủ [UserRole], [AccountLevel] và [Tokens].
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Lắng nghe sự thay đổi trạng thái xác thực (Stream).
  ///
  /// Giúp App tự động chuyển hướng khi người dùng Login/Logout.
  Stream<UserEntity?> get onAuthStateChanged;

  /// Cập nhật số dư Token sau khi người dùng nạp tiền hoặc chi tiêu.
  ///
  /// [newTokens] là số dư mới sau khi đã tính toán.
  Future<Either<Failure, void>> updateTokens({
    required String uid,
    required int newTokens,
  });
}