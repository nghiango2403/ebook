import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/book_entity.dart';
import '../repositories/book_repository.dart';

/// Tham số để lấy danh sách sách đã đánh dấu, hỗ trợ phân trang
class GetBookmarkedBooksParams {
  final String userId;
  final int pageSize;
  final int offset;

  GetBookmarkedBooksParams({
    required this.userId,
    this.pageSize = 20, // Mặc định lấy 20 cuốn mỗi lần
    this.offset = 0,
  });
}

class GetBookmarkedBooksUseCase {
  final BookRepository repository;

  GetBookmarkedBooksUseCase(this.repository);

  /// Lấy danh sách sách mà người dùng đã nhấn Bookmark
  Future<Either<Failure, List<BookEntity>>> call(GetBookmarkedBooksParams params) async {
    return await repository.getBookmarkedBooks(
      userId: params.userId,
      pageSize: params.pageSize,
      offset: params.offset,
    );
  }
}