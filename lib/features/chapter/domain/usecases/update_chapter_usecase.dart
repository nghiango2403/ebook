import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/chapter_repository.dart';

class UpdateChapterUseCase {
  final ChapterRepository repository;

  UpdateChapterUseCase(this.repository);

  /// Sửa chương
  Future<Either<Failure, void>> call(
    String bookId,
    String chapterId,
    String title,
    String content,
  ) async {
    return await repository.updateChapter(bookId, chapterId, title, content);
  }
}
