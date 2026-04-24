import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/reading_history_repository.dart';

class DeleteReadingHistoryUseCase {
  final ReadingHistoryRepository repository;

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
