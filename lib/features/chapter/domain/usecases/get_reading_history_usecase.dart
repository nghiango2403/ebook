import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/reading_history_entity.dart';
import '../repositories/chapter_repository.dart';

class GetReadingHistoryUseCase {
  final ChapterRepository repository;

  GetReadingHistoryUseCase(this.repository);

  Future<Either<Failure, ReadingHistoryEntity>> call(
    String bookId,
    String userId,
  ) async {
    return await repository.getReadingHistory(bookId, userId);
  }
}
