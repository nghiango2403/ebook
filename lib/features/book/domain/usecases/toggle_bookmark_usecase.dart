import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/book_repository.dart';

/// Class đóng gói tham số cho hành động Toggle Bookmark
class ToggleBookmarkParams {
  final String bookId;
  final String userId;
  final DateTime createdAt;

  ToggleBookmarkParams({
    required this.bookId,
    required this.userId,
    required this.createdAt
  });
}

class ToggleBookmarkUseCase {
  final BookRepository repository;

  ToggleBookmarkUseCase(this.repository);

  /// Thực hiện thêm hoặc xóa sách khỏi danh sách yêu thích của người dùng
  Future<Either<Failure, void>> call(ToggleBookmarkParams params) async {
    return await repository.toggleBookmark(
      params.bookId,
      params.userId,
      params.createdAt,
    );
  }
}