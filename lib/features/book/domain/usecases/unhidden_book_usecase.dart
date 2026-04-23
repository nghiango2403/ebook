import 'package:dartz/dartz.dart';
import 'package:ebook/features/book/domain/repositories/book_repository.dart';

import '../../../../core/errors/failures.dart';

class UnHiddenBookUseCase {
  final BookRepository repository;

  UnHiddenBookUseCase(this.repository);

  /// Hàm thực thi hiện sách đã ẩn
  Future<Either<Failure, bool>> call(String bookId) async {
    return await repository.unHiddenBook(bookId);
  }
}
