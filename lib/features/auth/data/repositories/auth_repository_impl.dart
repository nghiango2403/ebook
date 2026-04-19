import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Triển khai thực tế của [AuthRepository].
///
/// Lớp này kết hợp giữa [NetworkInfo] để kiểm tra mạng và [AuthRemoteDataSource]
/// để tương tác với Firebase. Kết quả trả về luôn là kiểu [Either] để đảm bảo
/// tầng Domain không bao giờ gặp Exception bất ngờ.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _executeWithNetworkCheck<UserEntity>(() async {
      return await remoteDataSource.signInWithEmail(email, password);
    });
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String gender,
  }) async {
    return await _executeWithNetworkCheck<UserEntity>(() async {
      return await remoteDataSource.signUpWithEmail(
        email: email,
        password: password,
        username: username,
        gender: gender,
      );
    });
  }
  

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    return await _executeWithNetworkCheck<UserEntity>(() async {
      final user = await remoteDataSource.getCurrentUserData();
      if (user == null) throw AuthException("Người dùng chưa đăng nhập");
      return user;
    });
  }

  // Chú ý: Stream này không cần xử lý Either vì nó là dòng dữ liệu trạng thái
  @override
  Stream<UserEntity?> get onAuthStateChanged {
    // Trong thực tế, bạn sẽ map Stream từ Firebase Auth sang UserEntity ở đây
    throw UnimplementedError("Sẽ triển khai khi kết nối hoàn thiện Provider");
  }

  @override
  Future<Either<Failure, void>> updateTokens({
    required String uid,
    required int newTokens,
  }) async {
    // Logic cập nhật token sẽ được gọi ở đây
    return const Right(null);
  }

  // --- Hàm bổ trợ giúp Code ngắn gọn (Helper) ---

  /// Hàm generic để bao bọc các tác vụ gọi data với kiểm tra mạng và bắt lỗi.
  Future<Either<Failure, T>> _executeWithNetworkCheck<T>(
      Future<T> Function() action,
      ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await action();
        return Right(result);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message ?? "Lỗi khi xác thực tài khoản"));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? "Lỗi máy chủ không xác định"));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: "Vui lòng kiểm tra kết nối Internet của bạn"));
    }
  }
}