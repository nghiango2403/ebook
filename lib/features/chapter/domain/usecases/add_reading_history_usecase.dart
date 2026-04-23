import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/chapter_repository.dart';

class AddReadingHistoryUseCase {
  final ChapterRepository _chapterRepository;

  AddReadingHistoryUseCase(this._chapterRepository);

  /// Thêm lịch sử đọc
  Future<Either<Failure, void>> call(
    String bookId,
    String chapterId,
    String userId,
    DateTime lastReadAt,
  ) async {
    return await _chapterRepository.addReadingHistory(
      bookId,
      chapterId,
      userId,
      lastReadAt,
    );
  }
}
