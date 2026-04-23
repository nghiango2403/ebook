import 'package:dartz/dartz.dart';
import 'package:ebook/features/book/domain/repositories/book_repository.dart';

import '../../../../core/errors/failures.dart';
import '../entities/book_status.dart';

class UpdateBookStatusUseCase {
  final BookRepository repository;

  UpdateBookStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call(String bookId, BookStatus status) async {
    return await repository.updateBookStatus(bookId, status);
  }
}
