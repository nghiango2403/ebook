import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/book_repository.dart';

class IsBookmarkedUsecase {
  final BookRepository repository;

  IsBookmarkedUsecase(this.repository);

  /// Trả về true nếu sách đã được bookmark, false nếu chưa.
  Future<Either<Failure, bool>> execute(String userId, String bookId) async {
    return await repository.isBookmarked(userId: userId, bookId: bookId);
  }
}