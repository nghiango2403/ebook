import 'package:dartz/dartz.dart';
import 'package:ebook/features/chapter/domain/repositories/chapter_repository.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chapter_entity.dart';

class GetListBooksChaptersUseCase {
  final ChapterRepository repository;

  GetListBooksChaptersUseCase(this.repository);

  /// Lấy danh sách tất cả các chương của một cuốn sách
  /// Dữ liệu thường được sắp xếp theo số thứ tự chương (orderIndex) từ Repository
  Future<Either<Failure, List<ChapterEntity>>> call(String bookId) async {
    return await repository.getListChapter(bookId);
  }
}