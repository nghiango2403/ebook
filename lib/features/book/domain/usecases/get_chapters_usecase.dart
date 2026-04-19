import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chapter_entity.dart';
import '../repositories/book_repository.dart';

class GetChaptersUseCase {
  final BookRepository repository;

  GetChaptersUseCase(this.repository);

  /// Lấy danh sách tất cả các chương của một cuốn sách
  /// Dữ liệu thường được sắp xếp theo số thứ tự chương (orderIndex) từ Repository
  Future<Either<Failure, List<ChapterEntity>>> call(String bookId) async {
    return await repository.getChapters(bookId);
  }
}