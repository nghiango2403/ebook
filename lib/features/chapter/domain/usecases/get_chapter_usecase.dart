import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/chapter_entity.dart';
import '../repositories/chapter_repository.dart';

class GetChapterUseCase {
  final ChapterRepository repository;

  GetChapterUseCase(this.repository);

  /// Lấy nội dung chương
  Future<Either<Failure, ChapterEntity>> call(
    String bookId,
    String chapterId,
    String userId,
  ) async {
    return await repository.getChapter(bookId, chapterId, userId);
  }
}
