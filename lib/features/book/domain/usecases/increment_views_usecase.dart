import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/book_repository.dart';

class IncrementViewsUseCase {
  final BookRepository repository;

  IncrementViewsUseCase(this.repository);

  /// Thực thi tăng số lượt xem cho một cuốn sách cụ thể
  /// Hàm này sẽ kích hoạt tăng đồng thời viewsDay, viewsWeek và viewsTotal ở tầng Data
  Future<Either<Failure, void>> call(String bookId) async {
    return await repository.incrementViews(bookId);
  }
}