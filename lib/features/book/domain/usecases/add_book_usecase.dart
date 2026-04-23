import 'package:dartz/dartz.dart';
import 'package:ebook/features/book/domain/repositories/book_repository.dart';

import '../../../../core/errors/failures.dart';

class AddBookUseCase {
  final BookRepository repository;

  AddBookUseCase(this.repository);

  /// Hàm thực thi thêm sách
  Future<Either<Failure, bool>> call(String bookId) async {
    return await repository.addBook(bookId);
  }
}
