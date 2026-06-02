import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// [UseCase] là lớp cơ sở cho tất cả các use case trong hệ thống.
/// [Type] là kiểu dữ liệu trả về khi thành công.
/// [Params] là các tham số cần thiết để thực hiện use case.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Sử dụng [NoParams] khi use case không cần tham số đầu vào.
class NoParams {}
