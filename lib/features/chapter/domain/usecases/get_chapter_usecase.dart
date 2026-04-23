import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/chapter_repository.dart';

class GetChapterUseCase {
  final ChapterRepository repository;

  GetChapterUseCase(this.repository);

  /// Lấy nội dung chương
  Future<Either<Failure, void>> call(
    String bookId,
    String chapterId,
    String userId,
  ) async {
    return await repository.getChapter(bookId, chapterId, userId);
  }
}
