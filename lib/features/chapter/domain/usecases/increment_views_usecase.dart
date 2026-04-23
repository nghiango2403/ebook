import 'package:dartz/dartz.dart';
import 'package:ebook/features/chapter/domain/repositories/chapter_repository.dart';
import '../../../../core/errors/failures.dart';

class IncrementViewsUseCase {
  final ChapterRepository repository;

  IncrementViewsUseCase(this.repository);

  /// Thực thi tăng số lượt xem cho một cuốn sách cụ thể
  /// Hàm này sẽ kích hoạt tăng đồng thời viewsDay, viewsWeek và viewsTotal ở tầng Data
  Future<Either<Failure, void>> call(String bookId) async {
    return await repository.incrementViews(bookId);
  }
}