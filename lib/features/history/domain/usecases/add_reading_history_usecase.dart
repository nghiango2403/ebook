import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/reading_history_repository.dart';

class AddReadingHistoryUseCase {
  final ReadingHistoryRepository _readingChapterRepository;

  AddReadingHistoryUseCase(this._readingChapterRepository);

  /// Thêm lịch sử đọc
  Future<Either<Failure, void>> call(
    String bookId,
    String chapterId,
    String userId,
    String chapterTitle,
    int orderIndex,
    DateTime lastReadAt,
  ) async {
    return await _readingChapterRepository.addReadingHistory(
      bookId,
      chapterId,
      userId,
      chapterTitle,
      orderIndex,
      lastReadAt,
    );
  }
}
