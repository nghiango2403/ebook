import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/chapter_repository.dart';

class UpdateReadingHistoryUseCase {
  final ChapterRepository repository;

  UpdateReadingHistoryUseCase(this.repository);

  Future<Either<Failure, void>> call(
    String bookId,
    String chapterId,
    String userId,
    DateTime lastReadAt,
  ) async {
    return await repository.updateReadingHistory(
      bookId,
      chapterId,
      userId,
      lastReadAt,
    );
  }
}
