import 'package:dartz/dartz.dart';
import 'package:ebook/features/chapter/domain/repositories/chapter_repository.dart';

import '../../../../core/errors/failures.dart';

class DeleteChapterUseCase {
  final ChapterRepository repository;

  DeleteChapterUseCase(this.repository);

  /// Xóa chương
  Future<Either<Failure, void>> call(String bookId, String chapterId) async {
    return await repository.deleteChapter(bookId, chapterId);
  }
}
