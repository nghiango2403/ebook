import 'package:dartz/dartz.dart';
import 'package:ebook/features/book/domain/repositories/book_repository.dart';

import '../../../../core/errors/failures.dart';

class HiddenBookUseCase {
  final BookRepository repository;

  HiddenBookUseCase(this.repository);

  /// Hàm thực thi ẩn sách
  Future<Either<Failure, bool>> call(String bookId) async {
    return await repository.hiddenBook(bookId);
  }
}
