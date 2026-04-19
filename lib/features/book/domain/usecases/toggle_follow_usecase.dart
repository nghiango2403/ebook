import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/book_repository.dart';

/// Tham số cần thiết để thực hiện hành động Theo dõi
class ToggleFollowParams {
  final String bookId;
  final String userId;

  ToggleFollowParams({
    required this.bookId,
    required this.userId,
  });
}

class ToggleFollowUseCase {
  final BookRepository repository;

  ToggleFollowUseCase(this.repository);

  /// Thực hiện theo dõi hoặc hủy theo dõi một bộ truyện
  Future<Either<Failure, void>> call(ToggleFollowParams params) async {
    return await repository.toggleFollow(
      params.bookId,
      params.userId,
    );
  }
}