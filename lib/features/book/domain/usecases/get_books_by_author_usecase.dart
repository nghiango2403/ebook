import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/book_entity.dart';
import '../repositories/book_repository.dart';

/// Class bọc các tham số cần thiết cho Usecase
class GetBooksByAuthorParams {
  final String authorId;
  final String excludedBookId;

  GetBooksByAuthorParams({
    required this.authorId,
    required this.excludedBookId,
  });
}

class GetBooksByAuthorUseCase {
  final BookRepository repository;

  GetBooksByAuthorUseCase(this.repository);

  /// Lấy danh sách truyện cùng tác giả (loại trừ cuốn đang xem)
  Future<Either<Failure, List<BookEntity>>> call(GetBooksByAuthorParams params) async {
    return await repository.getBooksByAuthor(
      authorId: params.authorId,
      excludedBookId: params.excludedBookId,
    );
  }
}