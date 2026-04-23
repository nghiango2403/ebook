import 'package:dartz/dartz.dart';
import 'package:ebook/features/chapter/domain/repositories/chapter_repository.dart';

import '../../../../core/errors/failures.dart';

class DeleteReadingHistoryUseCase {
  final ChapterRepository repository;

  DeleteReadingHistoryUseCase(this.repository);

  /// Xóa lịch sử đọc
  Future<Either<Failure, void>> call(
    String bookId,
    String chapterId,
    String userId,
  ) async {
    return await repository.deleteReadingHistory(bookId, chapterId, userId);
  }
}
