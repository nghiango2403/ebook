import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/book_entity.dart';
import '../repositories/book_repository.dart';

class GetBookByIdUseCase {
  final BookRepository repository;

  GetBookByIdUseCase(this.repository);

  /// Hàm thực thi lấy chi tiết sách theo ID
  Future<Either<Failure, BookEntity>> call(String bookId) async {
    return await repository.getBookById(bookId);
  }
}