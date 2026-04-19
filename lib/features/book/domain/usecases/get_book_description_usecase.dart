import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/book_repository.dart';

class GetBookDescriptionUseCase {
  final BookRepository repository;

  GetBookDescriptionUseCase(this.repository);

  /// Hàm thực thi lấy mô tả chi tiết của sách
  /// Trả về [String] là nội dung mô tả hoặc [Failure] nếu có lỗi
  Future<Either<Failure, String>> call(String bookId) async {
    return await repository.getBookDescription(bookId);
  }
}