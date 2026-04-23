import 'package:dartz/dartz.dart';
import 'package:ebook/features/chapter/domain/repositories/chapter_repository.dart';

import '../../../../core/errors/failures.dart';

class AddChapterUseCase {
  final ChapterRepository repository;

  AddChapterUseCase(this.repository);

  /// Thêm chương mới
  Future<Either<Failure, void>> call(
    String bookId,
    String title,
    String content,
  ) async {
    return await repository.addChapter(bookId, title, content);
  }
}
